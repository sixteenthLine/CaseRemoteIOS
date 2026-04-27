import Foundation

struct GroupedInventoryCase: Identifiable {
    let id: String
    let representativeInventoryItemId: Int
    let displayName: String
    let marketHashName: String?
    let quantity: Int
    let lastSyncedAt: String?
}
