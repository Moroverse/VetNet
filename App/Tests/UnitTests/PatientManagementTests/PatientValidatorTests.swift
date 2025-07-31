// PatientValidatorTests.swift
// Copyright (c) 2025 Moroverse
// VetNet Patient Validator Tests

import Testing
import Foundation
import SwiftUI
import QuickForm
@testable import VetNet

@Suite("Patient Validator Tests")
@MainActor
struct PatientValidatorTests {

    private func makeSUT(calendar: Calendar = .current, date: Date = Date()) -> PatientValidator {
        let dateProvider = MockDateProvider(calendar: calendar, currentDate: date)
        return PatientValidator(dateProvider: dateProvider)
    }

    // MARK: - Name Validation Tests
    
    @Test(arguments: [
        "Max",
        "Princess Luna",
        "Charlie Brown",
        "Mr. Whiskers",
        "Rex Jr.",
        "Buddy-Boy"
    ])
    func testValidName(_ name: String) {
        let result = makeSUT().nameValidation.validate(name)
        #expect(result == .success, "Name '\(name)' should be valid")
    }
    
    @Test(arguments: [
        ("", "This field cannot be empty"),
        ("A", "This field must be at least 2 characters long"),
        (String(repeating: "A", count: 51), "This field must not exceed 50 characters"),
        ("  ", "This field contains only whitespace characters")
    ])
    func testInvalidName(_ name: String, _ expectedError: String) {
        let result = makeSUT().nameValidation.validate(name)
        if case .failure(var error) = result {
            error.locale = Locale(identifier: "en_US")
            #expect(String(localized: error) == expectedError, "Name '\(name)' should fail with expected error")
        } else {
            #expect(Bool(false), "Name '\(name)' should be invalid")
        }
    }
    
    // MARK: - Birth Date Validation Tests
    
    @Test(arguments: [
            Date(timeIntervalSince1970: 1753890013),
            Date(timeIntervalSince1970: 1751298013),
            Date(timeIntervalSince1970: 1753976429)
        ]
    )
    func testValidBirthDate(_ date: Date) {
        let today = Date(timeIntervalSince1970: 1753976429)
        let result = makeSUT(date: today).birthdayValidation.validate(date)
        #expect(result == .success, "Date should be valid")
    }
    
    @Test("Birth date validation rejects future dates")
    func testFutureBirthDates() {
        let today = Date(timeIntervalSince1970: 1753976429)
        let tomorrow = Date(timeIntervalSince1970: 1754062813)

        let result = makeSUT(date: today).birthdayValidation.validate(tomorrow)
        if case .failure(var error) = result {
            error.locale = Locale(identifier: "en_US")
            #expect(String(localized: error) == "Date must be before 31. 7. 2025., 17:40")
        } else {
            #expect(Bool(false), "Future date should be invalid")
        }
    }
    
    // MARK: - Weight Validation Tests
    
    @Test(arguments: [
        Measurement(value: 1, unit: UnitMass.kilograms),
        Measurement(value: 50, unit: UnitMass.kilograms),
        Measurement(value: 100, unit: UnitMass.kilograms)
    ])
    func testDogWeightValidation_Valid(_ weight: Measurement<UnitMass>) {
        let dogWeightValidation =  makeSUT().weightValidation(for: .dog)
        let result = dogWeightValidation.validate(weight)
        #expect(result == .success, "Weight \(weight) should be valid for dogs")
    }
    
    @Test(arguments: [
        Measurement(value: 0.4, unit: UnitMass.kilograms),
        Measurement(value: 101, unit: UnitMass.kilograms)
    ])
    func testDogWeightValidation_Invalid(_ weight: Measurement<UnitMass>) {
        let dogWeightValidation = makeSUT().weightValidation(for: .dog)
        let result = dogWeightValidation.validate(weight)
        #expect(result != .success, "Weight \(weight) should be invalid for dogs")
    }
    
    @Test(arguments: [
        Measurement(value: 1, unit: UnitMass.kilograms),
        Measurement(value: 5, unit: UnitMass.kilograms),
        Measurement(value: 10, unit: UnitMass.kilograms)
    ])
    func testCatWeightValidation_Valid(_ weight: Measurement<UnitMass>) {
        let catWeightValidation =  makeSUT().weightValidation(for: .cat)
        let result = catWeightValidation.validate(weight)
        #expect(result == .success, "Weight \(weight) should be valid for cats")
    }
    
