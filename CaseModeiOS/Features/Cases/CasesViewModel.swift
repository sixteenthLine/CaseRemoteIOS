import Foundation
import Observation

@Observable
final class CasesViewModel {
    var groupedCases: [GroupedInventoryCase] = []
    var terminals: [TerminalCatalogItem] = []
    var isLoading = false
    var isSyncing = false
    var errorMessage: String?
    var syncMessage: String?
    var lastSyncedAt: String?

    init() {
        terminals = TerminalCatalogService.shared.loadItems()
    }

    func loadCases(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await ApiClient.shared.getCases(token: token)
            groupedCases = groupCases(response.cases)
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

    private func groupCases(_ cases: [InventoryCase]) -> [GroupedInventoryCase] {
        let grouped = Dictionary(grouping: cases) { item in
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
}
