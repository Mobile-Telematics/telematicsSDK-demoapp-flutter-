// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "telematics_sdk",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "telematics-sdk", targets: ["telematics_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM.git", from: "7.0.3")
    ],
    targets: [
        .target(
            name: "telematics_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "TelematicsSDK", package: "telematicsSDK-iOS-new-SPM")
            ],
            resources: []
        )
    ]
)

