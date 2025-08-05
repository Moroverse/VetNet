// PatientFormViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-24 11:19 GMT.

import FactoryKit
import Foundation
import QuickForm

// MARK: - Form State

enum PatientFormState: Equatable {
    case idle
    case editing
    case saving
    case saved(Patient)
    case error(String, isRetryable: Bool = true)
    case validationError(String)

    var isError: Bool {
        switch self {
        case .error, .validationError:
            true
        default:
            false
        }
    }

    var errorMessage: String? {
        switch self {
        case let .error(message, _), let .validationError(message):
            message
        default:
            nil
        }
    }

    var isRetryable: Bool {
        switch self {
        case let .error(_, retryable):
            retryable
        default:
            false
        }
    }
}

// MARK: - Form Components

struct PatientComponents: Sendable {
    var id: Patient.ID?
    var createdAt: Date?
    var name: String = ""
    var species: Species = .dog
    var breed: Breed = .dogMixed
    var birthDate: Date = .now
    var weight: Measurement<UnitMass> = .init(value: 0, unit: .kilograms)
    var ownerName: String = ""
    var ownerPhoneNumber: String = ""
    var ownerEmail: String?
    var medicalID: String = ""
    var microchipNumber: String?
    var notes: String?

    init() {}

    init(patient: Patient) {
        id = patient.id
        createdAt = patient.createdAt
        name = patient.name
        species = patient.species
        breed = patient.breed
        birthDate = patient.birthDate
        weight = patient.weight
        ownerName = patient.ownerName
        ownerPhoneNumber = patient.ownerPhoneNumber
        ownerEmail = patient.ownerEmail
        medicalID = patient.medicalID
        microchipNumber = patient.microchipNumber
        notes = patient.notes
    }
}

// MARK: - Patient Form View Model

@QuickForm(PatientComponents.self)
final class PatientFormViewModel: Validatable {
    convenience init(value: Patient) {
        self.init(value: .init(patient: value))
    }

    @Injected(\.patientCRUDRepository)
    private var repository

    @Injected(\.dateProvider)
    private var dateProvider

    // MARK: - Patient Information Fields

    @PropertyEditor(keyPath: \PatientComponents.name)
    var name = FormFieldViewModel(
        type: String.self,
        title: "Patient Name",
        placeholder: "Enter patient name"
    )

    @PropertyEditor(keyPath: \PatientComponents.species)
    var species = PickerFieldViewModel(
        value: Species.dog,
        allValues: Species.allCases,
        title: "Species"
    )

    @PropertyEditor(keyPath: \PatientComponents.breed)
    var breed = PickerFieldViewModel(
        value: Breed.dogMixed,
        allValues: Species.dog.availableBreeds, // Start with dog breeds as default
        title: "Breed"
    )

    @PropertyEditor(keyPath: \PatientComponents.birthDate)
    var birthDate = FormFieldViewModel(
        value: Date(),
        title: "Birth Date"
    )

    @PropertyEditor(keyPath: \PatientComponents.weight)
    var weight = FormFieldViewModel(
        value: Measurement(value: 0, unit: UnitMass.kilograms),
        title: "Weight (kg)",
        placeholder: "0.0"
    )

    // MARK: - Owner Information Fields

    @PropertyEditor(keyPath: \PatientComponents.ownerName)
    var ownerName = FormFieldViewModel(
        type: String.self,
        title: "Owner Name",
        placeholder: "Enter owner name"
    )

    @PropertyEditor(keyPath: \PatientComponents.ownerPhoneNumber)
    var ownerPhoneNumber = FormFieldViewModel(
        type: String.self,
        title: "Phone Number",
        placeholder: "Enter phone number"
    )

    @PropertyEditor(keyPath: \PatientComponents.ownerEmail)
    var ownerEmail = FormFieldViewModel(
        type: String?.self,
        title: "Email",
        placeholder: "Enter email address (optional)"
    )

    // MARK: - Medical Information Fields

    @PropertyEditor(keyPath: \PatientComponents.medicalID)
    var medicalID = FormFieldViewModel(
        type: String.self,
        title: "Medical ID",
        placeholder: "Enter or generate medical ID"
    )

    @PropertyEditor(keyPath: \PatientComponents.microchipNumber)
    var microchipNumber = FormFieldViewModel(
        type: String?.self,
        title: "Microchip Number",
        placeholder: "Enter microchip number (optional)"
    )

    @PropertyEditor(keyPath: \PatientComponents.notes)
    var notes = FormFieldViewModel(
        type: String?.self,
        title: "Notes",
        placeholder: "Enter additional notes (optional)"
    )

    // MARK: - State

    @StateObserved
    private(set) var formState: PatientFormState = .idle

    var isEditing: Bool {
        value.id != nil
    }

    // MARK: - Configuration

