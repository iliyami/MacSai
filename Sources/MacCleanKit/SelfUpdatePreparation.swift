import Foundation

/// One preparation owns the update callback at a time. Cancellation invalidates
/// that ownership before waking any suspended task, so an old helper wait can
/// never install an update or overwrite a newer preparation's state.
@MainActor
public final class SelfUpdatePreparation {
    public enum Result: Sendable {
        case ready, unavailable, cancelled
    }

    private var generation: UUID?
    private var task: Task<Void, Never>?
    private var completion: (@MainActor (Result) -> Void)?

    public init() {}
    public var isRunning: Bool { generation != nil }

    @discardableResult
    public func start(
        prepare: @escaping @MainActor () async -> Bool,
        completion: @escaping @MainActor (Result) -> Void
    ) -> Bool {
        guard generation == nil else { return false }
        let generation = UUID()
        self.generation = generation
        self.completion = completion
        task = Task { @MainActor in
            let ready = await prepare()
            guard self.generation == generation, !Task.isCancelled else { return }
            self.generation = nil
            self.task = nil
            self.completion = nil
            completion(ready ? .ready : .unavailable)
        }
        return true
    }

    public func cancel(beforeCompletion: () -> Void = {}) {
        let completion = self.completion
        generation = nil
        self.completion = nil
        task?.cancel()
        task = nil
        // The owner can restore its state after invalidation but before an
        // external reply starts another preparation synchronously.
        beforeCompletion()
        // A pending Quit request receives its negative completion now,
        // even if the old asynchronous work is slow to observe cancellation.
        completion?(.cancelled)
    }
}
