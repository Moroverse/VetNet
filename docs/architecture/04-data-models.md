# Data Models and Persistence

## Overview

This document details the data modeling strategy for VetNet, including the mapping between rich domain models, Data Transfer Objects (DTOs), and SwiftData persistence entities. The architecture employs a three-layer data approach to maintain clean boundaries while enabling efficient persistence and inter-module communication.

Related documents: [01-modular-design.md](01-modular-design.md) | [03-feature-modules.md](03-feature-modules.md) | [02-tech-stack.md](02-tech-stack.md)

## Modular Data Architecture

With the modular architecture, data models are organized into three distinct categories:

### Data Model Layers

**1. Internal Domain Models**: Rich domain objects with business logic, residing within feature modules
- Pure Swift objects with no persistence concerns
- Contain business rules and domain logic
- Module-specific and not shared across boundaries

**2. Data Transfer Objects (DTOs)**: Simple data structures for inter-module communication
- Codable structs with no business logic
- Used for module public interfaces
- Version-stable for API contracts

**3. Persistence Models**: SwiftData entities in the Infrastructure layer
- SwiftData @Model objects with CloudKit integration
- Designed for efficient storage and synchronization
- Support compound constraints and relationships

### Data Model Mapping Strategy

```swift
// Example: Appointment data flow across layers

// 1. Internal Domain Model (Features/Scheduling/Domain)
struct Appointment {
    let id: AppointmentId
    let timeSlot: TimeSlot
    let patientReference: PatientReference
    let specialistReference: SpecialistReference
    // Rich business logic methods
    func canReschedule(to newSlot: TimeSlot) -> Bool { ... }
}

// 2. DTO for public interface (Features/Scheduling/Public)
public struct AppointmentDTO: Codable {
    public let id: UUID
    public let startTime: Date
    public let endTime: Date
    public let patientId: UUID
    public let specialistId: UUID
    public let status: String
}

// 3. Persistence Model (Infrastructure/Persistence)
@Model
final class AppointmentEntity {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var patientId: UUID
    var specialistId: UUID
    var status: AppointmentStatus
    
    // SwiftData relationships
    @Relationship var patient: PatientEntity?
    @Relationship var specialist: SpecialistEntity?
}
```

## Core Business Entities

### Practice Entity
**Purpose**: Represents veterinary practice organization with staff, specialists, and operational parameters

**Key Attributes**:
- `practiceID`: UUID - Unique practice identifier with CloudKit synchronization
- `name`: String - Practice name and branding information  
- `location`: CLLocation - Geographic location for multi-location practices
- `operatingHours`: OperatingSchedule - Daily operating hours and holiday schedules
- `specialties`: [SpecialtyType] - Available veterinary specialties and services

**SwiftData Implementation**:
```swift
@Model
final class Practice {
    @Attribute(.unique) var practiceID: UUID
    var name: String
    var location: CLLocation?
    var operatingHours: OperatingSchedule
    var specialties: [SpecialtyType]
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var specialists: [Specialist] = []
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var patients: [Patient] = []
    @Relationship(deleteRule: .cascade) var owners: [Owner] = []
    
    init(name: String, location: CLLocation? = nil) {
        self.practiceID = UUID()
        self.name = name
        self.location = location
        self.operatingHours = OperatingSchedule()
        self.specialties = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Supporting Value Objects
struct OperatingSchedule: Codable {
    let weekdays: [DaySchedule]
    let holidays: [Holiday]
    let emergencyHours: EmergencySchedule?
    
    func isOpen(at date: Date) -> Bool {
        // Business logic for operating hours
    }
}
```

### Specialist Entity
**Purpose**: Veterinary professional with expertise areas, availability, and scheduling preferences

**Key Attributes**:
- `specialistID`: UUID - Unique specialist identifier
- `name`: String - Professional name and credentials
- `expertiseAreas`: [ExpertiseArea] - Specialty areas with proficiency levels  
- `availabilitySchedule`: AvailabilitySchedule - Working hours and preferences
- `caseLoadPreferences`: CaseLoadPreferences - Optimal scheduling parameters

