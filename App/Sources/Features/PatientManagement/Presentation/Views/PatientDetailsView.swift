// PatientDetailsView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-13 15:33 GMT.

import SwiftUI

struct PatientDetailsView: View {
    @State private var viewModel: PatientDetailsViewModel

    init(patient: Patient) {
        _viewModel = State(initialValue: PatientDetailsViewModel(patient: patient))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                patientInfoSection
                ownerInfoSection
            }
            .padding()
        }
        .navigationTitle(viewModel.patient.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var patientInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patient Information")
                .font(.headline)

            LabeledContent("Name", value: viewModel.patient.name)
            LabeledContent("Species", value: viewModel.speciesDisplay)
            LabeledContent("Breed", value: viewModel.breedDisplay)
            LabeledContent("Medical ID", value: viewModel.patient.medicalID)
            LabeledContent("Age", value: viewModel.ageDisplay)
            LabeledContent("Weight", value: viewModel.weightDisplay)
        }
    }

    private var ownerInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Owner Information")
                .font(.headline)

            LabeledContent("Owner", value: viewModel.patient.ownerName)
            LabeledContent("Phone", value: viewModel.patient.ownerPhoneNumber)
            if let email = viewModel.patient.ownerEmail {
                LabeledContent("Email", value: email)
            }
        }
    }
}
