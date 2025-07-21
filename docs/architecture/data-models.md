# Data Models

## Core Business Entities

The data model architecture leverages SwiftData with iOS 26 enhancements including custom DataStore protocols, compound uniqueness constraints, and performance optimization through strategic indexing.

## Practice Entity
**Purpose**: Represents veterinary practice organization with staff, specialists, and operational parameters

**Key Attributes**:
- `practiceID`: UUID - Unique practice identifier with CloudKit synchronization
- `name`: String - Practice name and branding information
- `location`: CLLocation - Geographic location for multi-location practices
- `operatingHours`: OperatingSchedule - Daily operating hours and holiday schedules
- `specialties`: [SpecialtyType] - Available veterinary specialties and services

**Relationships**:
- **One-to-Many with Specialist**: Practice contains multiple veterinary specialists
- **One-to-Many with Appointment**: Practice manages all appointment scheduling
- **One-to-Many with Patient**: Practice maintains patient database

**SwiftData Implementation**:
```swift
@Model
final class Practice {
    @Attribute(.unique) var practiceID: UUID
    var name: String
    var location: CLLocation?
    var operatingHours: OperatingSchedule
    var specialties: [SpecialtyType]
    
    @Relationship(deleteRule: .cascade) var specialists: [Specialist] = []
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var patients: [Patient] = []
    
    init(name: String, location: CLLocation? = nil) {
        self.practiceID = UUID()
        self.name = name
        self.location = location
        self.operatingHours = OperatingSchedule()
        self.specialties = []
    }
}
```

## Specialist Entity
**Purpose**: Veterinary professional with expertise areas, availability, and scheduling preferences

**Key Attributes**:
- `specialistID`: UUID - Unique specialist identifier
- `name`: String - Professional name and credentials
- `expertiseAreas`: [ExpertiseArea] - Specialty areas with proficiency levels
- `availabilitySchedule`: AvailabilitySchedule - Working hours and preferences
- `caseLoadPreferences`: CaseLoadPreferences - Optimal scheduling parameters

**Relationships**:
- **Many-to-One with Practice**: Specialist belongs to practice organization
- **One-to-Many with Appointment**: Specialist handles multiple appointments
- **Many-to-Many with SpecialtyType**: Specialist can cover multiple specialties

**SwiftData Implementation**:
```swift
@Model
final class Specialist {
    @Attribute(.unique) var specialistID: UUID
    var name: String
    var credentials: String
    var expertiseAreas: [ExpertiseArea]
    var availabilitySchedule: AvailabilitySchedule
    var caseLoadPreferences: CaseLoadPreferences
    
    @Relationship(inverse: \Practice.specialists) var practice: Practice?
    @Relationship(deleteRule: .nullify) var appointments: [Appointment] = []
    
    init(name: String, credentials: String) {
        self.specialistID = UUID()
        self.name = name
        self.credentials = credentials
        self.expertiseAreas = []
        self.availabilitySchedule = AvailabilitySchedule()
        self.caseLoadPreferences = CaseLoadPreferences()
    }
}
```

## Patient Entity
**Purpose**: Animal patient with medical history, owner information, and case complexity data

**Key Attributes**:
- `patientID`: UUID - Unique patient identifier with medical record number
- `name`: String - Patient name and identification
- `species`: AnimalSpecies - Species type affecting care protocols
- `medicalHistory`: MedicalHistory - Comprehensive health records
- `caseComplexity`: CaseComplexityProfile - AI-assessed complexity indicators

**Relationships**:
- **Many-to-One with Owner**: Patient belongs to pet owner
- **One-to-Many with Appointment**: Patient can have multiple appointments
- **One-to-Many with CaseAssessment**: Patient has assessment history

