import AppKit
import Foundation

/// Keep both values from AppKit's completion handler: successful moves are
/// reported even when another item in the same batch failed or was cancelled.
struct BatchTrashReceipt: Sendable {
    var relocated: [URL: URL]
    var errorMessage: String?
    var wasCancelled: Bool = false
}

struct BatchTrashService: Sendable {
    var recycle: @Sendable ([URL]) async -> BatchTrashReceipt

    static let live = BatchTrashService { urls in
        await withCheckedContinuation { continuation in
            // NSWorkspace may display system authentication/progress UI.
            // Cancellation is handled between batches; do not resume early
            // and lose the receipt while Finder is still moving files.
            Task { @MainActor in
                NSWorkspace.shared.recycle(urls) { relocated, error in
                    continuation.resume(returning: BatchTrashReceipt(
                        relocated: relocated,
                        errorMessage: error?.localizedDescription,
                        wasCancelled: Self.isCancellation(error)
                    ))
                }
            }
        }
    }

    static func isCancellation(_ error: (any Error)?) -> Bool {
        guard let error = error as NSError? else { return false }
        if error.domain == NSCocoaErrorDomain, error.code == NSUserCancelledError { return true }
        if error.domain == NSOSStatusErrorDomain, error.code == -128 { return true }
        return isCancellation(error.userInfo[NSUnderlyingErrorKey] as? any Error)
    }
}
