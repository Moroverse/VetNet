//
//  PatientRoute.swift
//  VetNet
//
//  Created by Daniel Moro on 24. 7. 2025..
//

/// Navigation routes for patient management module
/// Defines the different destinations within the patient management flow
enum PatientRoute: Hashable {
    case patientDetail(Patient)
    case medicalHistory(Patient)
    case appointmentHistory(Patient)
}