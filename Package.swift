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
            url: "https://github.com/EffectsSDK/swift-video-effects-sdk/releases/download/2.5.0/TSVB.xcframework-iOS-2.5.0.112667-stable.zip",
            checksum: "e0b9a6048fd5139d4b1f1f05a22b7a195a0a13f33184212a242d00a9dee53d1f"
        )
    ]
)
