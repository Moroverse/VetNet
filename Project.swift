 import ProjectDescription

let project = Project(
    name: "VetNet",
    targets: [
        .target(
            name: "VetNet",
            destinations: [.iPad, .iPhone, .mac],
            product: .app,
            bundleId: "com.moroverse.VetNet",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "CFBundleDisplayName": "VetNet",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "SWIFT_APPROACHABLE_CONCURRENCY": true,
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_STRICT_CONCURRENCY": "Complete"
                ]
            ),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            entitlements: .dictionary([
                "com.apple.developer.icloud-services": .array(["CloudKit"]),
                "com.apple.developer.icloud-container-identifiers": .array(["iCloud.com.moroverse.VetNet"]),
                "com.apple.developer.ubiquity-kvstore-identifier": "$(TeamIdentifierPrefix)$(CFBundleIdentifier)",
                "com.apple.security.app-sandbox": true,
                "com.apple.security.network.client": true,
                "com.apple.security.files.user-selected.read-write": true
            ]),
            dependencies: [
                .external(name: "Factory"),
                .external(name: "SwiftUIRouting"),
                .external(name: "Mockable"),
            ]
        ),
        .target(
            name: "VetNetTests",
            destinations: [.iPad, .iPhone],
            product: .unitTests,
            bundleId: "com.moroverse.VetNetTests",
            infoPlist: .default,
            sources: ["App/Tests/**"],
            resources: [],
            dependencies: [
                .target(name: "VetNet"),
                .external(name: "Mockable"),
                .external(name: "ViewInspector")
            ]
        ),
    ]
)
