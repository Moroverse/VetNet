import SwiftUI
import SwiftUIRouting

@Observable
class PatientListViewModel {
    private let repository: PatientRepository
    private let router: PatientRouter
    
    var searchText: String = ""
    
    var patients: [Patient] {
        repository.patients
    }
    
    var isLoading: Bool {
        repository.isLoading
    }
    
    var errorMessage: String? {
        get { repository.errorMessage }
        set { repository.errorMessage = newValue }
    }
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        }
        return patients.filter { patient in
            patient.name.localizedCaseInsensitiveContains(searchText) ||
            patient.medicalRecordNumber.localizedCaseInsensitiveContains(searchText) ||
            patient.condition.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(repository: PatientRepository, router: PatientRouter) {
        self.repository = repository
        self.router = router
    }
    
    func loadPatients() {
        repository.loadPatients()
    }
    
    func deletePatients(at offsets: IndexSet) {
        repository.deletePatients(at: offsets)
    }
    
    func addNewPatient() async {
        let result = await router.createPatient()
        await handleFormResult(result)
    }
    
    func navigateToPatient(_ patient: Patient) {
        router.navigateToPatientDetail(patient)
    }
    
    @MainActor
    private func handleFormResult(_ result: PatientFormResult) async {
        switch result {
        case .created(let patient):
            repository.addPatient(patient)
        case .updated(let patient):
            repository.updatePatient(patient)
        case .cancelled:
            break
        case .error(let error):
            errorMessage = error.localizedDescription
        }
    }
}