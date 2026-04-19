import Foundation
import Observation

@Observable
final class CasesViewModel {
    var cases: [InventoryCase] = []
    var isLoading = false
    var errorMessage: String?

    func loadCases(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await ApiClient.shared.getCases(token: token)
            cases = response.cases
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
