// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TarotDeckCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "TarotDeckCore",
            targets: ["TarotDeckCore"]
        )
    ],
    targets: [
        .target(name: "TarotDeckCore"),
        .testTarget(
            name: "TarotDeckCoreTests",
            dependencies: ["TarotDeckCore"]
        )
    ]
)
