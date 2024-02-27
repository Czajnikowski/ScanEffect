// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScanEffect",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ScanEffect",
            targets: ["ScanEffect"]
        ),
    ],
    targets: [
        .target(
            name: "ScanEffect",
            resources: [.process("Shaders/ScanEffect.metal")]
        ),
    ]
)
