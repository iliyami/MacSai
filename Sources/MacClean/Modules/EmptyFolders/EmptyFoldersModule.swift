import Foundation
import MacCleanKit

public struct EmptyFoldersModule: ScanModule {
    public let id = "empty_folders"
    public var name: String { L10n.tr("空文件夹", "Empty Folders", "Dossiers vides") }
    public let category = ModuleCategory.files
    public let includedInSmartScan = false

    public init() {}

    public func scan() async -> [ScanResult] {
        let fm = FileManager.default
        let searchPath = fm.homeDirectoryForCurrentUser
        
        guard let enumerator = fm.enumerator(
            at: searchPath,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsPackageDescendants, .skipsHiddenFiles]
        ) else {
            return []
        }
        
        var directories: [URL] = []
        
        // Collect directories (Need to do this synchronously without await in loop if possible, or just a while loop)
        while let fileURL = enumerator.nextObject() as? URL {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
                if resourceValues.isDirectory == true {
                    directories.append(fileURL)
                }
            } catch {
                continue
            }
        }
        
        // Process directories from deepest to shallowest to catch newly emptied folders
        directories.sort { $0.path.count > $1.path.count }
        
        var emptyFolderItems: [FileItem] = []
        
        for dir in directories {
            do {
                let contents = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                if contents.isEmpty {
                    // Check if it's not a restricted folder (like Library, etc)
                    if dir.path.contains("Library") || dir.path.contains("System") {
                        continue
                    }
                    
                    let attr = try fm.attributesOfItem(atPath: dir.path)
                    let size = attr[.size] as? Int64 ?? 0
                    
                    let item = FileItem(
                        url: dir,
                        name: dir.lastPathComponent,
                        size: UInt64(size),
                        allocatedSize: UInt64(size),
                        isDirectory: true
                    )
                    emptyFolderItems.append(item)
                }
            } catch {
                continue
            }
        }
        
        if emptyFolderItems.isEmpty {
            return []
        }
        
        return [ScanResult(category: .emptyFolders, items: emptyFolderItems, autoSelect: false)]
    }
}
