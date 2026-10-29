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
        .library(name: "MacCleanKit", targets: ["MacCleanKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1"),
    ],
    targets: [
        .executableTarget(
            name: "MacClean",
            dependencies: [
                "MacCleanKit",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "Sources/MacClean",
            linkerSettings: [.unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])]
        ),
        .executableTarget(
            name: "MacCleanMenu",
            dependencies: ["MacCleanKit"],
            path: "Sources/MacCleanMenu"
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
