import Foundation
import SwiftData

/// VTL protocol-based case assessment with urgency scoring and specialist routing recommendations
/// Implements intelligent triage assessment for veterinary case prioritization
@Model
final class TriageAssessment {
    
    /// Unique assessment identifier
    var assessmentID: UUID = UUID()
    
    /// VTL (Veterinary Triage Level) classification
    var vtlUrgencyLevel: VTLUrgencyLevel = VTLUrgencyLevel.green
    
    /// Systematic clinical evaluation
    var abcdeAssessment: ABCDEAssessment = ABCDEAssessment()
    
    /// AI-calculated complexity scoring
    var caseComplexityScore: Float = 0.0 // 0.0 - 1.0
    
    /// Ranked specialist suggestions
    var specialistRecommendations: [SpecialistRecommendation] = []
    
    /// Assessment metadata
    var assessmentDateTime: Date = Date()
    var assessedBy: String = ""
    var assessmentMethod: AssessmentMethod = AssessmentMethod.inPerson
    
    /// Clinical findings
    var presentingSymptoms: [String] = []
    var vitalSigns: VitalSigns?
    var painScore: Int? // 1-10 scale
    var behavioralObservations: String?
    
    /// Recommendations and actions
    var immediateActions: [String] = []
    var recommendedDiagnostics: [String] = []
    var estimatedWaitTime: TimeInterval? // in seconds
    
    /// Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // MARK: - Relationships
    
    /// Assessment belongs to a patient
    @Relationship(inverse: \Patient.assessments) 
    var patient: Patient?
    
    /// Assessment can be linked to an appointment
    @Relationship(inverse: \Appointment.triageAssessment)
    var appointment: Appointment?
    
    // MARK: - Initialization
    
    init(vtlLevel: VTLUrgencyLevel = VTLUrgencyLevel.green, assessedBy: String = "") {
        self.vtlUrgencyLevel = vtlLevel
        self.assessedBy = assessedBy
    }
}

// MARK: - Supporting Types

/// VTL (Veterinary Triage Level) urgency classification system
enum VTLUrgencyLevel: String, CaseIterable, Codable {
    case green = "Green" // Non-urgent, routine care
    case yellow = "Yellow" // Semi-urgent, can wait
    case orange = "Orange" // Urgent, priority care needed
    case red = "Red" // Emergency, immediate attention
    case black = "Black" // Critical, life-threatening
    
    /// Time window for care in minutes
    var maxWaitTime: Int {
        switch self {
        case .green: return 120 // 2 hours
        case .yellow: return 60 // 1 hour
        case .orange: return 30 // 30 minutes
        case .red: return 15 // 15 minutes
        case .black: return 0 // Immediate
        }
    }
    
    /// Priority score for scheduling (higher = more urgent)
    var priorityScore: Int {
        switch self {
        case .green: return 1
        case .yellow: return 3
        case .orange: return 7
        case .red: return 9
        case .black: return 10
        }
    }
}

/// ABCDE systematic assessment protocol for veterinary triage
struct ABCDEAssessment: Codable {
    var airway: AirwayAssessment
    var breathing: BreathingAssessment
    var circulation: CirculationAssessment
    var disability: DisabilityAssessment
    var exposure: ExposureAssessment
    
    init() {
        self.airway = AirwayAssessment()
        self.breathing = BreathingAssessment()
        self.circulation = CirculationAssessment()
        self.disability = DisabilityAssessment()
        self.exposure = ExposureAssessment()
    }
}

/// Airway assessment component
struct AirwayAssessment: Codable {
    var isPatent: Bool // Airway open and clear
    var obstructionPresent: Bool
    var interventionRequired: Bool
    var notes: String?
    
    init() {
        self.isPatent = true
        self.obstructionPresent = false
        self.interventionRequired = false
    }
}

/// Breathing assessment component
struct BreathingAssessment: Codable {
    var respiratoryRate: Int? // breaths per minute
    var respiratoryEffort: RespiratoryEffort
    var oxygenSaturation: Float? // percentage
    var abnormalSounds: Bool
    var notes: String?
    
    enum RespiratoryEffort: String, CaseIterable, Codable {
        case normal = "Normal"
        case increased = "Increased"
        case decreased = "Decreased"
        case absent = "Absent"
    }
    
    init() {
        self.respiratoryEffort = RespiratoryEffort.normal
        self.abnormalSounds = false
    }
}

