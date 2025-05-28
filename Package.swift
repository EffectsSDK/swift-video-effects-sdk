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
            url: "https://github.com/EffectsSDK/swift-video-effects-sdk/releases/download/2.5.1/TSVB.xcframework-iOS-2.5.1.112678-stable.zip",
            checksum: "d2e179f59906fdd450c0c2205c4e8ecf714ad1d5c1211355342d1b3b928bbcd5"
        )
    ]
)
