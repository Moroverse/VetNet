import SwiftUI
import SwiftUIRouting

@Observable
class PatientRouter: BaseFormRouter<PatientFormMode, PatientFormResult> {
    
    func createPatient() async -> PatientFormResult {
        await presentForm(.create)
    }
    
    func editPatient(_ patient: Patient) async -> PatientFormResult {
        await presentForm(.edit(patient))
    }
    
    func navigateToPatientDetail(_ patient: Patient) {
        navigate(to: PatientRoute.patientDetail(patient))
    }
}