import XCTest
@testable import MacCleanKit

final class NetworkRateTests: XCTestCase {

    func testRateIsDeltaOverElapsed() {
        XCTAssertEqual(NetworkRate.bytesPerSecond(current: 3_000, previous: 1_000, elapsed: 2), 1_000)
    }

    func testCounterGoingBackwardsYieldsZeroInsteadOfTrapping() {
        // if_data byte counters are 32-bit and wrap every 4 GiB, and the
        // summed total also drops when a utun/VPN interface disappears.
        XCTAssertEqual(NetworkRate.bytesPerSecond(current: 10, previous: 4_294_967_000, elapsed: 1), 0)
    }

    func testNonPositiveElapsedYieldsZero() {
        XCTAssertEqual(NetworkRate.bytesPerSecond(current: 500, previous: 100, elapsed: 0), 0)
        XCTAssertEqual(NetworkRate.bytesPerSecond(current: 500, previous: 100, elapsed: -1), 0)
    }
}
