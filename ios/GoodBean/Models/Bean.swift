import Foundation

/// Lifecycle status of a bean in a user's inventory.
/// Backed 1:1 by the `public.bean_status` Postgres ENUM.
enum BeanStatus: String, Codable, CaseIterable, Sendable {
    case active
    case frozen
    case defrosted
    case archived
    case depleted

    var displayName: String {
        switch self {
        case .active:    return "Active"
        case .frozen:    return "Frozen"
        case .defrosted: return "Defrosted"
        case .archived:  return "Archived"
        case .depleted:  return "Depleted"
        }
    }

    var emoji: String {
        switch self {
        case .active:    return "☕️"
        case .frozen:    return "🧊"
        case .defrosted: return "💧"
        case .archived:  return "📦"
        case .depleted:  return "🪫"
        }
    }

    /// SF Symbol used in menus and badges.
    var iconName: String {
        switch self {
        case .active:    return "checkmark.circle"
        case .frozen:    return "snowflake"
        case .defrosted: return "drop"
        case .archived:  return "archivebox"
        case .depleted:  return "battery.0"
        }
    }
}

// User's personal bean inventory row.
// Catalog-level fields (name, roaster, roast_level) come via the beans_catalog join.
// Fetch with: beans.select("*, beans_catalog(*)")

struct Bean: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let catalogId: UUID?
    let catalog: BeanCatalogEntry?  // joined via beans_catalog FK
    let roastDate: String?
    let status: BeanStatus
    let remainingGrams: Double?     // grams left in the user's bag; nil = unknown
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
        case roastDate      = "roast_date"
        case status
        case remainingGrams = "remaining_grams"
        case isPublic       = "is_public"
        case notes
        case createdAt  = "created_at"
    }
}
