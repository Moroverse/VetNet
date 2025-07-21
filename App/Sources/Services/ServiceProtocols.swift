import Foundation
import SwiftUIRouting

// MARK: - Practice Service Protocol

protocol PracticeServiceProtocol {
    func createPractice(name: String, location: Foundation.URL?) async throws -> Practice
    func updatePractice(_ practice: Practice) async throws
    func deletePractice(_ practice: Practice) async throws
    func getAllPractices() async throws -> [Practice]
    func getPractice(by id: UUID) async throws -> Practice?
}

// MARK: - Specialist Service Protocol

protocol SpecialistServiceProtocol {
    func createSpecialist(name: String, credentials: String) async throws -> VeterinarySpecialist
    func updateSpecialist(_ specialist: VeterinarySpecialist) async throws
    func deleteSpecialist(_ specialist: VeterinarySpecialist) async throws
    func getAllSpecialists() async throws -> [VeterinarySpecialist]
    func getSpecialist(by id: UUID) async throws -> VeterinarySpecialist?
    func getSpecialistsByExpertise(_ expertise: SpecialtyType) async throws -> [VeterinarySpecialist]
    func getAvailableSpecialists(at date: Date) async throws -> [VeterinarySpecialist]
}

// MARK: - Patient Service Protocol

protocol PatientServiceProtocol {
    func createPatient(name: String, species: AnimalSpecies, ownerName: String) async throws -> Patient
    func updatePatient(_ patient: Patient) async throws
    func deletePatient(_ patient: Patient) async throws
    func getAllPatients() async throws -> [Patient]
    func getPatient(by id: UUID) async throws -> Patient?
    func searchPatients(query: String) async throws -> [Patient]
    func getPatientsByOwner(_ ownerName: String) async throws -> [Patient]
}

// MARK: - Appointment Service Protocol

protocol AppointmentServiceProtocol {
    func createAppointment(
        scheduledDateTime: Date,
        estimatedDuration: TimeInterval,
        appointmentType: AppointmentType,
        reasonForVisit: String,
        patientID: UUID,
        specialistID: UUID?
    ) async throws -> Appointment
    
    func updateAppointment(_ appointment: Appointment) async throws
    func cancelAppointment(_ appointment: Appointment) async throws
    func rescheduleAppointment(_ appointment: Appointment, newDateTime: Date) async throws
    
    func getAllAppointments() async throws -> [Appointment]
    func getAppointment(by id: UUID) async throws -> Appointment?
    func getAppointmentsForDate(_ date: Date) async throws -> [Appointment]
    func getAppointmentsForSpecialist(_ specialistID: UUID, on date: Date) async throws -> [Appointment]
    func getAppointmentsForPatient(_ patientID: UUID) async throws -> [Appointment]
    
    func findAvailableSlots(
        for specialistID: UUID,
        duration: TimeInterval,
        startDate: Date,
        endDate: Date
    ) async throws -> [Date]
}

// MARK: - Navigation Service Protocol

protocol NavigationServiceProtocol {
    var navigationPath: [VetNetRoute] { get }
    var currentAlert: AppAlert? { get }
    var isShowingAlert: Bool { get }
    
    func navigateToSchedule()
    func navigateToPatients() 
    func navigateToSpecialists()
    func navigateToAppointment(_ appointmentID: UUID)
    func navigateToPatient(_ patientID: UUID)
    func navigateToSpecialist(_ specialistID: UUID)
    func showAlert(_ alert: AppAlert)
    func dismissCurrentView()
    func dismissAlert()
}

// MARK: - Triage Service Protocol

protocol TriageServiceProtocol {
    func createTriageAssessment(
        patientID: UUID,
        vtlLevel: VTLUrgencyLevel,
        assessedBy: String
    ) async throws -> TriageAssessment
    
    func updateTriageAssessment(_ assessment: TriageAssessment) async throws
    func getTriageAssessment(by id: UUID) async throws -> TriageAssessment?
    func getTriageAssessmentsForPatient(_ patientID: UUID) async throws -> [TriageAssessment]
    
    func calculateComplexityScore(for assessment: TriageAssessment) async -> Float
    func recommendSpecialists(for assessment: TriageAssessment) async -> [SpecialistRecommendation]
}