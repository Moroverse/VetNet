# QuickForm Integration Architecture

**Document Version**: 1.0  
**Last Updated**: 2025-07-22  
**Related**: [Main Architecture](./main-architecture.md), [Data Models](./data-models.md), [Testing Strategy](./testing-strategy.md)

## Overview

QuickForm is a declarative Swift framework for building sophisticated form-based user interfaces with automatic data binding, validation, and state management in SwiftUI. This document outlines how QuickForm integrates into VetNet's architecture to provide powerful form capabilities for veterinary practice workflows.

## QuickForm Core Concepts

### Framework Capabilities

QuickForm transforms SwiftUI form development through:

- **🎯 Declarative Form Definition**: Swift macros eliminate boilerplate code
- **🔄 Automatic Data Binding**: Bidirectional synchronization between UI and data models  
- **✅ Comprehensive Validation**: Built-in and custom validation with real-time feedback
- **📝 Rich Field Types**: Text fields, pickers, date selectors, collections, async data loading
- **🔗 Reactive Relationships**: Interdependent fields with automatic value propagation
- **🎨 SwiftUI Native**: Seamless integration with SwiftUI's declarative paradigm
- **⚡ Performance Optimized**: Efficient change tracking and minimal re-renders
- **🛡️ Type Safe**: Compile-time guarantees for form field bindings

### Core Architecture Components

#### 1. Value Editor Protocol System

```swift
/// Base protocol for types that can edit values
public protocol ValueEditor<Value> {
    associatedtype Value
    var value: Value { get set }
}

/// Extended protocol with observation capabilities
public protocol ObservableValueEditor: ValueEditor {
    func onValueChanged(_ change: @escaping (Value) -> Void) -> Subscription
}
```

#### 2. Macro-Driven Infrastructure

QuickForm uses 6 Swift macros that work together:

- **@QuickForm(Type.self)**: Generates form infrastructure, Observable conformance, validation support
- **@PropertyEditor(keyPath:)**: Creates two-way binding between form fields and model properties
- **@StateObserved**: Provides observation tracking for properties with initializers
- **@Dependency**: Marks properties for dependency injection
- **@OnInit**: Marks methods to run during initialization
- **@PostInit**: Marks methods to run after initialization (for setup requiring all properties)

#### 3. Form Field ViewModels

Rich set of specialized view models for different input types:

- `FormFieldViewModel<T>`: Basic form field with validation
- `FormattedFieldViewModel<T>`: Input with formatting/masking
- `PickerFieldViewModel<T>`: Single selection picker
- `MultiPickerFieldViewModel<T>`: Multiple selection
- `AsyncPickerFieldViewModel<T>`: Async data loading with search
- `FormCollectionViewModel<T>`: Dynamic collections with add/remove
- `TokenSetViewModel<T>`: Tag-style input for collections

#### 4. Validation System

Comprehensive validation with:

- **Field-Level Validation**: Each view model can have validation rules
- **Form-Level Validation**: Aggregated validation across all fields
- **Built-in Rules**: `.notEmpty`, `.minLength()`, `.maxLength()`, `.email`, `.usZipCode`
- **Custom Rules**: Domain-specific validation through `ValidationRule` protocol
- **Reactive Validation**: Real-time feedback as users type

## VetNet Integration Patterns

### 1. Patient Information Forms

**Use Case**: Capturing and editing patient demographics, medical history, and contact information.

