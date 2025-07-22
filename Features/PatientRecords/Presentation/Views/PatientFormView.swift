import SwiftUI
import QuickForm

struct PatientFormView: View {
    @Bindable private var viewModel: PatientFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: PatientFormViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                patientSection
                ownerSection
                actionSection
            }
            .navigationTitle("New Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.formState == .saving)
                    .accessibilityIdentifier("cancel_patient_button")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            if viewModel.formState == .saved {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                    .accessibilityIdentifier("save_patient_button")
                }
            }
            .alert("Validation Error", isPresented: .constant(isValidationError)) {
                Button("OK") {
                    // Reset to editing state
                    viewModel.formState = .editing
                }
            } message: {
                if case .validationError(let message) = viewModel.formState {
                    Text(message)
                }
            }
            .alert("Save Error", isPresented: .constant(isSaveError)) {
                Button("OK") {
                    // Reset to editing state
                    viewModel.formState = .editing
                }
            } message: {
                if case .error(let message) = viewModel.formState {
                    Text(message)
                }
            }
        }
    }
    
    private var patientSection: some View {
        Section("Patient Information") {
            FormTextField(viewModel.name)
                .accessibilityIdentifier("patient_name_field")
            
            FormPickerField(viewModel.species)
                .accessibilityIdentifier("patient_species_picker")
            
            FormPickerField(viewModel.breed)
                .accessibilityIdentifier("patient_breed_picker")
            
            FormDatePickerField(
                viewModel.birthDate,
                range: viewModel.birthDateRange,
                style: .compact
            )
            .accessibilityIdentifier("patient_birth_date_picker")
            
            FormValueDimensionField(viewModel.weight)
                .accessibilityIdentifier("patient_weight_field")
            
            FormTextField(viewModel.microchipNumber)
                .accessibilityIdentifier("patient_microchip_field")
            
            FormTextEditor(viewModel.notes)
                .accessibilityIdentifier("patient_notes_editor")
        }
    }
    
    private var ownerSection: some View {
        Section("Owner Information") {
            FormTextField(viewModel.ownerFirstName)
                .accessibilityIdentifier("owner_first_name_field")
            
            FormTextField(viewModel.ownerLastName)
                .accessibilityIdentifier("owner_last_name_field")
            
            FormTextField(viewModel.ownerEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .accessibilityIdentifier("owner_email_field")
            
            FormTextField(viewModel.ownerPhoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .accessibilityIdentifier("owner_phone_field")
        }
    }
    
    private var actionSection: some View {
        Section {
            if viewModel.formState == .saving {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Saving patient...")
                        .foregroundColor(.secondary)
                }
                .accessibilityIdentifier("saving_indicator")
            }
        }
    }
    
    private var isValidationError: Bool {
        if case .validationError = viewModel.formState {
            return true
        }
        return false
    }
    
    private var isSaveError: Bool {
        if case .error = viewModel.formState {
            return true
        }
        return false
    }
}

// MARK: - Previews

struct PatientFormView_Previews: PreviewProvider {
    static var previews: some View {
        PatientFormView(
            viewModel: PatientFormViewModel(value: PatientComponents())
        )
        .previewDisplayName("Empty Form")

        let components = PatientComponents(
            name: "Luna",
            species: .cat,
            breed: "Persian",
            birthDate: Calendar.current.date(byAdding: .year, value: -2, to: Date()) ?? Date(),
            weight: Measurement(value: 4.2, unit: .kilograms),
            microchipNumber: "123456789012345",
            notes: "Very friendly cat, loves treats",
            ownerFirstName: "Jane",
            ownerLastName: "Smith",
            ownerEmail: "jane.smith@email.com",
            ownerPhoneNumber: "+1-555-123-4567"
        )

        return PatientFormView(
            viewModel: PatientFormViewModel(value: components)
        )
        .previewDisplayName("Filled Form")
    }
}
