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
            url: "https://github.com/EffectsSDK/swift-video-effects-sdk/releases/download/2.4.0/TSVB.xcframework-2.4.0.112360.zip",
            checksum: "c9185ed39059c34895726e9c26e137e99fd9ad53f3fdb1b2c8419e0724da7988"

        )
    ]
)
