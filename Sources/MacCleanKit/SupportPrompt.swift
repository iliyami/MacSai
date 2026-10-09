import Foundation

/// When the post-clean "support Mac Sai" card may appear. It is deliberately
/// rare so it never turns into a nag screen: only after a clean that freed a
/// real amount of space, never on the very first clean (the user is still
/// deciding whether to trust the app), at most once per cooldown window, and
/// never again once the user opts out or follows the link. Everything is a
/// local `UserDefaults` value; nothing is sent anywhere.
public enum SupportPrompt {
    public static let minFreedBytes: UInt64 = 1_000_000_000
    public static let minCleanCount = 2
    public static let cooldown: TimeInterval = 60 * 24 * 60 * 60

    static let cleanCountKey = "supportPrompt.cleanCount"
    static let lastShownKey = "supportPrompt.lastShown"
    static let optedOutKey = "supportPrompt.optedOut"

    public struct State: Equatable, Sendable {
        /// Successful cleans so far, including the one being evaluated.
        public var cleanCount: Int
        public var lastShown: Date?
        public var optedOut: Bool

        public init(cleanCount: Int, lastShown: Date?, optedOut: Bool) {
            self.cleanCount = cleanCount
            self.lastShown = lastShown
            self.optedOut = optedOut
        }
    }

    public static func shouldShow(state: State, freedBytes: UInt64, now: Date) -> Bool {
        guard !state.optedOut,
              freedBytes >= minFreedBytes,
              state.cleanCount >= minCleanCount else { return false }
        guard let lastShown = state.lastShown else { return true }
        return now.timeIntervalSince(lastShown) >= cooldown
    }

    public static func state(defaults: UserDefaults = .standard) -> State {
        State(
            cleanCount: defaults.integer(forKey: cleanCountKey),
            lastShown: defaults.object(forKey: lastShownKey) as? Date,
            optedOut: defaults.bool(forKey: optedOutKey)
        )
    }

    /// Records a successful clean and returns whether to show the card for it.
    /// Showing starts the cooldown immediately, so "Maybe later" needs no
    /// extra bookkeeping.
    public static func registerClean(
        freedBytes: UInt64,
        now: Date = Date(),
        defaults: UserDefaults = .standard
    ) -> Bool {
        var current = state(defaults: defaults)
        current.cleanCount += 1
        defaults.set(current.cleanCount, forKey: cleanCountKey)
        guard shouldShow(state: current, freedBytes: freedBytes, now: now) else { return false }
        defaults.set(now, forKey: lastShownKey)
        return true
    }

    /// "Don't ask again", or the user followed the link: never show it again.
    public static func optOut(defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: optedOutKey)
    }
}
