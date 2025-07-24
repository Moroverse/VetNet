// PatientValidator.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:58 GMT.

import Foundation
import QuickForm

// MARK: - Patient Validator

final class PatientValidator: Sendable {
    private let dateProvider: DateProvider

    init(dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }

    // MARK: - Individual Field Validation

    func isValidName(_ name: String) -> Bool {
        nameValidation.validate(name) == .success
    }

    func isValidBirthDate(_ birthDate: Date) -> Bool {
        birthdayValidation.validate(birthDate) == .success
    }

    func isValidWeight(_ weight: Measurement<UnitMass>, for species: Species) -> Bool {
        weightValidation(for: species).validate(weight) == .success
    }

    func isValidBreed(_ breed: Breed, for species: Species) -> Bool {
        breedValidation(for: species).validate(breed) == .success
    }

    func isValidOwnerName(_ name: String) -> Bool {
        ownerNameValidation.validate(name) == .success
    }

    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        phoneNumberValidation.validate(phoneNumber) == .success
    }

    func isValidEmail(_ email: String) -> Bool {
        emailValidation.validate(email) == .success
    }

    func isValidMedicalID(_ medicalID: String) -> Bool {
        medicalIDValidation.validate(medicalID) == .success
    }
}

// MARK: - Validation Rules

extension PatientValidator {
    var nameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(50),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-")))
        )
    }

    var birthdayValidation: AnyValidationRule<Date> {
        .combined(
            MaxDateRule(dateProvider),
            MaxDateRangeRule(maxRange: .init(year: -30), dateProvider)
        )
    }

    func weightValidation(for species: Species) -> AnyValidationRule<Measurement<UnitMass>> {
        .of(SpeciesMaxWeightRangeRule(species))
    }

    func breedValidation(for species: Species) -> AnyValidationRule<Breed> {
        .of(SpeciesBreedValidationRule(species))
    }

    var ownerNameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(100),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-.")))
        )
    }

    var phoneNumberValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            PhoneNumberValidationRule()
        )
    }

    var emailValidation: AnyValidationRule<String?> {
        // Use QuickForm's built-in email validation
        .of(OptionalRule.ifPresent(.email))
    }

    var medicalIDValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            MedicalIDValidationRule()
        )
    }
}

// MARK: - Date Ranges

extension PatientValidator {
    /// Valid birth date range for patient creation
    var birthDateRange: ClosedRange<Date> {
        let now = dateProvider.now()
        let thirtyYearsAgo = dateProvider.calendar.date(byAdding: .year, value: -30, to: now) ?? now
        return thirtyYearsAgo ... now
    }
}
