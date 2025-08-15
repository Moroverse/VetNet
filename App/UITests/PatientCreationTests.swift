// PatientCreationTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-06 17:31 GMT.

import XCTest

/// Basic patient creation UI tests using navigation-based approach
final class PatientCreationTests: VetNetUITestCase {
    @MainActor
    func testCreatePatientHappyPath() async throws {
        let app = makeApp()
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
        patientCreationScreen.assertPatientCreatedSuccessfully(id: "00000000-0000-0000-0000-000000000001")
    }

    // MARK: - Phase 2: Form Validation Tests

    @MainActor
    func testEmptyNameValidation() async throws {
        let app = makeApp()
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        patientCreationScreen
            // Test: Empty name field should show validation error
            // Note: We don't need to tap save since validation appears immediately
            // and save button is disabled when form is invalid
            .enterPatientName("") // Empty name - validation should appear immediately
            .assertValidationError(for: "name", message: "This field cannot be empty")
            // Test: Name too short should show validation error
            .enterPatientName("A") // One character - too short
            .assertValidationError(for: "name", message: "This field must be at least 2 characters long")
            // Test: Name too long should show validation error
            .enterPatientName(String(repeating: "A", count: 51)) // 51 characters - too long
            .assertValidationError(for: "name", message: "This field must not exceed 50 characters")
    }

    // MARK: - Phase 2.2: Birth Date Validation Tests

    @MainActor
    func testFutureBirthDateValidation() async throws {
        let app = makeApp()
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        // Test: Future birth date should show validation error
        // With fixed date "2023-08-09T08:00:00Z", validation message is deterministic
        patientCreationScreen
            .selectFutureBirthDate()
            .assertValidationError(for: "birthDate", message: "Date must be before 8/9/2023, 8:00 AM")
    }

    // MARK: - Phase 2.3: Species-Breed Dependency Tests

    @MainActor
    func testSpeciesBreedDependency() async throws {
        let app = makeApp()
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        // Test: Dog species should show dog breeds
        patientCreationScreen
            .selectSpecies("Dog")
            .assertBreedPickerContains(["Labrador Retriever", "German Shepherd"])

        // Test: Cat species should show cat breeds
        patientCreationScreen
            .selectSpecies("Cat")
            .assertBreedPickerContains(["Persian", "Siamese", "Maine Coon"])
    }

    // MARK: - Alert Testing

    @MainActor
    func testValidationError() async throws {
        // Launch app with validation_errors scenario - this makes patientCRUDRepository return duplicate key errors
        let app = makeApp(testScenario: "validation_errors")

        // Navigate to patient creation form
        let patientCreationScreen = app
            .navigateToPatientList()
            .tapCreateNewPatient()

        // Fill in patient details with valid data
        patientCreationScreen
            .enterPatientName("Buddy")
            .selectSpecies("Dog")
            .selectBreed("Labrador Retriever")
            .enterOwnerName("John Doe")
            .enterOwnerPhone("555-123-4567")
            .enterWeight("25.5") // Add valid weight for a Labrador

        // Trigger save - the Test Control Plane will make patientCRUDRepository return a duplicate key error
        patientCreationScreen
            .tapSave()
            .assertValidationAlert()
            .dismissAlert()
    }
}
