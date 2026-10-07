import XCTest
@testable import MacCleanKit

final class CPUStatsTests: XCTestCase {

    func testSummed_aggregatesAcrossCPUs() {
        // 2 CPUs × 4 states each. State order: user, system, idle, nice.
        // CPU 0: u=100 s=20 i=80 n=5
        // CPU 1: u=200 s=30 i=70 n=0
        let raw: [Int32] = [100, 20, 80, 5, 200, 30, 70, 0]
        let ticks = CPUTicks.summed(rawLoadInfo: raw, cpuCount: 2)
        XCTAssertEqual(ticks, CPUTicks(user: 300, system: 50, idle: 150, nice: 5))
    }

    func testSummed_handlesPartialArrayGracefully() {
        // Caller claims 3 CPUs but only 2 worth of data — must not crash.
        let raw: [Int32] = [10, 20, 30, 40, 50, 60, 70, 80]
        let ticks = CPUTicks.summed(rawLoadInfo: raw, cpuCount: 3)
        XCTAssertEqual(ticks, CPUTicks(user: 60, system: 80, idle: 100, nice: 120))
    }

    func testSummed_readsTicksAboveInt32MaxAsUnsigned() {
        // Mach tick counters are natural_t (UInt32) delivered through an
        // integer_t (Int32) array. A core idle for ~248 days of uptime passes
        // Int32.max; its counter arrives negative and must not trap.
        let idle = Int32(bitPattern: 0x8000_0010)
        let raw: [Int32] = [1, 2, idle, 3]
        let ticks = CPUTicks.summed(rawLoadInfo: raw, cpuCount: 1)
        XCTAssertEqual(ticks, CPUTicks(user: 1, system: 2, idle: 0x8000_0010, nice: 3))
    }

    func testUsage_returnsNilWhenACounterWrapped() {
        // After ~497 days a UInt32 counter wraps to a small value; skip that
        // one sample instead of reporting a nonsense fraction.
        let prev = CPUTicks(user: 1000, system: 200, idle: 4_294_967_000, nice: 0)
        let curr = CPUTicks(user: 1050, system: 225, idle: 300, nice: 0)
        XCTAssertNil(CPUUsage(previous: prev, current: curr))
    }

    func testUsage_computesFractionsFromDelta() {
        let prev = CPUTicks(user: 1000, system: 200, idle: 800, nice: 0)
        // Over the interval: user gained 50, system 25, idle 425, nice 0.
        // Total: 500 → user 10%, system 5%, idle 85%, nice 0%.
        let curr = CPUTicks(user: 1050, system: 225, idle: 1225, nice: 0)
        let usage = CPUUsage(previous: prev, current: curr)!
        XCTAssertEqual(usage.userFraction,   0.10, accuracy: 0.001)
        XCTAssertEqual(usage.systemFraction, 0.05, accuracy: 0.001)
        XCTAssertEqual(usage.idleFraction,   0.85, accuracy: 0.001)
        XCTAssertEqual(usage.niceFraction,   0.00, accuracy: 0.001)
        XCTAssertEqual(usage.totalActiveFraction, 0.15, accuracy: 0.001)
    }

    func testUsage_returnsNilForZeroInterval() {
        let ticks = CPUTicks(user: 100, system: 50, idle: 200, nice: 0)
        XCTAssertNil(CPUUsage(previous: ticks, current: ticks),
                     "two identical snapshots → 0 delta → nil (can't divide)")
    }

    func testUsage_fractionsAlwaysSumToOne() {
        let prev = CPUTicks(user: 0, system: 0, idle: 0, nice: 0)
        let curr = CPUTicks(user: 123, system: 456, idle: 789, nice: 12)
        let usage = CPUUsage(previous: prev, current: curr)!
        let sum = usage.userFraction + usage.systemFraction +
                  usage.idleFraction + usage.niceFraction
        XCTAssertEqual(sum, 1.0, accuracy: 0.0001)
    }
}

final class MemoryStatsTests: XCTestCase {

    private let pageSize: UInt64 = 16_384  // 16 KB on Apple Silicon

    func testUsedIsActivePlusWiredPlusCompressed() {
        // 1000 active + 500 wired + 200 compressed pages × 16 KB
        let stats = VMStatistics(
            activeCount: 1000,
            inactiveCount: 2000,
            wireCount: 500,
            freeCount: 3000,
            compressorPageCount: 200
        )
        let total: UInt64 = 16_384 * 1_000_000  // 16 GB
        let mem = MemoryUsage(physicalTotal: total, vmStats: stats, pageSize: pageSize)
        XCTAssertEqual(mem.used, 16_384 * (1000 + 500 + 200),
                       "used must be active + wired + compressed only — inactive/free are reclaimable")
        XCTAssertEqual(mem.total, total)
    }

    func testPressureIsUsedOverTotal() {
        let stats = VMStatistics(
            activeCount: 100,
            inactiveCount: 0,
            wireCount: 0,
            freeCount: 0,
            compressorPageCount: 0
        )
        let total: UInt64 = pageSize * 1000  // used = 100/1000 of total
        let mem = MemoryUsage(physicalTotal: total, vmStats: stats, pageSize: pageSize)
        XCTAssertEqual(mem.pressure, 0.10, accuracy: 0.001)
    }

    func testPressureZeroWhenTotalZero() {
        let stats = VMStatistics(
            activeCount: 100, inactiveCount: 0,
            wireCount: 0, freeCount: 0, compressorPageCount: 0
        )
        let mem = MemoryUsage(physicalTotal: 0, vmStats: stats, pageSize: pageSize)
        XCTAssertEqual(mem.pressure, 0,
                       "0 total → 0 pressure (not NaN)")
    }

    func testSwapUsedPropagates() {
        let stats = VMStatistics(
            activeCount: 0, inactiveCount: 0,
            wireCount: 0, freeCount: 0, compressorPageCount: 0
        )
        let mem = MemoryUsage(physicalTotal: 1, vmStats: stats, pageSize: pageSize, swapUsed: 4096)
        XCTAssertEqual(mem.swapUsed, 4096)
    }
}

final class DiskStatsTests: XCTestCase {

    func testUsedIsTotalMinusFree() {
        let d = DiskUsage(total: 1_000_000, free: 250_000)
        XCTAssertEqual(d.used, 750_000)
    }

    func testUsedFraction() {
        let d = DiskUsage(total: 1_000, free: 250)
        XCTAssertEqual(d.usedFraction, 0.75, accuracy: 0.001)
    }

    func testFreeClampedToTotal() {
        // Some statfs returns inflate free count via APFS purgeable; pin
        // free to total so used never goes negative.
        let d = DiskUsage(total: 100, free: 1000)
        XCTAssertEqual(d.free, 100, "free clamped to total")
        XCTAssertEqual(d.used, 0)
        XCTAssertEqual(d.usedFraction, 0, accuracy: 0.001)
    }

    func testZeroTotalDoesNotDivideByZero() {
        let d = DiskUsage(total: 0, free: 0)
        XCTAssertEqual(d.usedFraction, 0)
        XCTAssertEqual(d.used, 0)
    }

    func testFromStatfsMultipliesBlockCountsByBlockSize() {
        // statfs reports counts in blocks; bytes = count * f_bsize.
        // 100 total blocks, 40 available, 4096-byte blocks.
        let d = DiskUsage.fromStatfs(blocks: 100, availableBlocks: 40, blockSize: 4096)
        XCTAssertEqual(d.total, 409_600)
        XCTAssertEqual(d.free, 163_840)
        XCTAssertEqual(d.used, 245_760)
    }
}
