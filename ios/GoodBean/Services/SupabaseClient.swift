import Foundation
import Supabase

/// Central access point for the Supabase backend.
///
/// Usage:
/// - `SupabaseService.shared.client` for direct SDK access (filters, joins, realtime)
/// - Convenience methods like `getBeans()` for common queries
///
/// To add a new table:
/// 1. Create a `Codable` model in Models/ with `CodingKeys` for snake_case mapping
/// 2. Add a convenience method here that calls `fetchAll(from:)` or `fetchById(from:id:)`
final class SupabaseService: Sendable {
    static let shared = SupabaseService()

    /// The underlying supabase-swift client. Exposed for direct use
    /// when convenience methods are insufficient.
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://jbyqmxmftvqhhfuyddls.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpieXFteG1mdHZxaGhmdXlkZGxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyMTM4NDgsImV4cCI6MjA4Njc4OTg0OH0.pAYVpUNuZ5gBDVjoE1j1fNtozpMaTn7sA5GWFPn6uCg"
        )
    }

    // MARK: - Generic Query Helpers

    /// Fetch all rows from a table, decoded to the given type.
    func fetchAll<T: Decodable & Sendable>(from table: String) async throws -> [T] {
        try await client.from(table).select().execute().value
    }

    /// Fetch a single row by ID.
    func fetchById<T: Decodable & Sendable>(from table: String, id: UUID) async throws -> T {
        try await client.from(table).select().eq("id", value: id).single().execute().value
    }

    /// Insert a single row into a table.
    func insert<T: Encodable & Sendable>(into table: String, value: T) async throws {
        try await client.from(table).insert(value).execute()
    }

    /// Insert multiple rows into a table.
    func insertAll<T: Encodable & Sendable>(into table: String, values: [T]) async throws {
        try await client.from(table).insert(values).execute()
    }

    // MARK: - Beans

    func getBeans() async throws -> [Bean] {
        try await fetchAll(from: "beans")
    }

    func getBean(id: UUID) async throws -> Bean {
        try await fetchById(from: "beans", id: id)
    }

    func updateBeanStatus(id: UUID, status: BeanStatus, remainingGrams: Double?) async throws {
        struct BeanStatusUpdate: Encodable {
            let status: String
            let remaining_grams: Double?
        }
        let update = BeanStatusUpdate(status: status.rawValue, remaining_grams: remainingGrams)
        try await client.from("beans").update(update).eq("id", value: id).execute()
    }

    // MARK: - Profiles

    func getProfiles() async throws -> [Profile] {
        try await fetchAll(from: "profiles")
    }

    func getProfile(id: UUID) async throws -> Profile {
        try await fetchById(from: "profiles", id: id)
    }

    // MARK: - Machines

    func getMachine(id: UUID) async throws -> Machine {
        try await fetchById(from: "machines", id: id)
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
            .select("*,shot_likes(user_id),shot_comments(id),beans(name,roaster),profiles(username,avatar_url)")
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .limit(50)
            .execute().value
    }

    func getFeedBeans() async throws -> [FeedBean] {
        try await client.from("beans")
            .select("*,bean_likes(user_id),bean_comments(id),profiles!created_by(username,avatar_url)")
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .limit(50)
            .execute().value
    }

    func getFeedMachines() async throws -> [FeedMachine] {
        try await client.from("machines")
            .select("*,machine_likes(user_id),machine_comments(id),profiles!created_by(username,avatar_url)")
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .limit(50)
            .execute().value
    }
}
