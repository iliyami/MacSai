import Foundation

/// Coordinates destructive work with application replacement. Acquiring an
/// update lease closes the gate before waiting for existing work to finish,
/// so a new clean cannot race the final idle check. Waiting never blocks a
/// thread. Scope tokens belong at outer operation boundaries, not nested
/// calls: a nested acquisition could otherwise wait behind its own outer work.
public final class AppOperationActivity: @unchecked Sendable {
    public static let shared = AppOperationActivity()

    private let lock = NSLock()
    private var active: Set<UUID> = []
    private var updateRequested = false
    private var waitingOperations: [CheckedContinuation<UUID, Never>] = []
    private var waitingUpdates: [CheckedContinuation<Bool, Never>] = []

    public init() {}

    public var isBusy: Bool { lock.withLock { !active.isEmpty } }
    public var isPreparingUpdate: Bool { lock.withLock { updateRequested } }

    /// Pair with `end` in a defer, including cancellation and failure paths.
    public func begin() async -> UUID {
        await withCheckedContinuation { continuation in
            let token: UUID? = lock.withLock {
                guard !updateRequested else {
                    waitingOperations.append(continuation)
                    return nil
                }
                let token = UUID()
                active.insert(token)
                return token
            }
            if let token { continuation.resume(returning: token) }
        }
    }

    public func end(_ token: UUID) {
        let ready: [CheckedContinuation<Bool, Never>] = lock.withLock {
            active.remove(token)
            guard active.isEmpty else { return [] }
            let ready = waitingUpdates
            waitingUpdates.removeAll()
            return ready
        }
        for continuation in ready { continuation.resume(returning: true) }
    }

    /// Holds the gate closed until the app exits or `cancelUpdate` is called.
    public func prepareForUpdate() async -> Bool {
        await withCheckedContinuation { continuation in
            let ready = lock.withLock {
                updateRequested = true
                guard active.isEmpty else {
                    waitingUpdates.append(continuation)
                    return false
                }
                return true
            }
            if ready { continuation.resume(returning: true) }
        }
    }

    /// Restore normal operation if installation is cancelled or fails.
    public func cancelUpdate() {
        let (waiting, updates): ([(CheckedContinuation<UUID, Never>, UUID)], [CheckedContinuation<Bool, Never>]) = lock.withLock {
            updateRequested = false
            let waiting = waitingOperations.map { continuation in
                let token = UUID()
                active.insert(token)
                return (continuation, token)
            }
            waitingOperations.removeAll()
            let updates = waitingUpdates
            waitingUpdates.removeAll()
            return (waiting, updates)
        }
        for continuation in updates { continuation.resume(returning: false) }
        for (continuation, token) in waiting { continuation.resume(returning: token) }
    }
}
