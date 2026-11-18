import Foundation
import IOKit
import MacCleanKit

/// Minimal client for the AppleSMC user client.
///
/// Reads need no privileges and are used by the menu-bar stats. On Macs
/// without the service, or for missing keys, reads return `nil`. Not
/// thread-safe: callers serialize access.
public final class SMCConnection {
    public enum Failure: Error {
        case call(kern_return_t)
        case smc(UInt8)
    }

    // Layout of the kernel's SMCKeyData_t (80 bytes). A raw buffer with fixed
    // offsets avoids relying on Swift struct padding matching C.
    private static let structSize = 80
    private static let keyOffset = 0
    private static let dataSizeOffset = 28
    private static let dataTypeOffset = 32
    private static let resultOffset = 40
    private static let commandOffset = 42
    private static let bytesOffset = 48
    private static let maxBytes = 32

    private static let structMethodSelector: UInt32 = 2
    private static let commandReadBytes: UInt8 = 5
    private static let commandReadKeyInfo: UInt8 = 9

    private var connection: io_connect_t = 0

    public init?() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        guard IOServiceOpen(service, mach_task_self_, 0, &connection) == KERN_SUCCESS else { return nil }
    }

    deinit {
        IOServiceClose(connection)
    }

    public func read(_ key: String) -> FanSpeedReader.SMCValue? {
        guard let (size, type) = keyInfo(key),
              let value = try? call(key: key, command: Self.commandReadBytes, dataSize: size)
        else { return nil }
        let bytes = Array(value[Self.bytesOffset..<(Self.bytesOffset + Int(size))])
        return (FanSpeedReader.string(fromFourCharCode: type), bytes)
    }

    /// The key's size and type; a missing key fails here.
    private func keyInfo(_ key: String) -> (UInt32, UInt32)? {
        guard let info = try? call(key: key, command: Self.commandReadKeyInfo, dataSize: 0) else { return nil }
        let size = info.load(fromByteOffset: Self.dataSizeOffset, as: UInt32.self)
        let type = info.load(fromByteOffset: Self.dataTypeOffset, as: UInt32.self)
        guard size > 0, size <= Self.maxBytes else { return nil }
        return (size, type)
    }

    private func call(key: String, command: UInt8, dataSize: UInt32) throws -> [UInt8] {
        var input = [UInt8](repeating: 0, count: Self.structSize)
        var output = [UInt8](repeating: 0, count: Self.structSize)
        input.withUnsafeMutableBytes { raw in
            raw.storeBytes(of: FanSpeedReader.fourCharCode(key), toByteOffset: Self.keyOffset, as: UInt32.self)
            raw.storeBytes(of: dataSize, toByteOffset: Self.dataSizeOffset, as: UInt32.self)
            raw.storeBytes(of: command, toByteOffset: Self.commandOffset, as: UInt8.self)
        }
        var outputSize = Self.structSize
        let status = IOConnectCallStructMethod(
            connection, Self.structMethodSelector,
            input, Self.structSize,
            &output, &outputSize
        )
        guard status == KERN_SUCCESS else { throw Failure.call(status) }
        // The SMC reports per-key failures in the result byte, not the status.
        guard output[Self.resultOffset] == 0 else { throw Failure.smc(output[Self.resultOffset]) }
        return output
    }
}

private extension Array where Element == UInt8 {
    func load<T>(fromByteOffset offset: Int, as type: T.Type) -> T {
        withUnsafeBytes { $0.loadUnaligned(fromByteOffset: offset, as: type) }
    }
}