**SwiftData Implementation**:
```swift
@Model
final class Patient {
    @Attribute(.unique) var patientID: UUID
    var name: String
    var species: AnimalSpecies
    var breed: String?
    var dateOfBirth: Date?
    var medicalHistory: MedicalHistory
    var caseComplexity: CaseComplexityProfile
    
    @Relationship(inverse: \Owner.patients) var owner: Owner?
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var assessments: [CaseAssessment] = []
    
    init(name: String, species: AnimalSpecies) {
        self.patientID = UUID()
        self.name = name
        self.species = species
        self.medicalHistory = MedicalHistory()
        self.caseComplexity = CaseComplexityProfile()
    }
}
```

## Appointment Entity
**Purpose**: Scheduled veterinary appointment with specialist matching, triage data, and scheduling intelligence

**Key Attributes**:
- `appointmentID`: UUID - Unique appointment identifier with audit trail
- `scheduledDateTime`: Date - Appointment date and time with time zone handling
- `estimatedDuration`: TimeInterval - AI-predicted appointment duration
- `triageAssessment`: TriageAssessment - VTL protocol assessment results
- `specialistMatch`: SpecialistMatchResult - Intelligent matching algorithm results

**Relationships**:
- **Many-to-One with Patient**: Appointment is for specific patient
- **Many-to-One with Specialist**: Appointment assigned to specialist
- **One-to-One with TriageAssessment**: Appointment has initial assessment
- **One-to-Many with AppointmentNote**: Appointment can have multiple notes

**SwiftData Implementation**:
```swift
@Model
final class Appointment {
    @Attribute(.unique) var appointmentID: UUID
    var scheduledDateTime: Date
    var estimatedDuration: TimeInterval
    var actualDuration: TimeInterval?
    var status: AppointmentStatus
    var triageAssessment: TriageAssessment?
    var specialistMatch: SpecialistMatchResult?
    
    @Relationship(inverse: \Patient.appointments) var patient: Patient?
    @Relationship(inverse: \Specialist.appointments) var specialist: Specialist?
    @Relationship(deleteRule: .cascade) var notes: [AppointmentNote] = []
    
    // Compound uniqueness constraint preventing double-booking
    @Attribute(.unique) var scheduleKey: String { 
        "\(specialist?.specialistID.uuidString ?? "")_\(scheduledDateTime.timeIntervalSince1970)"
    }
    
    init(scheduledDateTime: Date, estimatedDuration: TimeInterval) {
        self.appointmentID = UUID()
        self.scheduledDateTime = scheduledDateTime
        self.estimatedDuration = estimatedDuration
        self.status = .scheduled
    }
}
```

## TriageAssessment Entity
**Purpose**: VTL protocol-based case assessment with urgency scoring and specialist routing recommendations

**Key Attributes**:
- `assessmentID`: UUID - Unique assessment identifier
- `vtlUrgencyLevel`: VTLUrgencyLevel - Five-level triage classification
- `abcdeAssessment`: ABCDEAssessment - Systematic clinical evaluation
- `caseComplexityScore`: Float - AI-calculated complexity scoring
- `specialistRecommendations`: [SpecialistRecommendation] - Ranked specialist suggestions

**SwiftData Implementation**:
```swift
@Model
final class TriageAssessment {
    @Attribute(.unique) var assessmentID: UUID
    var vtlUrgencyLevel: VTLUrgencyLevel
    var abcdeAssessment: ABCDEAssessment
    var caseComplexityScore: Float
    var specialistRecommendations: [SpecialistRecommendation]
    var assessmentDateTime: Date
    var assessedBy: String
    
    @Relationship(inverse: \Appointment.triageAssessment) var appointment: Appointment?
    @Relationship(inverse: \Patient.assessments) var patient: Patient?
    
    init(vtlLevel: VTLUrgencyLevel) {
        self.assessmentID = UUID()
        self.vtlUrgencyLevel = vtlLevel
        self.abcdeAssessment = ABCDEAssessment()
        self.caseComplexityScore = 0.0
        self.specialistRecommendations = []
        self.assessmentDateTime = Date()
        self.assessedBy = ""
    }
}
```
