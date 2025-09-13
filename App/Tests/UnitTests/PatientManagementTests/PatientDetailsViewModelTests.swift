// PatientDetailsViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-13 15:33 GMT.

import FactoryKit
import Foundation
import Testing
@testable import VetNet

// MARK: - Patient Details View Model Tests

/// Unit tests for PatientDetailsViewModel
/// Following TDD: Red → Green → Refactor
@Suite("Patient Details View Model Tests")
struct PatientDetailsViewModelTests {
    @Test("View model formats age display correctly for exact years")
    @MainActor
    func formatsAgeDisplayExactYears() {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000) // Nov 14, 2023
        Container.shared.dateProvider.register { MockDateProvider(date: fixedDate) }

        let patient = Patient(
            name: "Bella",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date(timeIntervalSince1970: 1_605_312_000), // Nov 14, 2020 (exactly 3 years before)
            weight: Measurement(value: 25.5, unit: .kilograms),
            ownerName: "John Smith",
            ownerPhoneNumber: "+1-555-0123",
            ownerEmail: "john.smith@example.com",
            medicalID: "DOG-001"
        )

        // When
        let viewModel = PatientDetailsViewModel(patient: patient)

        // Then
        #expect(viewModel.ageDisplay == "3 years")
    }

    @Test("View model formats age display for young animals")
    @MainActor
    func formatsAgeDisplayYoungAnimals() {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000) // Nov 14, 2023
        Container.shared.dateProvider.register { MockDateProvider(date: fixedDate) }

        // Create a date 2 months before fixedDate using calendar
        let calendar = Calendar.current
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: fixedDate)!

        let patient = Patient(
            name: "Puppy",
            species: .dog,
            breed: .dogLabrador,
            birthDate: twoMonthsAgo,
            weight: Measurement(value: 5.5, unit: .kilograms),
            ownerName: "Jane Doe",
            ownerPhoneNumber: "+1-555-0124",
            ownerEmail: "jane.doe@example.com",
            medicalID: "DOG-002"
        )

        // When
        let viewModel = PatientDetailsViewModel(patient: patient)

        // Then
        #expect(viewModel.ageDisplay == "2 months")
    }
}

// MARK: - Test Helpers

private struct MockDateProvider: DateProvider {
    let date: Date
    let calendar: Calendar

    init(date: Date, calendar: Calendar = .current) {
        self.date = date
        self.calendar = calendar
    }

    func now() -> Date {
        date
    }
}
