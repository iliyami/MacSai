import Foundation
import os

/// Thrown by ``withTimeout(_:_:)`` when the operation outlives its budget.
public struct TimeoutError: Error, Equatable {
    public init() {}
}

/// Run `operation`, returning its result, or throw ``TimeoutError`` if it does
/// not finish within `duration`.
///
/// IMPORTANT: Swift task cancellation is cooperative. If `operation` is blocked
/// inside a non-cancellable C/syscall (the exact failure this guards against in
/// the menu-bar stats loop), the underlying work keeps running on its executor
/// until it returns; this function only stops *waiting* on it. So this is a
/// safety net that keeps the UI responsive, not a way to kill a hung syscall.
/// Callers must still ensure the operation is fundamentally non-blocking (e.g.
/// use `statfs` rather than the purgeable-space disk key) so a wedged call can't
/// pile up behind a serial actor.
///
/// The operation and the clock run as unstructured tasks racing to resume one
/// continuation. A task group can't be used here: it doesn't return until every
/// child has finished, so a wedged operation would hold the caller hostage.
public func withTimeout<T: Sendable>(
    _ duration: Duration,
    _ operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    let race = TimeoutRace<T>()
    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            race.start(
                continuation,
                work: Task {
                    do { race.finish(.success(try await operation())) } catch { race.finish(.failure(error)) }
                },
                clock: Task {
                    do {
                        try await Task.sleep(for: duration)
                        race.finish(.failure(TimeoutError()))
                    } catch {}
                }
            )
        }
    } onCancel: {
        race.finish(.failure(CancellationError()))
    }
}

/// Resumes the continuation exactly once with whichever outcome arrives first,
/// then cancels both racing tasks.
private final class TimeoutRace<T: Sendable>: Sendable {
    private struct State {
        var continuation: CheckedContinuation<T, Error>?
        var tasks: [Task<Void, Never>] = []
        var outcome: Result<T, Error>?
    }

    private let state = OSAllocatedUnfairLock<State>(uncheckedState: State())

    func start(_ continuation: CheckedContinuation<T, Error>, work: Task<Void, Never>, clock: Task<Void, Never>) {
        let early: Result<T, Error>? = state.withLockUnchecked { state in
            if let outcome = state.outcome { return outcome }
            state.continuation = continuation
            state.tasks = [work, clock]
            return nil
        }
        if let early {
            work.cancel()
            clock.cancel()
            continuation.resume(with: early)
        }
    }

    func finish(_ outcome: Result<T, Error>) {
        let (continuation, tasks): (CheckedContinuation<T, Error>?, [Task<Void, Never>]) =
            state.withLockUnchecked { state in
                guard state.outcome == nil else { return (nil, []) }
                state.outcome = outcome
                defer { state.continuation = nil; state.tasks = [] }
                return (state.continuation, state.tasks)
            }
        tasks.forEach { $0.cancel() }
        continuation?.resume(with: outcome)
    }
}
