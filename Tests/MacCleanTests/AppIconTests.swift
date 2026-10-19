import XCTest
import Foundation
import ImageIO
import CoreGraphics

/// Guards issue #248: the app icon must be transparent outside its rounded
/// shape. An opaque icon shows a black square behind it in the Dock,
/// Launchpad, and Finder.
final class AppIconTests: XCTestCase {

    private var repoRoot: URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    /// Every representation in the shipped .icns, plus the README icon.
    private func iconImages() throws -> [(name: String, image: CGImage)] {
        var images: [(String, CGImage)] = []
        let icns = repoRoot.appending(path: "Resources/AppIcon.icns")
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(icns as CFURL, nil), "AppIcon.icns is missing")
        for index in 0..<CGImageSourceGetCount(source) {
            let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, index, nil))
            images.append(("AppIcon.icns #\(index) (\(image.width)px)", image))
        }
        let readmeIcon = repoRoot.appending(path: "assets/app_icon.png")
        let png = try XCTUnwrap(CGImageSourceCreateWithURL(readmeIcon as CFURL, nil), "assets/app_icon.png is missing")
        images.append(("assets/app_icon.png", try XCTUnwrap(CGImageSourceCreateImageAtIndex(png, 0, nil))))
        return images
    }

    /// Alpha of the pixel at (x, y), drawn into a known RGBA layout.
    private func alpha(of image: CGImage, x: Int, y: Int) -> UInt8 {
        let width = image.width, height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let context = CGContext(
            data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels[(y * width + x) * 4 + 3]
    }

    func testIconCornersAreTransparent() throws {
        let images = try iconImages()
        XCTAssertGreaterThanOrEqual(images.count, 2)
        for (name, image) in images {
            let last = image.width - 1
            for (x, y) in [(0, 0), (last, 0), (0, last), (last, last)] {
                XCTAssertEqual(alpha(of: image, x: x, y: y), 0, "\(name): corner (\(x), \(y)) is not transparent")
            }
        }
    }

    func testIconBodyIsOpaque() throws {
        for (name, image) in try iconImages() {
            XCTAssertEqual(alpha(of: image, x: image.width / 2, y: image.height / 2), 255, "\(name): center is not opaque")
        }
    }
}
