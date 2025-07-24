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

struct PatientCreationComponents: Sendable {
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
}

// MARK: - Patient Creation Form View Model

@QuickForm(PatientCreationComponents.self)
final class PatientCreationFormViewModel: Validatable {
    
    @Injected(\.patientRepository)
    private var repository
    
    @Injected(\.dateProvider)
    private var dateProvider

    @Injected(\.router)
    private var router

    // MARK: - Patient Information Fields
    
    @PropertyEditor(keyPath: \PatientCreationComponents.name)
    var name = FormFieldViewModel(
        type: String.self,
        title: "Patient Name",
        placeholder: "Enter patient name"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.species)
    var species = PickerFieldViewModel(
        value: Species.dog,
        allValues: Species.allCases,
        title: "Species"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.breed)
    var breed = PickerFieldViewModel(
        value: Breed.dogMixed,
        allValues: Breed.allCases,
        title: "Breed"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.birthDate)
    var birthDate = FormFieldViewModel(
        value: Date(),
        title: "Birth Date"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.weight)
    var weight = FormFieldViewModel(
        value: Measurement(value: 0, unit: UnitMass.kilograms),
        title: "Weight (kg)",
        placeholder: "0.0"
    )
    
    // MARK: - Owner Information Fields
    
    @PropertyEditor(keyPath: \PatientCreationComponents.ownerName)
    var ownerName = FormFieldViewModel(
        type: String.self,
        title: "Owner Name",
        placeholder: "Enter owner name"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.ownerPhoneNumber)
    var ownerPhoneNumber = FormFieldViewModel(
        type: String.self,
        title: "Phone Number",
        placeholder: "Enter phone number"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.ownerEmail)
    var ownerEmail = FormFieldViewModel(
        type: String?.self,
        title: "Email (Optional)",
        placeholder: "Enter email address"
    )
    
    // MARK: - Medical Information Fields
    
    @PropertyEditor(keyPath: \PatientCreationComponents.medicalID)
    var medicalID = FormFieldViewModel(
        type: String.self,
        title: "Medical ID",
        placeholder: "Enter or generate medical ID"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.microchipNumber)
    var microchipNumber = FormFieldViewModel(
        type: String?.self,
        title: "Microchip Number (Optional)",
        placeholder: "Enter microchip number"
    )
    
    @PropertyEditor(keyPath: \PatientCreationComponents.notes)
    var notes = FormFieldViewModel(
        type: String?.self,
        title: "Notes (Optional)",
        placeholder: "Enter additional notes"
    )
    
    // MARK: - State
    
    @StateObserved
    private(set) var formState: PatientCreationFormState = .idle
    
    // MARK: - Configuration
    
    @PostInit
    private func configure() {
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
        
        // Generate initial medical ID
        generateMedicalID()
    }
    
    // MARK: - Actions
    
    func generateMedicalID() {
        medicalID.value = MedicalIDGenerator.generateID(for: species.value, name: name.value.isEmpty ? "Patient" : name.value)
        formState = .editing
    }
    
    @MainActor
    func save() async {
        formState = .saving
        
        // Validate form
        let validationResult = validate()
        switch validationResult {
        case .success:
            break
        case .failure(let message):
            formState = .validationError(String(localized: message))
            return
        }
        
        do {
            let now = dateProvider.now()
            let patient = Patient(
                id: Patient.ID(),
                name: name.value,
                species: species.value,
                breed: breed.value,
                birthDate: birthDate.value,
                weight: weight.value.value > 0 ? weight.value : nil,
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
            
        } catch RepositoryError.duplicateKey(let key) {
            formState = .error("A patient with \(key) already exists. Please use a different medical ID.")
        } catch {
            formState = .error("Failed to create patient: \(error.localizedDescription)")
        }
    }

    func cancel() {
        //FIXME: -
        //router.dismissSheet()
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
