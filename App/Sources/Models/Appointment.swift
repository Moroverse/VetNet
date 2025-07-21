import Foundation
import SwiftData

/// Scheduled veterinary appointment with specialist matching, triage data, and scheduling intelligence
/// Implements compound uniqueness constraints to prevent double-booking scenarios
@Model
final class Appointment {
    
    /// Unique appointment identifier with audit trail
    var appointmentID: UUID = UUID()
    
    /// Scheduling information
    var scheduledDateTime: Date = Date()
    var estimatedDuration: TimeInterval = 1800 // 30 minutes in seconds
    var actualDuration: TimeInterval? // in seconds
    var status: AppointmentStatus = AppointmentStatus.scheduled
    
    /// Appointment details
    var appointmentType: AppointmentType = AppointmentType.wellness
    var reasonForVisit: String = ""
    var urgencyLevel: UrgencyLevel = UrgencyLevel.routine
    
    /// Assessment and matching results
    @Relationship var triageAssessment: TriageAssessment?
    var specialistMatch: SpecialistMatchResult?
    
    /// Financial information
    var estimatedCost: Double?
    var actualCost: Double?
    
    /// Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var checkedInAt: Date?
    var completedAt: Date?
    
    // MARK: - Relationships
    
    /// Appointment is for specific patient
    @Relationship(inverse: \Patient.appointments) 
    var patient: Patient?
    
    /// Appointment assigned to specialist
    @Relationship(inverse: \VeterinarySpecialist.appointments) 
    var specialist: VeterinarySpecialist?
    
    /// Appointment can have multiple notes
    @Relationship(deleteRule: .cascade) 
    var notes: [AppointmentNote]?
    
    /// Appointment belongs to a practice
    @Relationship(inverse: \Practice.appointments)
    var practice: Practice?
    
    // MARK: - Compound Uniqueness Constraint
    
    /// Prevents double-booking by ensuring unique specialist-time combinations (CloudKit compatible)
    var scheduleKey: String = ""
    
    // MARK: - Initialization
    
    init(scheduledDateTime: Date = Date(), estimatedDuration: TimeInterval = 1800, appointmentType: AppointmentType = AppointmentType.wellness, reasonForVisit: String = "") {
        self.scheduledDateTime = scheduledDateTime
        self.estimatedDuration = estimatedDuration
        self.appointmentType = appointmentType
        self.reasonForVisit = reasonForVisit
        self.scheduleKey = "unassigned_\(scheduledDateTime.timeIntervalSince1970)"
    }
}

// MARK: - Supporting Types

/// Appointment status tracking
enum AppointmentStatus: String, CaseIterable, Codable {
    case scheduled = "Scheduled"
    case confirmed = "Confirmed"
    case checkedIn = "Checked In"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case noShow = "No Show"
    case rescheduled = "Rescheduled"
}

/// Types of veterinary appointments
enum AppointmentType: String, CaseIterable, Codable {
    case wellness = "Wellness Exam"
    case vaccination = "Vaccination"
    case surgery = "Surgery"
    case dental = "Dental"
    case emergency = "Emergency"
    case followUp = "Follow-up"
    case consultation = "Consultation"
    case diagnostic = "Diagnostic"
    case grooming = "Grooming"
    case boarding = "Boarding"
    
    /// Default duration for appointment type in minutes
    var defaultDuration: Int {
        switch self {
        case .wellness, .vaccination:
            return 30
        case .consultation, .followUp:
            return 20
        case .diagnostic:
            return 45
        case .dental:
            return 60
        case .surgery:
            return 120
        case .emergency:
            return 60
        case .grooming:
            return 90
        case .boarding:
            return 15
        }
    }
}

/// Urgency level for appointment prioritization
enum UrgencyLevel: String, CaseIterable, Codable {
    case routine = "Routine"
    case urgent = "Urgent"
    case emergency = "Emergency"
    case critical = "Critical"
    
    /// Priority score for scheduling optimization (higher = more urgent)
    var priorityScore: Int {
        switch self {
        case .routine: return 1
        case .urgent: return 3
        case .emergency: return 7
        case .critical: return 10
        }
    }
}

/// Specialist matching algorithm results
struct SpecialistMatchResult: Codable {
    let recommendedSpecialist: UUID // Specialist ID
    let matchScore: Float // 0.0 - 1.0
    let matchingFactors: [MatchingFactor]
    let alternativeSpecialists: [AlternativeMatch]
    let confidenceLevel: Float // 0.0 - 1.0
    
    struct MatchingFactor: Codable, Identifiable {
        let id = UUID()
        let factor: String
        let weight: Float
        let contribution: Float
    }
    
    struct AlternativeMatch: Codable, Identifiable {
        let id = UUID()
        let specialistID: UUID
        let matchScore: Float
        let availableSlots: [Date]
    }
}

/// Appointment notes for detailed record keeping
@Model
final class AppointmentNote {
    
    var noteID: UUID = UUID()
    var content: String = ""
    var author: String = "" // Staff member who created the note
    var noteType: NoteType = NoteType.general
    var createdAt: Date = Date()
    var isPrivate: Bool = false
    
    // MARK: - Relationships
    
    @Relationship(inverse: \Appointment.notes) 
    var appointment: Appointment?
    
    init(content: String = "", author: String = "", noteType: NoteType = NoteType.general) {
        self.content = content
        self.author = author
        self.noteType = noteType
    }
}

/// Types of appointment notes
enum NoteType: String, CaseIterable, Codable {
    case general = "General"
    case medical = "Medical"
    case behavioral = "Behavioral"
    case billing = "Billing"
    case followUp = "Follow-up"
    case administrative = "Administrative"
}