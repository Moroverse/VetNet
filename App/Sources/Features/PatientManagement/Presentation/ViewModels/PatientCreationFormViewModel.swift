// PatientCreationFormViewModel.swift
// Copyright (c) 2025 Moroverse
// VetNet Patient Creation Form View Model

import FactoryKit
import Foundation
import QuickForm

// MARK: - Form State

enum PatientCreationFormState: Equatable {
    case idle
    case editing
    case saving
    case saved(Patient)
    case error(String)
    case validationError(String)
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
        self.id = patient.id
        self.createdAt = patient.createdAt
        self.name = patient.name
        self.species = patient.species
        self.breed = patient.breed
        self.birthDate = patient.birthDate
        self.weight = patient.weight
        self.ownerName = patient.ownerName
        self.ownerPhoneNumber = patient.ownerPhoneNumber
        self.ownerEmail = patient.ownerEmail
        self.medicalID = patient.medicalID
        self.microchipNumber = patient.microchipNumber
        self.notes = patient.notes
    }
}

// MARK: - Patient Creation Form View Model

@QuickForm(PatientComponents.self)
final class PatientCreationFormViewModel: Validatable {
    
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
        allValues: Breed.allCases,
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
    private(set) var formState: PatientCreationFormState = .idle

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
            medicalID.value = MedicalIDGenerator.generateID(for: species.value, name: name.value.isEmpty ? "Patient" : name.value)
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
        
        // Update weight validation when species changes
        species.onValueChanged { [weak self] newValue in
            guard let self else { return }
            weight.validation = validator.weightValidation(for: newValue)
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
    
    @MainActor
    func save() async -> Patient? {
        formState = .saving

        await Task.yield()

        // Validate form
        let validationResult = validate()
        switch validationResult {
        case .success:
            break
        case .failure(let message):
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
            
        } catch RepositoryError.duplicateKey(let key) {
            formState = .error("A patient with \(key) already exists. Please use a different medical ID.")
            return nil
        } catch {
            formState = .error("Failed to save patient: \(error.localizedDescription)")
            return nil
        }
    }


    var birthDateRange: ClosedRange<Date> {
        PatientValidator(dateProvider: dateProvider).birthDateRange
    }
    
    var canSave: Bool {
        switch formState {
        case .editing:
            return validate() == .success
        default:
            return false
        }
    }
}
