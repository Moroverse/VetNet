 import ProjectDescription

let project = Project(
    name: "VetNet",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.2",
            "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
            "MACOSX_DEPLOYMENT_TARGET": "26.0",
            "TARGETED_DEVICE_FAMILY": "1,2"
        ]
    ),
    targets: [
        .target(
            name: "VetNet",
            destinations: [.iPad, .iPhone, .mac],
            product: .app,
            bundleId: "com.moroverse.VetNet",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "CFBundleDisplayName": "VetNet",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ]
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
                .external(name: "FactoryKit"),
                .external(name: "SwiftUIRouting"),
                .external(name: "Mockable"),
                .external(name: "QuickForm"),
                .external(name: "StateKit"),
                .target(name: "PatientRecords")
            ],
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG MOCKING",
                            "SWIFT_APPROACHABLE_CONCURRENCY": true,
                            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                            "SWIFT_STRICT_CONCURRENCY": "Complete"
                        ]
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "SWIFT_APPROACHABLE_CONCURRENCY": true,
                            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                            "SWIFT_STRICT_CONCURRENCY": "Complete"
                        ]
                    )
                ]
                )
        ),
        .target(
            name: "PatientRecords",
            destinations: [.iPad, .iPhone, .mac],
            product: .framework,
            bundleId: "com.moroverse.VetNet.PatientRecords",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["Features/PatientRecords/**"],
            dependencies: [
                .external(name: "FactoryKit"),
                .external(name: "SwiftUIRouting"),
                .external(name: "QuickForm"),
                .external(name: "StateKit"),
                .external(name: "Mockable")
            ],
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG MOCKING",
                            "SWIFT_APPROACHABLE_CONCURRENCY": true,
                            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                            "SWIFT_STRICT_CONCURRENCY": "Complete"
                        ]
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "SWIFT_APPROACHABLE_CONCURRENCY": true,
                            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                            "SWIFT_STRICT_CONCURRENCY": "Complete"
                        ]
                    )
                ]
                )
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
                .target(name: "PatientRecords"),
                .external(name: "Mockable"),
                .external(name: "ViewInspector")
            ]
        ),
    ]
)
