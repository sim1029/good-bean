import Foundation

struct PressureStage: Codable, Sendable {
    let pressure: Double
    let seconds: Int
}

struct PressureProfile: Codable, Sendable {
    let stages: [PressureStage]
}

struct ShotPull: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let beanId: UUID?
    let doseGrams: Double
    let yieldGrams: Double
    let timeSeconds: Int
    let tempC: Int?
    let pressureProfile: PressureProfile?
    let rating: Int?
    let isPublic: Bool
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case beanId = "bean_id"
        case doseGrams = "dose_grams"
        case yieldGrams = "yield_grams"
        case timeSeconds = "time_seconds"
        case tempC = "temp_c"
        case pressureProfile = "pressure_profile"
        case rating
        case isPublic = "is_public"
        case createdAt = "created_at"
    }

    var ratio: Double { yieldGrams / doseGrams }

    var createdDate: Date? {
        guard let createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: createdAt)
    }
}
