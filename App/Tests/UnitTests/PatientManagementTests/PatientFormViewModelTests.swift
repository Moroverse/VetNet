// PatientFormViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import FactoryKit
import Foundation
import QuickForm
import Testing
import TestKit
@testable import VetNet

// MARK: - Test Doubles

@MainActor
final class TestPatientCRUDRepository: PatientCRUDRepository {
    // MARK: - Test Control Properties

    var createCallCount = 0
    var updateCallCount = 0
    var findByIdCallCount = 0
    var deleteCallCount = 0

    var createReturnValue: Patient?
    var updateReturnValue: Patient?
    var findByIdReturnValue: Patient?

    var createThrowableError: Error?
    var updateThrowableError: Error?

    var lastCreatedPatient: Patient?
    var lastUpdatedPatient: Patient?

    // MARK: - PatientCRUDRepository Implementation

    func create(_ patient: Patient) async throws -> Patient {
        createCallCount += 1
        lastCreatedPatient = patient

        if let error = createThrowableError {
            throw error
        }

        return createReturnValue ?? patient
    }

    func findById(_: Patient.ID) async throws -> Patient? {
        findByIdCallCount += 1
        return findByIdReturnValue
    }

    func update(_ patient: Patient) async throws -> Patient {
        updateCallCount += 1
        lastUpdatedPatient = patient

        if let error = updateThrowableError {
            throw error
        }

        return updateReturnValue ?? patient
    }

    func delete(_: Patient.ID) async throws {
        deleteCallCount += 1
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
        currentDate
    }
}

@Suite("Patient Form View Model Tests")
@MainActor
struct PatientFormViewModelTests {
    // MARK: - Test Helpers

    private func createTestPatient(
        id: Patient.ID? = nil,
        name: String = "Test Dog",
        createdAt: Date? = nil
    ) -> Patient {
        Patient(
            id: id ?? Patient.ID(),
            name: name,
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years ago
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "(123) 456-7890",
            ownerEmail: "test@example.com",
            medicalID: "DOG2025071234A",
            microchipNumber: "123456789",
            notes: "Test notes",
            createdAt: createdAt ?? Date(),
            updatedAt: Date()
        )
    }

    private struct SUT {
        let viewModel: PatientFormViewModel
        let repository: TestPatientCRUDRepository
        let dateProvider: MockDateProvider
    }

    private func makeSUT(existingPatient: Patient? = nil) -> SUT {
        let repository = TestPatientCRUDRepository()
        let dateProvider = MockDateProvider()

        // Register mocks in container
        Container.shared.patientCRUDRepository.register {
            repository
        }

        Container.shared.dateProvider.register {
            dateProvider
        }

        let viewModel = if let existingPatient {
            PatientFormViewModel(value: existingPatient)
        } else {
            PatientFormViewModel(value: PatientComponents())
        }

        return SUT(
            viewModel: viewModel,
            repository: repository,
            dateProvider: dateProvider
        )
    }

    // MARK: - Initialization Tests

    @Test("New patient form initializes with correct defaults")
    func newPatientFormInitialization() {
        let sut = makeSUT()

        // Patient information fields
        #expect(sut.viewModel.name.value.isEmpty)
        #expect(sut.viewModel.species.value == .dog)
        #expect(sut.viewModel.breed.value == .dogMixed)
        #expect(sut.viewModel.weight.value == Measurement(value: 0, unit: .kilograms))

        // Owner information fields
        #expect(sut.viewModel.ownerName.value.isEmpty)
        #expect(sut.viewModel.ownerPhoneNumber.value.isEmpty)
        #expect(sut.viewModel.ownerEmail.value == nil)

        // Medical information fields
        #expect(!sut.viewModel.medicalID.value.isEmpty) // Generated during setup
        #expect(sut.viewModel.microchipNumber.value == nil)
        #expect(sut.viewModel.notes.value == nil)

        // Form state
        #expect(!sut.viewModel.isEditing)
        #expect(sut.viewModel.formState == .editing) // generateMedicalID() in init triggers editing state
    }

