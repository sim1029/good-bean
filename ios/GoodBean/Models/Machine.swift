import Foundation

// User's personal machine inventory row.
// Catalog-level fields (brand, model) come via the machines_catalog join.
// Fetch with: machines.select("*, machines_catalog(*)")

struct Machine: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let catalogId: UUID?
    let catalog: MachineCatalogEntry?  // joined via machines_catalog FK
    let isPublic: Bool
    let notes: String?
    let createdAt: String?

    // Convenience accessors delegated to catalog
    var brand: String     { catalog?.brand ?? "Unknown"  }
    var model: String     { catalog?.model ?? "Machine"  }
    var imageUrl: String? { catalog?.imageUrl             }
    var displayName: String { "\(brand) \(model)" }

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy  = "created_by"
        case catalogId  = "catalog_id"
        case catalog    = "machines_catalog"
        case isPublic   = "is_public"
        case notes
        case createdAt  = "created_at"
    }
}
