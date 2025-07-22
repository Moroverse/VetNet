import Foundation
import SwiftData
import FactoryKit

/// Configure app-level dependencies
@MainActor
final class DependencyConfiguration {
    static func configure(with modelContainer: ModelContainer) {
        // Register the ModelContext for the entire app
        Container.shared.modelContext.register {
            modelContainer.mainContext
        }
    }
}