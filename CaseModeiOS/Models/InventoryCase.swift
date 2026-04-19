import Foundation

struct InventoryCasesResponse: Codable {
    let cases: [InventoryCase]
}

struct InventoryCase: Codable, Identifiable {
    let id: Int
    let externalItemId: String?
    let name: String
    let quantity: Int
    let imageURL: String?
    let metadata: String?
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case externalItemId = "external_item_id"
        case name
        case quantity
        case imageURL = "image_url"
        case metadata
        case updatedAt = "updated_at"
    }
}
