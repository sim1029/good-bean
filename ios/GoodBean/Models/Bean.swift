import Foundation

enum BeanStatus: String, Codable, CaseIterable, Sendable {
    case active
    case frozen
    case pantry
    case depleted

    var displayName: String {
        switch self {
        case .active:   return "Active"
        case .frozen:   return "Frozen"
        case .pantry:   return "Pantry"
        case .depleted: return "Depleted"
        }
    }

    var emoji: String {
        switch self {
        case .active:   return "☕️"
        case .frozen:   return "🧊"
        case .pantry:   return "📦"
        case .depleted: return "🪫"
        }
    }
}

struct Bean: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let roaster: String
    let name: String
    let roastLevel: String?
    let roastDate: String?
    let isPublic: Bool
    let notes: String?
    let createdAt: String?
    let status: BeanStatus
    let remainingGrams: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy = "created_by"
        case roaster
        case name
        case roastLevel = "roast_level"
        case roastDate = "roast_date"
        case isPublic = "is_public"
        case notes
        case createdAt = "created_at"
        case status
        case remainingGrams = "remaining_grams"
    }
}
