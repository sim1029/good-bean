import Foundation

struct ShotPull: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let beanId: UUID?
    let doseGrams: Double
    let yieldGrams: Double
    let timeSeconds: Int
    let tempC: Int?
    let pressureProfile: [String: AnyCodable]?
    let rating: Int?
    let isPublic: Bool
    let createdAt: Date

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
}

// Helper for JSON JSONB fields
enum AnyCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case dictionary([String: AnyCodable])
    case array([AnyCodable])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(dict)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .bool(let bool):
            try container.encode(bool)
        case .dictionary(let dict):
            try container.encode(dict)
        case .array(let array):
            try container.encode(array)
        }
    }
}
