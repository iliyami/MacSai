import Foundation

/// 10-level matching engine for finding files associated with an installed app.
/// Pure — given an `AppInfo`, produces a `Set<String>` of substring patterns
/// to search for in the user's Library subdirectories.
public enum AppMatching {

    public enum MatchLevel: Int, CaseIterable, Sendable {
        case bundleIDExact = 1        // com.google.Chrome
        case displayName = 2          // "google chrome"
        case appDirName = 3           // "google chrome"
        case normalizedName = 4       // "googlechrome"
        case bundleIDComponents = 5   // "google.Chrome"
        case baseBundleID = 6         // strip .helper / .agent / .daemon / .launcher / .updater
        case versionStripped = 7      // "chrome" (strip "100.0.0.1")
        case companyName = 8          // "google"
        case teamIdentifier = 9       // from code signature (not implemented)
        case entitlements = 10        // from entitlements (not implemented)
    }

    /// Library subdirectories the uninstaller searches for app leftovers.
    public static let librarySubdirectories: [String] = [
        "Application Support",
        "Caches",
        "Containers",
        "Group Containers",
        "Preferences",
        "Logs",
        "Application Scripts",
        "Cookies",
        "HTTPStorages",
        "LaunchAgents",
        "Saved Application State",
        "Internet Plug-Ins",
        "PreferencePanes",
        "PrivilegedHelperTools",
        "Services",
        "WebKit",
        "Frameworks",
    ]

    /// Generates the pattern set for an app using all match levels up to `maxLevel`.
    /// Each pattern is a substring (lowercased) that we'll search filenames for.
    ///
    /// The default stops at `.versionStripped` (7), deliberately excluding
    /// `.companyName` (8). The company-name level emits the bare vendor token
    /// (e.g. "tencent", "google"), which substring-matches every app from that
    /// vendor, so uninstalling one app would flag a sibling's files (issue #98:
    /// uninstalling Tencent Yuanbao also matched WeChat). For a tool that
    /// deletes files, precision matters more than recall, so company-name is
    /// opt-in only.
    public static func generatePatterns(
        for app: AppInfo,
        maxLevel: MatchLevel = .versionStripped
    ) -> Set<String> {
        var patterns: Set<String> = []
        let levels = MatchLevel.allCases.filter { $0.rawValue <= maxLevel.rawValue }

        for level in levels {
            switch level {
            case .bundleIDExact:
                patterns.insert(app.bundleIdentifier.lowercased())

            case .displayName:
                patterns.insert(app.name.lowercased())

            case .appDirName:
                let dirName = app.path.deletingPathExtension().lastPathComponent.lowercased()
                patterns.insert(dirName)

            case .normalizedName:
                let normalized = app.name.lowercased().filter(\.isLetter)
                if normalized.count >= 3 {
                    patterns.insert(normalized)
                }

            case .bundleIDComponents:
                let components = app.bundleIdentifier.components(separatedBy: ".")
                if components.count >= 2 {
                    let last2 = components.suffix(2).joined(separator: ".").lowercased()
                    patterns.insert(last2)
                }

            case .baseBundleID:
                var baseID = app.bundleIdentifier.lowercased()
                for suffix in [".helper", ".agent", ".daemon", ".launcher", ".updater"] {
                    if baseID.hasSuffix(suffix) {
                        baseID = String(baseID.dropLast(suffix.count))
                    }
                }
                patterns.insert(baseID)

            case .versionStripped:
                let stripped = app.name.replacingOccurrences(
                    of: "\\d+(\\.\\d+)*",
                    with: "",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces).lowercased()
                if stripped.count >= 3 {
                    patterns.insert(stripped)
                }

            case .companyName:
                let components = app.bundleIdentifier.components(separatedBy: ".")
                if components.count >= 2 {
                    let company = components[1].lowercased()
                    if company.count >= 3 && company != "apple" {
                        patterns.insert(company)
                    }
                }

            case .teamIdentifier:
                // Would require Security.framework code signing APIs
                break
            case .entitlements:
                // Would require Security.framework entitlement reading
                break
            }
        }

        // Substring matching makes short and generic tokens unsafe: "x" would
        // match Firefox, while "app" would match WhatsApp.
        let genericPatterns: Set<String> = ["app"]
        return patterns.filter {
            $0.count >= 3 && !genericPatterns.contains($0)
        }
    }

    /// Returns true if any pattern occurs in `fileName` (case-insensitively) as
    /// a whole word: both ends of the occurrence must sit on a word boundary
    /// (string edge, separator, lower→upper camel-case step, or letter↔digit
    /// step). A bare substring check let the Arc browser's "arc" pattern claim
    /// `com.apple.archiveutility.plist` and Safari's `SearchHelper`.
    public static func filenameMatches(_ fileName: String, patterns: Set<String>) -> Bool {
        // Skip empty patterns defensively: a "" token would match every file,
        // and these patterns drive file deletion.
        patterns.contains { !$0.isEmpty && containsWord($0, in: fileName) }
    }

    private static func containsWord(_ pattern: String, in fileName: String) -> Bool {
        var searchStart = fileName.startIndex
        while let range = fileName.range(of: pattern, options: .caseInsensitive,
                                         range: searchStart..<fileName.endIndex) {
            if isBoundary(in: fileName, at: range.lowerBound)
                && isBoundary(in: fileName, at: range.upperBound) {
                return true
            }
            searchStart = fileName.index(after: range.lowerBound)
        }
        return false
    }

    private static func isBoundary(in string: String, at index: String.Index) -> Bool {
        guard index > string.startIndex, index < string.endIndex else { return true }
        let before = string[string.index(before: index)]
        let after = string[index]
        // Only ASCII letters/digits form words, so names in scripts without
        // spaces or case (e.g. Chinese) keep matching as substrings.
        func isWordCharacter(_ c: Character) -> Bool { c.isASCII && (c.isLetter || c.isNumber) }
        guard isWordCharacter(before), isWordCharacter(after) else { return true }
        if before.isLowercase && after.isUppercase { return true }
        return before.isNumber != after.isNumber
    }
}
