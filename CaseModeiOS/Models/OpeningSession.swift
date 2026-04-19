import Foundation

struct OpeningSession: Codable, Identifiable {
    let id: Int
    let userId: Int
    let deviceId: Int
    let status: String

    let selectedInventoryItemId: Int
    let selectedExternalAssetId: String?
    let selectedCaseName: String
    let selectedMarketHashName: String?

    let inventoryBeforePayload: String?
    let inventoryAfterPayload: String?

    let errorMessage: String?
    let videoStatus: String
    let videoRef: String?

    let resultItemId: String?
    let resultFloat: Double?
    let resultPayload: String?

    let createdAt: String
    let startedAt: String?
    let finishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceId = "device_id"
        case status
        case selectedInventoryItemId = "selected_inventory_item_id"
        case selectedExternalAssetId = "selected_external_asset_id"
        case selectedCaseName = "selected_case_name"
        case selectedMarketHashName = "selected_market_hash_name"
        case inventoryBeforePayload = "inventory_before_payload"
        case inventoryAfterPayload = "inventory_after_payload"
        case errorMessage = "error_message"
        case videoStatus = "video_status"
        case videoRef = "video_ref"
        case resultItemId = "result_item_id"
        case resultFloat = "result_float"
        case resultPayload = "result_payload"
        case createdAt = "created_at"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }
}

struct CreateOpeningSessionRequest: Codable {
    let deviceId: Int
    let selectedInventoryItemId: Int

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case selectedInventoryItemId = "selected_inventory_item_id"
    }
}

struct OpeningSessionsResponse: Codable {
    let sessions: [OpeningSession]
}
