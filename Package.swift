// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "happyhome",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "happyhome", targets: ["happyhome"])
    ],
    targets: [
        .executableTarget(
            name: "happyhome",
            path: ".",
            exclude: [
                "happyhome.entitlements"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
