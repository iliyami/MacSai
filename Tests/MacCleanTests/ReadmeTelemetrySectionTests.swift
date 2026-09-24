import XCTest
import Foundation

/// Guards issue #1: the README must keep a user-verifiable "no telemetry"
/// section with copy-pasteable commands — not just a marketing claim.
final class ReadmeTelemetrySectionTests: XCTestCase {

    private func readmeURL(_ name: String) -> URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: name)
    }

    private func assertTelemetrySection(in fileName: String, headingNeedle: String) throws {
        let src = try String(contentsOf: readmeURL(fileName), encoding: .utf8)
        XCTAssertTrue(
            src.contains(headingNeedle),
            "\(fileName) must include heading «\(headingNeedle)» (issue #1)"
        )
        XCTAssertTrue(
            src.contains("lsof") || src.contains("URLSession"),
            "\(fileName) telemetry section must include a copy-pasteable verification command"
        )
        XCTAssertTrue(
            src.contains("nm -u"),
            "\(fileName) must include the binary-inspection step (nm -u) so verification covers the shipped artifact, not just the source"
        )
    }

    func testEnglishReadmeHasVerifyNoTelemetrySection() throws {
        try assertTelemetrySection(
            in: "README.md",
            headingNeedle: "Verify no telemetry yourself"
        )
    }

    func testChineseReadmeHasVerifyNoTelemetrySection() throws {
        try assertTelemetrySection(
            in: "README.zh-CN.md",
            headingNeedle: "自行验证无遥测"
        )
    }

    func testRussianReadmeHasVerifyNoTelemetrySection() throws {
        try assertTelemetrySection(
            in: "README.ru.md",
            headingNeedle: "Проверьте отсутствие телеметрии сами"
        )
    }
}
