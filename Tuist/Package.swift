// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "VetNet",
    dependencies: [
        // Dependency Injection
        .package(url: "https://github.com/hmlongco/Factory", from: "2.3.0"),
        // Custom Navigation
        .package(path: "../Modules/SwiftUIRouting"),
        // Testing
        .package(url: "https://github.com/Kolos65/Mockable", from: "0.0.9"),
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.0")
    ]
)
