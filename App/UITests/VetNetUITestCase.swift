// VetNetUITestCase.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-06 15:15 GMT.

import XCTest

/// Base class for all VetNet UI tests providing common setup and teardown
class VetNetUITestCase: XCTestCase {
    // MARK: - Properties

    /// The main application instance for testing
    var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        // Stop on first failure for faster debugging
        continueAfterFailure = false

        // Initialize and launch the app on main actor
        app = await Task { @MainActor in
            let application = XCUIApplication()
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