    @Test("Existing patient form initializes with patient data")
    func existingPatientFormInitialization() {
        let existingPatient = createTestPatient()
        let sut = makeSUT(existingPatient: existingPatient)

        // Patient information should be populated
        #expect(sut.viewModel.name.value == existingPatient.name)
        #expect(sut.viewModel.species.value == existingPatient.species)
        #expect(sut.viewModel.breed.value == existingPatient.breed)
        #expect(sut.viewModel.birthDate.value == existingPatient.birthDate)
        #expect(sut.viewModel.weight.value == existingPatient.weight)

        // Owner information should be populated
        #expect(sut.viewModel.ownerName.value == existingPatient.ownerName)
        #expect(sut.viewModel.ownerPhoneNumber.value == existingPatient.ownerPhoneNumber)
        #expect(sut.viewModel.ownerEmail.value == existingPatient.ownerEmail)

        // Medical information should be populated
        // Note: Medical ID might be regenerated during initialization
        #expect(sut.viewModel.medicalID.value.hasPrefix("DOG")) // Dog species code
        #expect(sut.viewModel.microchipNumber.value == existingPatient.microchipNumber)
        #expect(sut.viewModel.notes.value == existingPatient.notes)

        // Should be in editing mode
        #expect(sut.viewModel.isEditing)
    }

    @Test("Form field titles are correct")
    func formFieldTitles() {
        let sut = makeSUT()

        #expect(sut.viewModel.name.title == "Patient Name")
        #expect(sut.viewModel.species.title == "Species")
        #expect(sut.viewModel.breed.title == "Breed")
        #expect(sut.viewModel.birthDate.title == "Birth Date")
        #expect(sut.viewModel.weight.title == "Weight (kg)")
        #expect(sut.viewModel.ownerName.title == "Owner Name")
        #expect(sut.viewModel.ownerPhoneNumber.title == "Phone Number")
        #expect(sut.viewModel.ownerEmail.title == "Email")
        #expect(sut.viewModel.medicalID.title == "Medical ID")
        #expect(sut.viewModel.microchipNumber.title == "Microchip Number")
        #expect(sut.viewModel.notes.title == "Notes")
    }

    // MARK: - Medical ID Generation Tests

    @Test("Medical ID generates with correct format for dogs")
    func medicalIDGenerationForDogs() {
        let sut = makeSUT()

        sut.viewModel.species.value = .dog
        sut.viewModel.name.value = "Buddy"
        sut.viewModel.generateMedicalID()

        let medicalID = sut.viewModel.medicalID.value
        #expect(medicalID.hasPrefix("DOG"))
        #expect(medicalID.count == 14) // DOG + YYYYMM + 4 digits + 1 letter

        // Verify format: DOG + 6 digits (YYYYMM) + 4 digits + 1 letter
        let afterPrefix = String(medicalID.dropFirst(3))
        let dateAndSequence = String(afterPrefix.dropLast()) // Remove check digit
        let checkDigit = String(afterPrefix.suffix(1))

        #expect(dateAndSequence.count == 10) // 6 (YYYYMM) + 4 (sequence)
        #expect(dateAndSequence.allSatisfy(\.isNumber))
        #expect(checkDigit.count == 1)
        #expect(checkDigit.first?.isLetter == true)
    }

    @Test("Medical ID generates with correct format for cats")
    func medicalIDGenerationForCats() {
        let sut = makeSUT()

        sut.viewModel.species.value = .cat
        sut.viewModel.name.value = "Whiskers"
        sut.viewModel.generateMedicalID()

        let medicalID = sut.viewModel.medicalID.value
        #expect(medicalID.hasPrefix("CAT"))
        #expect(medicalID.count == 14) // CAT + YYYYMM + 4 digits + 1 letter

        // Verify format: CAT + 6 digits (YYYYMM) + 4 digits + 1 letter
        let afterPrefix = String(medicalID.dropFirst(3))
        let dateAndSequence = String(afterPrefix.dropLast()) // Remove check digit
        let checkDigit = String(afterPrefix.suffix(1))

        #expect(dateAndSequence.count == 10) // 6 (YYYYMM) + 4 (sequence)
        #expect(dateAndSequence.allSatisfy(\.isNumber))
        #expect(checkDigit.count == 1)
        #expect(checkDigit.first?.isLetter == true)
    }

    @Test("Medical ID generation handles empty name")
    func medicalIDGenerationWithEmptyName() {
        let sut = makeSUT()

        sut.viewModel.species.value = .cat
        sut.viewModel.name.value = ""
        sut.viewModel.generateMedicalID()

        let medicalID = sut.viewModel.medicalID.value
        #expect(medicalID.hasPrefix("CAT"))
        #expect(medicalID.count == 14)
        #expect(!medicalID.isEmpty)
    }

