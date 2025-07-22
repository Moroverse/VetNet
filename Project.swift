// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:27 GMT.

import ProjectDescription

let project = Project(
    name: "VetNet",
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
            dependencies: [
                .external(name: "FactoryKit"),
                .external(name: "SwiftUIRouting"),
                .external(name: "Mockable"),
                .external(name: "QuickForm"),
                .external(name: "StateKit")
            ],
            settings:
            .settings(base: [
                "SWIFT_APPROACHABLE_CONCURRENCY": true,
                "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                "SWIFT_STRICT_CONCURRENCY": "Complete"
            ], configurations: [
                .debug(
                    name: "Debug",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG MOCKING"
                    ]
                )
            ])
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
                .external(name: "ViewInspector"),
                .external(name: "FactoryTesting"),
                .external(name: "TestKit")
            ]
        )
    ]
)
