import XCTest
import Foundation
@testable import MacClean
@testable import MacCleanKit

/// Integration tests for the secure shredder. Real files under
/// `~/Library/Caches/` so they pass SafetyGuard, the module's job is to touch
/// the filesystem, so mocking would only test stubs.
final class ShredderModuleTests: EnglishAppLanguageTestCase {

    private static func makeTestDir() throws -> URL {
        let dir = MCConstants.userCaches.appending(path: "MacCleanShredTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func cleanup(_ dir: URL) {
        // Restore write perms so a read-only test file can be removed.
        if let items = try? FileManager.default.contentsOfDirectory(atPath: dir.path(percentEncoded: false)) {
            for item in items {
                try? FileManager.default.setAttributes(
                    [.posixPermissions: 0o644],
                    ofItemAtPath: dir.appending(path: item).path(percentEncoded: false))
            }
        }
        try? FileManager.default.removeItem(at: dir)
    }

    /// A file that can't be overwritten must NOT be deleted and reported as a
    /// successful secure erase. Reproduces the silent-return bug in
    /// secureOverwrite (a 0444 file: opening for writing fails, but removeItem
    /// still succeeds, so it used to count as "securely erased" with nothing
    /// overwritten).
    func testSecureEraseDoesNotReportSuccessWhenItCannotOverwrite() async throws {
        let dir = try Self.makeTestDir()
        defer { Self.cleanup(dir) }

        let file = dir.appending(path: "readonly.dat")
        try Data("secret data that must be overwritten".utf8).write(to: file)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444], ofItemAtPath: file.path(percentEncoded: false))

        let result = await SecureEraser().erase(urls: [file], mode: .secure)

        XCTAssertEqual(result.erasedCount, 0,
                       "must not count as securely erased when the overwrite failed")
        XCTAssertEqual(result.errors.count, 1, "the failure must be reported")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: file.path(percentEncoded: false)),
            "a file we couldn't securely overwrite must NOT be deleted")
    }

    /// Secure erase must refuse a symlink rather than following it and zeroing
    /// the target file's contents.
    func testSecureEraseRefusesSymlinkInsteadOfZeroingTarget() async throws {
        let dir = try Self.makeTestDir()
        defer { Self.cleanup(dir) }

        let target = dir.appending(path: "target.dat")
        try Data("important target contents".utf8).write(to: target)
        let link = dir.appending(path: "link.dat")   // same-tree symlink passes SafetyGuard
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)

        let result = await SecureEraser().erase(urls: [link], mode: .secure)

        XCTAssertEqual(result.erasedCount, 0, "a symlink must not be secure-erased via its target")
        let contents = try String(contentsOf: target, encoding: .utf8)
        XCTAssertEqual(contents, "important target contents",
                       "the symlink's target must be left untouched")
    }

    /// Directories must not be deleted under the "secure" label unless every
    /// contained file was actually overwritten.
    func testSecureEraseRefusesDirectoryWithoutDeletingContents() async throws {
        let dir = try Self.makeTestDir()
        defer { Self.cleanup(dir) }

        let nestedFile = dir.appending(path: "nested.dat")
        try Data("nested secret".utf8).write(to: nestedFile)

        let result = await SecureEraser().erase(urls: [dir], mode: .secure)

        XCTAssertEqual(result.erasedCount, 0)
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertEqual(result.errors.first?.0, dir.path(percentEncoded: false))
        XCTAssertTrue(
            result.errors.first?.1.contains("Secure erase cannot be used on directories") == true,
            "the user must receive a clear explanation")
        XCTAssertTrue(FileManager.default.fileExists(atPath: dir.path(percentEncoded: false)))
        XCTAssertTrue(FileManager.default.fileExists(atPath: nestedFile.path(percentEncoded: false)))
    }

    /// A protected path in one selection must not block other safe paths from
    /// being erased.
    func testInvalidPathDoesNotAbortRemainingBatch() async throws {
        let dir = try Self.makeTestDir()
        defer { Self.cleanup(dir) }

        let safeFile = dir.appending(path: "safe.dat")
        try Data("erase me".utf8).write(to: safeFile)
        let protectedPath = URL(filePath: "/System")

        let result = await SecureEraser().erase(
            urls: [protectedPath, safeFile],
            mode: .permanent)

        XCTAssertEqual(result.erasedCount, 1)
        XCTAssertEqual(result.errors.count, 1)
        XCTAssertEqual(result.errors.first?.0, protectedPath.path(percentEncoded: false))
        XCTAssertFalse(FileManager.default.fileExists(atPath: safeFile.path(percentEncoded: false)))
    }

    /// A normal writable file is securely erased as before (guardrail against
    /// the fix breaking the happy path).
    func testSecureEraseStillWorksOnNormalFile() async throws {
        let dir = try Self.makeTestDir()
        defer { Self.cleanup(dir) }

        let file = dir.appending(path: "normal.dat")
        try Data("erase me".utf8).write(to: file)

        let result = await SecureEraser().erase(urls: [file], mode: .secure)

        XCTAssertEqual(result.erasedCount, 1)
        XCTAssertTrue(result.errors.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path(percentEncoded: false)))
    }
}
