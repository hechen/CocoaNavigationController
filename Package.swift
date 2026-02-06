// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CocoaNavigationController",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CocoaNavigationController",
            targets: ["CocoaNavigationController"]
        ),
    ],
    targets: [
        .target(
            name: "CocoaNavigationController",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CocoaNavigationControllerTests",
            dependencies: ["CocoaNavigationController"],
            path: "Tests"
        ),
    ]
)
