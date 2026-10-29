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
            url: "https://github.com/EffectsSDK/swift-video-effects-sdk/releases/download/2.6.0/TSVB.xcframework-iOS-2.6.0.118560-stable.zip",
            checksum: "03dcde7c55565b5d506273967faa2cc26dcbbb40937d37c20baa6e8fe1abc2a9"
        )
    ]
)
