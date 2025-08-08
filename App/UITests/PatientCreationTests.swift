// PatientCreationTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-06 17:31 GMT.

import XCTest

/// Basic patient creation UI tests using navigation-based approach
final class PatientCreationTests: VetNetUITestCase {
    @MainActor
    func testCreatePatientHappyPath() async throws {
        // Navigate to patient creation (real user flow)
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        // Fill in patient details and save
        patientCreationScreen
            .enterPatientName("Buddy")
            .selectSpecies("Dog")
            .selectBreed("Labrador Retriever")
            .enterOwnerName("John Doe")
            .enterOwnerPhone("555-123-4567")
            .enterWeight("25.5") // Add valid weight for a Labrador
            .tapSave()

        // Verify success
        patientCreationScreen.assertPatientCreatedSuccessfully()
    }

    // MARK: - Phase 2: Form Validation Tests

    @MainActor
    func testEmptyNameValidation() async throws {
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        // Test: Empty name field should show validation error
        // Note: We don't need to tap save since validation appears immediately
        // and save button is disabled when form is invalid
        patientCreationScreen
            .enterPatientName("") // Empty name - validation should appear immediately
            .assertValidationError(for: "name", message: "This field cannot be empty")
    }

    @MainActor
    func testNameTooShortValidation() async throws {
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        // Test: Name too short should show validation error
        patientCreationScreen
            .enterPatientName("A") // One character - too short
            .assertValidationError(for: "name", message: "This field must be at least 2 characters long")
    }
}
