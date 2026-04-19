import Foundation

struct OpeningSession: Codable, Identifiable {
    let id: Int
    let userId: Int
    let deviceId: Int
    let status: String
    let selectedCaseId: Int
    let selectedCaseName: String
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
        case selectedCaseId = "selected_case_id"
        case selectedCaseName = "selected_case_name"
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
    let selectedCaseId: Int
    let selectedCaseName: String?

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case selectedCaseId = "selected_case_id"
        case selectedCaseName = "selected_case_name"
    }
}

struct OpeningSessionsResponse: Codable {
    let sessions: [OpeningSession]
}
