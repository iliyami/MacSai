import Foundation
import IOKit
import IOKit.pwr_mgt
import MacCleanKit
import MacSaiSMC

/// Privileged fan helper (issue #242).
///
/// Safety rules:
/// - Only `FanHelperProtocol`'s three calls exist; every write comes from
///   `FanControlPolicy` and `SMCConnection.write` refuses any other key.
/// - Callers must satisfy the menu app's Developer ID requirement (bundle id
///   plus Team ID), checked by the kernel before any message is delivered.
/// - Targets are clamped to the fan's rated min/max; a fan under macOS
///   thermal management is never overridden.
/// - Automatic control is restored at startup, when the controlling client
///   disconnects or stops renewing its target (watchdog), before sleep, and
///   on SIGTERM (launchd sends it on unregister and uninstall) or exit.
final class FanHelperService: NSObject, NSXPCListenerDelegate, FanHelperProtocol, @unchecked Sendable {
    static let shared = FanHelperService()

    private static let clientRequirement =
        MCConstants.codeSigningRequirement(for: MCConstants.menuBundleIdentifier)

    // All SMC access and state below are confined to this serial queue.
    private let queue = DispatchQueue(label: "com.macclean.fanhelper.state")
    private let smc = SMCConnection()
    /// The connection that last pinned a fan; its disconnect restores automatic.
    private var owner: ObjectIdentifier?
    private var isPinned = false
    private var lastRenewal = Date.distantPast
    private var keepAlive: [AnyObject] = []
    private var powerPort: io_connect_t = 0

    func run() -> Never {
        queue.sync { restoreAutomatic(reason: "startup") }
        installExitHandlers()
        installSleepHandler()
        installWatchdog()

        let listener = NSXPCListener(machServiceName: FanHelperConstants.machServiceName)
        listener.delegate = self
        keepAlive.append(listener)
        listener.resume()
        RunLoop.main.run()
        fatalError("run loop returned")
    }

