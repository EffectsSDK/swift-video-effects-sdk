// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TSVBPackage",
    products: [
        .library(
            name: "TSVBPackage",
            targets: ["TSVBPackage"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "TSVBPackage", dependencies: ["TSVB"]),
        .binaryTarget(
            name: "TSVB", 
            url: "https://github.com/EffectsSDK/swift-video-effects-sdk/releases/download/2.4.1/TSVB.xcframework-2.4.1.112582.zip",
            checksum: "ea1f7b25f916021f18ccf73600583a327a16e919c54a047bea9fe1e57c7986cf"

        )
    ]
)
