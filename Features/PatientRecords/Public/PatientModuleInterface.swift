import Foundation
import FactoryKit
import SwiftData

// MARK: - Public Module Interface

// MARK: - Factory Extensions

extension Container {
    // MARK: - Core Dependencies
    
    var modelContext: Factory<ModelContext> {
        Factory(self) { @MainActor in
            // This should be provided by the app's main container
            fatalError("ModelContext must be registered by the app")
        }
        .scope(.singleton)
    }
    
    // MARK: - Repositories (MainActor isolated)
    
    var patientRepository: Factory<PatientRepository> {
        Factory(self) { @MainActor in
            SwiftDataPatientRepository(modelContext: self.modelContext())
        }
        .scope(.singleton)
    }
    
    var ownerRepository: Factory<OwnerRepository> {
        Factory(self) { @MainActor in
            SwiftDataOwnerRepository(modelContext: self.modelContext())
        }
        .scope(.singleton)
    }
    
    // MARK: - Services (Non-MainActor, work with pure domain models)
    
    var patientService: Factory<PatientService> {
        Factory(self) {
            PatientServiceImpl(repository: self.patientRepository())
        }
        .scope(.singleton)
    }
    
    var ownerService: Factory<OwnerService> {
        Factory(self) {
            // For now, keeping SampleOwnerService until we create OwnerServiceImpl
            SampleOwnerService()
        }
        .scope(.singleton)
    }
}

// MARK: - Public Types

public typealias PatientEntity = Patient
public typealias OwnerEntity = Owner
public typealias AnimalSpeciesType = AnimalSpecies
public typealias AnimalGenderType = AnimalGender


