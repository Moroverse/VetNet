import Foundation
import SwiftData

@Model
final class Appointment: Sendable {
    @Attribute(.unique) var appointmentID: UUID
    var scheduledDate: Date
    var duration: TimeInterval
    var status: AppointmentStatus
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \Patient.appointments) var patient: Patient?
    
    init(
        scheduledDate: Date,
        duration: TimeInterval = 1800, // 30 minutes default
        status: AppointmentStatus = .scheduled,
        notes: String? = nil,
        patient: Patient? = nil
    ) {
        self.appointmentID = UUID()
        self.scheduledDate = scheduledDate
        self.duration = duration
        self.status = status
        self.notes = notes
        self.patient = patient
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum AppointmentStatus: String, CaseIterable, Codable, Sendable {
    case scheduled = "Scheduled"
    case confirmed = "Confirmed"
    case checkedIn = "Checked In"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case noShow = "No Show"
}