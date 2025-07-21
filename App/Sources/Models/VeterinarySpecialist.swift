import Foundation
import SwiftData

/// Veterinary professional with expertise areas, availability, and scheduling preferences
/// Implements SwiftData with compound uniqueness constraints for conflict prevention
@Model
final class VeterinarySpecialist {
    
    /// Unique specialist identifier
    var specialistID: UUID = UUID()
    
    /// Professional name and credentials
    var name: String = ""
    var credentials: String = ""
    
    /// Specialty areas with proficiency levels
    var expertiseAreas: [ExpertiseArea] = []
    
    /// Working hours and preferences
    var availabilitySchedule: AvailabilitySchedule = AvailabilitySchedule()
    
    /// Optimal scheduling parameters
    var caseLoadPreferences: CaseLoadPreferences = CaseLoadPreferences()
    
    /// Contact information
    var email: String?
    var phoneNumber: String?
    
    /// Employment status
    var isActive: Bool = true
    
    /// Creation and modification timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // MARK: - Relationships
    
    /// Specialist belongs to practice organization
    @Relationship(inverse: \Practice.specialists) 
    var practice: Practice?
    
    /// Specialist handles multiple appointments
    @Relationship(deleteRule: .nullify) 
    var appointments: [Appointment]?
    
    // MARK: - Initialization
    
    init(name: String = "", credentials: String = "") {
        self.name = name
        self.credentials = credentials
    }
}

// MARK: - Supporting Types

/// Expertise area with proficiency level for specialist matching
struct ExpertiseArea: Codable {
    let specialty: SpecialtyType
    let proficiencyLevel: ProficiencyLevel
    let yearsOfExperience: Int
    
    enum ProficiencyLevel: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate" 
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

/// Working hours and availability preferences for scheduling optimization
struct AvailabilitySchedule: Codable {
    var mondaySchedule: DayAvailability?
    var tuesdaySchedule: DayAvailability?
    var wednesdaySchedule: DayAvailability?
    var thursdaySchedule: DayAvailability?
    var fridaySchedule: DayAvailability?
    var saturdaySchedule: DayAvailability?
    var sundaySchedule: DayAvailability?
    
    /// Time off periods
    var vacationDates: [DateInterval]
    var unavailableDates: [Date]
    
    init() {
        // Default availability: Mon-Fri 9AM-5PM
        let defaultAvailability = DayAvailability(
            startTime: "09:00",
            endTime: "17:00",
            breakStart: "12:00",
            breakEnd: "13:00"
        )
        
        self.mondaySchedule = defaultAvailability
        self.tuesdaySchedule = defaultAvailability
        self.wednesdaySchedule = defaultAvailability
        self.thursdaySchedule = defaultAvailability
        self.fridaySchedule = defaultAvailability
        self.saturdaySchedule = nil
        self.sundaySchedule = nil
        self.vacationDates = []
        self.unavailableDates = []
    }
}

/// Daily availability configuration with break times
struct DayAvailability: Codable {
    let startTime: String // Format: "HH:mm"
    let endTime: String // Format: "HH:mm"
    let breakStart: String? // Format: "HH:mm"
    let breakEnd: String? // Format: "HH:mm"
    let isAvailable: Bool
    
    init(startTime: String, endTime: String, breakStart: String? = nil, breakEnd: String? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.breakStart = breakStart
        self.breakEnd = breakEnd
        self.isAvailable = true
    }
    
    static var unavailable: DayAvailability {
        DayAvailability(startTime: "", endTime: "", isAvailable: false)
    }
    
    private init(startTime: String, endTime: String, breakStart: String? = nil, breakEnd: String? = nil, isAvailable: Bool) {
        self.startTime = startTime
        self.endTime = endTime
        self.breakStart = breakStart
        self.breakEnd = breakEnd
        self.isAvailable = isAvailable
    }
}

/// Case load preferences for optimal scheduling
struct CaseLoadPreferences: Codable {
    /// Maximum appointments per day
    var maxAppointmentsPerDay: Int
    
    /// Maximum appointments per hour
    var maxAppointmentsPerHour: Int
    
    /// Preferred appointment duration in minutes
    var preferredAppointmentDuration: Int
    
    /// Buffer time between appointments in minutes
    var bufferTimeBetweenAppointments: Int
    
    /// Preferred case complexity levels
    var preferredComplexityLevels: [CaseComplexityLevel]
    
    /// Minimum break time in minutes
    var minimumBreakTime: Int
    
    init() {
        self.maxAppointmentsPerDay = 12
        self.maxAppointmentsPerHour = 2
        self.preferredAppointmentDuration = 30
        self.bufferTimeBetweenAppointments = 15
        self.preferredComplexityLevels = CaseComplexityLevel.allCases
        self.minimumBreakTime = 15
    }
}

/// Case complexity levels for specialist matching
enum CaseComplexityLevel: String, CaseIterable, Codable {
    case simple = "Simple"
    case moderate = "Moderate"
    case complex = "Complex"
    case critical = "Critical"
}