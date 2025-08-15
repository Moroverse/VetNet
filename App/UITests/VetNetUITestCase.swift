// VetNetUITestCase.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-06 15:15 GMT.

import XCTest

/// Base class for all VetNet UI tests providing common setup and teardown
class VetNetUITestCase: XCTestCase {
    // MARK: - Properties

    /// The main application instance for testing
    private var app: XCUIApplication?

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Stop on first failure for faster debugging
        continueAfterFailure = false
    }

    override func tearDown() async throws {
        // Terminate the app on main actor
        if let app {
            await Task { @MainActor in
                app.terminate()
            }.value
        }
        app = nil

        try await super.tearDown()
    }

    // MARK: - App Creation

    /// Creates and launches an XCUIApplication with specified test configuration
    /// - Parameters:
    ///   - testScenario: Optional test scenario ID to activate
    ///   - additionalArguments: Additional launch arguments for the test
    /// - Returns: Configured and launched XCUIApplication
    @MainActor // swiftlint:disable:this test_case_accessibility
    func makeApp(testScenario: String? = nil, additionalArguments: [String] = []) -> XCUIApplication {
        // Terminate existing app if any
        if let existingApp = app {
            existingApp.terminate()
        }

        let application = XCUIApplication()

        // Set basic UI test arguments
        var launchArguments = [
            "UI_TESTING",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US_POSIX"
        ]

        // Use fixed_date scenario by default for deterministic behavior
        // This ensures all tests have predictable dates without FIXED_DATE environment variable
        let effectiveScenario = testScenario ?? "fixed_date"
        launchArguments.append(contentsOf: ["-TEST_SCENARIO", effectiveScenario])

        // Add any additional test-specific arguments
        launchArguments.append(contentsOf: additionalArguments)

        application.launchArguments = launchArguments

        // Set timezone for deterministic behavior (keep this as it's still useful)
        application.launchEnvironment = [
            "TZ": "UTC"
        ]

        application.launch()

        // Store reference for teardown
        app = application

        return application
    }
}
