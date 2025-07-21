// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIRouting",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftUIRouting",
            targets: ["SwiftUIRouting"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // No external dependencies - pure SwiftUI + Foundation implementation
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "SwiftUIRouting",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftUIRoutingTests",
            dependencies: ["SwiftUIRouting"]
        )
    ]
)
