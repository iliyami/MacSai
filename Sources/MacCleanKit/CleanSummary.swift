import Foundation

/// What happened during a Clean operation. Designed for the post-clean
/// UI to render an honest message — '0 bytes cleaned up' is ambiguous
/// across three different outcomes (nothing selected, everything errored,
/// or genuinely no junk found), and the field combinations here let the
/// view distinguish them.
public struct CleanSummary: Sendable, Equatable, Identifiable {
    /// Unique per clean, so per-clean decisions (the support card) can be
    /// made once even when a done screen re-renders or is rebuilt. Excluded
    /// from `==`, which compares only what happened.
    public let id = UUID()

    /// How many items the user had checked when they clicked Clean.
    /// Zero means the action ran with an empty selection — likely because
    /// every result category had `autoSelect = false` (e.g. Universal
    /// Binaries) and the user clicked Clean without manually checking
    /// anything.
    public let selectedCount: Int

    /// How many items actually got cleaned (moved to Trash). Always
    /// `<= selectedCount` — the difference is rejections (SafetyGuard
    /// + per-binary errors).
    public let removedCount: Int

    public let freedBytes: UInt64

    /// Every error message produced during the operation. Aggregated
    /// downstream into top-N groups for the UI; kept raw so a future
    /// "Show All Errors" inspector can list every individual failure.
    public let errorMessages: [String]

    public var errorCount: Int { errorMessages.count }

    public static func == (lhs: CleanSummary, rhs: CleanSummary) -> Bool {
        lhs.selectedCount == rhs.selectedCount
            && lhs.removedCount == rhs.removedCount
            && lhs.freedBytes == rhs.freedBytes
            && lhs.errorMessages == rhs.errorMessages
    }

    /// First raw error message, if any. Used for the single-error
    /// completion screen variant where showing the full text is honest.
    public var firstErrorMessage: String? { errorMessages.first }

    /// Top-3 most-frequent error messages with their counts. When 49,918
    /// items fail, the user wants to know what kind of failure dominates
    /// ("Operation not permitted") and how many — not a flat number
    /// that points them at Console.app.
    public var topErrorGroups: [ErrorGroup] {
        ErrorGroup.top(in: errorMessages, k: 3)
    }

    public init(
        selectedCount: Int,
        removedCount: Int,
        freedBytes: UInt64,
        errorMessages: [String]
    ) {
        self.selectedCount = selectedCount
        self.removedCount = removedCount
        self.freedBytes = freedBytes
        self.errorMessages = errorMessages
    }

    public struct ErrorGroup: Sendable, Equatable, Hashable {
        public let message: String
        public let count: Int

        public init(message: String, count: Int) {
            self.message = message
            self.count = count
        }

        /// Top-`k` most frequent messages in `messages`, sorted by count
        /// descending then by message text ascending for deterministic
        /// ordering across runs.
        public static func top(in messages: [String], k: Int) -> [ErrorGroup] {
            guard k > 0, !messages.isEmpty else { return [] }
            let grouped = Dictionary(grouping: messages, by: { $0 })
                .map { ErrorGroup(message: $0.key, count: $0.value.count) }
                .sorted {
                    if $0.count != $1.count { return $0.count > $1.count }
                    return $0.message < $1.message
                }
            return Array(grouped.prefix(k))
        }
    }
}
