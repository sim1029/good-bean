import Foundation

struct CatalogRequest: Encodable, Sendable {
    let submittedBy: UUID
    let itemType: String        // "bean" | "machine"
    let name: String
    let manufacturer: String
    let notes: String?
    let imageUrl: String?       // nil for v1 (photo upload is future scope)

    enum CodingKeys: String, CodingKey {
        case submittedBy  = "submitted_by"
        case itemType     = "item_type"
        case name, manufacturer, notes
        case imageUrl     = "image_url"
    }
}
