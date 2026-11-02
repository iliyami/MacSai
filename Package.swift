// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MacClean",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacClean", targets: ["MacClean"]),
        .executable(name: "MacCleanMenu", targets: ["MacCleanMenu"]),
        .executable(name: "MacSaiFanHelper", targets: ["MacSaiFanHelper"]),
        .library(name: "MacCleanKit", targets: ["MacCleanKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MacClean",
            dependencies: [
                "MacCleanKit",
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Sources/MacClean"
        ),
        .executableTarget(
            name: "MacCleanMenu",
            dependencies: ["MacCleanKit", "MacSaiSMC"],
            path: "Sources/MacCleanMenu"
        ),
        // Opt-in root LaunchDaemon for fan control (issue #242), nested in
        // the menu app by scripts/build-dmg.sh.
        .executableTarget(
            name: "MacSaiFanHelper",
            dependencies: ["MacCleanKit", "MacSaiSMC"],
            path: "Sources/MacSaiFanHelper"
        ),
        .target(
            name: "MacSaiSMC",
            dependencies: ["MacCleanKit"],
            path: "Sources/MacSaiSMC"
        ),
        .target(
            name: "MacCleanKit",
            dependencies: [],
            path: "Sources/MacCleanKit"
        ),
        .target(
            name: "MacCleanTestSupport",
            dependencies: ["MacCleanKit"],
            path: "Tests/MacCleanTestSupport"
        ),
        .testTarget(
            name: "MacCleanTests",
            dependencies: ["MacClean", "MacCleanKit", "MacCleanTestSupport"],
            path: "Tests/MacCleanTests"
        ),
        .testTarget(
            name: "MacCleanKitTests",
            dependencies: ["MacCleanKit", "MacCleanTestSupport"],
            path: "Tests/MacCleanKitTests"
        ),
    ]
)