/// Circulation assessment component
struct CirculationAssessment: Codable {
    var heartRate: Int? // beats per minute
    var pulseQuality: PulseQuality
    var capillaryRefillTime: Float? // seconds
    var mucousMembraneColor: MucousMembraneColor
    var bloodPressure: String? // "systolic/diastolic"
    var notes: String?
    
    enum PulseQuality: String, CaseIterable, Codable {
        case strong = "Strong"
        case weak = "Weak"
        case absent = "Absent"
        case irregular = "Irregular"
    }
    
    enum MucousMembraneColor: String, CaseIterable, Codable {
        case pink = "Pink"
        case pale = "Pale"
        case cyanotic = "Cyanotic"
        case icteric = "Icteric"
        case injected = "Injected"
    }
    
    init() {
        self.pulseQuality = PulseQuality.strong
        self.mucousMembraneColor = MucousMembraneColor.pink
    }
}

/// Neurological/disability assessment component
struct DisabilityAssessment: Codable {
    var consciousnessLevel: ConsciousnessLevel
    var motorFunction: MotorFunction
    var sensoryResponse: SensoryResponse
    var pupilResponse: PupilResponse
    var notes: String?
    
    enum ConsciousnessLevel: String, CaseIterable, Codable {
        case alert = "Alert"
        case lethargic = "Lethargic"
        case stuporous = "Stuporous"
        case comatose = "Comatose"
    }
    
    enum MotorFunction: String, CaseIterable, Codable {
        case normal = "Normal"
        case weakness = "Weakness"
        case paralysis = "Paralysis"
        case seizures = "Seizures"
    }
    
    enum SensoryResponse: String, CaseIterable, Codable {
        case normal = "Normal"
        case diminished = "Diminished"
        case absent = "Absent"
        case hyperresponsive = "Hyperresponsive"
    }
    
    enum PupilResponse: String, CaseIterable, Codable {
        case normal = "Normal"
        case dilated = "Dilated"
        case constricted = "Constricted"
        case unequal = "Unequal"
    }
    
    init() {
        self.consciousnessLevel = ConsciousnessLevel.alert
        self.motorFunction = MotorFunction.normal
        self.sensoryResponse = SensoryResponse.normal
        self.pupilResponse = PupilResponse.normal
    }
}

/// Exposure/environmental assessment component
struct ExposureAssessment: Codable {
    var bodyTemperature: Float? // Celsius
    var skinCondition: SkinCondition
    var hydrationStatus: HydrationStatus
    var bodyConditionScore: Int? // 1-9 scale
    var environmentalConcerns: [String]
    var notes: String?
    
    enum SkinCondition: String, CaseIterable, Codable {
        case normal = "Normal"
        case dry = "Dry"
        case oily = "Oily"
        case lesions = "Lesions"
        case parasites = "Parasites"
    }
    
    enum HydrationStatus: String, CaseIterable, Codable {
        case normal = "Normal"
        case mildDehydration = "Mild Dehydration"
        case moderateDehydration = "Moderate Dehydration"
        case severeDehydration = "Severe Dehydration"
    }
    
    init() {
        self.skinCondition = SkinCondition.normal
        self.hydrationStatus = HydrationStatus.normal
        self.environmentalConcerns = []
    }
}

/// Specialist recommendation from triage assessment
struct SpecialistRecommendation: Codable, Identifiable {
    let id = UUID()
    let specialty: SpecialtyType
    let priority: RecommendationPriority
    let reasoning: String
    let urgency: VTLUrgencyLevel
    let estimatedAppointmentDuration: Int // minutes
    
    enum RecommendationPriority: String, CaseIterable, Codable {
        case primary = "Primary"
        case secondary = "Secondary"
        case optional = "Optional"
    }
}

/// Vital signs measurements
struct VitalSigns: Codable {
    var temperature: Float? // Celsius
    var heartRate: Int? // beats per minute
    var respiratoryRate: Int? // breaths per minute
    var bloodPressureSystolic: Int? // mmHg
    var bloodPressureDiastolic: Int? // mmHg
    var weight: Float? // kg
    var painScore: Int? // 1-10 scale
    var measurementTime: Date
    var measuredBy: String?
    
    init(measurementTime: Date = Date()) {
        self.measurementTime = measurementTime
    }
}

/// Method used for triage assessment
enum AssessmentMethod: String, CaseIterable, Codable {
    case inPerson = "In Person"
    case telephone = "Telephone"
    case video = "Video Call"
    case ownerReported = "Owner Reported"
}