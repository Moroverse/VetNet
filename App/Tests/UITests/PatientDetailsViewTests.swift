// PatientDetailsViewTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-13 09:25 GMT.

import Foundation
import Testing
@testable import VetNet
import ViewInspector

// MARK: - Patient Details View Tests

/// Unit tests for PatientDetailsView using ViewInspector
/// Following TDD: Red → Green → Refactor
@Suite("Patient Details View Tests")
struct PatientDetailsViewTests {
    @Test("Patient details view displays basic patient information")
    @MainActor
    func displaysBasicPatientInformation() throws {
        // Given
        let patient = Patient(
            name: "Bella",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
            weight: Measurement(value: 25.5, unit: .kilograms),
            ownerName: "John Smith",
            ownerPhoneNumber: "+1-555-0123",
            ownerEmail: "john.smith@example.com",
            medicalID: "DOG-001"
        )

        // When
        let view = PatientDetailsView(patient: patient)

        // Then
        let inspection = try view.inspect()

        // Check that the patient name is displayed
        _ = try inspection.find(text: "Bella")

        // Check that the species is displayed
        _ = try inspection.find(text: "Dog")

        // Check that the medical ID is displayed
        _ = try inspection.find(text: "DOG-001")
    }

    @Test("Patient details view displays owner information")
    @MainActor
    func displaysOwnerInformation() throws {
        // Given
        let patient = Patient(
            name: "Luna",
            species: .cat,
            breed: .catPersian,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years old
            weight: Measurement(value: 4.5, unit: .kilograms),
            ownerName: "Emily Wilson",
            ownerPhoneNumber: "+1-555-0125",
            ownerEmail: "emily.w@example.com",
            medicalID: "CAT-001"
        )

        // When
        let view = PatientDetailsView(patient: patient)

        // Then
        let inspection = try view.inspect()

        // Check that owner information is displayed
        _ = try inspection.find(text: "Emily Wilson")
        _ = try inspection.find(text: "+1-555-0125")
        _ = try inspection.find(text: "emily.w@example.com")
    }
}
