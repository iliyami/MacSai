import Foundation

/// Identifies launch agent plists pointing at deleted binaries.
public struct BrokenLoginItemsCategory: JunkCategory {
    public init() {}

    public let scanCategory = ScanCategory.brokenLoginItems

    public var targets: [ScanTarget] {
        [
            ScanTarget(
                path: MCConstants.userLaunchAgents,
                recursive: false,
                fileExtensions: ["plist"]
            ),
        ]
    }

    /// Pure filter: a login item is "broken" if any of:
    ///  - the plist itself fails to parse
    ///  - the resolved Program/ProgramArguments[0] path no longer exists
    ///  - the plist's referenced .app bundle no longer exists
    ///
    /// `loadData`, `fileExists`, and `appExistsForBundleID` are injected for
    /// testability. Returns the items that should be flagged for cleanup.
    public func filterBroken(
        _ items: [FileItem],
        loadData: (URL) -> Data?,
        fileExists: (String) -> Bool,
        appExistsForBundleID: (String) -> Bool
    ) -> [FileItem] {
        items.filter { item in
            guard item.fileExtension == "plist" else { return false }
            guard let data = loadData(item.url) else { return true }

            let plist: [String: Any]
            do {
                guard let dict = try PropertyListSerialization
                    .propertyList(from: data, format: nil) as? [String: Any] else {
                    return true
                }
                plist = dict
            } catch {
                return true // can't parse = broken
            }

            let programPath: String?
            if let prog = plist["Program"] as? String {
                // launchd requires `Program` to be absolute and won't run the job otherwise.
                guard prog.hasPrefix("/") else { return true }
                programPath = prog
            } else if let args = plist["ProgramArguments"] as? [String], let first = args.first {
                guard let resolved = Self.resolveLaunchdCommand(first, fileExists: fileExists) else {
                    return true
                }
                programPath = resolved
            } else {
                programPath = nil
            }

            if let path = programPath {
                if !fileExists(path) { return true }
                if path.contains(".app/") {
                    let appPath = path.components(separatedBy: ".app/").first.map { $0 + ".app" }
                    if let appPath, !fileExists(appPath) { return true }
                }
            }

            if let label = plist["Label"] as? String, label.contains(".") {
                if !appExistsForBundleID(label) {
                    if let path = programPath, !fileExists(path) {
                        return true
                    }
                }
            }

            return false
        }
    }

    /// `_PATH_STDPATH` from `<paths.h>`: the search path launchd uses for a
    /// bare `ProgramArguments[0]` such as `open` or `sh` (see launchd.plist(5)).
    static let launchdSearchPath = ["/usr/bin", "/bin", "/usr/sbin", "/sbin"]

    /// Absolute path launchd would execute for `ProgramArguments[0]`, or nil
    /// when a bare command name isn't found on `launchdSearchPath`.
    static func resolveLaunchdCommand(_ command: String, fileExists: (String) -> Bool) -> String? {
        guard !command.hasPrefix("/"), !command.contains("/") else { return command }
        return launchdSearchPath
            .map { "\($0)/\(command)" }
            .first(where: fileExists)
    }
}
