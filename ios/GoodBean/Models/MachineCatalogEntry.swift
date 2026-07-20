import Foundation

// MARK: - MachineCatalogEntry
// Decoded from the machines_catalog table.
// Embedded inside Machine and MachineCatalogSearchResult via PostgREST joins.

struct MachineCatalogEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let brand: String
    let model: String
    let description: String?
    let imageUrl: String?
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id, brand, model
        case description
        case imageUrl   = "image_url"
        case isVerified = "is_verified"
    }

    var displayName: String { "\(brand) \(model)" }
}

// MARK: - MachineCatalogSearchResult
// Returned by searchMachineCatalog(query:).
// Includes the user's inventory row (if any) via a PostgREST embed on machines.catalog_id.

struct MachineCatalogSearchResult: Codable, Identifiable, Sendable {
    let id: UUID
    let brand: String
    let model: String
    let description: String?
    let imageUrl: String?
    let isVerified: Bool
    // RLS-filtered: contains the current user's inventory row if they own this machine, else []
    let machines: [InventoryMini]

    var isOwned: Bool       { !machines.isEmpty }
    var inventoryId: UUID?  { machines.first?.id }
    var displayName: String { "\(brand) \(model)" }

    struct InventoryMini: Codable, Sendable {
        let id: UUID
    }

    enum CodingKeys: String, CodingKey {
        case id, brand, model
        case description
        case imageUrl   = "image_url"
        case isVerified = "is_verified"
        case machines
    }
}
