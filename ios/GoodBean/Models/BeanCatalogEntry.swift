import Foundation

// MARK: - BeanCatalogEntry
// Decoded from the beans_catalog table.
// Embedded inside Bean and BeanCatalogSearchResult via PostgREST joins.

struct BeanCatalogEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let roaster: String
    let roastLevel: String?
    let description: String?
    let imageUrl: String?
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, roaster
        case roastLevel  = "roast_level"
        case description
        case imageUrl    = "image_url"
        case isVerified  = "is_verified"
    }
}

// MARK: - BeanCatalogSearchResult
// Returned by searchBeanCatalog(query:).
// Includes the user's inventory row (if any) via a PostgREST embed on beans.catalog_id.

struct BeanCatalogSearchResult: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let roaster: String
    let roastLevel: String?
    let description: String?
    let imageUrl: String?
    let isVerified: Bool
    // RLS-filtered: contains the current user's inventory row if they own this bean, else []
    let beans: [InventoryMini]

    var isOwned: Bool       { !beans.isEmpty }
    var inventoryId: UUID?  { beans.first?.id }

    struct InventoryMini: Codable, Sendable {
        let id: UUID
        let status: String
    }

    enum CodingKeys: String, CodingKey {
        case id, name, roaster
        case roastLevel  = "roast_level"
        case description
        case imageUrl    = "image_url"
        case isVerified  = "is_verified"
        case beans
    }
}
