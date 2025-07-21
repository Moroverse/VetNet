import Foundation
import SwiftData

/// Veterinary practice organization model with staff, specialists, and operational parameters
/// Implements SwiftData with CloudKit synchronization for multi-device practice management
@Model
final class Practice {
    
    /// Unique practice identifier with CloudKit synchronization
    var practiceID: UUID = UUID()
    
    /// Practice name and branding information
    var name: String = ""
    
    /// Geographic location for multi-location practices (stored as separate lat/long for SwiftData compatibility)
    var latitude: Double?
    var longitude: Double?
    
    /// Daily operating hours and holiday schedules
    var operatingHours: OperatingSchedule = OperatingSchedule()
    
    /// Available veterinary specialties and services
    var specialties: [SpecialtyType] = []
    
    /// Creation timestamp
    var createdAt: Date = Date()
    
    /// Last modification timestamp
    var updatedAt: Date = Date()
    
    // MARK: - Relationships
    
    /// Practice contains multiple veterinary specialists
    @Relationship(deleteRule: .cascade) 
    var specialists: [VeterinarySpecialist]?
    
    /// Practice manages all appointment scheduling
    @Relationship(deleteRule: .cascade) 
    var appointments: [Appointment]?
    
    /// Practice maintains patient database
    @Relationship(deleteRule: .cascade) 
    var patients: [Patient]?
    
    // MARK: - Initialization
    
    init(name: String = "", latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Supporting Types

/// Operating schedule configuration for veterinary practice
struct OperatingSchedule: Codable {
    var mondayHours: DaySchedule?
    var tuesdayHours: DaySchedule?
    var wednesdayHours: DaySchedule?
    var thursdayHours: DaySchedule?
    var fridayHours: DaySchedule?
    var saturdayHours: DaySchedule?
    var sundayHours: DaySchedule?
    var holidays: [Date]
    
    init() {
        // Default business hours: Mon-Fri 8AM-6PM, Sat 9AM-4PM
        let weekdaySchedule = DaySchedule(openTime: "08:00", closeTime: "18:00")
        let saturdaySchedule = DaySchedule(openTime: "09:00", closeTime: "16:00")
        
        self.mondayHours = weekdaySchedule
        self.tuesdayHours = weekdaySchedule
        self.wednesdayHours = weekdaySchedule
        self.thursdayHours = weekdaySchedule
        self.fridayHours = weekdaySchedule
        self.saturdayHours = saturdaySchedule
        self.sundayHours = nil // Closed Sundays by default
        self.holidays = []
    }
}

/// Daily operating hours configuration
struct DaySchedule: Codable {
    let openTime: String // Format: "HH:mm"
    let closeTime: String // Format: "HH:mm"
    let isClosed: Bool
    
    init(openTime: String, closeTime: String) {
        self.openTime = openTime
        self.closeTime = closeTime
        self.isClosed = false
    }
    
    static var closed: DaySchedule {
        DaySchedule(openTime: "", closeTime: "", isClosed: true)
    }
    
    private init(openTime: String, closeTime: String, isClosed: Bool) {
        self.openTime = openTime
        self.closeTime = closeTime
        self.isClosed = isClosed
    }
}

/// Veterinary specialty types available at the practice
enum SpecialtyType: String, CaseIterable, Codable {
    case general = "General Practice"
    case surgery = "Surgery"
    case `internal` = "Internal Medicine"
    case dermatology = "Dermatology"
    case ophthalmology = "Ophthalmology"
    case orthopedic = "Orthopedic Surgery"
    case cardiology = "Cardiology"
    case oncology = "Oncology"
    case neurology = "Neurology"
    case emergency = "Emergency Medicine"
    case dental = "Dentistry"
    case exotic = "Exotic Animal Medicine"
    case behavior = "Behavioral Medicine"
    case nutrition = "Clinical Nutrition"
    case rehabilitation = "Rehabilitation"
}
