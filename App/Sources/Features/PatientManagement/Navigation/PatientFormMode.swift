//
//  PatientFormMode.swift
//  VetNet
//
//  Created by Daniel Moro on 24. 7. 2025..
//

enum PatientFormMode: Identifiable, Hashable {
    case create
    case edit(Patient)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let patient):
            return "edit-\(patient.id.value.uuidString)"
        }
    }
    
    var title: String {
        switch self {
        case .create:
            return "New Patient"
        case .edit:
            return "Edit Patient"
        }
    }
    
    var patient: Patient? {
        switch self {
        case .create:
            return nil
        case .edit(let patient):
            return patient
        }
    }
}