**SwiftData Implementation**:
```swift
@Model
final class Specialist {
    @Attribute(.unique) var specialistID: UUID
    var name: String
    var credentials: String
    var licenseNumber: String
    var expertiseAreas: [ExpertiseArea]
    var availabilitySchedule: AvailabilitySchedule
    var caseLoadPreferences: CaseLoadPreferences
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \Practice.specialists) var practice: Practice?
    @Relationship(deleteRule: .nullify) var appointments: [Appointment] = []
    
    // Compound constraint preventing duplicate specialists in same practice
    @Attribute(.unique) var practiceSpecialistKey: String {
        "\(practice?.practiceID.uuidString ?? "")_\(licenseNumber)"
    }
    
    init(name: String, credentials: String, licenseNumber: String) {
        self.specialistID = UUID()
        self.name = name
        self.credentials = credentials
        self.licenseNumber = licenseNumber
        self.expertiseAreas = []
        self.availabilitySchedule = AvailabilitySchedule()
        self.caseLoadPreferences = CaseLoadPreferences()
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Supporting Value Objects
struct ExpertiseArea: Codable {
    let specialty: VeterinarySpecialty
    let proficiencyLevel: ProficiencyLevel
    let yearsExperience: Int
    let certifications: [String]
}

struct AvailabilitySchedule: Codable {
    let weeklySchedule: [DayAvailability]
    let exceptions: [ScheduleException]
    let preferences: [AvailabilityPreference]
}
```

### Patient Entity  
**Purpose**: Animal patient with medical history, owner information, and case complexity data

**Key Attributes**:
- `patientID`: UUID - Unique patient identifier with medical record number
- `name`: String - Patient name and identification
- `species`: AnimalSpecies - Species type affecting care protocols
- `medicalHistory`: MedicalHistory - Comprehensive health records
- `caseComplexity`: CaseComplexityProfile - AI-assessed complexity indicators

**SwiftData Implementation**:
```swift
@Model
final class Patient {
    @Attribute(.unique) var patientID: UUID
    var name: String
    var species: AnimalSpecies
    var breed: String?
    var dateOfBirth: Date?
    var gender: AnimalGender?
    var color: String?
    var microchipNumber: String?
    var medicalHistory: MedicalHistory
    var caseComplexity: CaseComplexityProfile
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \Owner.patients) var owner: Owner?
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var assessments: [CaseAssessment] = []
    @Relationship(deleteRule: .cascade) var medicalDocuments: [MedicalDocument] = []
    
    // Computed properties
    var age: TimeInterval? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        return Date().timeIntervalSince(dateOfBirth)
    }
    
    init(name: String, species: AnimalSpecies, owner: Owner) {
        self.patientID = UUID()
        self.name = name
        self.species = species
        self.medicalHistory = MedicalHistory()
        self.caseComplexity = CaseComplexityProfile()
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Supporting Value Objects
struct MedicalHistory: Codable {
    var conditions: [MedicalCondition]
    var medications: [Medication]
    var allergies: [Allergy]
    var vaccinations: [Vaccination]
    var surgicalHistory: [Surgery]
    
    init() {
        self.conditions = []
        self.medications = []
        self.allergies = []
        self.vaccinations = []
        self.surgicalHistory = []
    }
}

struct CaseComplexityProfile: Codable {
    var baseComplexity: Float
    var speciesModifier: Float
    var ageModifier: Float
    var medicalHistoryModifier: Float
    var lastUpdated: Date
    
    var overallComplexity: Float {
        return baseComplexity + speciesModifier + ageModifier + medicalHistoryModifier
    }
}
```

### Owner Entity
**Purpose**: Pet owner information and contact management

