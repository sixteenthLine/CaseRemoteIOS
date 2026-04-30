import Foundation
import Observation

@Observable
final class CasesViewModel {
    var groupedCases: [GroupedInventoryCase] = []
    var groupedTerminals: [GroupedInventoryCase] = []
    var isLoading = false
    var isStartingSync = false
    var errorMessage: String?
    var syncMessage: String?
    var syncCommandStatus: String?
    var lastSyncedAt: String?

    private var syncPollingTask: Task<Void, Never>?

    func loadInventory(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            async let casesResponse = ApiClient.shared.getCases(token: token)
            async let terminalsResponse = ApiClient.shared.getTerminals(token: token)

            let (cases, terminals) = try await (casesResponse, terminalsResponse)
            groupedCases = groupItems(cases.cases)
            groupedTerminals = groupItems(terminals.terminals)
            lastSyncedAt = latestSyncedAt(from: cases.cases + terminals.terminals)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func syncOwnerInventory(token: String) async {
        isStartingSync = true
        errorMessage = nil
        syncMessage = nil
        syncCommandStatus = nil
        syncPollingTask?.cancel()

        do {
            let response = try await ApiClient.shared.syncOwnerInventory(token: token)

            guard response.ok, let commandId = response.commandId else {
                errorMessage = response.error ?? "Unexpected sync response."
                isStartingSync = false
                return
            }

            syncCommandStatus = response.status
            syncMessage = "Inventory sync started. Waiting for Windows Agent..."
            isStartingSync = false
            startSyncPolling(commandId: commandId, token: token)
        } catch {
            errorMessage = userFacingMessage(for: error)
            isStartingSync = false
        }
    }

    func stopSyncPolling() {
        syncPollingTask?.cancel()
        syncPollingTask = nil
    }

    private func startSyncPolling(commandId: Int, token: String) {
        syncPollingTask = Task {
            for _ in 0..<10 {
                guard !Task.isCancelled else { return }

                do {
                    let command = try await ApiClient.shared.getCommand(commandId: commandId, token: token)
                    syncCommandStatus = command.status

                    switch command.status {
                    case "completed":
                        syncMessage = "Inventory sync completed. Inventory reloaded."
                        await loadInventory(token: token)
                        return
                    case "failed":
                        errorMessage = command.errorMessage ?? "Inventory sync failed."
                        syncMessage = nil
                        return
                    default:
                        syncMessage = "Inventory sync started. Waiting for Windows Agent..."
                    }
                } catch {
                    errorMessage = userFacingMessage(for: error)
                    return
                }

                try? await Task.sleep(for: .seconds(3))
            }

            if !Task.isCancelled {
                syncMessage = "Inventory sync is still pending. Refresh again in a moment."
            }
        }
    }

    private func userFacingMessage(for error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            return "Network error. Check your connection and try again."
        }

        if nsError.domain == "ApiError" {
            switch nsError.code {
            case 401, 403:
                return "Session expired. Please sign in again."
            case 404:
                return "Windows Agent не подключен. Подключите агент на ПК и попробуйте снова."
            default:
                if let message = nsError.userInfo[NSLocalizedDescriptionKey] as? String, !message.isEmpty {
                    return message
                }
                return "Unexpected server response."
            }
        }

        return error.localizedDescription
    }

    private func groupItems(_ items: [InventoryCase]) -> [GroupedInventoryCase] {
        let grouped = Dictionary(grouping: items) { item in
            item.marketHashName ?? item.name
        }

        return grouped
            .map { key, items in
                let representative = items[0]
                let quantity = items.reduce(0) { $0 + $1.quantity }

                return GroupedInventoryCase(
                    id: key,
                    representativeInventoryItemId: representative.inventoryItemId,
                    displayName: representative.name,
                    marketHashName: representative.marketHashName,
                    quantity: quantity,
                    lastSyncedAt: representative.lastSyncedAt
                )
            }
            .sorted { $0.displayName < $1.displayName }
    }

    private func latestSyncedAt(from items: [InventoryCase]) -> String? {
        items
            .map(\.lastSyncedAt)
            .sorted()
            .last
    }
}
