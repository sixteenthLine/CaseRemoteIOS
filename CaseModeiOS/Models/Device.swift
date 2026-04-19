import Foundation

struct DevicesResponse: Codable {
    let devices: [Device]
}

struct Device: Codable, Identifiable {
    let id: Int
    let name: String
    let platform: String
    let status: String
    let lastSeenAt: String?
    let agentVersion: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case platform
        case status
        case lastSeenAt = "last_seen_at"
        case agentVersion = "agent_version"
    }
}
