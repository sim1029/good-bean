import Foundation

struct Profile: Codable, Identifiable, Sendable {
    let id: UUID
    let username: String
    let avatarUrl: String?
    let activeBeanId: UUID?
    let activeMachineId: UUID?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case activeBeanId = "active_bean_id"
        case activeMachineId = "active_machine_id"
        case createdAt = "created_at"
    }

    init(id: UUID = UUID(), username: String, avatarUrl: String? = nil, activeBeanId: UUID? = nil, activeMachineId: UUID? = nil, createdAt: String? = nil) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.activeBeanId = activeBeanId
        self.activeMachineId = activeMachineId
        self.createdAt = createdAt
    }

    var initials: String {
        let parts = username.split(separator: "_").map(String.init)
        return parts.compactMap { $0.first }.prefix(2).map(String.init).joined().uppercased()
    }

    var memberSince: String {
        guard let createdAt else { return "Member" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: createdAt)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: createdAt)
        }
        guard let date else { return "Member" }
        let display = DateFormatter()
        display.dateFormat = "MMM yyyy"
        return "Member since \(display.string(from: date))"
    }
}
