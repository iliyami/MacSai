import Foundation

/// Interprets the system's batch-trash receipt without assuming that an
/// overall error means nothing moved (or that nil error means everything did).
public enum BatchTrashPolicy {
    public enum Outcome: Sendable, Equatable {
        case moved(to: URL)
        case missing
        case failed
        case invalidReceipt
    }

    public static func outcomes(
        requested: [URL],
        relocated: [URL: URL],
        missing: Set<URL>,
        trashRoot: String,
        uid: UInt32
    ) -> [URL: Outcome] {
        let requestedSet = Set(requested)
        // A duplicate destination cannot describe two independently moved
        // objects. Do not manufacture restore records from such a receipt.
        let destinations = Dictionary(grouping: relocated.filter { requestedSet.contains($0.key) },
                                      by: { receiptPath($0.value) })
        var outcomes: [URL: Outcome] = [:]
        for source in requestedSet {
            if let destination = relocated[source] {
                let destinationPath = receiptPath(destination)
                guard isLocalFileURL(source), isLocalFileURL(destination),
                      receiptPath(source) != destinationPath,
                      destinations[destinationPath]?.count == 1,
                      CleanHistoryRestore.isInsideTrash(
                        destinationPath, trashRoot: trashRoot, uid: uid
                      ) else {
                    outcomes[source] = .invalidReceipt
                    continue
                }
                outcomes[source] = .moved(to: URL(filePath: destinationPath, directoryHint: .notDirectory))
            } else {
                outcomes[source] = missing.contains(source) ? .missing : .failed
            }
        }
        return outcomes
    }

    private static func isLocalFileURL(_ url: URL) -> Bool {
        url.isFileURL && (url.host == nil || url.host == "" || url.host == "localhost")
    }

    private static func receiptPath(_ url: URL) -> String {
        // AppKit may return a directory URL ending in '/'. Older Foundation
        // versions strip that marker when standardizing, so passing it to
        // the restore policy unchanged can reject a successful directory
        // move. Normalize only this marker; still reject '..' and bad paths.
        let rawPath = url.path(percentEncoded: false)
        return rawPath.count > 1 && rawPath.hasSuffix("/") ? String(rawPath.dropLast()) : rawPath
    }
}
