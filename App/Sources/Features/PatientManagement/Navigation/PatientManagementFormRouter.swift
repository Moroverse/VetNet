// PatientManagementFormRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import FactoryKit
import Observation
import SwiftUIRouting

// MARK: - Patient Form Router

final class PatientManagementFormRouter: BaseFormRouter<PatientFormMode, PatientFormResult> {
    // MARK: - Properties

    /// Callback to refresh the patient list when a patient is created or updated
    var onPatientListNeedsRefresh: (() async -> Void)?

    // MARK: - Form Routing Methods

    func createPatient() async -> PatientFormResult {
        let result = await presentForm(.create)

        // Trigger list refresh if patient was created successfully
        if case .created = result {
            await onPatientListNeedsRefresh?()
        }

        return result
    }

    func editPatient(_ patient: Patient) async -> PatientFormResult {
        let result = await presentForm(.edit(patient))

        // Trigger list refresh if patient was updated successfully
        if case .updated = result {
            await onPatientListNeedsRefresh?()
        }

        return result
    }

    // MARK: - Navigation Methods

    func navigateToPatientDetail(_ patient: Patient) {
        navigate(to: PatientRoute.patientDetail(patient))
    }

    func navigateToMedicalHistory(_ patient: Patient) {
        navigate(to: PatientRoute.medicalHistory(patient))
    }

    func navigateToAppointmentHistory(_ patient: Patient) {
        navigate(to: PatientRoute.appointmentHistory(patient))
    }
}

extension Container {
    @MainActor
    var patientManagementRouter: Factory<PatientManagementFormRouter> {
        self {
            PatientManagementFormRouter()
        }
        .shared
    }
}
