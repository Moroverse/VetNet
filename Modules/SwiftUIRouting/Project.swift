// Project.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:27 GMT.

import ProjectDescription

let project = Project(
    name: "PatientManagementExample",
    packages: [
        .package(path: "./")
    ],
    targets: [
        .target(
            name: "PatientManagementExample",
            destinations: [.iPad, .iPhone],
            product: .app,
            bundleId: "com.moroverse.PatientManagementExample",
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
            sources: ["Example/Sources/**"],
            resources: ["Example/Resources/**"],
            dependencies: [
                .package(product: "SwiftUIRouting")
            ],
            settings:
            .settings(base: [
                "SWIFT_VERSION": "6.0",
                "SWIFT_APPROACHABLE_CONCURRENCY": true,
                "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                "SWIFT_STRICT_CONCURRENCY": "Complete",
                "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": true
            ], configurations: [
                .debug(
                    name: "Debug",
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG MOCKING"
                    ]
                )
            ])
        )
    ]
)
