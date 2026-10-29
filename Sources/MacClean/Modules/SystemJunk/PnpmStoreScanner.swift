import Foundation
import MacCleanKit

/// Lists each pnpm store version folder (`store/v10`, `store/v3`, ...) as one
/// item sized by its whole subtree. A store holds far too many files to list
/// one by one, and the version is what tells the user which one is stale.
enum PnpmStoreScanner {
    static func scan(roots: [URL] = MCConstants.pnpmStoreRoots) -> [FileItem] {
        let fm = FileManager.default
        let folders = roots.flatMap { root in
            (try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey]))?
                .filter {
                    let values = try? $0.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
                    return values?.isDirectory == true && values?.isSymbolicLink != true
                } ?? []
        }
        return PnpmStore.versions(in: folders).compactMap { version in
            let size = AppLeftoversScanner.directorySize(at: version.url)
            guard size > 0 else { return nil }
            return FileItem(
                url: version.url,
                name: version.displayName,
                size: size,
                allocatedSize: size,
                isDirectory: true
            )
        }
    }
}
