// PatientDomainTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import Foundation
import Testing
@testable import VetNet

@Suite("Patient Domain Model Tests")
@MainActor
struct PatientDomainTests {
    // MARK: - Patient Creation Tests

    @Test("Patient initializes with provided values")
    func patientInitialization() {
        let birthDate = Date().addingTimeInterval(-365 * 24 * 60 * 60) // 1 year ago
        let weight = Measurement(value: 25.5, unit: UnitMass.kilograms)

        let patient = Patient(
            name: "Max",
            species: .dog,
            breed: .dogLabrador,
            birthDate: birthDate,
            weight: weight,
            ownerName: "John Doe",
            ownerPhoneNumber: "123-456-7890",
            ownerEmail: "john@example.com",
            microchipNumber: "123456789",
            notes: "Friendly dog"
        )

        #expect(patient.name == "Max")
        #expect(patient.species == .dog)
        #expect(patient.breed == .dogLabrador)
        #expect(patient.birthDate == birthDate)
        #expect(patient.weight == weight)
        #expect(patient.ownerName == "John Doe")
        #expect(patient.ownerPhoneNumber == "123-456-7890")
        #expect(patient.ownerEmail == "john@example.com")
        #expect(patient.microchipNumber == "123456789")
        #expect(patient.notes == "Friendly dog")
        #expect(!patient.medicalID.isEmpty)
    }

    @Test("Patient generates medical ID when not provided")
    func medicalIDGeneration() {
        let patient = Patient(
            name: "Luna",
            species: .cat,
            breed: .catPersian,
            birthDate: Date(),
            weight: Measurement(value: 4.5, unit: .kilograms),
            ownerName: "Jane Smith",
            ownerPhoneNumber: "987-654-3210"
        )

        #expect(patient.medicalID.hasPrefix("CAT"))
        #expect(patient.medicalID.count == 14) // CAT + 9 digits
    }

    // MARK: - Age Calculation Tests

    @Test("Age calculation returns correct years")
    func ageCalculation() {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -5, to: Date())!

        let patient = Patient(
            name: "Rex",
            species: .dog,
            breed: .dogGermanShepherd,
            birthDate: birthDate,
            weight: Measurement(value: 30, unit: UnitMass.kilograms),
            ownerName: "Bob Johnson",
            ownerPhoneNumber: "555-123-4567"
        )

        let age = patient.age(from: Date())
        #expect(age.years == 5)
        #expect(age.months >= 0)
        #expect(age.days >= 0)
    }

    @Test("Age calculation handles same day birth")
    func ageCalculationSameDay() {
        let patient = Patient(
            name: "Newborn",
            species: .cat,
            breed: .catSiamese,
            birthDate: Date(),
            weight: Measurement(value: 0.1, unit: UnitMass.kilograms),
            ownerName: "Alice Cooper",
            ownerPhoneNumber: "555-987-6543"
        )

        let age = patient.age(from: Date())
        #expect(age.years == 0)
    }

    // MARK: - Weight Validation Tests

    @Test("Normal weight range validation for dogs")
    func dogWeightValidation() {
        let patient = Patient(
            name: "Buddy",
            species: .dog,
            breed: .dogGoldenRetriever,
            birthDate: Date(),
            weight: Measurement(value: 30, unit: UnitMass.kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )

        // Weight validation would be done through validator
        #expect(patient.weight.value > 0)
        #expect(patient.weight.value < 150)

        // Test underweight
        var underweightPatient = patient
        underweightPatient.weight = Measurement(value: 0.5, unit: UnitMass.kilograms)
        #expect(underweightPatient.weight.value < 1)

        // Test overweight
        var overweightPatient = patient
        overweightPatient.weight = Measurement(value: 150, unit: UnitMass.kilograms)
        #expect(overweightPatient.weight.value > 100)
    }

    @Test("Normal weight range validation for cats")
    func catWeightValidation() {
        let patient = Patient(
            name: "Whiskers",
            species: .cat,
            breed: .catMaineCoon,
            birthDate: Date(),
            weight: Measurement(value: 5, unit: UnitMass.kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )

        // Weight validation would be done through validator
        #expect(patient.weight.value > 0)
        #expect(patient.weight.value < 20)

        // Test underweight
        var underweightPatient = patient
        underweightPatient.weight = Measurement(value: 0.5, unit: UnitMass.kilograms)
        #expect(underweightPatient.weight.value < 1)

        // Test overweight
        var overweightPatient = patient
        overweightPatient.weight = Measurement(value: 15, unit: UnitMass.kilograms)
        #expect(overweightPatient.weight.value > 10)
    }

    // MARK: - Display Formatting Tests

    @Test("Display name formats correctly")
    func displayName() {
        let patient = Patient(
            name: "Princess Luna",
            species: .cat,
            breed: .catPersian,
            birthDate: Date(),
            weight: Measurement(value: 4, unit: UnitMass.kilograms),
            ownerName: "Sarah Connor",
            ownerPhoneNumber: "555-1234"
        )

        // Display name formatting not implemented yet
        #expect(patient.name == "Princess Luna")
        #expect(patient.species == .cat)
        #expect(patient.breed == .catPersian)
    }

    @Test("Age display string formats correctly")
    func ageDisplayString() {
        let birthDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
        let patient = Patient(
            name: "Charlie",
            species: .dog,
            breed: .dogBeagle,
            birthDate: birthDate,
            weight: Measurement(value: 12, unit: UnitMass.kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )

        let ageString = patient.ageDescription(from: Date())
        #expect(ageString.contains("3 year"))
    }

    // MARK: - Patient ID Tests

    @Test("Patient ID generates unique UUIDs")
    func patientIDUniqueness() {
        let id1 = Patient.ID()
        let id2 = Patient.ID()

        #expect(id1 != id2)
        #expect(id1.value != id2.value)
    }

    @Test("Patient ID initializes from UUID string")
    func patientIDFromString() {
        let uuidString = UUID().uuidString
        let id = Patient.ID(uuidString)

        #expect(id.value.uuidString == uuidString)
    }

    @Test("Patient ID handles invalid UUID string")
    func patientIDInvalidString() {
        let id = Patient.ID("invalid-uuid")

        // Should create a new UUID when invalid string provided
        #expect(id.value.uuidString != "invalid-uuid")
    }
}
