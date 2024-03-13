// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWAESCrypt",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWAESCrypt", targets: ["WWAESCrypt"]),
    ],
    targets: [
        .target(name: "WWAESCrypt", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
