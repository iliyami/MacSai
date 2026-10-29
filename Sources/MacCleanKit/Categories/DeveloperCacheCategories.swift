import Foundation

// Developer cache categories, split by the developer's mental model so each
// shows as its own collapsible card with its own size and select-all (rather
// than one overloaded "Developer Junk" list). All cache-only and recursive,
// so multi-GB caches whose bulk lives in subdirectories are sized correctly.
// The matching history/memory/sessions/extensions are never targeted (see
// DeveloperCacheCategoriesTests.testNeverTargetsUserData).

/// npm, Cargo, pip, uv, Homebrew, Gradle download/build caches.
public struct PackageManagerCachesCategory: JunkCategory {
    public init() {}
    public let scanCategory = ScanCategory.packageManagerCaches
    public var targets: [ScanTarget] {
        [
            MCConstants.npmCacache,
            MCConstants.cargoRegistryCache,
            MCConstants.cargoRegistrySrc,
            MCConstants.gradleCaches,
            MCConstants.gradleDaemon,
            MCConstants.gradleWrapperDists,
            MCConstants.homebrewCache,
            MCConstants.pipCache,
            MCConstants.uvCache,
            MCConstants.uvLegacyCache,
        ].map { ScanTarget(path: $0, recursive: true) }
    }
}

/// VS Code-family editor caches (Cursor, Antigravity): the standard Electron
/// cache dirs only. `User/` settings and installed `extensions` are excluded.
public struct IDECachesCategory: JunkCategory {
    public init() {}
    public let scanCategory = ScanCategory.ideCaches
    public var targets: [ScanTarget] {
        (MCConstants.antigravityCaches + MCConstants.cursorCaches)
            .map { ScanTarget(path: $0, recursive: true) }
    }
}

/// AI coding tools (Claude, Codex): cache/scratch dirs only. Session history,
/// memory, and projects are user data and are never targeted.
public struct AIToolCachesCategory: JunkCategory {
    public init() {}
    public let scanCategory = ScanCategory.aiToolCaches
    public var targets: [ScanTarget] {
        [
            MCConstants.claudeCache,
            MCConstants.claudePasteCache,
            MCConstants.claudeShellSnapshots,
            MCConstants.codexTmp,
            MCConstants.codexCache,
        ].map { ScanTarget(path: $0, recursive: true) }
    }
}
