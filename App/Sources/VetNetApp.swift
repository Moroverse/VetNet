import SwiftUI
import SwiftData
import Factory

@main
struct VetNetApp: App {
    
    // SwiftData model container with CloudKit synchronization
    let modelContainer: ModelContainer
    
    init() {
        do {
            self.modelContainer = try VeterinaryDataStore.createModelContainer()
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .onAppear {
                    // Initialize any app-level setup here
                    setupVeterinaryServices()
                }
        }
    }
    
    private func setupVeterinaryServices() {
        // Services are automatically registered through Factory Container extensions
        // This method can be used for any additional initialization
    }
}
