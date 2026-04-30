import Foundation

final class ApiClient {
    static let shared = ApiClient()

    private init() {}

    static func absoluteURL(from pathOrURL: String?) -> URL? {
        guard let pathOrURL, !pathOrURL.isEmpty else { return nil }

        if let url = URL(string: pathOrURL), url.scheme != nil {
            return url
        }

        return URL(string: AppConfig.baseURL + pathOrURL)
    }

    private func makeURL(path: String) throws -> URL {
        guard let url = URL(string: AppConfig.baseURL + path) else {
            throw URLError(.badURL)
        }
        return url
    }

    private func request<T: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body? = nil,
        token: String? = nil,
        responseType: T.Type
    ) async throws -> T {
        let url = try makeURL(path: path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let serverText = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NSError(domain: "ApiError", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: serverText
            ])
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func register(email: String, password: String) async throws -> AuthResponse {
        try await request(
            path: "/auth/register",
            method: "POST",
            body: RegisterRequest(email: email, password: password),
            responseType: AuthResponse.self
        )
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        try await request(
            path: "/auth/login",
            method: "POST",
            body: LoginRequest(email: email, password: password),
            responseType: AuthResponse.self
        )
    }

    func getMe(token: String) async throws -> User {
        struct EmptyBody: Encodable {}
        return try await request(
            path: "/auth/me",
            method: "GET",
            body: Optional<EmptyBody>.none,
            token: token,
            responseType: User.self
        )
    }

    func getDevices(token: String) async throws -> DevicesResponse {
        struct EmptyBody: Encodable {}
        return try await request(
            path: "/devices",
            method: "GET",
            body: Optional<EmptyBody>.none,
            token: token,
            responseType: DevicesResponse.self
        )
    }
    
    func createCommand(deviceId: Int, type: String, token: String) async throws -> Command {
        try await request(
            path: "/devices/\(deviceId)/commands",
            method: "POST",
            body: CreateCommandRequest(type: type, payload: nil),
            token: token,
            responseType: Command.self
        )
    }

    func getCommand(commandId: Int, token: String) async throws -> Command {
        struct EmptyBody: Encodable {}
        return try await request(
            path: "/commands/\(commandId)",
            method: "GET",
            body: Optional<EmptyBody>.none,
            token: token,
            responseType: Command.self
        )
    }
    func syncInventory(token: String) async throws -> InventorySyncResponse {

        struct EmptyBody: Encodable {}

        return try await request(

            path: "/inventory/sync",

            method: "POST",

            body: Optional<EmptyBody>.some(EmptyBody()),

            token: token,

            responseType: InventorySyncResponse.self

        )

    }

    func syncOwnerInventory(token: String) async throws -> OwnerInventorySyncCommandResponse {

        struct EmptyBody: Encodable {}

        return try await request(

            path: "/inventory/sync-owner",

            method: "POST",

            body: Optional<EmptyBody>.some(EmptyBody()),

            token: token,

            responseType: OwnerInventorySyncCommandResponse.self

        )

    }
    
    func getCases(token: String) async throws -> InventoryCasesResponse {

        struct EmptyBody: Encodable {}

        return try await request(

            path: "/inventory/cases",

            method: "GET",

            body: Optional<EmptyBody>.none,

            token: token,

            responseType: InventoryCasesResponse.self

        )

    }

    func getTerminals(token: String) async throws -> InventoryTerminalsResponse {

        struct EmptyBody: Encodable {}

        return try await request(

            path: "/inventory/terminals",

            method: "GET",

            body: Optional<EmptyBody>.none,

            token: token,

            responseType: InventoryTerminalsResponse.self

        )

    }

    func createOpeningSession(

        deviceId: Int,

        selectedInventoryItemId: Int,

        token: String,

        openingStreamURL: String? = nil

    ) async throws -> OpeningSession {

        try await request(

            path: "/opening-sessions",

            method: "POST",

            body: CreateOpeningSessionRequest(

                deviceId: deviceId,

                selectedInventoryItemId: selectedInventoryItemId,

                openingStreamURL: openingStreamURL

            ),

            token: token,

            responseType: OpeningSession.self

        )

    }

    func getOpeningSession(id: Int, token: String) async throws -> OpeningSession {
        struct EmptyBody: Encodable {}
        return try await request(
            path: "/opening-sessions/\(id)",
            method: "GET",
            body: Optional<EmptyBody>.none,
            token: token,
            responseType: OpeningSession.self
        )
    }

    func getOpeningSessions(token: String) async throws -> OpeningSessionsResponse {
        struct EmptyBody: Encodable {}
        return try await request(
            path: "/opening-sessions",
            method: "GET",
            body: Optional<EmptyBody>.none,
            token: token,
            responseType: OpeningSessionsResponse.self
        )
    }

    func getOpeningHistory(token: String) async throws -> OpeningHistoryResponse {
        struct EmptyBody: Encodable {}
        return try await request(
            path: "/opening-history",
            method: "GET",
            body: Optional<EmptyBody>.none,
            token: token,
            responseType: OpeningHistoryResponse.self
        )
    }
}
