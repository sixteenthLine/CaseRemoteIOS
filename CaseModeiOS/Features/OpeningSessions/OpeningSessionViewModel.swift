import Foundation
import Observation

@Observable
final class OpeningSessionViewModel {
    var session: OpeningSession?
    var isLoading = false
    var errorMessage: String?

    private var pollingTask: Task<Void, Never>?

    func createSession(
        deviceId: Int,
        selectedCaseId: Int,
        selectedCaseName: String?,
        token: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let created = try await ApiClient.shared.createOpeningSession(
                deviceId: deviceId,
                selectedCaseId: selectedCaseId,
                selectedCaseName: selectedCaseName,
                token: token
            )
            session = created
            startPolling(sessionId: created.id, token: token)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func startPolling(sessionId: Int, token: String) {
        pollingTask?.cancel()

        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let updated = try await ApiClient.shared.getOpeningSession(id: sessionId, token: token)
                    await MainActor.run {
                        self.session = updated
                    }

                    if updated.status == "completed" || updated.status == "failed" || updated.status == "ready" {
                        break
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                    }
                }

                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}
