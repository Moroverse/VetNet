// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: ["FactoryKit": .framework, "StateKit": .framework, "SwiftUIRouting": .framework]
    )
#endif

let package = Package(
    name: "VetNet",
    dependencies: [
        // Forms
        .package(url: "https://github.com/Moroverse/quick-form", from: "0.1.2"),
        // View State
        .package(url: "https://github.com/Moroverse/state-kit", from: "0.6.1"),
        // Dependency Injection
        .package(url: "https://github.com/hmlongco/Factory.git", branch: "develop"),
        // Custom Navigation
        .package(path: "../Modules/SwiftUIRouting"),
        // Testing
        .package(url: "https://github.com/Kolos65/Mockable", from: "0.4.0"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.2"),
        .package(url: "https://github.com/Moroverse/test-kit.git", from: "0.3.10")
    ]
)
