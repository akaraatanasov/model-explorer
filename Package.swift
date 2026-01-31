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
        .executable(name: "ModelExplorer", targets: ["ModelExplorer"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ModelExplorer",
            dependencies: [
                "Shared",
                .target(name: "WebServer", condition: .when(platforms: [.macOS]))
            ]
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
