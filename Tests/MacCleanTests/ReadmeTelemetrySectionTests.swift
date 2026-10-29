import XCTest
import Foundation
import MacCleanTestSupport

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
        try assertLiveSocketScope(in: src, fileName: fileName)
        XCTAssertTrue(
            src.contains("bash scripts/check-network-surface.sh \"/Applications/Mac Sai.app\""),
            "\(fileName) must check the installed bundle, not only the main executable or source"
        )
        for component in ["Sparkle.framework", "Autoupdate", "Updater.app", "Downloader.xpc", "Installer.xpc"] {
            XCTAssertTrue(src.contains(component), "\(fileName) must disclose the checked component \(component)")
        }
    }

    /// Run the documented command with fixture processes, including similarly
    /// named unrelated helpers. Nothing queries real sockets or user processes.
    private func assertLiveSocketScope(in source: String, fileName: String) throws {
        let blocks = source.components(separatedBy: "```bash\n").dropFirst()
            .compactMap { $0.components(separatedBy: "```").first }
        let snippet = try XCTUnwrap(blocks.first { $0.contains("lsof") }, "\(fileName) needs a live socket command")
        try TestFixtures.withTempDir { directory in
            let app = directory.appending(path: "Mac Sai.app")
            let commands = directory.appending(path: "commands")
            let socketArguments = directory.appending(path: "socket-arguments")
            try FileManager.default.createDirectory(at: app, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: commands, withIntermediateDirectories: true)
            let fixtures = [
                "ps": """
                #!/bin/bash
                if [ "$1" = "-ww" ]; then
                  MACSAI_TEST_APP=$(cd "$MACSAI_TEST_APP" && pwd -P) || exit 1
                  printf ' 11 %s/Contents/MacOS/MacClean\\n' "$MACSAI_TEST_APP"
                  printf ' 12 %s/Contents/Library/LoginItems/MacCleanMenu.app/Contents/MacOS/MacCleanMenu\\n' "$MACSAI_TEST_APP"
                  printf ' 21 /Applications/Other.app/Contents/MacOS/Installer\\n'
                  printf ' 22 %s-extra/Contents/MacOS/Updater\\n' "$MACSAI_TEST_APP"
                fi
                """,
                "lsof": """
                #!/bin/bash
                printf '%s\\n' "$@" > "$MACSAI_TEST_SOCKET_ARGUMENTS"
                """,
            ]
            for (name, script) in fixtures {
                let url = commands.appending(path: name)
                try script.write(to: url, atomically: true, encoding: .utf8)
                try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: url.path)
            }
            let process = Process()
            process.executableURL = URL(filePath: "/bin/bash")
            process.arguments = ["-c", snippet.replacingOccurrences(of: "/Applications/Mac Sai.app", with: app.path)]
            process.environment = [
                "PATH": commands.path + ":/usr/bin:/bin:/usr/sbin:/sbin",
                "MACSAI_TEST_APP": app.resolvingSymlinksInPath().path,
                "MACSAI_TEST_SOCKET_ARGUMENTS": socketArguments.path,
            ]
            let output = Pipe()
            process.standardOutput = output
            process.standardError = output
            try process.run()
            process.waitUntilExit()
            let diagnostics = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
            XCTAssertEqual(process.terminationStatus, 0, "\(fileName): \(diagnostics)")
            XCTAssertTrue(FileManager.default.fileExists(atPath: socketArguments.path), "\(fileName): \(diagnostics)")
            guard FileManager.default.fileExists(atPath: socketArguments.path) else { return }
            let arguments = try String(contentsOf: socketArguments, encoding: .utf8).split(separator: "\n").map(String.init)
            let pidOption = try XCTUnwrap(arguments.firstIndex(of: "-p"), "\(fileName) must select explicit process IDs")
            XCTAssertLessThan(pidOption + 1, arguments.count)
            guard pidOption + 1 < arguments.count else { return }
            XCTAssertEqual(arguments[pidOption + 1], "11,12", "\(fileName) must exclude unrelated Installer/Updater and sibling bundles")
            XCTAssertTrue(arguments.contains("-a") && arguments.contains("-i"), "\(fileName) must intersect sockets with the selected PIDs")
        }
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

    func testGermanReadmeHasVerifyNoTelemetrySection() throws {
        try assertTelemetrySection(
            in: "README.de.md",
            headingNeedle: "Telemetriefreiheit selbst überprüfen"
        )
    }

    func testTraditionalChineseReadmeHasVerifyNoTelemetrySection() throws {
        try assertTelemetrySection(
            in: "README.zh-Hant.md",
            headingNeedle: "自行驗證無遙測"
        )
    }

    func testFrenchReadmeHasVerifyNoTelemetrySection() throws {
        try assertTelemetrySection(
            in: "README.fr.md",
            headingNeedle: "Vérifiez l'absence de télémétrie vous-même"
        )
    }

    /// A MalwareBazaar hit on a signed file makes macOS check the signing
    /// certificate's revocation status with Apple (OCSP). That request comes
    /// from macOS, so check-network-surface.sh can't see it; every README
    /// lists it next to the MalwareBazaar download.
    func testEveryReadmeDisclosesTheRevocationLookup() throws {
        let needles = [
            "README.md": "signing certificate was revoked",
            "README.fr.md": "certificat de signature a été révoqué",
            "README.de.md": "Signaturzertifikat widerrufen wurde",
            "README.ru.md": "не отозван ли его сертификат подписи",
            "README.zh-CN.md": "签名证书是否已被吊销",
            "README.zh-Hant.md": "簽署憑證是否已被撤銷",
        ]
        for (file, needle) in needles {
            let src = try String(contentsOf: readmeURL(file), encoding: .utf8)
            XCTAssertTrue(src.contains(needle), "\(file) must disclose the OCSP revocation lookup")
        }
        let security = try String(contentsOf: readmeURL("SECURITY.md"), encoding: .utf8)
        XCTAssertTrue(security.contains("signing certificate was revoked"), "SECURITY.md must disclose it too")
    }
}
