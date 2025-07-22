import Foundation
import QuickForm
import FactoryKit

enum FormState: Equatable {
    case idle           // Initial state, no changes
    case editing        // User has made unsaved changes
    case saving         // Save operation in progress
    case saved          // Successfully saved
    case error(String)  // Save failed with error message
    case validationError(String) // Form validation failed
}

@QuickForm(PatientComponents.self)
final class PatientFormViewModel: Validatable {
    @Injected(\.patientService)
    private var patientService: PatientService
    
    @Injected(\.ownerService) 
    private var ownerService: OwnerService
    
    private let patientValidator = PatientValidator()
    private let ownerValidator = OwnerValidator()
    
    @PropertyEditor(keyPath: \PatientComponents.name)
    var name = FormFieldViewModel(
        type: String.self,
        title: "Patient Name",
        placeholder: "Enter patient name"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.species)
    var species = PickerFieldViewModel(
        value: AnimalSpecies.dog,
        allValues: AnimalSpecies.allCases,
        title: "Species"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.breed)
    var breed = PickerFieldViewModel(
        value: "",
        allValues: AnimalSpecies.dog.breedOptions,
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
        title: "Weight",
        placeholder: "0.0"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.microchipNumber)
    var microchipNumber = FormFieldViewModel(
        type: String.self,
        title: "Microchip Number",
        placeholder: "15-digit number (optional)"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.notes)
    var notes = FormFieldViewModel(
        type: String.self,
        title: "Notes",
        placeholder: "Additional notes (optional)"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.ownerFirstName)
    var ownerFirstName = FormFieldViewModel(
        type: String.self,
        title: "Owner First Name",
        placeholder: "Enter first name"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.ownerLastName)
    var ownerLastName = FormFieldViewModel(
        type: String.self,
        title: "Owner Last Name",
        placeholder: "Enter last name"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.ownerEmail)
    var ownerEmail = FormFieldViewModel(
        type: String.self,
        title: "Owner Email",
        placeholder: "Enter email address"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.ownerPhoneNumber)
    var ownerPhoneNumber = FormFieldViewModel(
        type: String.self,
        title: "Owner Phone",
        placeholder: "Enter phone number"
    )
    
    private(set) var formState: FormState = .idle
    
    @PostInit
    private func configure() {
        setupValidation()
        setupChangeTracking()
        setupDynamicValidation()
    }
    
    private func setupValidation() {
        name.validation = patientValidator.nameValidation
        birthDate.validation = patientValidator.birthdateValidation
        weight.validation = patientValidator.weightValidation(for: species.value)
        microchipNumber.validation = patientValidator.microchipValidation
        notes.validation = patientValidator.notesValidation
        
        ownerFirstName.validation = ownerValidator.firstNameValidation
        ownerLastName.validation = ownerValidator.lastNameValidation
        ownerEmail.validation = ownerValidator.emailValidation
        ownerPhoneNumber.validation = ownerValidator.phoneNumberValidation
    }
    
    private func setupChangeTracking() {
        name.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        species.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        breed.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        birthDate.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        weight.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        microchipNumber.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        notes.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        ownerFirstName.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        ownerLastName.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        ownerEmail.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
        
        ownerPhoneNumber.onValueChanged { [weak self] _ in
            self?.formState = .editing
        }
    }
    
    private func setupDynamicValidation() {
        // Update breed options and validation when species changes
        species.onValueChanged { [weak self] newSpecies in
            guard let self = self else { return }
            
            // Update breed picker options
            breed.allValues = newSpecies.breedOptions
            breed.value = "" // Reset breed selection
            
            // Update validations based on new species
            weight.validation = patientValidator.weightValidation(for: newSpecies)
        }
    }
    
    var birthDateRange: ClosedRange<Date> {
        patientValidator.birthDateRange
    }
    
    var canSave: Bool {
        switch formState {
        case .saving:
            return false
        case .idle, .editing, .saved, .error, .validationError:
            return validate() == .success
        }
    }
    
    @MainActor
    func save() async {
        formState = .saving
        
        // Validate form first
        let validationResult = validate()
        switch validationResult {
        case .success:
            break // Continue with save
        case let .failure(message):
            formState = .validationError(String(localized: message))
            return
        }
        
        do {
            // Create or find owner
            let owner = try await createOrFindOwner()
            
            // Create patient
            let patient = Patient(
                name: name.value,
                species: species.value,
                breed: breed.value.isEmpty ? nil : breed.value,
                dateOfBirth: birthDate.value,
                weight: weight.value.value > 0 ? weight.value : nil,
                microchipNumber: microchipNumber.value.isEmpty ? nil : microchipNumber.value,
                notes: notes.value.isEmpty ? nil : notes.value,
                owner: owner
            )
            
            _ = try await patientService.create(patient)
            formState = .saved
            
        } catch {
            formState = .error(error.localizedDescription)
        }
    }
    
    private func createOrFindOwner() async throws -> Owner {
        // First try to find existing owner by email
        if let existingOwner = try await ownerService.findByEmail(ownerEmail.value) {
            return existingOwner
        }
        
        // Create new owner
        let newOwner = Owner(
            firstName: ownerFirstName.value,
            lastName: ownerLastName.value,
            email: ownerEmail.value,
            phoneNumber: ownerPhoneNumber.value
        )
        
        return try await ownerService.create(newOwner)
    }
    
    func reset() {
        name.value = ""
        species.value = .dog
        breed.value = ""
        birthDate.value = Date()
        weight.value = Measurement(value: 0, unit: .kilograms)
        microchipNumber.value = ""
        notes.value = ""
        ownerFirstName.value = ""
        ownerLastName.value = ""
        ownerEmail.value = ""
        ownerPhoneNumber.value = ""
        formState = .idle
    }
}
