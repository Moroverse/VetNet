import SwiftUI
import SwiftData

@main
struct VetNetApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure SwiftData with all model types
            let schema = Schema([
                Patient.self,
                Owner.self,
                Appointment.self,
                MedicalDocument.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Configure dependencies
            DependencyConfiguration.configure(with: modelContainer)
            
        } catch {
            fatalError("Failed to configure SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
