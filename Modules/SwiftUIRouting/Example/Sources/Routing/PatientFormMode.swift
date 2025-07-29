import Foundation
import SwiftUIRouting

enum PatientFormMode: Identifiable, Hashable {
    case create
    case edit(Patient)
    
    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let patient):
            return "edit-\(patient.id.uuidString)"
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

typealias PatientFormResult = FormOperationResult<Patient>

enum PatientRoute: Hashable {
    case patientDetail(Patient)
}