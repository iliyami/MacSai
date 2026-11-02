import Foundation

/// One fan's live and rated speeds in revolutions per minute.
public struct FanSpeed: Sendable, Equatable, Codable {
    public let index: Int
    public let current: Double
    public let minimum: Double?
    public let maximum: Double?

    public init(index: Int, current: Double, minimum: Double?, maximum: Double?) {
        self.index = index
        self.current = current
        self.minimum = minimum
        self.maximum = maximum
    }

    /// Position of `current` within the rated range, clamped to `0...1`.
    /// Without a usable range the fan is treated as idle or full by sign.
    public var fraction: Double {
        let low = minimum ?? 0
        guard let high = maximum, high > low else { return current > 0 ? 1 : 0 }
        return min(max((current - low) / (high - low), 0), 1)
    }
}

/// Decodes AppleSMC fan keys into `FanSpeed` values.
///
/// Reading needs no privileges (issue #242); only the opt-in fan helper
/// writes, through `FanControlPolicy`. The SMC connection is injected as
/// `readKey`, so the byte formats and missing-key handling are testable
/// without hardware.
public enum FanSpeedReader {
    /// Raw SMC value: the four-character data type and its payload.
    public typealias SMCValue = (type: String, bytes: [UInt8])

    /// Real Macs have at most a few fans; anything larger is a bad read.
    static let maximumFanCount = 8

    /// Returns every fan with a valid current speed, or `[]` on fanless Macs
    /// and when the SMC is unavailable.
    public static func readFans(readKey: (String) -> SMCValue?) -> [FanSpeed] {
        guard let countValue = readKey("FNum"),
              let count = decode(countValue),
              count >= 1 else { return [] }

        return (0..<min(Int(count), maximumFanCount)).compactMap { index in
            guard let current = readKey("F\(index)Ac").flatMap(rpm) else { return nil }
            return FanSpeed(
                index: index,
                current: current,
                minimum: readKey("F\(index)Mn").flatMap(rpm),
                maximum: readKey("F\(index)Mx").flatMap(rpm)
            )
        }
    }

    /// Decodes the numeric SMC types fan keys use. Unknown types and short
    /// payloads return `nil` rather than guessing.
    public static func decode(_ value: SMCValue) -> Double? {
        let b = value.bytes
        switch value.type {
        case "fpe2":
            // Intel: big-endian unsigned fixed point, 14 integer bits and 2 fraction bits.
            guard b.count >= 2 else { return nil }
            return Double(UInt16(b[0]) << 8 | UInt16(b[1])) / 4
        case "flt ":
            // Apple Silicon: little-endian IEEE 754 single precision.
            guard b.count >= 4 else { return nil }
            let bits = UInt32(b[0]) | UInt32(b[1]) << 8 | UInt32(b[2]) << 16 | UInt32(b[3]) << 24
            return Double(Float(bitPattern: bits))
        case "ui8 ":
            guard b.count >= 1 else { return nil }
            return Double(b[0])
        case "ui16":
            guard b.count >= 2 else { return nil }
            return Double(UInt16(b[0]) << 8 | UInt16(b[1]))
        default:
            return nil
        }
    }

    /// Inverse of `decode` for the types fan control writes. Returns `nil`
    /// for unknown types or values the type cannot represent.
    public static func encode(_ number: Double, type: String) -> [UInt8]? {
        guard number.isFinite, number >= 0 else { return nil }
        switch type {
        case "fpe2":
            guard number * 4 <= Double(UInt16.max) else { return nil }
            let raw = UInt16((number * 4).rounded())
            return [UInt8(raw >> 8), UInt8(raw & 0xff)]
        case "flt ":
            let bits = Float(number).bitPattern
            return [UInt8(bits & 0xff), UInt8(bits >> 8 & 0xff), UInt8(bits >> 16 & 0xff), UInt8(bits >> 24)]
        case "ui8 ":
            guard number <= Double(UInt8.max) else { return nil }
            return [UInt8(number.rounded())]
        case "ui16":
            guard number <= Double(UInt16.max) else { return nil }
            let raw = UInt16(number.rounded())
            return [UInt8(raw >> 8), UInt8(raw & 0xff)]
        default:
            return nil
        }
    }

    /// A speed is usable only when finite and within a plausible range.
    private static func rpm(_ value: SMCValue) -> Double? {
        guard let speed = decode(value), speed.isFinite, speed >= 0, speed < 20_000 else { return nil }
        return speed
    }

    /// Packs a four-character SMC key into the big-endian code IOKit expects.
    public static func fourCharCode(_ key: String) -> UInt32 {
        key.utf8.prefix(4).reduce(0) { $0 << 8 | UInt32($1) }
    }

    /// Unpacks a four-character code, e.g. a returned data type.
    public static func string(fromFourCharCode code: UInt32) -> String {
        String(decoding: (0..<4).map { UInt8(truncatingIfNeeded: code >> (24 - $0 * 8)) }, as: UTF8.self)
    }
}