```swift
@Model
final class Owner {
    @Attribute(.unique) var ownerID: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var address: Address
    var emergencyContact: EmergencyContact?
    var preferredCommunication: CommunicationPreference
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var patients: [Patient] = []
    
    // Compound constraint preventing duplicate emails in same practice
    @Attribute(.unique) var emailKey: String { email.lowercased() }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(firstName: String, lastName: String, email: String, phoneNumber: String) {
        self.ownerID = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = Address()
        self.preferredCommunication = .email
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

### Appointment Entity
**Purpose**: Scheduled veterinary appointment with specialist matching, triage data, and scheduling intelligence

**Key Attributes**:
- `appointmentID`: UUID - Unique appointment identifier with audit trail
- `scheduledDateTime`: Date - Appointment date and time with time zone handling
- `estimatedDuration`: TimeInterval - AI-predicted appointment duration
- `triageAssessment`: TriageAssessment - VTL protocol assessment results
- `specialistMatch`: SpecialistMatchResult - Intelligent matching algorithm results

**SwiftData Implementation**:
```swift
@Model
final class Appointment {
    @Attribute(.unique) var appointmentID: UUID
    var scheduledDateTime: Date
    var estimatedDuration: TimeInterval
    var actualDuration: TimeInterval?
    var status: AppointmentStatus
    var type: AppointmentType
    var reason: String
    var notes: String?
    var triageAssessmentID: UUID?
    var specialistMatchResult: SpecialistMatchResult?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \Patient.appointments) var patient: Patient?
    @Relationship(inverse: \Specialist.appointments) var specialist: Specialist?
    @Relationship(deleteRule: .cascade) var appointmentNotes: [AppointmentNote] = []
    
    // Compound uniqueness constraint preventing double-booking
    @Attribute(.unique) var scheduleKey: String { 
        "\(specialist?.specialistID.uuidString ?? "")_\(scheduledDateTime.timeIntervalSince1970)"
    }
    
    // Validation constraints
    var endDateTime: Date {
        return scheduledDateTime.addingTimeInterval(estimatedDuration)
    }
    
    init(scheduledDateTime: Date, estimatedDuration: TimeInterval, type: AppointmentType) {
        self.appointmentID = UUID()
        self.scheduledDateTime = scheduledDateTime
        self.estimatedDuration = estimatedDuration
        self.type = type
        self.reason = ""
        self.status = .scheduled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Supporting Enums and Value Objects
enum AppointmentStatus: String, CaseIterable, Codable {
    case scheduled = "scheduled"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
}

enum AppointmentType: String, CaseIterable, Codable {
    case routine = "routine"
    case emergency = "emergency"
    case surgery = "surgery"
    case followUp = "follow_up"
    case vaccination = "vaccination"
}
```

### TriageAssessment Entity
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
    var symptoms: [String]
    var vitalSigns: VitalSigns?
    var notes: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship var patient: Patient?
    @Relationship var appointment: Appointment?
    
    init(vtlLevel: VTLUrgencyLevel, assessedBy: String) {
        self.assessmentID = UUID()
        self.vtlUrgencyLevel = vtlLevel
        self.assessedBy = assessedBy
        self.abcdeAssessment = ABCDEAssessment()
        self.caseComplexityScore = 0.0
        self.specialistRecommendations = []
        self.assessmentDateTime = Date()
        self.symptoms = []
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Supporting Value Objects
enum VTLUrgencyLevel: Int, CaseIterable, Codable {
    case red = 1      // Immediate
    case orange = 2   // Very urgent
    case yellow = 3   // Urgent
    case green = 4    // Standard
    case blue = 5     // Non-urgent
}

struct ABCDEAssessment: Codable {
    var airway: AssessmentResult
    var breathing: AssessmentResult
    var circulation: AssessmentResult
    var disability: AssessmentResult
    var exposure: AssessmentResult
    
    init() {
        self.airway = .notAssessed
        self.breathing = .notAssessed
        self.circulation = .notAssessed
        self.disability = .notAssessed
        self.exposure = .notAssessed
    }
}

struct VitalSigns: Codable {
    var temperature: Double?
    var heartRate: Int?
    var respiratoryRate: Int?
    var bloodPressure: String?
    var weight: Double?
    var measuredAt: Date
    
    init() {
        self.measuredAt = Date()
    }
}
```

## CloudKit Integration

### CloudKit Schema Design

**Custom Zones**:
- **PracticeZone**: Practice-specific data isolation
- **SharedZone**: Cross-practice data (if applicable for enterprise)

**Subscription Configuration**:
```swift
// CloudKit subscriptions for real-time updates
class CloudKitSubscriptionManager {
    func configureSubscriptions() {
        // Appointment updates
        let appointmentSubscription = CKQuerySubscription(
            recordType: "Appointment",
            predicate: NSPredicate(format: "TRUEPREDICATE"),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        // Patient record updates
        let patientSubscription = CKQuerySubscription(
            recordType: "Patient", 
            predicate: NSPredicate(format: "TRUEPREDICATE"),
            options: [.firesOnRecordUpdate]
        )
    }
}
```

### HIPAA Compliance Considerations

**Data Encryption**:
- All patient data encrypted at rest using CloudKit's encryption
- Additional layer of application-level encryption for sensitive fields
- Audit trails for all data access and modifications

**Access Control**:
- Practice-level data isolation through CloudKit zones
- Role-based access control within each practice
- Secure key management for encryption operations

## Data Transfer Objects (DTOs)

### Module Public Interface DTOs

```swift
// Scheduling Module DTOs
public struct AppointmentDTO: Codable {
    public let id: UUID
    public let patientId: UUID
    public let specialistId: UUID
    public let scheduledDateTime: Date
    public let estimatedDuration: TimeInterval
    public let status: String
    public let type: String
}

public struct TimeSlotDTO: Codable {
    public let start: Date
    public let end: Date
    public let isAvailable: Bool
    public let specialistId: UUID?
}

// Patient Records Module DTOs  
public struct PatientDTO: Codable {
    public let id: UUID
    public let name: String
    public let species: String
    public let breed: String?
    public let ownerId: UUID
    public let lastVisit: Date?
}

// Triage Module DTOs
public struct TriageResultDTO: Codable {
    public let assessmentId: UUID
    public let vtlLevel: Int
    public let complexityScore: Float
    public let recommendedSpecialists: [UUID]
    public let urgentCare: Bool
}
```

## Performance Optimizations

### Compound Constraints
Prevention of scheduling conflicts and data integrity:

```swift
@Model
final class Appointment {
    // Prevents double-booking of specialists
    @Attribute(.unique) var scheduleKey: String { 
        "\(specialist?.specialistID.uuidString ?? "")_\(scheduledDateTime.timeIntervalSince1970)"
    }
}

@Model  
final class Patient {
    // Prevents duplicate microchip numbers
    @Attribute(.unique) var microchipKey: String? {
        microchipNumber?.isEmpty == false ? microchipNumber : nil
    }
}
```

### Query Optimization

**Efficient Relationship Queries**:
```swift
// Optimized queries using predicates
func getAppointmentsForDate(_ date: Date, specialist: Specialist) -> [Appointment] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    
    let predicate = #Predicate<Appointment> { appointment in
        appointment.scheduledDateTime >= startOfDay &&
        appointment.scheduledDateTime < endOfDay &&
        appointment.specialist == specialist
    }
    
    return context.fetch(FetchDescriptor(predicate: predicate))
}
```

## Related Documentation

- **[03-feature-modules.md](03-feature-modules.md)**: Domain models within each feature module
- **[02-tech-stack.md](02-tech-stack.md)**: SwiftData and CloudKit technology choices  
- **[08-security-performance.md](08-security-performance.md)**: HIPAA compliance and data encryption strategies
- **[01-modular-design.md](01-modular-design.md)**: Data flow patterns between modules