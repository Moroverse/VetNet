import Foundation
import SwiftData

/// Animal patient with medical history, owner information, and case complexity data
/// Implements SwiftData with CloudKit synchronization for comprehensive patient records
@Model
final class Patient {
    
    /// Unique patient identifier with medical record number
    var patientID: UUID = UUID()
    
    /// Patient identification
    var name: String = ""
    var species: AnimalSpecies = AnimalSpecies.dog
    var breed: String?
    var dateOfBirth: Date?
    var weight: Double? // in kg
    var color: String?
    var microchipNumber: String?
    
    /// Medical information
    var medicalHistory: MedicalHistory = MedicalHistory()
    var caseComplexity: CaseComplexityProfile = CaseComplexityProfile()
    var allergies: [String] = []
    var currentMedications: [String] = []
    
    /// Owner information
    var ownerName: String = ""
    var ownerEmail: String?
    var ownerPhone: String?
    var ownerAddress: String?
    
    /// Status and tracking
    var isActive: Bool = true
    var lastVisitDate: Date?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // MARK: - Relationships
    
    /// Patient can have multiple appointments
    @Relationship(deleteRule: .cascade) 
    var appointments: [Appointment]?
    
    /// Patient has assessment history
    @Relationship(deleteRule: .cascade) 
    var assessments: [TriageAssessment]?
    
    /// Patient belongs to a practice
    @Relationship(inverse: \Practice.patients)
    var practice: Practice?
    
    // MARK: - Initialization
    
    init(name: String = "", species: AnimalSpecies = AnimalSpecies.dog, ownerName: String = "") {
        self.name = name
        self.species = species
        self.ownerName = ownerName
    }
}

// MARK: - Supporting Types

/// Animal species classification for veterinary care protocols
enum AnimalSpecies: String, CaseIterable, Codable {
    case dog = "Dog"
    case cat = "Cat"
    case bird = "Bird"
    case rabbit = "Rabbit"
    case hamster = "Hamster"
    case guineaPig = "Guinea Pig"
    case ferret = "Ferret"
    case reptile = "Reptile"
    case fish = "Fish"
    case horse = "Horse"
    case cow = "Cow"
    case goat = "Goat"
    case sheep = "Sheep"
    case pig = "Pig"
    case other = "Other"
    
    /// Species-specific care requirements
    var careRequirements: SpeciesCareRequirements {
        switch self {
        case .dog, .cat:
            return SpeciesCareRequirements(
                typicalAppointmentDuration: 30,
                requiresSpecialHandling: false,
                commonConditions: ["Vaccination", "Dental", "Skin Issues"]
            )
        case .bird, .rabbit, .hamster, .guineaPig, .ferret:
            return SpeciesCareRequirements(
                typicalAppointmentDuration: 45,
                requiresSpecialHandling: true,
                commonConditions: ["Respiratory Issues", "Dietary Problems", "Behavioral Issues"]
            )
        case .reptile:
            return SpeciesCareRequirements(
                typicalAppointmentDuration: 60,
                requiresSpecialHandling: true,
                commonConditions: ["Temperature Issues", "Shedding Problems", "Parasites"]
            )
        case .horse, .cow, .goat, .sheep, .pig:
            return SpeciesCareRequirements(
                typicalAppointmentDuration: 90,
                requiresSpecialHandling: true,
                commonConditions: ["Hoof Care", "Vaccination", "Reproduction"]
            )
        default:
            return SpeciesCareRequirements(
                typicalAppointmentDuration: 45,
                requiresSpecialHandling: true,
                commonConditions: ["General Wellness", "Behavioral Assessment"]
            )
        }
    }
}

/// Species-specific care requirements for appointment scheduling
struct SpeciesCareRequirements: Codable {
    let typicalAppointmentDuration: Int // minutes
    let requiresSpecialHandling: Bool
    let commonConditions: [String]
}

/// Comprehensive medical history for patient care
struct MedicalHistory: Codable {
    var previousConditions: [MedicalCondition]
    var surgicalHistory: [SurgicalProcedure]
    var vaccinationRecords: [VaccinationRecord]
    var labResults: [LabResult]
    var notes: String
    
    init() {
        self.previousConditions = []
        self.surgicalHistory = []
        self.vaccinationRecords = []
        self.labResults = []
        self.notes = ""
    }
}

/// Medical condition record
struct MedicalCondition: Codable, Identifiable {
    let id = UUID()
    let condition: String
    let diagnosisDate: Date
    let treatingSpecialist: String?
    let resolved: Bool
    let notes: String?
}

/// Surgical procedure record
struct SurgicalProcedure: Codable, Identifiable {
    let id = UUID()
    let procedure: String
    let procedureDate: Date
    let surgeon: String
    let complications: String?
    let outcome: String?
}

/// Vaccination record
struct VaccinationRecord: Codable, Identifiable {
    let id = UUID()
    let vaccineName: String
    let administrationDate: Date
    let nextDueDate: Date?
    let veterinarian: String
    let batchNumber: String?
}

/// Laboratory result record
struct LabResult: Codable, Identifiable {
    let id = UUID()
    let testName: String
    let testDate: Date
    let results: String
    let referenceRange: String?
    let abnormalFlags: [String]
}

/// AI-assessed complexity indicators for case management
struct CaseComplexityProfile: Codable {
    var overallComplexityScore: Float // 0.0 - 1.0
    var complexityFactors: [ComplexityFactor]
    var riskLevel: RiskLevel
    var specialistRequirements: [SpecialtyType]
    var estimatedAppointmentDuration: Int // minutes
    var requiresEmergencyCapability: Bool
    
    init() {
        self.overallComplexityScore = 0.0
        self.complexityFactors = []
        self.riskLevel = RiskLevel.low
        self.specialistRequirements = []
        self.estimatedAppointmentDuration = 30
        self.requiresEmergencyCapability = false
    }
}

/// Complexity factors contributing to case assessment
struct ComplexityFactor: Codable, Identifiable {
    let id = UUID()
    let factor: String
    let weight: Float // Impact on overall complexity
    let description: String
}

/// Risk level classification for patient care
enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case critical = "Critical"
}