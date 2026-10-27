/// A prepared installer can outlive the UI/check cycle that created it. A
/// network error, declined background check or ordinary dismissal must not
/// forget the need to stop the menu helper on the next normal Quit.
public struct SelfUpdateInstallationState: Sendable, Equatable {
    public private(set) var hasPreparedUpdate = false

    public init() {}

    public mutating func prepared() { hasPreparedUpdate = true }
    public mutating func skipped() { hasPreparedUpdate = false }

    public mutating func aborted(installationFailed: Bool) {
        if installationFailed { hasPreparedUpdate = false }
    }
}
