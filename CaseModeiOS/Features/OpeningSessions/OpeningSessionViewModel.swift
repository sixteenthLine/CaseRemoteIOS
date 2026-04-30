import Foundation
import Observation

@Observable
@MainActor
final class OpeningSessionViewModel {
    var session: OpeningSession?
    var historyItem: OpeningHistoryItem?
    var isLoading = false
    var isPolling = false
    var errorMessage: String?

    private var pollingTask: Task<Void, Never>?

    func createSession(
        deviceId: Int,
        selectedInventoryItemId: Int,
        token: String
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let created = try await ApiClient.shared.createOpeningSession(
                deviceId: deviceId,
                selectedInventoryItemId: selectedInventoryItemId,
                token: token
            )
            session = created
            historyItem = nil
            startPolling(sessionId: created.id, token: token)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func startPolling(sessionId: Int, token: String) {
        pollingTask?.cancel()
        isPolling = true

        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let updated = try await ApiClient.shared.getOpeningSession(id: sessionId, token: token)
                    self.session = updated

                    if Self.isTerminalStatus(updated.status) {
                        self.isPolling = false
                        if updated.status == "completed" {
                            await self.loadHistoryItem(openingSessionId: updated.id, token: token)
                        }
                        break
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                }

                try? await Task.sleep(for: .seconds(2))
            }

            if !Task.isCancelled {
                self.isPolling = false
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        isPolling = false
    }

    func loadHistoryItem(openingSessionId: Int, token: String) async {
        do {
            let response = try await ApiClient.shared.getOpeningHistory(token: token)
            historyItem = response.openings.first { $0.openingSessionId == openingSessionId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    static func isTerminalStatus(_ status: String) -> Bool {
        status == "completed" || status == "result_detection_failed" || status == "failed"
    }
}
