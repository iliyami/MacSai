import XCTest
import MacCleanKit

final class ResourceHogsPolicyTests: XCTestCase {

    private func hog(
        pid: Int32,
        name: String,
        cpu: Double,
        memory: UInt64,
        bundleID: String? = "com.example.app"
    ) -> ResourceHogSnapshot {
        ResourceHogSnapshot(
            pid: pid,
            name: name,
            cpuPercent: cpu,
            memoryBytes: memory,
            bundleIdentifier: bundleID
        )
    }

    func testRankedByCPUPutsHighestFirstAndRespectsLimit() {
        let input = [
            hog(pid: 1, name: "Low", cpu: 5, memory: 1_000),
            hog(pid: 2, name: "High", cpu: 80, memory: 500),
            hog(pid: 3, name: "Mid", cpu: 20, memory: 2_000),
        ]

        let ranked = ResourceHogsPolicy.ranked(input, sortBy: .cpu, limit: 2)

        XCTAssertEqual(ranked.map(\.name), ["High", "Mid"])
    }

    func testRankedByMemoryPutsLargestFirst() {
        let input = [
            hog(pid: 1, name: "Small", cpu: 90, memory: 100),
            hog(pid: 2, name: "Large", cpu: 1, memory: 9_000_000_000),
        ]

        let ranked = ResourceHogsPolicy.ranked(input, sortBy: .memory, limit: 10)

        XCTAssertEqual(ranked.map(\.name), ["Large", "Small"])
    }

    func testCanQuitRejectsOwnAppAndShellProcesses() {
        XCTAssertFalse(ResourceHogsPolicy.canQuit(bundleIdentifier: MCConstants.bundleIdentifier))
        XCTAssertFalse(ResourceHogsPolicy.canQuit(bundleIdentifier: MCConstants.menuBundleIdentifier))
        XCTAssertFalse(ResourceHogsPolicy.canQuit(bundleIdentifier: "com.apple.finder"))
        XCTAssertFalse(ResourceHogsPolicy.canQuit(bundleIdentifier: "com.apple.dock"))
        XCTAssertTrue(ResourceHogsPolicy.canQuit(bundleIdentifier: "com.google.Chrome"))
        XCTAssertTrue(ResourceHogsPolicy.canQuit(bundleIdentifier: nil),
                      "unknown bundle IDs remain quitable after confirmation")
    }

    func testRowsMarkProtectedProcessesAsNotQuitable() {
        let rows = ResourceHogsPolicy.rows(from: [
            hog(pid: 1, name: "Chrome", cpu: 40, memory: 1, bundleID: "com.google.Chrome"),
            hog(pid: 2, name: "Finder", cpu: 5, memory: 1, bundleID: "com.apple.finder"),
            hog(pid: 3, name: "Mac Sai", cpu: 2, memory: 1, bundleID: MCConstants.bundleIdentifier),
        ], sortBy: .cpu, limit: 10)

        XCTAssertEqual(rows.map(\.canQuit), [true, false, false])
    }
}
