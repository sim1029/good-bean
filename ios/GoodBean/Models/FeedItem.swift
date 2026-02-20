import Foundation

// MARK: - Shared Embed Types

struct LikeEmbed: Codable, Sendable {
    let userId: UUID
    enum CodingKeys: String, CodingKey { case userId = "user_id" }
}

struct CommentEmbed: Codable, Sendable {
    let id: UUID
}

struct BeanEmbed: Codable, Sendable {
    let name: String
    let roaster: String
}

struct ProfileEmbed: Codable, Sendable {
    let username: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case username
        case avatarUrl = "avatar_url"
    }

    var initials: String {
        let parts = username.split(separator: "_").map(String.init)
        return parts.compactMap { $0.first }.prefix(2).map(String.init).joined().uppercased()
    }
}

// MARK: - Feed Shot Pull
// PostgREST select: "*,shot_likes(user_id),shot_comments(id),beans(name,roaster),profiles(username,avatar_url)"

struct FeedShotPull: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let doseGrams: Double
    let yieldGrams: Double
    let timeSeconds: Int
    let tempC: Int?
    let rating: Int?
    let isPublic: Bool
    let createdAt: String?
    let shotLikes: [LikeEmbed]
    let shotComments: [CommentEmbed]
    let bean: BeanEmbed?
    let profile: ProfileEmbed?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case doseGrams = "dose_grams"
        case yieldGrams = "yield_grams"
        case timeSeconds = "time_seconds"
        case tempC = "temp_c"
        case rating
        case isPublic = "is_public"
        case createdAt = "created_at"
        case shotLikes = "shot_likes"
        case shotComments = "shot_comments"
        case bean = "beans"
        case profile = "profiles"
    }

    var likeCount: Int { shotLikes.count }
    var commentCount: Int { shotComments.count }
    var ratio: Double { yieldGrams / doseGrams }

    func hasLiked(userId: UUID?) -> Bool {
        guard let userId else { return false }
        return shotLikes.contains { $0.userId == userId }
    }
}

// MARK: - Feed Bean
// PostgREST select: "*,bean_likes(user_id),bean_comments(id),profiles(username,avatar_url)"

struct FeedBean: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let roaster: String
    let name: String
    let roastLevel: String?
    let roastDate: String?
    let notes: String?
    let isPublic: Bool
    let createdAt: String?
    let beanLikes: [LikeEmbed]
    let beanComments: [CommentEmbed]
    let profile: ProfileEmbed?

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy = "created_by"
        case roaster
        case name
        case roastLevel = "roast_level"
        case roastDate = "roast_date"
        case notes
        case isPublic = "is_public"
        case createdAt = "created_at"
        case beanLikes = "bean_likes"
        case beanComments = "bean_comments"
        case profile = "profiles"
    }

    var likeCount: Int { beanLikes.count }
    var commentCount: Int { beanComments.count }

    func hasLiked(userId: UUID?) -> Bool {
        guard let userId else { return false }
        return beanLikes.contains { $0.userId == userId }
    }
}

// MARK: - Feed Machine
// PostgREST select: "*,machine_likes(user_id),machine_comments(id),profiles(username,avatar_url)"

struct FeedMachine: Codable, Identifiable, Sendable {
    let id: UUID
    let createdBy: UUID?
    let brand: String
    let model: String
    let notes: String?
    let isPublic: Bool
    let createdAt: String?
    let machineLikes: [LikeEmbed]
    let machineComments: [CommentEmbed]
    let profile: ProfileEmbed?

    enum CodingKeys: String, CodingKey {
        case id
        case createdBy = "created_by"
        case brand
        case model
        case notes
        case isPublic = "is_public"
        case createdAt = "created_at"
        case machineLikes = "machine_likes"
        case machineComments = "machine_comments"
        case profile = "profiles"
    }

    var likeCount: Int { machineLikes.count }
    var commentCount: Int { machineComments.count }
    var displayName: String { "\(brand) \(model)" }

    func hasLiked(userId: UUID?) -> Bool {
        guard let userId else { return false }
        return machineLikes.contains { $0.userId == userId }
    }
}

// MARK: - Unified Feed Enum

enum FeedItem: Identifiable, Sendable {
    case shot(FeedShotPull)
    case bean(FeedBean)
    case machine(FeedMachine)

    var id: UUID {
        switch self {
        case .shot(let s): return s.id
        case .bean(let b): return b.id
        case .machine(let m): return m.id
        }
    }

    var createdAt: String? {
        switch self {
        case .shot(let s): return s.createdAt
        case .bean(let b): return b.createdAt
        case .machine(let m): return m.createdAt
        }
    }

    var sortDate: Date {
        guard let createdAt else { return .distantPast }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: createdAt) ?? .distantPast
    }
}