    @PostInit
    private func configure() {
        // If we have an existing patient, populate the fields
        if isEditing {
            name.value = value.name
            species.value = value.species

            // Set breed options for the patient's species before setting breed value
            breed.allValues = value.species.availableBreeds
            breed.value = value.breed

            birthDate.value = value.birthDate
            weight.value = value.weight
            ownerName.value = value.ownerName
            ownerPhoneNumber.value = value.ownerPhoneNumber
            ownerEmail.value = value.ownerEmail
            medicalID.value = value.medicalID
            microchipNumber.value = value.microchipNumber
            notes.value = value.notes
        } else {
            // For new patients, ensure breed options match default species (dog)
            breed.allValues = species.value.availableBreeds
            generateMedicalID()
        }

        let validator = PatientValidator(dateProvider: dateProvider)

        // Set up validation rules
        name.validation = validator.nameValidation
        birthDate.validation = validator.birthdayValidation
        weight.validation = validator.weightValidation(for: species.value)
        ownerName.validation = validator.ownerNameValidation
        ownerPhoneNumber.validation = validator.phoneNumberValidation
        ownerEmail.validation = validator.emailValidation
        medicalID.validation = validator.medicalIDValidation

        // Note: PickerFieldViewModel doesn't support validation
        // Breed validation is handled at form level in validate() method

        // Update weight validation and breed options when species changes
        species.onValueChanged { [weak self] newSpecies in
            guard let self else { return }

            // Update weight validation for new species
            weight.validation = validator.weightValidation(for: newSpecies)

            // Update available breed options based on species
            breed.allValues = newSpecies.availableBreeds

            // Reset breed selection if current breed is not valid for new species
            if !newSpecies.availableBreeds.contains(breed.value) {
                breed.value = newSpecies.availableBreeds.first ?? .dogMixed
            }

            formState = .editing
        }

        // Set editing state when any field changes
        name.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        birthDate.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        weight.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        ownerName.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        ownerPhoneNumber.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        ownerEmail.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        medicalID.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        microchipNumber.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }

        notes.onValueChanged { [weak self] _ in
            guard let self else { return }
            formState = .editing
        }
    }

    // MARK: - Actions

    func generateMedicalID() {
        medicalID.value = MedicalIDGenerator.generateID(for: species.value, name: name.value.isEmpty ? "Patient" : name.value)
        formState = .editing
    }

    func clearError() {
        if formState.isError {
            formState = .editing
        }
    }

    func retry() async -> Patient? {
        guard formState.isRetryable else { return nil }
        return await save()
    }

    @MainActor
    func save() async -> Patient? {
        formState = .saving

        await Task.yield()

        // Validate form
        let validationResult = validate()
        switch validationResult {
        case .success:
            break
        case let .failure(message):
            formState = .validationError(String(localized: message))
            return nil
        }

        do {
            let now = dateProvider.now()
            let patient: Patient

            if let id = value.id, let createdAt = value.createdAt {
                // Update existing patient
                patient = Patient(
                    id: id,
                    name: name.value,
                    species: species.value,
                    breed: breed.value,
                    birthDate: birthDate.value,
                    weight: weight.value,
                    ownerName: ownerName.value,
                    ownerPhoneNumber: ownerPhoneNumber.value,
                    ownerEmail: ownerEmail.value,
                    medicalID: medicalID.value,
                    microchipNumber: microchipNumber.value,
                    notes: notes.value,
                    createdAt: createdAt,
                    updatedAt: now
                )
                let savedPatient = try await repository.update(patient)
                formState = .saved(savedPatient)
                return savedPatient
            } else {
                // Create new patient
                patient = Patient(
                    id: Patient.ID(),
                    name: name.value,
                    species: species.value,
                    breed: breed.value,
                    birthDate: birthDate.value,
                    weight: weight.value,
                    ownerName: ownerName.value,
                    ownerPhoneNumber: ownerPhoneNumber.value,
                    ownerEmail: ownerEmail.value,
                    medicalID: medicalID.value,
                    microchipNumber: microchipNumber.value,
                    notes: notes.value,
                    createdAt: now,
                    updatedAt: now
                )
                let savedPatient = try await repository.create(patient)
                formState = .saved(savedPatient)
                return savedPatient
            }

        } catch let RepositoryError.duplicateKey(key) {
            formState = .error("A patient with \(key) already exists. Please use a different medical ID.", isRetryable: false)
            return nil
        } catch {
            formState = .error("Failed to save patient: \(error.localizedDescription)", isRetryable: true)
            return nil
        }
    }

    var birthDateRange: ClosedRange<Date> {
        PatientValidator(dateProvider: dateProvider).birthDateRange
    }

    var canSave: Bool {
        switch formState {
        case .editing:
            validate() == .success
        default:
            false
        }
    }
}
