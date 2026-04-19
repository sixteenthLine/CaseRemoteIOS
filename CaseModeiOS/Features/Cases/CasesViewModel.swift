import Foundation
import Observation

@Observable
final class CasesViewModel {
    var cases: [InventoryCase] = []
    var isLoading = false
    var isSyncing = false
    var errorMessage: String?
    var syncMessage: String?
    var lastSyncedAt: String?

    func loadCases(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await ApiClient.shared.getCases(token: token)
            cases = response.cases
            lastSyncedAt = response.cases.first?.lastSyncedAt
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func syncAndReload(token: String) async {
        isSyncing = true
        errorMessage = nil
        syncMessage = nil

        do {
            let sync = try await ApiClient.shared.syncInventory(token: token)
            syncMessage = "Synced \(sync.totalItems) items, \(sync.totalCases) cases"
            await loadCases(token: token)
        } catch {
            errorMessage = error.localizedDescription
        }

        isSyncing = false
    }
}
