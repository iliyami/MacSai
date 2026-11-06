import XCTest
@testable import MacClean
import MacCleanKit

final class DockerDiskImageSafetyTests: XCTestCase {
    func testDiskImagePathsPointAtDockerDesktopsVirtualDisk() {
        let paths = MCConstants.dockerDesktopDiskImages.map { $0.path(percentEncoded: false) }
        XCTAssertEqual(paths.map { ($0 as NSString).lastPathComponent }, ["Docker.raw", "Docker.qcow2"])
        XCTAssertTrue(paths.allSatisfy { $0.hasSuffix("/Library/Containers/com.docker.docker/Data/vms/0/data/" + ($0 as NSString).lastPathComponent) })
    }

    /// The disk image holds every image, container, and volume, so it is only
    /// ever reported on the Disk Hogs screen. No System Junk target may reach it.
    func testNoJunkCategoryTargetsTheDiskImage() {
        for category in SystemJunkModule.allCategories {
            for target in category.targets {
                let root = target.path.path(percentEncoded: false)
                for image in MCConstants.dockerDesktopDiskImages {
                    XCTAssertFalse(
                        PathExclusion.isInside(image.path(percentEncoded: false), root: root),
                        "\(category.scanCategory) target \(root) would reach \(image.path)"
                    )
                }
            }
        }
    }
}
