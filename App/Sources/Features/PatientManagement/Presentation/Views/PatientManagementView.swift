// PatientManagementView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import FactoryKit
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
                    PatientDetailView(
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
    var body: some View {
        List {
            Text("Patient 2")
            Text("Patient 2")
        }
        .navigationTitle("Patient Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {
                    Task {
                        await router.createPatient()
                    }
                }
            }
        }
    }
}

struct PatientDetailView: View {
    let patient: Patient
    let isReadOnly: Bool = false

    var body: some View {
        Text("Patient Detail: \(patient.name)")
            .navigationTitle("Patient Details")
    }
}
