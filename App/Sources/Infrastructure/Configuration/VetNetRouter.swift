// VetNetRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:32 GMT.

import SwiftUI
import SwiftUIRouting

// MARK: - VetNet App Router

final class VetNetAppRouter: BaseAppRouter {
    // MARK: - Routes

    enum Route: Hashable {
        case patientList
        case createPatient
        case editPatient(String) // Patient ID
        case patientDetail(String) // Patient ID
    }

    // MARK: - Navigation

    func navigate(to route: Route) {
        switch route {
        case .patientList:
            // Clear navigation path to go to root
            navigationPath = NavigationPath()
        case .createPatient, .editPatient, .patientDetail:
            // For now, just show a success message
            // TODO: Implement proper navigation in Task 4
            showSuccess(message: "Navigation will be implemented in Task 4")
        }
    }

    // MARK: - Form Results

    func handlePatientFormResult(_ result: PatientFormResult) {
        switch result {
        case .saved:
            showSuccess(message: "Patient saved successfully")
        case .cancelled:
            // Just dismiss any overlay
            hideOverlay()
        case .deleted:
            showSuccess(message: "Patient deleted successfully")
        }
    }
}

// MARK: - Patient Form Result

enum PatientFormResult: RouteResult {
    case saved
    case cancelled
    case deleted

    // Required by RouteResult protocol
    typealias SuccessType = Void
    typealias ErrorType = Never

    var isSuccess: Bool {
        switch self {
        case .saved, .deleted: true
        case .cancelled: false
        }
    }

    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }

    var isError: Bool {
        false // No error cases in this simple implementation
    }

    var error: Never? {
        nil
    }
}

// MARK: - Placeholder Views (to be implemented in later tasks)

struct PatientFormView: View {
    enum Mode {
        case create
        case edit(String)
    }

    let mode: Mode

    var body: some View {
        Text("Patient Form - \(modeDescription)")
            .navigationTitle(modeDescription)
    }

    private var modeDescription: String {
        switch mode {
        case .create:
            "Create Patient"
        case .edit:
            "Edit Patient"
        }
    }
}

struct PatientDetailView: View {
    let patientId: String

    var body: some View {
        Text("Patient Detail: \(patientId)")
            .navigationTitle("Patient Details")
    }
}
