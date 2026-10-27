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
        let destinations = Dictionary(grouping: relocated.filter { requestedSet.contains($0.key) }, by: \.value)
        var outcomes: [URL: Outcome] = [:]
        for source in requestedSet {
            if let destination = relocated[source] {
                guard isLocalFileURL(source), isLocalFileURL(destination),
                      source != destination,
                      destinations[destination]?.count == 1,
                      CleanHistoryRestore.isInsideTrash(
                        destination.path(percentEncoded: false), trashRoot: trashRoot, uid: uid
                      ) else {
                    outcomes[source] = .invalidReceipt
                    continue
                }
                outcomes[source] = .moved(to: destination)
            } else {
                outcomes[source] = missing.contains(source) ? .missing : .failed
            }
        }
        return outcomes
    }

    private static func isLocalFileURL(_ url: URL) -> Bool {
        url.isFileURL && (url.host == nil || url.host == "" || url.host == "localhost")
    }
}
