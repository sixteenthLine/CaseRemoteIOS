import Foundation

enum InventoryDisplayTab: String, CaseIterable, Identifiable {
    case cases = "Cases"
    case terminals = "Terminals"

    var id: String { rawValue }
}
