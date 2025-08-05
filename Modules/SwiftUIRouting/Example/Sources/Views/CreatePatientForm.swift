// CreatePatientForm.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import SwiftUI
import SwiftUIRouting

struct CreatePatientForm: View {
    @State private var viewModel: CreatePatientViewModel
    let onResult: (PatientFormResult) -> Void

    init(mode: PatientFormMode, onResult: @escaping (PatientFormResult) -> Void) {
        _viewModel = State(initialValue: CreatePatientViewModel(patient: mode.patient))
        self.onResult = onResult
    }

    var body: some View {
        Form {
            Section("Patient Information") {
                TextField("Full Name", text: $viewModel.name)
                    .textContentType(.name)

                TextField("Age", text: $viewModel.age)
                    .keyboardType(.numberPad)

                TextField("Medical Record Number", text: $viewModel.medicalRecordNumber)
                    .textContentType(.none)
                    .autocorrectionDisabled()

                TextField("Primary Condition", text: $viewModel.condition)
                    .textContentType(.none)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    savePatient()
                }
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
        }
        .disabled(viewModel.isLoading)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Saving...")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func savePatient() {
        Task {
            do {
                let patient = try await viewModel.save()
                let result: PatientFormResult = viewModel.isEditing ? .updated(patient) : .created(patient)
                onResult(result)
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview("Create Mode") {
    NavigationStack {
        CreatePatientForm(mode: .create) { result in
            print("Result: \(result)")
        }
    }
}

#Preview("Edit Mode") {
    NavigationStack {
        CreatePatientForm(mode: .edit(Patient.preview)) { result in
            print("Result: \(result)")
        }
    }
}
