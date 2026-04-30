import Foundation

struct OpeningSession: Codable, Identifiable {
    let id: Int
    let userId: Int
    let deviceId: Int
    let commandId: Int?
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
    let openingStreamURL: String?

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
        case commandId = "command_id"
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
        case openingStreamURL = "opening_stream_url"
        case resultItemId = "result_item_id"
        case resultFloat = "result_float"
        case resultPayload = "result_payload"
        case createdAt = "created_at"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        deviceId = try container.decode(Int.self, forKey: .deviceId)
        commandId = try container.decodeIfPresent(Int.self, forKey: .commandId)
        status = try container.decode(String.self, forKey: .status)
        selectedInventoryItemId = try container.decode(Int.self, forKey: .selectedInventoryItemId)
        selectedExternalAssetId = try container.decodeIfPresent(String.self, forKey: .selectedExternalAssetId)
        selectedCaseName = try container.decode(String.self, forKey: .selectedCaseName)
        selectedMarketHashName = try container.decodeIfPresent(String.self, forKey: .selectedMarketHashName)
        inventoryBeforePayload = try container.decodeFlexibleStringIfPresent(forKey: .inventoryBeforePayload)
        inventoryAfterPayload = try container.decodeFlexibleStringIfPresent(forKey: .inventoryAfterPayload)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        videoStatus = try container.decode(String.self, forKey: .videoStatus)
        videoRef = try container.decodeIfPresent(String.self, forKey: .videoRef)
        openingStreamURL = try container.decodeIfPresent(String.self, forKey: .openingStreamURL)
        resultItemId = try container.decodeIfPresent(String.self, forKey: .resultItemId)
        resultFloat = try container.decodeIfPresent(Double.self, forKey: .resultFloat)
        resultPayload = try container.decodeFlexibleStringIfPresent(forKey: .resultPayload)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        startedAt = try container.decodeIfPresent(String.self, forKey: .startedAt)
        finishedAt = try container.decodeIfPresent(String.self, forKey: .finishedAt)
    }
}

struct CreateOpeningSessionRequest: Codable {
    let deviceId: Int
    let selectedInventoryItemId: Int
    let openingStreamURL: String?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case selectedInventoryItemId = "selected_inventory_item_id"
        case openingStreamURL = "opening_stream_url"
    }
}

struct OpeningSessionsResponse: Codable {
    let sessions: [OpeningSession]
}

struct OpeningHistoryResponse: Codable {
    let openings: [OpeningHistoryItem]
}

struct OpeningHistoryItem: Codable, Identifiable {
    let id: Int
    let openingSessionId: Int
    let commandId: Int?
    let status: String
    let videoStatus: String?
    let selectedCaseName: String?
    let selectedMarketHashName: String?
    let resultAssetId: String?
    let resultMarketHashName: String?
    let resultName: String?
    let resultRarity: String?
    let resultExterior: String?
    let resultFloat: Double?
    let resultIconURL: String?
    let recordingURL: String?
    let openedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case openingSessionId = "opening_session_id"
        case commandId = "command_id"
        case status
        case videoStatus = "video_status"
        case selectedCaseName = "selected_case_name"
        case selectedMarketHashName = "selected_market_hash_name"
        case resultAssetId = "result_asset_id"
        case resultMarketHashName = "result_market_hash_name"
        case resultName = "result_name"
        case resultRarity = "result_rarity"
        case resultExterior = "result_exterior"
        case resultFloat = "result_float"
        case resultIconURL = "result_icon_url"
        case recordingURL = "recording_url"
        case openedAt = "opened_at"
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleStringIfPresent(forKey key: Key) throws -> String? {
        if let value = try decodeIfPresent(String.self, forKey: key) {
            return value
        }

        if let value = try decodeIfPresent(Double.self, forKey: key) {
            return String(value)
        }

        if let value = try decodeIfPresent(Int.self, forKey: key) {
            return String(value)
        }

        if let value = try decodeIfPresent(Bool.self, forKey: key) {
            return String(value)
        }

        if let value = try decodeIfPresent(JSONValue.self, forKey: key) {
            return value.prettyPrintedString
        }

        return nil
    }
}

private enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([String: JSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([JSONValue].self) {
            self = .array(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    var prettyPrintedString: String {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        case .object, .array:
            guard
                let data = try? JSONEncoder().encode(self),
                let object = try? JSONSerialization.jsonObject(with: data),
                let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
                let string = String(data: prettyData, encoding: .utf8)
            else {
                return ""
            }
            return string
        case .null:
            return ""
        }
    }
}
