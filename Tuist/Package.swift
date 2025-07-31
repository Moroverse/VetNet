// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            "FactoryKit": .framework,
            "StateKit": .framework,
            "SwiftUIRouting": .framework,
            "ConcurrencyExtras": .framework,
            "IssueReporting": .framework,
            "IssueReportingPackageSupport": .framework
        ]
    )
#endif

let package = Package(
    name: "VetNet",
    dependencies: [
        // Forms
        //.package(url: "https://github.com/Moroverse/quick-form", branch: "develop"),
        // View State
        .package(url: "https://github.com/Moroverse/state-kit", from: "0.6.1"),
        // Dependency Injection
        .package(url: "https://github.com/hmlongco/Factory.git", branch: "develop"),
        // Custom Navigation
        //.package(path: "../Modules/SwiftUIRouting"),
        // Testing
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras.git", from: "1.3.1"),
        .package(url: "https://github.com/Kolos65/Mockable", from: "0.4.0"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.2"),
        .package(url: "https://github.com/Moroverse/test-kit.git", branch: "develop")
    ]
)
