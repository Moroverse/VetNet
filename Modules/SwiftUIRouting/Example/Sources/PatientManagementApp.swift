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
        self._patientRepository = State(initialValue: repository)
        self._patientRouter = State(initialValue: router)
        self._patientListViewModel = State(initialValue: PatientListViewModel(repository: repository, router: router))
    }
    
    var body: some View {
        FormRouterView(router: patientRouter) {
            NavigationRouterView(router: patientRouter) {
                PatientListView(
                    viewModel: patientListViewModel
                )
            } destination: { (route: PatientRoute) in
                switch route {
                case .patientDetail(let patient):
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