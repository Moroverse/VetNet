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
             .selectBreed("Labrador")
             .enterOwnerName("John Doe")
             .enterOwnerPhone("555-123-4567")
             .tapSave()

         // Verify success
         patientCreationScreen.assertPatientCreatedSuccessfully()
     }
}