    @Test("Medical ID generates unique values")
    func medicalIDUniqueness() {
        let sut1 = makeSUT()
        let sut2 = makeSUT()

        sut1.viewModel.species.value = .dog
        sut1.viewModel.name.value = "Max"
        sut1.viewModel.generateMedicalID()

        sut2.viewModel.species.value = .dog
        sut2.viewModel.name.value = "Max"
        sut2.viewModel.generateMedicalID()

        #expect(sut1.viewModel.medicalID.value != sut2.viewModel.medicalID.value)
    }

    // MARK: - Form State Management Tests

    @Test("Name field change triggers editing state")
    func nameFieldChangeTriggersEditingState() {
        let sut = makeSUT()

        sut.viewModel.name.value = "New Name"

        #expect(sut.viewModel.formState == .editing)
    }

    @Test("Owner name field change triggers editing state")
    func ownerNameFieldChangeTriggersEditingState() {
        let sut = makeSUT()

        sut.viewModel.ownerName.value = "New Owner"

        #expect(sut.viewModel.formState == .editing)
    }

    @Test("Species change triggers editing state")
    func speciesChangeTriggersEditingState() {
        let sut = makeSUT()

        sut.viewModel.species.value = .cat

        #expect(sut.viewModel.formState == .editing)
    }

    @Test("Species change updates weight validation")
    func speciesChangeUpdatesWeightValidation() {
        let sut = makeSUT()

        // Set valid dog weight
        sut.viewModel.species.value = .dog
        sut.viewModel.weight.value = Measurement(value: 50, unit: .kilograms)

        let dogValidation = sut.viewModel.weight.validate()
        #expect(dogValidation == .success)

        // Change to cat - same weight should be invalid for cats
        sut.viewModel.species.value = .cat

        let catValidation = sut.viewModel.weight.validate()
        #expect(catValidation != .success)
    }

    @Test("Multiple field changes maintain editing state")
    func multipleFieldChangesMaintainEditingState() {
        let sut = makeSUT()

        sut.viewModel.name.value = "Test Name"
        #expect(sut.viewModel.formState == .editing)

        sut.viewModel.ownerName.value = "Test Owner"
        #expect(sut.viewModel.formState == .editing)

        sut.viewModel.ownerPhoneNumber.value = "555-1234"
        #expect(sut.viewModel.formState == .editing)
    }

    // MARK: - Save Operation Tests

    @Test("Save creates new patient when not editing")
    func saveCreatesNewPatient() async {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2) // 2 years ago
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"
        sut.viewModel.ownerEmail.value = "john@example.com"
        sut.viewModel.microchipNumber.value = "123456789"
        sut.viewModel.notes.value = "Friendly dog"

        // Save the patient
        let savedPatient = await sut.viewModel.save()

        // Verify repository was called
        #expect(sut.repository.createCallCount == 1)
        #expect(sut.repository.updateCallCount == 0)

        // Get the patient that was passed to the repository
        let createdPatient = sut.repository.lastCreatedPatient

        // Verify the correct patient data was sent to repository
        #expect(createdPatient != nil)
        #expect(createdPatient?.name == "Max")
        #expect(createdPatient?.species == .dog)
        #expect(createdPatient?.breed == .dogLabrador)
        #expect(createdPatient?.weight == Measurement(value: 25, unit: .kilograms))
        #expect(createdPatient?.ownerName == "John Doe")
        #expect(createdPatient?.ownerPhoneNumber == "(123) 456-7890")
        #expect(createdPatient?.ownerEmail == "john@example.com")
        #expect(createdPatient?.medicalID == sut.viewModel.medicalID.value)
        #expect(createdPatient?.microchipNumber == "123456789")
        #expect(createdPatient?.notes == "Friendly dog")

        // Verify the saved patient is what repository returned
        #expect(savedPatient == createdPatient)

