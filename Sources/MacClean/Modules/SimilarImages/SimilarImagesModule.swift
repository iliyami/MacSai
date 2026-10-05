import Foundation
import MacCleanKit
import Vision
import CoreImage

public struct SimilarImagesModule: ScanModule {
    public let id = "similar_images"
    public var name: String { L10n.tr("相似图片", "Similar Images", "Похожие изображения") }
    public let category = ModuleCategory.files
    public let includedInSmartScan = false

    public init() {}

    public func scan() async -> [ScanResult] {
        return []
    }
}
