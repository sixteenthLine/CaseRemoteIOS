import Foundation

struct InventorySyncResponse: Codable {
    let totalItems: Int
    let totalCases: Int
    let syncedAt: String

    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case totalCases = "total_cases"
        case syncedAt = "synced_at"
    }
}

struct InventoryCasesResponse: Codable {
    let cases: [InventoryCase]
}

struct InventoryCase: Codable, Identifiable {
    let inventoryItemId: Int
    let externalAssetId: String
    let classId: String?
    let instanceId: String?
    let name: String
    let marketHashName: String?
    let iconURL: String?
    let quantity: Int
    let tradable: Bool
    let marketable: Bool
    let metadataJSON: String?
    let lastSyncedAt: String

    var id: Int { inventoryItemId }

    enum CodingKeys: String, CodingKey {
        case inventoryItemId = "inventory_item_id"
        case externalAssetId = "external_asset_id"
        case classId = "class_id"
        case instanceId = "instance_id"
        case name
        case marketHashName = "market_hash_name"
        case iconURL = "icon_url"
        case quantity
        case tradable
        case marketable
        case metadataJSON = "metadata_json"
        case lastSyncedAt = "last_synced_at"
    }
}
