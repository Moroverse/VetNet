import Foundation
import Factory
import SwiftData

// MARK: - Service Registrations
// Factory-based dependency injection for VetNet veterinary practice services

extension Container {
    
    // MARK: - Data Services
    
    /// SwiftData model container with CloudKit synchronization
    var modelContainer: Factory<ModelContainer> {
        self { 
            do {
                return try ModelContainer(
                    for: Practice.self, 
                         VeterinarySpecialist.self, 
                         Patient.self, 
                         Appointment.self,
                         TriageAssessment.self,
                    configurations: ModelConfiguration(
                        cloudKitDatabase: .private("VeterinaryPracticeData")
                    )
                )
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
        .singleton
    }
    
    /// Custom data store for veterinary-specific data handling
    var dataStore: Factory<VeterinaryDataStoreProtocol> {
        self { VeterinaryDataStore() }
            .singleton
    }
    
    // MARK: - Core Services
    
    /// Practice management service for veterinary practice operations
    var practiceService: Factory<PracticeServiceProtocol> {
        self { PracticeService(dataStore: self.dataStore()) }
            .singleton
    }
    
    /// Specialist management service for veterinary professional handling
    var specialistService: Factory<SpecialistServiceProtocol> {
        self { SpecialistService(dataStore: self.dataStore()) }
            .singleton
    }
    
    /// Patient management service for animal patient records
    var patientService: Factory<PatientServiceProtocol> {
        self { PatientService(dataStore: self.dataStore()) }
            .singleton
    }
    
    /// Appointment scheduling service with intelligent optimization
    var appointmentService: Factory<AppointmentServiceProtocol> {
        self { AppointmentService(
            dataStore: self.dataStore(),
            specialistService: self.specialistService()
        )}
        .singleton
    }
    
    // MARK: - Navigation Services
    
    /// SwiftUIRouting-based navigation service for veterinary workflows
    var navigationService: Factory<NavigationServiceProtocol> {
        self { NavigationService() }
            .singleton
    }
}