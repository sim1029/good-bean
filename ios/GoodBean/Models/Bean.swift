import Foundation

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
    }
}