```swift
@QuickForm(Patient.self)
class PatientEditModel: Validatable {
    @PropertyEditor(keyPath: \Patient.name)
    var patientName = FormFieldViewModel(
        type: String.self,
        title: "Patient Name",
        placeholder: "Max",
        validation: .combined(.notEmpty, .minLength(1), .maxLength(50))
    )
    
    @PropertyEditor(keyPath: \Patient.species)
    var species = PickerFieldViewModel(
        type: Species.self,
        allValues: Species.allCases,
        title: "Species"
    )
    
    @PropertyEditor(keyPath: \Patient.breed)
    var breed = AsyncPickerFieldViewModel(
        value: nil,
        title: "Breed",
        valuesProvider: { query in
            try await BreedService.searchBreeds(species: self.species.value, query: query)
        },
        queryBuilder: { $0?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    )
    
    @PropertyEditor(keyPath: \Patient.dateOfBirth)
    var dateOfBirth = FormFieldViewModel(
        type: Date?.self,
        title: "Date of Birth"
    )
    
    @PropertyEditor(keyPath: \Patient.weight)
    var weight = FormFieldViewModel(
        type: Measurement<UnitMass>?.self,
        title: "Weight"
    )
    
    @PostInit
    func configure() {
        // Set up reactive relationships
        species.onValueChanged { [weak self] newSpecies in
            self?.breed.value = nil // Reset breed when species changes
        }
        
        // Add custom validation
        addCustomValidationRule(AgeValidationRule())
    }
}
```

**SwiftUI Integration**:

```swift
struct PatientEditView: View {
    @StateObject private var model = PatientEditModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    FormTextField(model.patientName)
                        .accessibilityIdentifier("patient_name_field")
                    
                    FormPickerField(model.species)
                        .accessibilityIdentifier("species_picker")
                    
                    FormAsyncPickerField(model.breed)
                        .accessibilityIdentifier("breed_picker")
                }
                
                Section("Physical Details") {
                    FormDatePickerField(model.dateOfBirth)
                        .accessibilityIdentifier("date_of_birth_picker")
                    
                    FormValueUnitField(model.weight)
                        .accessibilityIdentifier("weight_field")
                }
            }
            .navigationTitle("Patient Information")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        if model.validate().isValid {
                            savePatient(model.value)
                        }
                    }
                    .accessibilityIdentifier("save_patient_button")
                }
            }
        }
    }
}
```

### 2. Appointment Scheduling Forms

**Use Case**: Comprehensive appointment booking with time slots, services, and specialist matching.

```swift
@QuickForm(AppointmentRequest.self)
class AppointmentScheduleModel: Validatable {
    @PropertyEditor(keyPath: \AppointmentRequest.patient)
    var patient = AsyncPickerFieldViewModel(
        value: nil,
        title: "Patient",
        valuesProvider: { query in
            try await PatientService.searchPatients(query: query)
        }
    )
    
    @PropertyEditor(keyPath: \AppointmentRequest.serviceType)
    var serviceType = PickerFieldViewModel(
        type: ServiceType.self,
        allValues: ServiceType.allCases,
        title: "Service Type"
    )
    
    @PropertyEditor(keyPath: \AppointmentRequest.preferredDate)
    var preferredDate = FormFieldViewModel(
        type: Date.self,
        title: "Preferred Date"
    )
    
    @PropertyEditor(keyPath: \AppointmentRequest.timeSlot)
    var timeSlot = OptionalPickerFieldViewModel(
        type: TimeSlot?.self,
        allValues: [],
        title: "Available Times"
    )
    
    @PropertyEditor(keyPath: \AppointmentRequest.specialist)
    var specialist = OptionalPickerFieldViewModel(
        type: VeterinarySpecialist?.self,
        allValues: [],
        title: "Preferred Specialist"
    )
    
    @PropertyEditor(keyPath: \AppointmentRequest.notes)
    var notes = FormFieldViewModel(
        type: String?.self,
        title: "Additional Notes",
        placeholder: "Any special requirements or concerns..."
    )
    
    @PostInit
    func configure() {
        // Set up reactive scheduling logic
        serviceType.onValueChanged { [weak self] newService in
            self?.updateAvailableSpecialists(for: newService)
        }
        
        preferredDate.onValueChanged { [weak self] newDate in
            Task { @MainActor in
                await self?.updateAvailableTimeSlots(for: newDate)
            }
        }
        
        specialist.onValueChanged { [weak self] newSpecialist in
            Task { @MainActor in
                await self?.updateTimeSlotAvailability(for: newSpecialist)
            }
        }
        
        addCustomValidationRule(AppointmentAvailabilityRule())
    }
    
    private func updateAvailableSpecialists(for service: ServiceType) {
        specialist.allValues = SpecialistService.getSpecialists(for: service)
        specialist.value = nil
    }
    
    private func updateAvailableTimeSlots(for date: Date) async {
        let slots = await SchedulingService.getAvailableSlots(
            date: date,
            serviceType: serviceType.value,
            specialist: specialist.value
        )
        timeSlot.allValues = slots
        timeSlot.value = nil
    }
}
```

