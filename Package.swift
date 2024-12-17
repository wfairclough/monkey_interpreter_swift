// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Monkey",
    products: [
        .executable(
            name: "monkey",
            targets: ["Monkey"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.57.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Monkey",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            plugins: [
                .plugin(name: "swiftlint", package: "SwiftLint"),
            ]
        ),
        .testTarget(
            name: "MonkeyTests",
            dependencies: [
                "Monkey"
            ]
        ),
    ],
    swiftLanguageModes: [
        .v6
    ]
)