    @Test(arguments: [
        Measurement(value: 0.49, unit: UnitMass.kilograms),
        Measurement(value: 15.1, unit: UnitMass.kilograms)
    ])
    func testCatWeightValidation_Invalid(_ weight: Measurement<UnitMass>) {
        let catWeightValidation =  makeSUT().weightValidation(for: .cat)
        let result = catWeightValidation.validate(weight)
        #expect(result != .success, "Weight \(weight) should be invalid for cats")
    }
    
    // MARK: - Owner Validation Tests
    
    @Test("Owner name validation")
    func testOwnerNameValidation() {
        // Similar to patient name but might have different rules
        let result =  makeSUT().ownerNameValidation.validate("John Doe")
        #expect(result == .success)
        
        let emptyResult =  makeSUT().ownerNameValidation.validate("")
        #expect(emptyResult != .success)
    }
    
    // MARK: - Phone Number Validation Tests
    
    @Test(arguments: [
        "123-456-7890",
        "(123) 456-7890",
        "1234567890",
        "+1-123-456-7890"
    ])
    func testPhoneNumberValidation_Valid(_ phone: String) {
        let result =  makeSUT().phoneNumberValidation.validate(phone)
        #expect(result == .success, "Phone '\(phone)' should be valid")
    }
    
    @Test(arguments: [
        "",
        "123",
        "abc-def-ghij"
    ])
    func testPhoneNumberValidation_Invalid(_ phone: String) {
        let result =  makeSUT().phoneNumberValidation.validate(phone)
        #expect(result != .success, "Phone '\(phone)' should be invalid")
    }
    
    // MARK: - Email Validation Tests
    
    @Test("Email validation for optional field")
    func testEmailValidation() {
        // Nil should be valid for optional field
        let nilResult =  makeSUT().emailValidation.validate(nil)
        #expect(nilResult == .success)
    }
    
    @Test(arguments: [
        "test@example.com",
        "john.doe@company.co.uk",
        "user+tag@domain.org"
    ])
    func testEmailValidation_Valid(_ email: String) {
        let result =  makeSUT().emailValidation.validate(email)
        #expect(result == .success, "Email '\(email)' should be valid")
    }
    
    // MARK: - Medical ID Validation Tests
    
    @Test(arguments: [
        "DOG2025071234A",
        "CAT2025079876B", 
        "RBT2025071111C"
    ])
    func testMedicalIDValidation_Valid(_ id: String) {
        let result =  makeSUT().medicalIDValidation.validate(id)
        #expect(result == .success, "Medical ID '\(id)' should be valid")
    }
    
    @Test(arguments: [
        "",
        "DOG",
        "123456789",
        "INVALID123456"
    ])
    func testMedicalIDValidation_Invalid(_ id: String) {
        let result =  makeSUT().medicalIDValidation.validate(id)
        #expect(result != .success, "Medical ID '\(id)' should be invalid")
    }
    
    // MARK: - Breed Validation Tests
    
    @Test("Breed validation matches species")
    func testBreedSpeciesValidation() {
        // Dog breed for dog species - valid
        let dogResult =  makeSUT().breedValidation(for: .dog).validate(Breed.dogLabrador)
        #expect(dogResult == .success)
        
        // Cat breed for cat species - valid
        let catResult =  makeSUT().breedValidation(for: .cat).validate(.catPersian)
        #expect(catResult == .success)
        
        // Dog breed for cat species - invalid
        let mismatchResult =  makeSUT().breedValidation(for: .cat).validate(.dogLabrador)
        if case .failure(var error) = mismatchResult {
            error.locale = Locale(identifier: "en_US")
            #expect(String(localized: error) == "'Labrador Retriever' is not a valid breed for Cat")
        } else {
            #expect(Bool(false), "Mismatched breed/species should be invalid")
        }
    }
}

// MARK: - Mock Date Provider

private struct MockDateProvider: DateProvider {
    var calendar: Calendar
    private var currentDate = Date()

    init(calendar: Calendar = .current, currentDate: Date = Date()) {
        self.calendar = calendar
        self.currentDate = currentDate
    }

    func now() -> Date {
        return currentDate
    }

}
