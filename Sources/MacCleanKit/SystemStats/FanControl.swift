import Foundation

/// Decides every SMC write the privileged fan helper may perform.
///
/// The helper only ever applies the writes planned here, and its SMC client
/// rejects any key `isWritableKey` does not allow, so a compromised or buggy
/// caller cannot reach arbitrary SMC keys. Reads are injected the same way as
/// `FanSpeedReader`, so the plans are tested against byte fixtures.
public enum FanControlPolicy {
    public struct Write: Equatable, Sendable {
        public let key: String
        public let bytes: [UInt8]
    }

    public enum Refusal: Error, Equatable, Sendable {
        case noSuchFan
        case invalidSpeed
        case missingRange
        /// macOS thermal management owns the fan; it is never overridden.
        case thermalManaged
        case unsupported
    }

    /// `F<n>Md` value while macOS manages the fan during a thermal event.
    static let thermalMode = 3.0

    /// Fan mode and target keys, the Apple Silicon test unlock, and the
    /// legacy Intel forced-fan bitmask. Nothing else is writable.
    public static func isWritableKey(_ key: String) -> Bool {
        if key == "Ftst" || key == "FS! " { return true }
        let chars = Array(key)
        guard chars.count == 4, chars[0] == "F", let digit = chars[1].wholeNumberValue,
              digit < FanSpeedReader.maximumFanCount else { return false }
        return ["Md", "Tg"].contains(String(chars[2...]))
    }

    /// Clamps a requested speed to the fan's rated range. Returns `nil` for
    /// non-finite input or when the fan does not report a usable range.
    public static func clamp(rpm: Double, minimum: Double?, maximum: Double?) -> Double? {
        guard rpm.isFinite, let minimum, let maximum,
              minimum.isFinite, maximum.isFinite, minimum >= 0, maximum > 0, minimum <= maximum
        else { return nil }
        return min(max(rpm, minimum), maximum)
    }

    /// Maps a `0...1` slider position onto the fan's rated range.
    public static func rpm(atFraction fraction: Double, for fan: FanSpeed) -> Double? {
        guard fraction.isFinite, let minimum = fan.minimum, let maximum = fan.maximum else { return nil }
        return clamp(rpm: minimum + min(max(fraction, 0), 1) * (maximum - minimum),
                     minimum: minimum, maximum: maximum)
    }

    /// Writes that pin one fan to a clamped target speed.
    public static func manualWrites(
        fan: Int,
        rpm: Double,
        readKey: (String) -> FanSpeedReader.SMCValue?
    ) -> Result<(target: Double, writes: [Write]), Refusal> {
        guard fan >= 0, fan < fanCount(readKey) else { return .failure(.noSuchFan) }
        guard rpm.isFinite else { return .failure(.invalidSpeed) }
        guard let target = clamp(
            rpm: rpm,
            minimum: readKey("F\(fan)Mn").flatMap(FanSpeedReader.decode),
            maximum: readKey("F\(fan)Mx").flatMap(FanSpeedReader.decode)
        ) else { return .failure(.missingRange) }

        var writes: [Write] = []
        if let mode = readKey("F\(fan)Md") {
            // Apple Silicon and newer Intel: per-fan mode, 1 = forced.
            if FanSpeedReader.decode(mode) == thermalMode { return .failure(.thermalManaged) }
            guard let bytes = FanSpeedReader.encode(1, type: mode.type) else { return .failure(.unsupported) }
            writes.append(Write(key: "F\(fan)Md", bytes: bytes))
        } else if let mask = readKey("FS! "), let current = FanSpeedReader.decode(mask) {
            // Older Intel: one forced bit per fan.
            let forced = UInt16(truncatingIfNeeded: Int(current)) | UInt16(1) << UInt16(fan)
            guard let bytes = FanSpeedReader.encode(Double(forced), type: mask.type) else { return .failure(.unsupported) }
            writes.append(Write(key: "FS! ", bytes: bytes))
        } else {
            return .failure(.unsupported)
        }

        guard let targetKey = readKey("F\(fan)Tg"),
              let bytes = FanSpeedReader.encode(target, type: targetKey.type)
        else { return .failure(.unsupported) }
        writes.append(Write(key: "F\(fan)Tg", bytes: bytes))
        return .success((target, writes))
    }

    /// Some Apple Silicon firmware only accepts manual mode after `Ftst = 1`.
    /// The helper applies this once and retries when a manual write fails.
    public static func unlockWrites(readKey: (String) -> FanSpeedReader.SMCValue?) -> [Write] {
        guard let test = readKey("Ftst"), FanSpeedReader.decode(test) == 0,
              let bytes = FanSpeedReader.encode(1, type: test.type) else { return [] }
        return [Write(key: "Ftst", bytes: bytes)]
    }

    /// Writes that hand every fan back to macOS. Keys already in automatic
    /// state are skipped, and a fan under thermal management is left alone.
    public static func automaticWrites(readKey: (String) -> FanSpeedReader.SMCValue?) -> [Write] {
        var writes: [Write] = []
        for fan in 0..<fanCount(readKey) {
            let key = "F\(fan)Md"
            guard let mode = readKey(key), let value = FanSpeedReader.decode(mode),
                  value != 0, value != thermalMode,
                  let bytes = FanSpeedReader.encode(0, type: mode.type) else { continue }
            writes.append(Write(key: key, bytes: bytes))
        }
        for key in ["FS! ", "Ftst"] {
            guard let value = readKey(key), let number = FanSpeedReader.decode(value), number != 0,
                  let bytes = FanSpeedReader.encode(0, type: value.type) else { continue }
            writes.append(Write(key: key, bytes: bytes))
        }
        return writes
    }

    private static func fanCount(_ readKey: (String) -> FanSpeedReader.SMCValue?) -> Int {
        guard let count = readKey("FNum").flatMap(FanSpeedReader.decode), count >= 1 else { return 0 }
        return min(Int(count), FanSpeedReader.maximumFanCount)
    }
}

/// XPC interface of the privileged fan helper. It is deliberately limited to
/// these three calls; there is no generic SMC, file or process access.
@objc public protocol FanHelperProtocol {
    /// JSON-encoded `[FanSpeed]` as the helper reads them.
    func fanInfo(withReply reply: @escaping @Sendable (Data?) -> Void)
    /// Pins one fan. Replies with the applied, clamped speed, or an error.
    /// Also renews the helper's watchdog; callers resend while manual.
    func setTargetRPM(_ rpm: Double, forFan fan: Int, withReply reply: @escaping @Sendable (Double, String?) -> Void)
    /// Hands every fan back to macOS.
    func setAutomatic(withReply reply: @escaping @Sendable (Bool) -> Void)
}

public enum FanHelperConstants {
    public static let machServiceName = "com.macclean.fanhelper"
    public static let daemonPlistName = "com.macclean.fanhelper.plist"
    /// Without a renewed target for this long, the helper restores automatic.
    public static let watchdogSeconds: TimeInterval = 10
}
