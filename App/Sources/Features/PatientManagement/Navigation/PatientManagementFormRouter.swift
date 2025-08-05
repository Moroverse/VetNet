// PatientManagementFormRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import FactoryKit
import Observation
import SwiftUIRouting

// MARK: - Patient Form Router

final class PatientManagementFormRouter: BaseFormRouter<PatientFormMode, PatientFormResult> {
    // MARK: - Form Routing Methods

    func createPatient() async -> PatientFormResult {
        await presentForm(.create)
    }

    func editPatient(_ patient: Patient) async -> PatientFormResult {
        await presentForm(.edit(patient))
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
