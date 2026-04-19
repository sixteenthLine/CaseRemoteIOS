import Foundation
import Observation

@Observable
final class CommandViewModel {
    var currentCommand: Command?
    var isSending = false
    var statusText: String = "No command sent yet"

    private var pollingTask: Task<Void, Never>?

    func sendCommand(deviceId: Int, type: String, token: String) async {
        isSending = true
        statusText = "Sending command..."

        do {
            let command = try await ApiClient.shared.createCommand(deviceId: deviceId, type: type, token: token)
            currentCommand = command
            statusText = "Command sent: \(command.status)"
            startPolling(commandId: command.id, token: token)
        } catch {
            statusText = "Send failed: \(error.localizedDescription)"
        }

        isSending = false
    }

    func startPolling(commandId: Int, token: String) {
        pollingTask?.cancel()

        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let command = try await ApiClient.shared.getCommand(commandId: commandId, token: token)
                    await MainActor.run {
                        self.currentCommand = command
                        self.statusText = "Command status: \(command.status)"
                    }

                    if command.status == "succeeded" || command.status == "failed" {
                        break
                    }
                } catch {
                    await MainActor.run {
                        self.statusText = "Polling failed: \(error.localizedDescription)"
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
