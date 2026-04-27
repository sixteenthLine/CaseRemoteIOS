import Foundation

final class TerminalCatalogService {
    static let shared = TerminalCatalogService()

    private init() {}

    func loadItems() -> [TerminalCatalogItem] {
        guard let url = Bundle.main.url(
            forResource: "terminal_catalog",
            withExtension: "json",
            subdirectory: "Resources/Catalogs"
        ) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([TerminalCatalogItem].self, from: data)
        } catch {
            print("Failed to load terminal catalog: \(error)")
            return []
        }
    }
}