### 3. Medical Record Forms

**Use Case**: Capturing examination findings, diagnoses, and treatment plans.

```swift
@QuickForm(MedicalRecord.self)
class MedicalRecordModel: Validatable {
    @PropertyEditor(keyPath: \MedicalRecord.chiefComplaint)
    var chiefComplaint = FormFieldViewModel(
        type: String.self,
        title: "Chief Complaint",
        placeholder: "Primary concern or reason for visit",
        validation: .combined(.notEmpty, .maxLength(500))
    )
    
    @PropertyEditor(keyPath: \MedicalRecord.vitalSigns)
    var vitalSigns = VitalSignsEditModel()
    
    @PropertyEditor(keyPath: \MedicalRecord.symptoms)
    var symptoms = MultiPickerFieldViewModel(
        value: [],
        allValues: Symptom.commonSymptoms,
        title: "Observed Symptoms"
    )
    
    @PropertyEditor(keyPath: \MedicalRecord.diagnoses)
    var diagnoses = FormCollectionViewModel(
        type: Diagnosis.self,
        title: "Diagnoses"
    )
    
    @PropertyEditor(keyPath: \MedicalRecord.treatments)
    var treatments = FormCollectionViewModel(
        type: Treatment.self,
        title: "Treatment Plan"
    )
    
    @PropertyEditor(keyPath: \MedicalRecord.followUpRequired)
    var followUpRequired = FormFieldViewModel(
        type: Bool.self,
        title: "Follow-up Required"
    )
    
    @PropertyEditor(keyPath: \MedicalRecord.followUpDate)
    var followUpDate = FormFieldViewModel(
        type: Date?.self,
        title: "Follow-up Date"
    )
    
    @PostInit
    func configure() {
        // Conditional validation based on follow-up requirement
        followUpRequired.onValueChanged { [weak self] required in
            if required {
                self?.followUpDate.validation = .required()
            } else {
                self?.followUpDate.validation = nil
                self?.followUpDate.value = nil
            }
        }
        
        addCustomValidationRule(MedicalRecordCompletenessRule())
    }
}
```

## Advanced Integration Patterns

### 1. Nested Form Models

QuickForm supports complex hierarchical forms by nesting form models:

```swift
// Address as a nested form model
@QuickForm(Address.self)
class AddressEditModel: Validatable, ValueEditor {
    @PropertyEditor(keyPath: \Address.street)
    var street = FormFieldViewModel(
        type: String.self,
        title: "Street Address",
        validation: .notEmpty
    )
    
    @PropertyEditor(keyPath: \Address.city)
    var city = FormFieldViewModel(
        type: String.self,
        title: "City",
        validation: .notEmpty
    )
    
    @PropertyEditor(keyPath: \Address.state)
    var state = PickerFieldViewModel(
        type: State.self,
        allValues: State.allCases,
        title: "State"
    )
    
    @PropertyEditor(keyPath: \Address.zipCode)
    var zipCode = FormattedFieldViewModel(
        type: String.self,
        format: .usZipCode,
        title: "ZIP Code",
        validation: .usZipCode
    )
}

// Used in parent form
@QuickForm(Owner.self)
class OwnerEditModel: Validatable {
    // ... other fields ...
    
    @PropertyEditor(keyPath: \Owner.address)
    var address = AddressEditModel()
    
    @PropertyEditor(keyPath: \Owner.billingAddress)
    var billingAddress = AddressEditModel()
}
```

