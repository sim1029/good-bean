import Foundation

// User's personal bean inventory row.
// Catalog-level fields (name, roaster, roast_level) come via the beans_catalog join.
// Fetch with: beans.select("*, beans_catalog(*)")

struct Bean: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let catalogId: UUID?
    let catalog: BeanCatalogEntry?  // joined via beans_catalog FK
    let roastDate: String?
    let status: String              // active | frozen | defrosted | archived | depleted
    let isPublic: Bool
    let notes: String?
    let createdAt: String?

    // Convenience accessors delegated to catalog
    var name: String        { catalog?.name      ?? "Unknown Bean"    }
    var roaster: String     { catalog?.roaster   ?? "Unknown Roaster" }
    var roastLevel: String? { catalog?.roastLevel                      }
    var imageUrl: String?   { catalog?.imageUrl                        }

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy  = "created_by"
        case catalogId  = "catalog_id"
        case catalog    = "beans_catalog"
        case roastDate  = "roast_date"
        case status
        case isPublic   = "is_public"
        case notes
        case createdAt  = "created_at"
    }
}
