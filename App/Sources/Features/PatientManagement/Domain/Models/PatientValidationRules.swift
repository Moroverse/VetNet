// PatientValidationRules.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:44 GMT.

import Foundation
import QuickForm

// MARK: - Date Validation Rules

struct MaxDateRule: ValidationRule {
    let dateProvider: DateProvider

    init(_ dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }

    func validate(_ value: Date) -> ValidationResult {
        if value > dateProvider.now() {
            .failure("Date must be before \(dateProvider.now().formatted())")
        } else {
            .success
        }
    }
}

struct MaxDateRangeRule: ValidationRule {
    let dateProvider: DateProvider
    let range: DateComponents

    init(maxRange: DateComponents, _ dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
        range = maxRange
    }

    func validate(_ value: Date) -> ValidationResult {
        guard let minDate = dateProvider.calendar.date(byAdding: range, to: dateProvider.now()) else {
            return .failure("Invalid date range")
        }

        let result = dateProvider.calendar.compare(value, to: minDate, toGranularity: .second)
        switch result {
        case .orderedDescending, .orderedSame:
            return .success
        case .orderedAscending:
            return .failure("Date must be after \(minDate.formatted())")
        }
    }
}

// MARK: - String Validation Rules

struct AllowedCharactersRule: ValidationRule {
    let allowedCharacters: CharacterSet

    init(_ allowedCharacters: CharacterSet) {
        self.allowedCharacters = allowedCharacters
    }

    func validate(_ value: String) -> ValidationResult {
        let filteredText = value.filter { char in
            let unicodeScalars = String(char).unicodeScalars
            return !unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        }

        if filteredText.isEmpty {
            return .success
        } else {
            return .failure("Contains invalid characters: \(filteredText)")
        }
    }
}

// MARK: - Medical ID Validation Rule

struct MedicalIDValidationRule: ValidationRule {
    func validate(_ value: String) -> ValidationResult {
        if MedicalIDGenerator.isValidFormat(value) {
            .success
        } else {
            .failure("Invalid medical ID format")
        }
    }
}

// MARK: - Weight Validation Rules

struct SpeciesMaxWeightRangeRule: ValidationRule {
    let species: Species

    init(_ species: Species) {
        self.species = species
    }

    func validate(_ value: Measurement<UnitMass>) -> ValidationResult {
        let weightInKg = value.converted(to: .kilograms).value
        let range = species.typicalWeightRange

        if range.contains(weightInKg) {
            return .success
        } else if weightInKg < range.lowerBound {
            return .failure("\(species.displayName)s must weigh at least \(range.lowerBound)kg")
        } else {
            return .failure("\(species.displayName)s must weigh no more than \(range.upperBound)kg")
        }
    }
}

// MARK: - Breed Validation Rules

struct SpeciesBreedValidationRule: ValidationRule {
    let species: Species

    init(_ species: Species) {
        self.species = species
    }

    func validate(_ value: Breed) -> ValidationResult {
        if species.availableBreeds.contains(value) {
            .success
        } else {
            .failure("'\(value.displayName)' is not a valid breed for \(species.displayName)")
        }
    }
}

// MARK: - Phone Number Validation Rule

struct PhoneNumberValidationRule: ValidationRule {
    func validate(_ value: String) -> ValidationResult {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        // Allow various phone number formats
        let phoneRegex = #"^[\+]?[(]?[\d\s\-\(\)\.]{10,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)

        if predicate.evaluate(with: trimmed) {
            return .success
        } else {
            return .failure("Invalid phone number format")
        }
    }
}
