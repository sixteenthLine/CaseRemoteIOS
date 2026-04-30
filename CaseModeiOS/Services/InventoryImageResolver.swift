import Foundation
import UIKit

enum InventoryImageCategory: String {
    case cases
    case terminals
}

final class InventoryImageResolver {
    static let shared = InventoryImageResolver()

    private var imageIndex: [String: URL] = [:]
    private var didBuildIndex = false

    private init() {}

    func imageName(for rawName: String) -> String {
        var slug = rawName.lowercased()
        slug = slug.trimmingCharacters(in: .whitespacesAndNewlines)

        slug = slug.replacingOccurrences(of: ":", with: "-")

        slug = slug.replacingOccurrences(of: " ", with: "_")

        while slug.contains("__") {
            slug = slug.replacingOccurrences(of: "__", with: "_")
        }

        return slug
    }

    func loadImage(named rawName: String, category: InventoryImageCategory) -> UIImage? {
        buildIndexIfNeeded()

        let fileName = imageName(for: rawName)

        let categorySpecificFileName = "\(category.rawValue.dropLast())_\(fileName)"
        if let url = imageIndex[categorySpecificFileName] {
            return UIImage(contentsOfFile: url.path)
        }

        if let url = imageIndex[fileName] {
            return UIImage(contentsOfFile: url.path)
        }

        let categoryPrefix = "\(category.rawValue)/\(fileName)"
        if let url = imageIndex[categoryPrefix] {
            return UIImage(contentsOfFile: url.path)
        }

        print("Image not found for \(rawName) -> \(fileName).png")
        return nil
    }

    private func buildIndexIfNeeded() {
        guard !didBuildIndex else { return }
        didBuildIndex = true

        guard let resourcePath = Bundle.main.resourcePath else {
            print("InventoryImageResolver: Bundle.main.resourcePath is nil")
            return
        }

        do {
            let items = try FileManager.default.subpathsOfDirectory(atPath: resourcePath)

            for item in items where item.lowercased().hasSuffix(".png") {
                let fullPath = (resourcePath as NSString).appendingPathComponent(item)
                let url = URL(fileURLWithPath: fullPath)

                let fileBaseName = url.deletingPathExtension().lastPathComponent.lowercased()
                imageIndex[fileBaseName] = url

                let relativeNoExt = (item as NSString).deletingPathExtension.lowercased()
                imageIndex[relativeNoExt] = url
            }

            print("InventoryImageResolver indexed \(imageIndex.count) image entries")
        } catch {
            print("InventoryImageResolver failed to inspect bundle: \(error)")
        }
    }
}
