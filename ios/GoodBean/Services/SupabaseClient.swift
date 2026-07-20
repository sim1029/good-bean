import Foundation
import Supabase

/// Central access point for the Supabase backend.
final class SupabaseService: Sendable {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://wstoovvsmmurdmatkvkq.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzdG9vdnZzbW11cmRtYXRrdmtxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ0OTY4MDMsImV4cCI6MjEwMDA3MjgwM30.uJM2PbLH6Ygf1PK9c5165qfUA-Uf2Syii1T4Id3Txdk"
        )
    }

    // MARK: - Generic Query Helpers

    func fetchAll<T: Decodable & Sendable>(from table: String) async throws -> [T] {
        try await client.from(table).select().execute().value
    }

    func fetchById<T: Decodable & Sendable>(from table: String, id: UUID) async throws -> T {
        try await client.from(table).select().eq("id", value: id).single().execute().value
    }

    func insert<T: Encodable & Sendable>(into table: String, value: T) async throws {
        try await client.from(table).insert(value).execute()
    }

    func insertAll<T: Encodable & Sendable>(into table: String, values: [T]) async throws {
        try await client.from(table).insert(values).execute()
    }

    // MARK: - Beans (user inventory, always joined with beans_catalog)

    func getBeans() async throws -> [Bean] {
        try await client.from("beans").select("*, beans_catalog(*)").execute().value
    }

    func getBean(id: UUID) async throws -> Bean {
        try await client.from("beans")
            .select("*, beans_catalog(*)")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    /// Updates the lifecycle status and remaining inventory of a user's bean.
    /// RLS ("Users can update own beans") gates this to the owner.
    func updateBeanStatus(id: UUID, status: BeanStatus, remainingGrams: Double?) async throws {
        struct BeanStatusUpdate: Encodable, Sendable {
            let status: String
            let remaining_grams: Double?
        }
        try await client.from("beans")
            .update(BeanStatusUpdate(status: status.rawValue, remaining_grams: remainingGrams))
            .eq("id", value: id)
            .execute()
    }

    // MARK: - Profiles

    func getProfiles() async throws -> [Profile] {
        try await fetchAll(from: "profiles")
    }

    func getProfile(id: UUID) async throws -> Profile {
        try await fetchById(from: "profiles", id: id)
    }

    // MARK: - Machines (user inventory, always joined with machines_catalog)

    func getMachine(id: UUID) async throws -> Machine {
        try await client.from("machines")
            .select("*, machines_catalog(*)")
            .eq("id", value: id)
            .single()
            .execute().value
    }

    // MARK: - Catalog Search
    // Returns catalog entries with the user's inventory row embedded (RLS-filtered).
    // isOwned == true when the user already has this catalog item in their inventory.

    func searchBeanCatalog(query: String) async throws -> [BeanCatalogSearchResult] {
        var req = client.from("beans_catalog")
            .select("*, beans(id, status)")
        if !query.isEmpty {
            req = req.or("name.ilike.%\(query)%,roaster.ilike.%\(query)%")
        }
        return try await req.order("name").limit(50).execute().value
    }

    func searchMachineCatalog(query: String) async throws -> [MachineCatalogSearchResult] {
        var req = client.from("machines_catalog")
            .select("*, machines(id)")
        if !query.isEmpty {
            req = req.or("brand.ilike.%\(query)%,model.ilike.%\(query)%")
        }
        return try await req.order("brand").limit(50).execute().value
    }

    // MARK: - User Inventory Management

    /// Adds a catalog bean to the user's inventory and returns the new inventory UUID.
    func addBeanToInventory(catalogId: UUID, userId: UUID) async throws -> UUID {
        struct NewBean: Encodable, Sendable {
            let created_by: UUID
            let catalog_id: UUID
            let status: String
            let is_public: Bool
        }
        struct Inserted: Decodable, Sendable { let id: UUID }
        let rows: [Inserted] = try await client.from("beans")
            .insert(NewBean(created_by: userId, catalog_id: catalogId, status: BeanStatus.active.rawValue, is_public: false))
            .select("id")
            .execute().value
        guard let row = rows.first else { throw SupabaseError.insertFailed }
        return row.id
    }

    /// Adds a catalog machine to the user's inventory and returns the new inventory UUID.
    func addMachineToInventory(catalogId: UUID, userId: UUID) async throws -> UUID {
        struct NewMachine: Encodable, Sendable {
            let created_by: UUID
            let catalog_id: UUID
            let is_public: Bool
        }
        struct Inserted: Decodable, Sendable { let id: UUID }
        let rows: [Inserted] = try await client.from("machines")
            .insert(NewMachine(created_by: userId, catalog_id: catalogId, is_public: false))
            .select("id")
            .execute().value
        guard let row = rows.first else { throw SupabaseError.insertFailed }
        return row.id
    }

    // MARK: - Profile Active-Item Setters

    func setActiveBean(userId: UUID, beanId: UUID) async throws {
        struct Patch: Encodable { let active_bean_id: UUID }
        try await client.from("profiles").update(Patch(active_bean_id: beanId))
            .eq("id", value: userId).execute()
    }

    func setActiveMachine(userId: UUID, machineId: UUID) async throws {
        struct Patch: Encodable { let active_machine_id: UUID }
        try await client.from("profiles").update(Patch(active_machine_id: machineId))
            .eq("id", value: userId).execute()
    }

    // MARK: - Catalog Requests

    func submitCatalogRequest(_ request: CatalogRequest) async throws {
        try await insert(into: "catalog_requests", value: request)
    }

    // MARK: - Shot Pulls

    func getShotPulls(for userId: UUID) async throws -> [ShotPull] {
        try await client.from("shot_pulls").select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute().value
    }

    // MARK: - Feed

    func getFeedShots() async throws -> [FeedShotPull] {
        try await client.from("shot_pulls")
            .select("*,shot_likes(user_id),shot_comments(id),beans(id,beans_catalog(name,roaster)),profiles(username,avatar_url)")
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .limit(50)
            .execute().value
    }

    func getFeedBeans() async throws -> [FeedBean] {
        try await client.from("beans")
            .select("*,beans_catalog(name,roaster,roast_level),bean_likes(user_id),bean_comments(id),profiles!created_by(username,avatar_url)")
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .limit(50)
            .execute().value
    }

    func getFeedMachines() async throws -> [FeedMachine] {
        try await client.from("machines")
            .select("*,machines_catalog(brand,model),machine_likes(user_id),machine_comments(id),profiles!created_by(username,avatar_url)")
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .limit(50)
            .execute().value
    }
}

// MARK: - Errors

enum SupabaseError: Error {
    case insertFailed
}
