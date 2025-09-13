// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:27 GMT.

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "VetNet",
    packages: [
        .package(url: "https://github.com/Moroverse/quick-form", .upToNextMajor(from: "0.2.0")),
        .package(path: "Modules/SwiftUIRouting")
    ],
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
                        "UIImageName": ""
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
            scripts: [
                .pre(
                    script: .formatScript(),
                    name: "Format",
                    basedOnDependencyAnalysis: false
                ),
                .pre(
                    script: .lintScript(),
                    name: "Lint",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .external(name: "FactoryKit"),
                .package(product: "SwiftUIRouting"),
                .package(product: "QuickForm"),
                .external(name: "StateKit")
            ],
            settings:
            .settings(base: [
                "SWIFT_VERSION": "6.0",
                "SWIFT_APPROACHABLE_CONCURRENCY": true,
                "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                "SWIFT_STRICT_CONCURRENCY": "Complete",
                "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": true
            ], configurations: [])
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
                .external(name: "ViewInspector"),
                .external(name: "FactoryTesting"),
                .external(name: "TestKit"),
                .external(name: "ConcurrencyExtras"),
                .package(product: "QuickForm")
            ],
            settings:
            .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_APPROACHABLE_CONCURRENCY": true,
                    "SWIFT_STRICT_CONCURRENCY": "Complete",
                    "OTHER_SWIFT_FLAGS": "-enable-experimental-feature MacroExpansionDiagnostics"
                ],
                configurations: []
            )
        ),
        .target(
            name: "VetNetUITests",
            destinations: [.iPad, .iPhone],
            product: .uiTests,
            bundleId: "com.moroverse.VetNetUITests",
            infoPlist: .default,
            sources: ["App/UITests/**"],
            resources: [],
            dependencies: [
                .target(name: "VetNet")
            ],
            settings:
            .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_APPROACHABLE_CONCURRENCY": true,
                    "TEST_TARGET_NAME": "VetNet"
                ],
                configurations: []
            )
        )
    ]
)
