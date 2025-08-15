// PatientManagementView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import FactoryKit
import StateKit
import SwiftUI
import SwiftUIRouting

struct PatientManagementView: View {
    @InjectedObservable(\.patientManagementRouter) var router
    var body: some View {
        FormRouterView(router: router) {
            NavigationRouterView(router: router) {
                PatientListView()
            } destination: { (route: PatientRoute) in
                switch route {
                case let .patientDetail(patient):
                    PatientDetailsView(
                        patient: patient
                    )

                case .medicalHistory:
                    EmptyView()

                case .appointmentHistory:
                    EmptyView()
                }
            }
        } formContent: { mode in
            NavigationStack {
                PatientFormView(mode: mode) { result in
                    router.handleResult(result)
                }
            }
        }
    }
}

#Preview {
    PatientManagementView()
}

// MARK: - Placeholder Views (to be implemented in later tasks)

struct PatientListView: View {
    @InjectedObservable(\.patientManagementRouter) var router
    @State private var viewModel = PatientListViewModel()

    var body: some View {
        BasicList(viewModel: viewModel.listModel, isSearchable: true, listRow: { patient in
            PatientRowView(patient: patient)
                .contentShape(Rectangle())
                .onTapGesture {
                    router.navigateToPatientDetail(patient)
                }
        })
        .searchScopes($viewModel.listModel.selectedScope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue)
            }
        }
        .navigationTitle("Patients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {
                    Task {
                        await router.createPatient()
                    }
                }
            }
        }
        .task {
            // Load initial data
            await viewModel.initialLoad()
        }
        .refreshable {
            // Pull to refresh
            await viewModel.refreshList()
        }
    }
}

// MARK: - Patient Row View

struct PatientRowView: View {
    let patient: Patient

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(patient.name)
                    .font(.headline)
                Spacer()
                Text(ageText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("\(patient.species.description) • \(patient.breed.description)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(patient.medicalID)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            if !patient.ownerName.isEmpty {
                Text("Owner: \(patient.ownerName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("patient_row_\(patient.id.value.uuidString)")
    }

    private var ageText: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1

        let age = Calendar.current.dateComponents([.year, .month], from: patient.birthDate, to: Date())
        return formatter.string(from: age) ?? "Unknown age"
    }
}
