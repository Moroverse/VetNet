// PatientFormView.swift
// Copyright (c) 2025 Moroverse
// VetNet Patient Creation View

import FactoryKit
import QuickForm
import SwiftUI
import SwiftUIRouting
import StateKit

// MARK: - Patient Creation View

struct PatientFormView: View {
    @State private var viewModel: PatientFormViewModel
    let mode: PatientFormMode
    let onResult: (PatientFormResult) -> Void

    init(
        mode: PatientFormMode,
        onResult: @escaping (PatientFormResult) -> Void
    ) {
        self.mode = mode
        let viewModel = if let patient = mode.patient {
            PatientFormViewModel(value: patient)
        } else {
            PatientFormViewModel(value: PatientComponents())
        }
        self._viewModel = State(initialValue: viewModel)
        self.onResult = onResult
    }

    var body: some View {
        Form {
            PatientInfoSection(viewModel: viewModel)

            OwnerInfoSection(viewModel: viewModel)

            MedicalInfoSection(viewModel: viewModel)
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        if let patient = await viewModel.save() {
                            let result: PatientFormResult = viewModel.isEditing ? .updated(patient) : .created(patient)
                            onResult(result)
                        }
                    }
                }
                .disabled(!viewModel.canSave || viewModel.formState == .saving)
                .accessibilityIdentifier("patient_creation_save_button")
            }
        }
        .alert("Error", isPresented: .constant(viewModel.formState.isError)) {
            Button("OK") {
                // State will be managed by view model based on user actions
            }
        } message: {
            Text(viewModel.formState.errorMessage ?? "An unknown error occurred")
        }
    }
}

// MARK: - Patient Info Section

struct PatientInfoSection: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        Section("Patient Details") {
            PatientNameField(viewModel: viewModel)
            PatientSpeciesField(viewModel: viewModel)
            PatientBreedField(viewModel: viewModel)
            PatientBirthDateField(viewModel: viewModel)
            PatientWeightField(viewModel: viewModel)
        }
    }
}

// MARK: - Owner Info Section

struct OwnerInfoSection: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        Section("Owner Information") {
            OwnerNameField(viewModel: viewModel)
            OwnerPhoneField(viewModel: viewModel)
            OwnerEmailField(viewModel: viewModel)
        }
    }
}

// MARK: - Medical Info Section

struct MedicalInfoSection: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        Section("Medical Information") {
            MedicalIDField(viewModel: viewModel)
            MicrochipField(viewModel: viewModel)
            NotesField(viewModel: viewModel)
        }
    }
}

// MARK: - Individual Field Views

struct PatientNameField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormTextField(viewModel.name)
            .accessibilityIdentifier("patient_creation_name_field")
    }
}

struct PatientSpeciesField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormPickerField(viewModel.species)
            .accessibilityIdentifier("patient_creation_species_picker")
    }
}

struct PatientBreedField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormPickerField(viewModel.breed)
            .accessibilityIdentifier("patient_creation_breed_picker")
    }
}

struct PatientBirthDateField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormDatePickerField(viewModel.birthDate)
            .accessibilityIdentifier("patient_creation_birth_date_picker")
    }
}

struct PatientWeightField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormValueUnitField(viewModel.weight)
            .accessibilityIdentifier("patient_creation_weight_field")
    }
}

struct OwnerNameField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormTextField(viewModel.ownerName)
            .accessibilityIdentifier("patient_creation_owner_name_field")
    }
}

struct OwnerPhoneField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormTextField(viewModel.ownerPhoneNumber)
            .keyboardType(.phonePad)
            .accessibilityIdentifier("patient_creation_owner_phone_field")
    }
}

struct OwnerEmailField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormOptionalTextField(viewModel.ownerEmail)
            .keyboardType(.emailAddress)
            .accessibilityIdentifier("patient_creation_owner_email_field")
    }
}

struct MedicalIDField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        HStack {
            FormTextField(viewModel.medicalID)
                .accessibilityIdentifier("patient_creation_medical_id_field")

            Button("Generate") {
                viewModel.generateMedicalID()
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("patient_creation_generate_medical_id_button")
        }
    }
}

struct MicrochipField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormOptionalTextField(viewModel.microchipNumber)
            .accessibilityIdentifier("patient_creation_microchip_field")
    }
}

struct NotesField: View {
    @Bindable var viewModel: PatientFormViewModel

    var body: some View {
        FormTextEditor(viewModel: viewModel.notes)
            .accessibilityIdentifier("patient_creation_notes_field")
    }
}

// MARK: - Form State Extensions

extension PatientFormState {
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
        case let .error(message), let .validationError(message):
            message
        default:
            nil
        }
    }
}


// MARK: - Preview Provider

struct PatientFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state with successful repository
            NavigationStack {
                PatientFormView(mode: .create) { result in
                    print("Result: \(result)")
                }
            }
            .previewDisplayName("Create Mode")

            // Edit mode
            NavigationStack {
                PatientFormView(mode: .edit(Patient(
                    name: "Buddy",
                    species: .dog,
                    breed: .dogLabrador,
                    birthDate: Date(),
                    weight: .init(value: 12.5, unit: .kilograms),
                    ownerName: "Alice Example",
                    ownerPhoneNumber: "123-456-7890"
                ))) { result in
                    print("Result: \(result)")
                }
            }
            .previewDisplayName("Edit Mode")

            // Preview with duplicate key error
            let _ = Container.shared.patientRepository.register { MockPatientRepository(behavior: .duplicateKeyError) }
            NavigationStack {
                PatientFormView(mode: .edit(Patient(
                    name: "Buddy",
                    species: .dog,
                    breed: .dogLabrador,
                    birthDate: Date(),
                    weight: .init(value: 12.5, unit: .kilograms),
                    ownerName: "Alice Example",
                    ownerPhoneNumber: "123-456-7890"
                ))) { result in
                    print("Result: \(result)")
                }
            }
            .previewDisplayName("Duplicate Key Error")

            // Preview with general error
            let _ = Container.shared.patientRepository.register { MockPatientRepository(behavior: .generalError) }
            NavigationStack {
                PatientFormView(mode: .edit(Patient(
                    name: "Buddy",
                    species: .dog,
                    breed: .dogLabrador,
                    birthDate: Date(),
                    weight: .init(value: 12.5, unit: .kilograms),
                    ownerName: "Alice Example",
                    ownerPhoneNumber: "123-456-7890"
                ))) { result in
                    print("Result: \(result)")
                }
            }
            .previewDisplayName("General Error")

            // Preview with slow response (saving state)
            let _ = Container.shared.patientRepository.register { MockPatientRepository(behavior: .slowResponse) }
            NavigationStack {
                PatientFormView(mode: .create) { result in
                    print("Result: \(result)")
                }
            }
            .previewDisplayName("Slow Response")
        }
    }
}
