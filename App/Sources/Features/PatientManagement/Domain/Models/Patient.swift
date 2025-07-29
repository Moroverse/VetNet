// Patient.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:45 GMT.

import Foundation

// MARK: - Patient Domain Model

/// Pure Swift domain model representing a veterinary patient
/// Contains business logic and validation rules without persistence dependencies
struct Patient: Sendable, Identifiable, Hashable {
    // MARK: - Identity

    let id: ID

    // MARK: - Basic Information

    var name: String
    var species: Species
    var breed: Breed
    var birthDate: Date
    var weight: Measurement<UnitMass>

    // MARK: - Owner Information

    var ownerName: String
    var ownerPhoneNumber: String
    var ownerEmail: String?

    // MARK: - Medical Information

    let medicalID: String
    var microchipNumber: String?
    var notes: String?

    // MARK: - Metadata

    let createdAt: Date
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: ID = ID(),
        name: String,
        species: Species,
        breed: Breed,
        birthDate: Date,
        weight: Measurement<UnitMass>,
        ownerName: String,
        ownerPhoneNumber: String,
        ownerEmail: String? = nil,
        medicalID: String? = nil,
        microchipNumber: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.birthDate = birthDate
        self.weight = weight
        self.ownerName = ownerName
        self.ownerPhoneNumber = ownerPhoneNumber
        self.ownerEmail = ownerEmail
        self.medicalID = medicalID ?? MedicalIDGenerator.generateID(for: species, name: name)
        self.microchipNumber = microchipNumber
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Patient ID

extension Patient {
    struct ID: Sendable, Hashable, Identifiable {
        let value: UUID

        var id: UUID { value }

        init() {
            value = UUID()
        }

        init(_ uuid: UUID) {
            value = uuid
        }

        init(_ string: String) {
            value = UUID(uuidString: string) ?? UUID()
        }
    }
}

// MARK: - Business Logic

extension Patient {
    /// Calculate the patient's current age
    /// - Parameter currentDate: The date to calculate age from (defaults to current date)
    /// - Returns: Age components (years, months, days)
    func age(from currentDate: Date = Date()) -> AgeComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: currentDate)

        return AgeComponents(
            years: components.year ?? 0,
            months: components.month ?? 0,
            days: components.day ?? 0
        )
    }

    /// Get age as a human-readable string
    /// - Parameter currentDate: The date to calculate age from (defaults to current date)
    /// - Returns: Formatted age string (e.g., "2 years, 3 months")
    func ageDescription(from currentDate: Date = Date()) -> String {
        let ageComponents = age(from: currentDate)

        var parts: [String] = []

        if ageComponents.years > 0 {
            parts.append("\(ageComponents.years) year\(ageComponents.years == 1 ? "" : "s")")
        }

        if ageComponents.months > 0 {
            parts.append("\(ageComponents.months) month\(ageComponents.months == 1 ? "" : "s")")
        }

        if parts.isEmpty, ageComponents.days > 0 {
            parts.append("\(ageComponents.days) day\(ageComponents.days == 1 ? "" : "s")")
        }

        if parts.isEmpty {
            return "Newborn"
        }

        return parts.joined(separator: ", ")
    }

    /// Check if patient is considered a puppy/kitten/young based on species
    var isYoung: Bool {
        let ageInMonths = age().totalMonths

        switch species {
        case .dog:
            return ageInMonths < 12 // Under 1 year
        case .cat:
            return ageInMonths < 12 // Under 1 year
        case .bird:
            return ageInMonths < 6 // Under 6 months
        case .rabbit:
            return ageInMonths < 8 // Under 8 months
        case .other:
            return ageInMonths < 12 // Default to 1 year
        }
    }

    /// Validate patient data using ValidationRule pattern
    /// - Parameter validator: PatientValidator instance to use
    /// - Returns: True if all validation passes
    func isValid(using validator: PatientValidator = PatientValidator()) -> Bool {
        validator.isValidName(name) &&
            validator.isValidBirthDate(birthDate) &&
            validator.isValidBreed(breed, for: species) &&
            validator.isValidOwnerName(ownerName) &&
            validator.isValidPhoneNumber(ownerPhoneNumber) &&
            validator.isValidEmail(ownerEmail ?? "") &&
            validator.isValidMedicalID(medicalID) &&
            validator.isValidWeight(weight, for: species)
    }
}

// MARK: - Age Components

struct AgeComponents: Sendable, Hashable {
    let years: Int
    let months: Int
    let days: Int

    /// Total age in months (approximate)
    var totalMonths: Int {
        years * 12 + months
    }

    /// Total age in days (approximate)
    var totalDays: Int {
        years * 365 + months * 30 + days
    }
}