### 2. Dynamic Form Generation

For forms that change based on data or user selections:

```swift
@QuickForm(TreatmentPlan.self)
class TreatmentPlanModel: Validatable {
    @PropertyEditor(keyPath: \TreatmentPlan.treatmentType)
    var treatmentType = PickerFieldViewModel(
        type: TreatmentType.self,
        allValues: TreatmentType.allCases,
        title: "Treatment Type"
    )
    
    @PropertyEditor(keyPath: \TreatmentPlan.medications)
    var medications = FormCollectionViewModel(
        type: MedicationPrescription.self,
        title: "Medications"
    )
    
    @PropertyEditor(keyPath: \TreatmentPlan.surgicalProcedures)
    var surgicalProcedures = FormCollectionViewModel(
        type: SurgicalProcedure.self,
        title: "Surgical Procedures"
    )
    
    @PostInit
    func configure() {
        treatmentType.onValueChanged { [weak self] newType in
            self?.updateAvailableOptions(for: newType)
        }
    }
    
    private func updateAvailableOptions(for type: TreatmentType) {
        switch type {
        case .medical:
            medications.isVisible = true
            surgicalProcedures.isVisible = false
        case .surgical:
            medications.isVisible = false
            surgicalProcedures.isVisible = true
        case .combined:
            medications.isVisible = true
            surgicalProcedures.isVisible = true
        }
    }
}
```

### 3. Custom Validation Rules

VetNet-specific validation rules for domain requirements:

```swift
// Age validation for pets
struct PetAgeValidationRule: ValidationRule {
    func validate(_ form: PatientEditModel) -> ValidationResult {
        guard let birthDate = form.dateOfBirth.value else {
            return .success
        }
        
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        
        if age < 0 {
            return .failure("Birth date cannot be in the future")
        }
        
        if age > 30 {
            return .failure("Please verify the birth date - this would make the pet over 30 years old")
        }
        
        return .success
    }
}

// Appointment scheduling validation
struct AppointmentAvailabilityRule: ValidationRule {
    func validate(_ form: AppointmentScheduleModel) -> ValidationResult {
        guard let timeSlot = form.timeSlot.value,
              let specialist = form.specialist.value else {
            return .success
        }
        
        // Check if the specialist is available at the selected time
        let isAvailable = SchedulingService.isSpecialistAvailable(
            specialist: specialist,
            timeSlot: timeSlot
        )
        
        return isAvailable ? 
            .success : 
            .failure("Selected specialist is not available at this time")
    }
}

// Medical record completeness validation
struct MedicalRecordCompletenessRule: ValidationRule {
    func validate(_ form: MedicalRecordModel) -> ValidationResult {
        if form.diagnoses.items.isEmpty && form.treatments.items.isEmpty {
            return .failure("At least one diagnosis or treatment must be recorded")
        }
        
        return .success
    }
}
```

## Testing Integration

### ViewInspector Integration

QuickForm forms integrate seamlessly with VetNet's ViewInspector testing strategy:

```swift
@Test("Patient form validates required fields")
func testPatientFormValidation() throws {
    let model = PatientEditModel()
    
    // Test empty form validation
    let emptyResult = model.validate()
    #expect(!emptyResult.isValid)
    #expect(emptyResult.errors.contains { $0.contains("Patient Name") })
    
    // Test valid form
    model.patientName.value = "Max"
    model.species.value = .dog
    
    let validResult = model.validate()
    #expect(validResult.isValid)
}

@Test("Patient form UI responds to validation")
func testPatientFormUI() throws {
    let view = PatientEditView()
    
    let patientNameField = try view.inspect()
        .find(viewWithAccessibilityIdentifier: "patient_name_field")
    
    let saveButton = try view.inspect()
        .find(viewWithAccessibilityIdentifier: "save_patient_button")
    
    // Initially save button should be disabled due to validation
    #expect(!try saveButton.button().isEnabled())
    
    // Fill required fields
    try patientNameField.textField().setValue("Max")
    
    // Now save button should be enabled
    #expect(try saveButton.button().isEnabled())
}
```

