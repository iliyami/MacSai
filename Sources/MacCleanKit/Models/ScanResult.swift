import Foundation

public struct ScanResult: Sendable {
    public let category: ScanCategory
    public var items: [FileItem]
    public let autoSelect: Bool

    public init(category: ScanCategory, items: [FileItem], autoSelect: Bool = true) {
        self.category = category
        self.items = items
        self.autoSelect = autoSelect
    }

    public var totalSize: UInt64 {
        items.reduce(0) { $0 + $1.size }
    }

    public var fileCount: Int {
        items.count
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
    }
}

public struct ModuleScanResult: Sendable {
    public let moduleID: String
    public let moduleName: String
    public var categories: [ScanResult]
    public let scanDuration: TimeInterval

    public init(moduleID: String, moduleName: String, categories: [ScanResult], scanDuration: TimeInterval) {
        self.moduleID = moduleID
        self.moduleName = moduleName
        self.categories = categories
        self.scanDuration = scanDuration
    }

    public var totalSize: UInt64 {
        categories.reduce(0) { $0 + $1.totalSize }
    }

    public var totalFileCount: Int {
        categories.reduce(0) { $0 + $1.fileCount }
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
    }
}

public extension Array where Element == ScanResult {
    /// What a results screen checks when a scan finishes: every item of the
    /// categories that ask for it (`autoSelect`) and nothing else, so items
    /// listed for review start unchecked.
    var preselectedURLs: Set<URL> {
        Set(filter(\.autoSelect).flatMap { $0.items.map(\.url) })
    }
}
