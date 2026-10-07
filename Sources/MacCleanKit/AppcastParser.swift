import Foundation

/// Minimal Sparkle appcast XML parser. Extracts the latest marketing version's
/// `sparkle:shortVersionString`, falling back to `sparkle:version` only when
/// the feed has no marketing versions.
///
/// Sparkle accepts both versions either as `<enclosure>` attributes (Sparkle 1
/// style) or as child elements of `<item>` (what Sparkle 2's `generate_appcast`
/// writes). Like Sparkle itself, the item element wins when both are present.
public final class AppcastParser: NSObject, XMLParserDelegate, @unchecked Sendable {
    private static let shortVersionKey = "sparkle:shortVersionString"
    private static let buildVersionKey = "sparkle:version"

    /// Keep marketing and build versions in separate domains. A build such as
    /// 4012 must never outrank a marketing version such as 2.1.0.
    private var bestShortVersion: String?
    private var bestShortDownloadURL: URL?
    private var bestBuildVersion: String?
    private var bestBuildDownloadURL: URL?
    private var inItem = false
    private var inDeltas = false
    private var currentDownloadURL: URL?
    private var currentAttributeShortVersion: String?
    private var currentAttributeBuildVersion: String?
    private var currentElementShortVersion: String?
    private var currentElementBuildVersion: String?
    /// Name of the item-level version element whose text is being collected.
    private var capturingElement: String?
    private var capturedText = ""

    public override init() { super.init() }

    public func parseLatestVersion(from data: Data) -> String? {
        parseLatestItem(from: data).version
    }

    public func parseLatestItem(from data: Data) -> (version: String?, downloadURL: URL?) {
        bestShortVersion = nil
        bestShortDownloadURL = nil
        bestBuildVersion = nil
        bestBuildDownloadURL = nil
        inItem = false
        resetCurrentItem()
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        let version = UpdateChecker.preferredAppcastVersion(
            shortVersion: bestShortVersion,
            buildVersion: bestBuildVersion
        )
        let downloadURL = bestShortVersion == nil
            ? bestBuildDownloadURL
            : bestShortDownloadURL
        return (version, downloadURL)
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String,
                       namespaceURI: String?, qualifiedName: String?,
                       attributes: [String: String] = [:]) {
        switch elementName {
        case "item":
            inItem = true
            resetCurrentItem()
        case "sparkle:deltas" where inItem:
            inDeltas = true
        case "enclosure" where inItem && !inDeltas:
            // Delta enclosures patch one specific older build, so only the
            // item's full enclosure is a usable download.
            if currentDownloadURL == nil {
                currentDownloadURL = attributes["url"].flatMap(URL.init(string:))
            }
            if currentAttributeShortVersion == nil {
                currentAttributeShortVersion = attributes[Self.shortVersionKey]
            }
            if currentAttributeBuildVersion == nil {
                currentAttributeBuildVersion = attributes[Self.buildVersionKey]
            }
        case Self.shortVersionKey where inItem && !inDeltas,
             Self.buildVersionKey where inItem && !inDeltas:
            capturingElement = elementName
            capturedText = ""
        default:
            break
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if capturingElement != nil { capturedText += string }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String,
                       namespaceURI: String?, qualifiedName: String?) {
        switch elementName {
        case "sparkle:deltas":
            inDeltas = false
        case Self.shortVersionKey where capturingElement == elementName:
            currentElementShortVersion = trimmedCapture()
        case Self.buildVersionKey where capturingElement == elementName:
            currentElementBuildVersion = trimmedCapture()
        case "item":
            finishItem()
        default:
            break
        }
    }

    private func trimmedCapture() -> String? {
        let text = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
        capturingElement = nil
        capturedText = ""
        return text.isEmpty ? nil : text
    }

    private func finishItem() {
        inItem = false
        // Keep the highest version across all items. Sparkle appcasts are NOT
        // guaranteed to list the newest release first (issue #105: taking the
        // first item offered downgrades), so compare every item's version.
        if let version = currentElementShortVersion ?? currentAttributeShortVersion,
           shouldReplace(bestShortVersion, with: version) {
            bestShortVersion = version
            bestShortDownloadURL = currentDownloadURL
        }
        if let version = currentElementBuildVersion ?? currentAttributeBuildVersion,
           shouldReplace(bestBuildVersion, with: version) {
            bestBuildVersion = version
            bestBuildDownloadURL = currentDownloadURL
        }
        resetCurrentItem()
    }

    private func shouldReplace(_ bestVersion: String?, with candidate: String) -> Bool {
        guard let bestVersion else { return true }
        return UpdateChecker.isNewer(candidate, than: bestVersion)
    }

    private func resetCurrentItem() {
        inDeltas = false
        currentDownloadURL = nil
        currentAttributeShortVersion = nil
        currentAttributeBuildVersion = nil
        currentElementShortVersion = nil
        currentElementBuildVersion = nil
        capturingElement = nil
        capturedText = ""
    }
}
