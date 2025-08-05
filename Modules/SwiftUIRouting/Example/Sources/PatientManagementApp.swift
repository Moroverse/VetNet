// PatientManagementApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import SwiftUI
import SwiftUIRouting

@main
struct PatientManagementApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var patientRepository = PatientRepository()
    @State private var patientRouter = PatientRouter()
    @State private var patientListViewModel: PatientListViewModel

    init() {
        let repository = PatientRepository()
        let router = PatientRouter()
        _patientRepository = State(initialValue: repository)
        _patientRouter = State(initialValue: router)
        _patientListViewModel = State(initialValue: PatientListViewModel(repository: repository, router: router))
    }

    var body: some View {
        FormRouterView(router: patientRouter) {
            NavigationRouterView(router: patientRouter) {
                PatientListView(
                    viewModel: patientListViewModel
                )
            } destination: { (route: PatientRoute) in
                switch route {
                case let .patientDetail(patient):
                    PatientDetailView(
                        patient: patient,
                        repository: patientRepository,
                        router: patientRouter
                    )
                }
            }
        } formContent: { mode in
            NavigationStack {
                CreatePatientForm(mode: mode) { result in
                    patientRouter.handleResult(result)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