### Mock Integration

QuickForm works with VetNet's Mockable service layer:

```swift
@Mockable
protocol BreedService {
    func searchBreeds(species: Species, query: String) async throws -> [Breed]
}

@Test("Breed picker loads data asynchronously")
func testBreedPickerAsync() async throws {
    let mockService = MockBreedService()
    let expectedBreeds = [Breed(name: "Labrador"), Breed(name: "Golden Retriever")]
    
    given(mockService)
        .searchBreeds(species: .any, query: .any)
        .willReturn(expectedBreeds)
    
    let model = PatientEditModel(breedService: mockService)
    model.species.value = .dog
    
    // Wait for async breed loading
    try await Task.sleep(for: .milliseconds(100))
    
    #expect(model.breed.allValues == expectedBreeds)
}
```

## Performance Considerations

### 1. Observation Efficiency

QuickForm's macro-generated observation code is optimized for minimal re-renders:

- Uses `withObservationTracking` for efficient change detection
- Recursive observation pattern maintains continuous tracking
- Weak references prevent retain cycles

### 2. Async Data Loading

For async pickers and data sources:

```swift
// Debounced search to prevent excessive API calls
@PropertyEditor(keyPath: \Patient.breed)
var breed = AsyncPickerFieldViewModel(
    value: nil,
    title: "Breed",
    valuesProvider: { query in
        // Built-in debouncing prevents excessive API calls
        try await BreedService.searchBreeds(query: query)
    },
    debounceInterval: 0.3 // Wait 300ms after user stops typing
)
```

### 3. Memory Management

- Form models use `@weak self` in observation closures
- Property editors automatically clean up subscriptions
- Nested form models properly manage their observation lifecycle

## Security Considerations

### 1. Data Validation

All form inputs go through validation before being committed to the data model:

```swift
// Sanitize and validate all text inputs
@PropertyEditor(keyPath: \Patient.notes)
var notes = FormFieldViewModel(
    type: String?.self,
    title: "Notes",
    validation: .combined(
        .maxLength(2000),
        .custom { input in
            // Sanitize HTML/script content
            let sanitized = input?.sanitizeHTML() ?? ""
            return sanitized.count <= 2000 ? .success : .failure("Notes too long")
        }
    )
)
```

### 2. HIPAA Compliance

- Form data is not logged or persisted outside of approved data stores
- Sensitive fields can be marked for secure handling
- Validation errors don't leak sensitive information

## Best Practices

### 1. Form Organization

- **Single Responsibility**: Each form model should handle one logical entity
- **Composition**: Use nested form models for complex structures
- **Validation Grouping**: Group related validation rules together

### 2. User Experience

- **Progressive Disclosure**: Show/hide fields based on context
- **Smart Defaults**: Pre-populate fields when possible
- **Immediate Feedback**: Use real-time validation for better UX

### 3. Performance

- **Lazy Loading**: Load expensive data (like large picklists) on demand
- **Debouncing**: Use debouncing for search fields to reduce API calls
- **Caching**: Cache frequently accessed data (breeds, medications)

### 4. Accessibility

All QuickForm UI components include:

```swift
FormTextField(model.patientName)
    .accessibilityIdentifier("patient_name_field")
    .accessibilityLabel("Patient name input field")
    .accessibilityHint("Enter the patient's name")
```

## Conclusion

QuickForm provides VetNet with a powerful, type-safe, and declarative approach to form management that integrates seamlessly with SwiftUI and the existing architecture. The macro-driven approach eliminates boilerplate while maintaining full type safety and performance, making it ideal for the complex forms required in veterinary practice management.

The framework's reactive nature, comprehensive validation system, and SwiftUI integration align perfectly with VetNet's architectural goals of maintainability, testability, and excellent user experience.