// PatientCreationView.swift
// Copyright (c) 2025 Moroverse
// VetNet Patient Creation View

import FactoryKit
import QuickForm
import SwiftUI
import SwiftUIRouting
import StateKit

// MARK: - Patient Creation View

struct PatientCreationView: View {
    @State private var viewModel: PatientCreationFormViewModel

    init(viewModel: PatientCreationFormViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Form {
                PatientInfoSection(viewModel: viewModel)

                OwnerInfoSection(viewModel: viewModel)

                MedicalInfoSection(viewModel: viewModel)
            }
            .navigationTitle("New Patient")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.cancel()
                    }
                    .accessibilityIdentifier("patient_creation_cancel_button")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .disabled(!viewModel.canSave || viewModel.formState == .saving)
                    .accessibilityIdentifier("patient_creation_save_button")
                }
            }
//            .onChange(of: viewModel.formState) { _, newState in
//                handleFormStateChange(newState)
//            }
            .alert("Error", isPresented: .constant(viewModel.formState.isError)) {
                Button("OK") {
                    // State will be managed by view model based on user actions
                }
            } message: {
                Text(viewModel.formState.errorMessage ?? "An unknown error occurred")
            }
        }
    }
    // FIXME: -
//    private func handleFormStateChange(_ newState: PatientCreationFormState) {
//        switch newState {
//        case .saved(let patient):
//            router.dismissSheet()
//            router.navigate(to: PatientProfileRoute(patientId: patient.id))
//        default:
//            break
//        }
//    }
}

// MARK: - Patient Info Section

struct PatientInfoSection: View {
    @Bindable var viewModel: PatientCreationFormViewModel

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
    @Bindable var viewModel: PatientCreationFormViewModel

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
    @Bindable var viewModel: PatientCreationFormViewModel

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
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormTextField(viewModel.name)
            .accessibilityIdentifier("patient_creation_name_field")
    }
}

struct PatientSpeciesField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormPickerField(viewModel.species)
            .accessibilityIdentifier("patient_creation_species_picker")
    }
}

struct PatientBreedField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormPickerField(viewModel.breed)
            .accessibilityIdentifier("patient_creation_breed_picker")
    }
}

struct PatientBirthDateField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormDatePickerField(viewModel.birthDate)
            .accessibilityIdentifier("patient_creation_birth_date_picker")
    }
}

struct PatientWeightField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormValueUnitField(viewModel.weight)
            .accessibilityIdentifier("patient_creation_weight_field")
    }
}

struct OwnerNameField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormTextField(viewModel.ownerName)
            .accessibilityIdentifier("patient_creation_owner_name_field")
    }
}

struct OwnerPhoneField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormTextField(viewModel.ownerPhoneNumber)
            .keyboardType(.phonePad)
            .accessibilityIdentifier("patient_creation_owner_phone_field")
    }
}

struct OwnerEmailField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormOptionalTextField(viewModel.ownerEmail)
            .keyboardType(.emailAddress)
            .accessibilityIdentifier("patient_creation_owner_email_field")
    }
}

struct MedicalIDField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

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
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormOptionalTextField(viewModel.microchipNumber)
            .accessibilityIdentifier("patient_creation_microchip_field")
    }
}

struct NotesField: View {
    @Bindable var viewModel: PatientCreationFormViewModel

    var body: some View {
        FormTextEditor(viewModel: viewModel.notes)
            .accessibilityIdentifier("patient_creation_notes_field")
    }
}

// MARK: - Form State Extensions

extension PatientCreationFormState {
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

// MARK: - Routing Support

// FIXME: -
// struct PatientProfileRoute: AppRoute {
//    let patientId: Patient.ID
//
//    func body(router: Router) -> some View {
//        PatientProfileView(patientId: patientId)
//    }
// }

// MARK: - Preview Provider

struct PatientCreationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state with successful repository
            PatientCreationView(viewModel: PatientCreationFormViewModel(value: .init()))
                .previewDisplayName("Normal Flow")

            // Preview with duplicate key error
            let _ = Container.shared.patientRepository.register { MockPatientRepository(behavior: .duplicateKeyError) }
            PatientCreationView(viewModel: PatientCreationFormViewModel(value: .init()))
                .previewDisplayName("Duplicate Key Error")

            // Preview with general error
            let _ = Container.shared.patientRepository.register { MockPatientRepository(behavior: .generalError) }
            PatientCreationView(viewModel: PatientCreationFormViewModel(value: .init()))
                .previewDisplayName("General Error")

            // Preview with slow response (saving state)
            let _ = Container.shared.patientRepository.register { MockPatientRepository(behavior: .slowResponse) }
            PatientCreationView(viewModel: PatientCreationFormViewModel(value: .init()))
                .previewDisplayName("Slow Response")
        }
    }
}

// MARK: - Mock Repository for Previews

private class MockPatientRepository: PatientRepositoryProtocol {
    enum Behavior {
        case success
        case duplicateKeyError
        case generalError
        case slowResponse
    }

    private let behavior: Behavior

    init(behavior: Behavior = .success) {
        self.behavior = behavior
    }

    func create(_ patient: Patient) async throws -> Patient {
        switch behavior {
        case .success:
            return patient
        case .duplicateKeyError:
            throw RepositoryError.duplicateKey("medicalID: \(patient.medicalID)")
        case .generalError:
            throw RepositoryError.databaseError("Network connection failed")
        case .slowResponse:
            try await Task.sleep(for: .seconds(3))
            return patient
        }
    }

    // MARK: - Required Protocol Methods (Stub implementations for preview)

    func findById(_ id: Patient.ID) async throws -> Patient? { nil }
    func update(_ patient: Patient) async throws -> Patient { patient }
    func delete(_ id: Patient.ID) async throws {}
    func findAll() async throws -> [Patient] { [] }
    func findByMedicalID(_ medicalID: String) async throws -> Patient? { nil }
    func searchByName(_ nameQuery: String) async throws -> [Patient] { [] }
    func findBySpecies(_ species: Species) async throws -> [Patient] { [] }
    func findByOwnerName(_ ownerName: String) async throws -> [Patient] { [] }
    func findCreatedBetween(startDate: Date, endDate: Date) async throws -> [Patient] { [] }
    func findWithPagination(limit: Int) async throws -> Paginated<Patient> { Paginated(items: []) }
    func searchByNameWithPagination(_ nameQuery: String, limit: Int) async throws -> Paginated<Patient> { Paginated(items: []) }
    func count() async throws -> Int { 0 }
    func medicalIDExists(_ medicalID: String) async throws -> Bool { false }
}
