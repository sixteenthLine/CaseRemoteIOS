import Foundation
import Observation

@Observable
final class SessionStore {
    var token: String?
    var isLoading = true

    var isAuthenticated: Bool {
        token != nil
    }

    init() {
        loadToken()
    }

    func loadToken() {
        token = KeychainService.shared.loadToken()
        isLoading = false
    }

    func saveToken(_ token: String) {
        KeychainService.shared.saveToken(token)
        self.token = token
    }

    func logout() {
        KeychainService.shared.deleteToken()
        token = nil
    }
}
