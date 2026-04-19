import Foundation

struct Command: Codable, Identifiable {
    let id: Int
    let userId: Int
    let deviceId: Int
    let type: String
    let status: String
    let payload: String?
    let result: String?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceId = "device_id"
        case type
        case status
        case payload
        case result
        case errorMessage = "error_message"
    }
}

struct CreateCommandRequest: Codable {
    let type: String
    let payload: String?
}

struct DeviceCommandsResponse: Codable {
    let commands: [Command]
}