    // MARK: - XPC

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        // Kernel-enforced: messages from a peer that fails the requirement
        // are never delivered, so unsigned or foreign processes get nothing.
        connection.setCodeSigningRequirement(Self.clientRequirement)
        connection.exportedInterface = NSXPCInterface(with: FanHelperProtocol.self)
        connection.exportedObject = self
        let id = ObjectIdentifier(connection)
        connection.invalidationHandler = { [weak self] in
            guard let self else { return }
            self.queue.async {
                // A crashed or quit client must not leave fans pinned.
                if self.owner == id { self.restoreAutomatic(reason: "client disconnected") }
            }
        }
        connection.resume()
        return true
    }

    func fanInfo(withReply reply: @escaping @Sendable (Data?) -> Void) {
        queue.async {
            reply(try? JSONEncoder().encode(self.readFans()))
        }
    }

    func setTargetRPM(_ rpm: Double, forFan fan: Int, withReply reply: @escaping @Sendable (Double, String?) -> Void) {
        let caller = NSXPCConnection.current().map(ObjectIdentifier.init)
        queue.async {
            guard let smc = self.smc else { return reply(-1, "AppleSMC unavailable") }
            let read: (String) -> FanSpeedReader.SMCValue? = { smc.read($0) }
            switch FanControlPolicy.manualWrites(fan: fan, rpm: rpm, readKey: read) {
            case .failure(let refusal):
                reply(-1, "\(refusal)")
            case .success(let plan):
                do {
                    do {
                        try self.apply(plan.writes)
                    } catch {
                        // Some Apple Silicon firmware needs the test unlock first.
                        let unlock = FanControlPolicy.unlockWrites(readKey: read)
                        guard !unlock.isEmpty else { throw error }
                        try self.apply(unlock)
                        try self.apply(plan.writes)
                    }
                    self.owner = caller
                    self.isPinned = true
                    self.lastRenewal = Date()
                    reply(plan.target, nil)
                } catch {
                    self.restoreAutomatic(reason: "manual write failed")
                    reply(-1, "\(error)")
                }
            }
        }
    }

    func setAutomatic(withReply reply: @escaping @Sendable (Bool) -> Void) {
        queue.async {
            self.restoreAutomatic(reason: "requested")
            reply(true)
        }
    }

    // MARK: - SMC (queue only)

    private func readFans() -> [FanSpeed] {
        guard let smc else { return [] }
        return FanSpeedReader.readFans { smc.read($0) }
    }

    private func apply(_ writes: [FanControlPolicy.Write]) throws {
        guard let smc else { return }
        for write in writes {
            try smc.write(write.key, bytes: write.bytes)
        }
    }

    private func restoreAutomatic(reason: String) {
        owner = nil
        isPinned = false
        guard let smc else { return }
        let writes = FanControlPolicy.automaticWrites { smc.read($0) }
        guard !writes.isEmpty else { return }
        log("restoring automatic fan control (\(reason))")
        // Keep going past a failed key so the remaining fans are still restored.
        for write in writes {
            do { try smc.write(write.key, bytes: write.bytes) } catch { log("restore \(write.key) failed: \(error)") }
        }
    }

    // MARK: - Fail-safes

    private func installWatchdog() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 1, repeating: 1)
        timer.setEventHandler { [weak self] in
            guard let self, self.isPinned,
                  Date().timeIntervalSince(self.lastRenewal) > FanHelperConstants.watchdogSeconds else { return }
            self.restoreAutomatic(reason: "watchdog")
        }
        timer.resume()
        keepAlive.append(timer)
    }

    private func installExitHandlers() {
        signal(SIGPIPE, SIG_IGN)
        atexit { FanHelperService.shared.restoreOnExit() }
        for sig in [SIGTERM, SIGINT, SIGHUP] {
            signal(sig, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: sig, queue: queue)
            source.setEventHandler { [weak self] in
                self?.restoreAutomatic(reason: "signal \(sig)")
                exit(0)
            }
            source.resume()
            keepAlive.append(source)
        }
    }

    /// atexit runs on whichever thread exits; hop onto the queue unless the
    /// exit already happens there (a signal handler).
    private func restoreOnExit() {
        if DispatchQueue.getSpecific(key: Self.queueKey) != nil {
            restoreAutomatic(reason: "exit")
        } else {
            queue.sync { restoreAutomatic(reason: "exit") }
        }
    }

    private static let queueKey = DispatchSpecificKey<Bool>()

    private func installSleepHandler() {
        queue.setSpecific(key: Self.queueKey, value: true)
        var notifier: io_object_t = 0
        var port: IONotificationPortRef?
        powerPort = IORegisterForSystemPower(nil, &port, { _, _, messageType, argument in
            FanHelperService.shared.handlePower(messageType: messageType, argument: argument)
        }, &notifier)
        guard powerPort != 0, let port else { return log("power notifications unavailable") }
        IONotificationPortSetDispatchQueue(port, queue)
    }

    // IOKit message constants (iokit_common_msg) are macros Swift cannot import.
    private static let canSystemSleep: UInt32 = 0xE000_0270
    private static let systemWillSleep: UInt32 = 0xE000_0280

    /// Runs on `queue`. Fans go back to automatic before sleep; after wake a
    /// manual client resends its target on its next poll.
    private func handlePower(messageType: UInt32, argument: UnsafeMutableRawPointer?) {
        switch messageType {
        case Self.systemWillSleep:
            restoreAutomatic(reason: "sleep")
            IOAllowPowerChange(powerPort, Int(bitPattern: argument))
        case Self.canSystemSleep:
            IOAllowPowerChange(powerPort, Int(bitPattern: argument))
        default:
            break
        }
    }

    private func log(_ message: String) {
        FileHandle.standardError.write(Data("[fanhelper] \(message)\n".utf8))
    }
}
