// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ModelExplorer",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        // Library for Xcode project to consume (iOS builds)
        .library(name: "ModelExplorerApp", targets: ["ModelExplorerApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0")
    ],
    targets: [
        // Executable for `swift run` and Swift Playgrounds (shares entry point with Xcode)
        .executableTarget(
            name: "ModelExplorer",
            dependencies: ["ModelExplorerApp"],
            path: "App",
            exclude: ["Assets.xcassets", "ModelExplorer.xcodeproj"],
            sources: ["AppMain.swift"]
        ),
        // Main app library (used by both executable and Xcode project)
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
