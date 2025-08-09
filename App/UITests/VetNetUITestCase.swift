// VetNetUITestCase.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-06 15:15 GMT.

import XCTest

/// Base class for all VetNet UI tests providing common setup and teardown
class VetNetUITestCase: XCTestCase {
    // MARK: - Properties

    /// The main application instance for testing
    private(set) var app: XCUIApplication! // swiftlint:disable:this test_case_accessibility

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Stop on first failure for faster debugging
        continueAfterFailure = false

        // Initialize and launch the app on main actor
        app = await Task { @MainActor in
            let application = XCUIApplication()

            // Set deterministic environment for UI tests
            application.launchArguments = [
                "UI_TESTING",
                "-AppleLanguages", "(en)",
                "-AppleLocale", "en_US_POSIX"
            ]

            // Set fixed date and timezone for deterministic behavior
            application.launchEnvironment = [
                "TZ": "UTC",
                "FIXED_DATE": "2023-08-09T08:00:00Z" // Fixed date: August 9, 2023, 8:00 AM UTC
            ]

            application.launch()
            return application
        }.value
    }

    override func tearDown() async throws {
        // Terminate the app on main actor
        if let app {
            Task { @MainActor in
                app.terminate()
            }
        }
        app = nil

        try await super.tearDown()
    }
}
