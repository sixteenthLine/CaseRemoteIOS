import Foundation
import Observation

@Observable
final class DevicesViewModel {
    var devices: [Device] = []
    var isLoading = false
    var errorMessage: String?

    func loadDevices(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await ApiClient.shared.getDevices(token: token)
            devices = response.devices
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clear() {
        devices = []
        errorMessage = nil
        isLoading = false
    }
}
