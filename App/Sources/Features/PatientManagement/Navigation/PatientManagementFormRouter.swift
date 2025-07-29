//
//  PatientManagementFormRouter.swift
//  VetNet
//
//  Created by Daniel Moro on 24. 7. 2025..
//

import SwiftUIRouting
import Observation
import FactoryKit
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
