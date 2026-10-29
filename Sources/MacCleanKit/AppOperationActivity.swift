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
    // Every field in the waiter objects is protected by `lock`, including the
    // cancellation flag. Cancellation can arrive before continuation setup.
    private final class OperationWaiter: @unchecked Sendable {
        let id = UUID()
        var cancelled = false
        var continuation: CheckedContinuation<UUID, any Error>?
    }

    private final class UpdateWaiter: @unchecked Sendable {
        let id = UUID()
        var cancelled = false
        var continuation: CheckedContinuation<Bool, Never>?
    }

    private var updateRequests: Set<UUID> = []
    private var waitingOperations: [UUID: OperationWaiter] = [:]
    private var waitingUpdates: [UUID: UpdateWaiter] = [:]

    public init() {}

    public var isBusy: Bool { lock.withLock { !active.isEmpty } }
    public var isPreparingUpdate: Bool { lock.withLock { !updateRequests.isEmpty } }
    var queuedOperationCount: Int { lock.withLock { waitingOperations.count } }
    var pendingUpdateCount: Int { lock.withLock { updateRequests.count } }

    /// Pair with `end` in a defer, including cancellation and failure paths.
    public func begin() async throws -> UUID {
        let waiter = OperationWaiter()
        return try await withTaskCancellationHandler {
            let token: UUID = try await withCheckedThrowingContinuation { continuation in
                let result: Result<UUID, any Error>? = lock.withLock {
                    guard !waiter.cancelled, !Task.isCancelled else {
                        return .failure(CancellationError())
                    }
                    guard updateRequests.isEmpty else {
                        waiter.continuation = continuation
                        waitingOperations[waiter.id] = waiter
                        return nil
                    }
                    active.insert(waiter.id)
                    return .success(waiter.id)
                }
                if let result { continuation.resume(with: result) }
            }
            // A cancellation racing with a granted continuation must not leave
            // a phantom active token or let the caller start destructive work.
            if Task.isCancelled {
                end(token)
                throw CancellationError()
            }
            return token
        } onCancel: {
            let continuation = self.lock.withLock {
                waiter.cancelled = true
                return self.waitingOperations.removeValue(forKey: waiter.id)?.continuation
            }
            continuation?.resume(throwing: CancellationError())
        }
    }

    public func end(_ token: UUID) {
        let ready: [CheckedContinuation<Bool, Never>] = lock.withLock {
            active.remove(token)
            guard active.isEmpty else { return [] }
            let ready = waitingUpdates.values.compactMap(\.continuation)
            waitingUpdates.removeAll()
            return ready
        }
        for continuation in ready { continuation.resume(returning: true) }
    }

    /// Holds the gate closed until the app exits or `cancelUpdate` is called.
    /// Cancelling while waiting returns false and releases only this request;
    /// another updater's request still keeps destructive operations suspended.
    /// There is deliberately no timeout that could install over active work.
    public func prepareForUpdate(
        confirmWhileBusy: @escaping @Sendable () async -> Bool = { true }
    ) async -> Bool {
        let waiter = UpdateWaiter()
        return await withTaskCancellationHandler {
            // Reserve the gate before asking whether to wait. Existing work
            // may finish while the prompt is visible, but new work cannot
            // slip between the user's decision and the final idle check.
            let reserved = lock.withLock {
                guard !waiter.cancelled, !Task.isCancelled else { return false }
                updateRequests.insert(waiter.id)
                return true
            }
            guard reserved else { return false }
            if isBusy, !(await confirmWhileBusy()) {
                cancel(waiter)
                return false
            }
            let ready = await withCheckedContinuation { continuation in
                let result: Bool? = lock.withLock {
                    guard !waiter.cancelled, !Task.isCancelled,
                          updateRequests.contains(waiter.id) else { return false }
                    guard active.isEmpty else {
                        waiter.continuation = continuation
                        waitingUpdates[waiter.id] = waiter
                        return nil
                    }
                    return true
                }
                if let result { continuation.resume(returning: result) }
            }
            if Task.isCancelled {
                cancel(waiter)
                return false
            }
            return lock.withLock { ready && updateRequests.contains(waiter.id) && !waiter.cancelled }
        } onCancel: {
            self.cancel(waiter)
        }
    }

    private func cancel(_ waiter: UpdateWaiter) {
        let (update, operations) = lock.withLock {
            waiter.cancelled = true
            updateRequests.remove(waiter.id)
            let update = waitingUpdates.removeValue(forKey: waiter.id)?.continuation
            return (update, resumeOperationsIfOpen())
        }
        update?.resume(returning: false)
        for (continuation, token) in operations { continuation.resume(returning: token) }
    }

    /// Called only with `lock` held. Tokens are reserved before opening a
    /// continuation so a new update cannot pass an apparently idle gate.
    private func resumeOperationsIfOpen() -> [(CheckedContinuation<UUID, any Error>, UUID)] {
        guard updateRequests.isEmpty else { return [] }
        let waiting = waitingOperations.values.compactMap { waiter -> (CheckedContinuation<UUID, any Error>, UUID)? in
            guard let continuation = waiter.continuation else { return nil }
            active.insert(waiter.id)
            return (continuation, waiter.id)
        }
        waitingOperations.removeAll()
        return waiting
    }

    /// Restore normal operation if installation is cancelled or fails.
    public func cancelUpdate() {
        let (waiting, updates) = lock.withLock {
            updateRequests.removeAll()
            let waiting = resumeOperationsIfOpen()
            let updates = waitingUpdates.values.compactMap(\.continuation)
            waitingUpdates.removeAll()
            return (waiting, updates)
        }
        for continuation in updates { continuation.resume(returning: false) }
        for (continuation, token) in waiting { continuation.resume(returning: token) }
    }
}