        // Verify form state
        if case let .saved(patient) = sut.viewModel.formState {
            #expect(patient == savedPatient)
        } else {
            Issue.record("Expected saved state")
        }
    }

    @Test("Save updates existing patient when editing")
    func saveUpdatesExistingPatient() async {
        let existingPatient = createTestPatient()
        let sut = makeSUT(existingPatient: existingPatient)

        // Modify some fields
        sut.viewModel.name.value = "Updated Name"
        sut.viewModel.weight.value = Measurement(value: 30, unit: .kilograms)
        sut.viewModel.notes.value = "Updated notes"

        // Save the patient
        let savedPatient = await sut.viewModel.save()

        // Verify repository was called
        #expect(sut.repository.createCallCount == 0)
        #expect(sut.repository.updateCallCount == 1)

        // Get the patient that was passed to the repository
        let updatedPatient = sut.repository.lastUpdatedPatient

        // Verify the correct updated data was sent to repository
        #expect(updatedPatient != nil)
        #expect(updatedPatient?.id == existingPatient.id)
        #expect(updatedPatient?.name == "Updated Name")
        #expect(updatedPatient?.weight == Measurement(value: 30, unit: .kilograms))
        #expect(updatedPatient?.notes == "Updated notes")
        #expect(updatedPatient?.createdAt == existingPatient.createdAt)

        // Verify fields that shouldn't change
        #expect(updatedPatient?.species == existingPatient.species)
        #expect(updatedPatient?.breed == existingPatient.breed)
        #expect(updatedPatient?.ownerName == existingPatient.ownerName)

        // Verify the saved patient is what repository returned
        #expect(savedPatient == updatedPatient)

        // Verify form state
        if case let .saved(patient) = sut.viewModel.formState {
            #expect(patient == savedPatient)
        } else {
            Issue.record("Expected saved state")
        }
    }

    @Test("Save fails with validation error for invalid data")
    func saveFailsWithValidationError() async {
        let sut = makeSUT()

        // Set up invalid patient data (missing required fields)
        sut.viewModel.name.value = "" // Invalid: empty name
        sut.viewModel.ownerName.value = "" // Invalid: empty owner name
        sut.viewModel.ownerPhoneNumber.value = "" // Invalid: empty phone

        // Try to save
        let savedPatient = await sut.viewModel.save()

        // Verify no repository calls were made
        #expect(sut.repository.createCallCount == 0)
        #expect(sut.repository.updateCallCount == 0)

        // Verify save failed
        #expect(savedPatient == nil)

        // Verify form state shows validation error
        if case let .validationError(message) = sut.viewModel.formState {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Expected validation error state")
        }
    }

    @Test("Save handles duplicate key error")
    func saveHandlesDuplicateKeyError() async {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Configure repository to throw duplicate key error
        sut.repository.createThrowableError = RepositoryError.duplicateKey("medicalID: DOG123456789")

        // Try to save
        let savedPatient = await sut.viewModel.save()

        // Verify repository was called
        #expect(sut.repository.createCallCount == 1)

        // Verify save failed
        #expect(savedPatient == nil)

        // Verify form state shows error
        if case let .error(message, isRetryable) = sut.viewModel.formState {
            #expect(message.contains("already exists"))
            #expect(message.contains("medical ID"))
            #expect(isRetryable == false) // Duplicate key errors should not be retryable
        } else {
            Issue.record("Expected error state for duplicate key")
        }
    }

    @Test("Save handles general repository error")
    func saveHandlesGeneralRepositoryError() async {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Configure repository to throw general error
        sut.repository.createThrowableError = RepositoryError.databaseError("Connection failed")

        // Try to save
        let savedPatient = await sut.viewModel.save()

        // Verify repository was called
        #expect(sut.repository.createCallCount == 1)

        // Verify save failed
        #expect(savedPatient == nil)

        // Verify form state shows error
        if case let .error(message, isRetryable) = sut.viewModel.formState {
            #expect(message.contains("Failed to save patient"))
            #expect(isRetryable == true) // General errors should be retryable
        } else {
            Issue.record("Expected error state for database error")
        }
    }

    @Test("Save transitions through correct states")
    func saveTransitionsThroughCorrectStates() async throws {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Verify initial state is editing
        #expect(sut.viewModel.formState == .editing)

        let formStateObservation = ObservationSpy(observation: Observations {
            sut.viewModel.formState
        })

        let savedPatient = await sut.viewModel.save()

        let changes = try await formStateObservation.waitForChanges(count: 2)
        #expect(changes == [PatientFormState.saving, PatientFormState.saved(savedPatient!)])
    }

    @Test("canSave returns true for valid form data")
    func canSaveReturnsTrueForValidData() {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        #expect(sut.viewModel.canSave == true)
    }

    @Test("canSave returns false for invalid form data")
    func canSaveReturnsFalseForInvalidData() {
        let sut = makeSUT()

        // Leave required fields empty
        sut.viewModel.name.value = ""
        sut.viewModel.ownerName.value = ""

        #expect(sut.viewModel.canSave == false)
    }

    @Test("canSave returns false when not in editing state")
    func canSaveReturnsFalseWhenNotEditing() async {
        let sut = makeSUT()

        // Set up valid data and save
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "555-1234"

        _ = await sut.viewModel.save()

        // After save, should not be able to save again until editing
        #expect(sut.viewModel.canSave == false)
    }

    @Test("Save preserves timestamps correctly")
    func savePreservesTimestampsCorrectly() async {
        let createdDate = Date().addingTimeInterval(-86400) // 1 day ago
        let existingPatient = createTestPatient(createdAt: createdDate)
        let sut = makeSUT(existingPatient: existingPatient)

        // Update the patient
        sut.viewModel.name.value = "Updated Name"

        let savedPatient = await sut.viewModel.save()

        // Verify createdAt is preserved
        #expect(savedPatient?.createdAt == createdDate)

        // Verify updatedAt is current
        #expect(savedPatient?.updatedAt != nil)
        #expect(savedPatient?.updatedAt != createdDate)
    }

    @Test("Save handles optional fields correctly")
    func saveHandlesOptionalFieldsCorrectly() async {
        let sut = makeSUT()

        // Set up only required fields
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Leave optional fields nil
        sut.viewModel.ownerEmail.value = nil
        sut.viewModel.microchipNumber.value = nil
        sut.viewModel.notes.value = nil

        let savedPatient = await sut.viewModel.save()

        // Verify save succeeded
        #expect(savedPatient != nil)

        // Verify optional fields are nil
        #expect(savedPatient?.ownerEmail == nil)
        #expect(savedPatient?.microchipNumber == nil)
        #expect(savedPatient?.notes == nil)
    }

    // MARK: - Error Management Tests

    @Test("clearError changes error state to editing")
    func clearErrorChangesStateToEditing() async {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Configure repository to throw error
        sut.repository.createThrowableError = RepositoryError.databaseError("Connection failed")

        // Try to save to get into error state
        _ = await sut.viewModel.save()

        // Verify we're in error state
        #expect(sut.viewModel.formState.isError)

        // Clear the error
        sut.viewModel.clearError()

        // Verify state changed to editing
        #expect(sut.viewModel.formState == .editing)
    }

    @Test("clearError does nothing when not in error state")
    func clearErrorDoesNothingWhenNotInErrorState() {
        let sut = makeSUT()

        // Verify initial state
        #expect(sut.viewModel.formState == .editing)

        // Clear error when not in error state
        sut.viewModel.clearError()

        // Verify state unchanged
        #expect(sut.viewModel.formState == .editing)
    }

    @Test("retry attempts save again for retryable errors")
    func retryAttemptsSaveAgainForRetryableErrors() async {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Configure repository to throw error first time, succeed second time
        sut.repository.createThrowableError = RepositoryError.databaseError("Connection failed")

        // Try to save to get into error state
        let firstResult = await sut.viewModel.save()
        #expect(firstResult == nil)
        #expect(sut.viewModel.formState.isRetryable)

        // Clear the error so retry can succeed
        sut.repository.createThrowableError = nil

        // Retry the operation
        let retryResult = await sut.viewModel.retry()

        // Verify retry succeeded
        #expect(retryResult != nil)
        #expect(sut.repository.createCallCount == 2) // Both original and retry attempts
    }

    @Test("retry returns nil for non-retryable errors")
    func retryReturnsNilForNonRetryableErrors() async {
        let sut = makeSUT()

        // Set up valid patient data
        sut.viewModel.name.value = "Max"
        sut.viewModel.species.value = .dog
        sut.viewModel.breed.value = .dogLabrador
        sut.viewModel.birthDate.value = Date().addingTimeInterval(-365 * 24 * 60 * 60)
        sut.viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        sut.viewModel.ownerName.value = "John Doe"
        sut.viewModel.ownerPhoneNumber.value = "(123) 456-7890"

        // Configure repository to throw non-retryable error
        sut.repository.createThrowableError = RepositoryError.duplicateKey("medicalID: DOG123456789")

        // Try to save to get into error state
        _ = await sut.viewModel.save()
        #expect(!sut.viewModel.formState.isRetryable)

        // Try to retry
        let retryResult = await sut.viewModel.retry()

        // Verify retry did nothing
        #expect(retryResult == nil)
        #expect(sut.repository.createCallCount == 1) // Only original attempt
    }
}
