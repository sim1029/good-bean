import Foundation

struct Machine: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let brand: String
    let model: String
    let notes: String?
    let isPublic: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy = "created_by"
        case brand
        case model
        case notes
        case isPublic = "is_public"
        case createdAt = "created_at"
    }

    var displayName: String { "\(brand) \(model)" }
}
