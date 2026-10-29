import XCTest
@testable import MacCleanKit

final class DeveloperCacheCategoriesTests: XCTestCase {
    private var allTargets: [ScanTarget] {
        PackageManagerCachesCategory().targets
            + IDECachesCategory().targets
            + AIToolCachesCategory().targets
    }
    private var allPaths: [String] { allTargets.map { $0.path.path(percentEncoded: false) } }

    func testPackageManagerCachesIncludeExpected() {
        let p = PackageManagerCachesCategory().targets.map { $0.path.path(percentEncoded: false) }
        func has(_ s: String) -> Bool { p.contains { $0.hasSuffix(s) } }
        XCTAssertTrue(has("/.npm/_cacache"))
        XCTAssertTrue(has("/.cargo/registry/cache"))
        XCTAssertTrue(has("/.cargo/registry/src"))
        XCTAssertTrue(has("/.gradle/caches"))
        XCTAssertTrue(has("/Library/Caches/Homebrew"))
        XCTAssertTrue(has("/Library/Caches/pip"))
        XCTAssertTrue(has("/.cache/uv"))
        XCTAssertTrue(has("/Library/Caches/uv"))
    }

    func testIDECachesIncludeEditors() {
        let p = IDECachesCategory().targets.map { $0.path.path(percentEncoded: false) }
        XCTAssertTrue(p.contains { $0.contains("Application Support/Antigravity/") && $0.hasSuffix("/Cache") })
        XCTAssertTrue(p.contains { $0.contains("Application Support/Cursor/") && $0.hasSuffix("/Cache") })
    }

    func testAIToolCachesIncludeClaudeAndCodex() {
        let p = AIToolCachesCategory().targets.map { $0.path.path(percentEncoded: false) }
        func has(_ s: String) -> Bool { p.contains { $0.hasSuffix(s) } }
        XCTAssertTrue(has("/.claude/cache"))
        XCTAssertTrue(has("/.claude/paste-cache"))
        XCTAssertTrue(has("/.claude/shell-snapshots"))
        XCTAssertTrue(has("/.codex/.tmp"))
        XCTAssertTrue(has("/.codex/cache"))
    }

    // Load-bearing safety test across ALL developer cache categories.
    func testNeverTargetsUserData() {
        let forbidden = [
            "/.claude/projects", "/.claude/file-history",
            "/.codex/sessions", "/.codex/archived_sessions",
            "/extensions", "/Antigravity/User", "/Cursor/User",
            "com.docker.docker", "Docker.raw",
        ]
        for path in allPaths {
            for bad in forbidden {
                XCTAssertFalse(path.contains(bad), "Developer caches must never target \(bad), found in \(path)")
            }
        }
    }

    func testAllTargetsAreRecursive() {
        // Recursive so each cache dir's contents are enumerated and sized;
        // non-recursive lists subdirs as ~0-byte items, under-reporting space.
        XCTAssertTrue(allTargets.allSatisfy { $0.recursive })
    }
}
