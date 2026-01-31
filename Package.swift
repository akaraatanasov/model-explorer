// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ModelExplorer",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .macCatalyst(.v26)
    ],
    products: [
        // Library for Xcode project to consume
        .library(name: "ModelExplorerApp", targets: ["ModelExplorerApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0")
    ],
    targets: [
        // Main app library (used by Xcode project)
        .target(
            name: "ModelExplorerApp",
            dependencies: [
                "Shared",
                .target(name: "WebServer", condition: .when(platforms: [.macOS]))
            ],
            path: "Sources/ModelExplorer"
        ),
        .target(
            name: "WebServer",
            dependencies: [
                "Shared",
                .product(name: "Hummingbird", package: "hummingbird")
            ]
        ),
        .target(
            name: "Shared"
        )
    ]
)
