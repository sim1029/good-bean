import Foundation

struct Bean: Codable, Identifiable {
    let id: UUID
    let createdBy: UUID
    let roaster: String
    let name: String
    let roastLevel: String
    let roastDate: Date?
    let isPublic: Bool
    let notes: String?
    let createdAt: Date

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

    init(
        id: UUID = UUID(),
        createdBy: UUID,
        roaster: String,
        name: String,
        roastLevel: String,
        roastDate: Date? = nil,
        isPublic: Bool = false,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.createdBy = createdBy
        self.roaster = roaster
        self.name = name
        self.roastLevel = roastLevel
        self.roastDate = roastDate
        self.isPublic = isPublic
        self.notes = notes
        self.createdAt = createdAt
    }
}
