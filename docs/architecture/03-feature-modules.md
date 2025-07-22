# Feature Module Specifications

## Overview

This document provides detailed specifications for each feature module in the VetNet application. Each module represents a distinct bounded context with its own domain models, business logic, and public interfaces following Domain-Driven Design principles.

Related documents: [01-modular-design.md](01-modular-design.md) | [04-data-models.md](04-data-models.md) | [06-workflows.md](06-workflows.md)

## Module Architecture Pattern

Each feature module follows the consistent internal structure detailed in [01-modular-design.md](01-modular-design.md):

- **Domain Layer**: Pure business logic with rich domain models
- **Application Layer**: Use cases and application services
- **Infrastructure Layer**: Technical implementations and external integrations
- **Presentation Layer**: SwiftUI views and @Observable view models
- **Public Layer**: External interfaces, DTOs, and domain events

## Scheduling Module

### Bounded Context
Appointment scheduling and calendar management for veterinary practices.

### Core Responsibilities
- Managing appointment lifecycle (create, update, cancel, complete)
- Scheduling conflict detection and resolution
- Time slot availability calculation with veterinary-specific constraints
- Specialist workload balancing and optimization
- Appointment duration prediction based on case complexity

### Internal Domain Models

```swift
// Domain/Models/Appointment.swift (Internal)
struct Appointment {
    let id: AppointmentId
    let timeSlot: TimeSlot
    let patientReference: PatientReference  // Just ID, not full patient
    let specialistReference: SpecialistReference
    let estimatedDuration: Duration
    let actualDuration: Duration?
    let status: AppointmentStatus
    let type: AppointmentType
    
    // Business logic methods
    func canReschedule(to newSlot: TimeSlot) -> Bool {
        guard status.allowsRescheduling else { return false }
        return !newSlot.overlaps(with: timeSlot)
    }
    
    func calculateBufferTime() -> Duration {
        switch type {
        case .emergency: return .minutes(15)
        case .surgery: return .minutes(30)
        case .routine: return .minutes(10)
        }
    }
}

// Domain/ValueObjects/TimeSlot.swift
struct TimeSlot: Equatable {
    let start: Date
    let end: Date
    
    func overlaps(with other: TimeSlot) -> Bool {
        return start < other.end && end > other.start
    }
    
    func duration() -> TimeInterval {
        return end.timeIntervalSince(start)
    }
}
```

### Public Interface

```swift
public protocol SchedulingModuleInterface {
    // Commands
    func scheduleAppointment(_ request: ScheduleAppointmentRequest) async throws -> AppointmentDTO
    func rescheduleAppointment(_ appointmentId: UUID, to newSlot: TimeSlotDTO) async throws -> AppointmentDTO
    func cancelAppointment(_ appointmentId: UUID, reason: String) async throws
    
    // Queries
    func getAvailableSlots(for date: Date, specialist: UUID?, duration: TimeInterval) async -> [TimeSlotDTO]
    func getAppointments(for date: Date) async -> [AppointmentDTO]
    func getDailySchedule(for specialist: UUID, date: Date) async -> DailyScheduleDTO
}
```

### Key Use Cases
- **ScheduleAppointmentUseCase**: Complex appointment creation with conflict resolution
- **OptimizeScheduleUseCase**: AI-powered schedule optimization using Metal Performance Shaders
- **BalanceWorkloadUseCase**: Even distribution of appointments across specialists
- **PredictDurationUseCase**: Machine learning-based appointment duration estimation

## Triage Module

### Bounded Context
Medical assessment and urgency classification using VTL (Veterinary Triage Level) protocols.

### Core Responsibilities
- VTL protocol implementation with five-level urgency classification
- ABCDE assessment workflow (Airway, Breathing, Circulation, Disability, Exposure)
- Case complexity scoring using AI-powered analysis
- Specialist recommendation engine based on assessment results
- Triage history tracking and outcome analysis

### Internal Domain Models

```swift
// Domain/Models/TriageAssessment.swift (Internal)
struct TriageAssessment {
    let id: AssessmentId
    let patientReference: PatientReference
    let vtlLevel: VTLUrgencyLevel
    let abcdeResults: ABCDEAssessment
    let complexityScore: ComplexityScore
    let symptoms: [Symptom]
    let vitalSigns: VitalSigns?
    let assessmentDateTime: Date
    
    // Business logic
    func calculateUrgency() -> UrgencyLevel {
        let baseUrgency = vtlLevel.baseUrgency
        let complexityModifier = complexityScore.urgencyModifier
        let vitalSignsModifier = vitalSigns?.urgencyModifier ?? 0
        
        return UrgencyLevel(base: baseUrgency, complexity: complexityModifier, vitals: vitalSignsModifier)
    }
    
    func recommendSpecialties() -> [SpecialtyRecommendation] {
        return symptoms.compactMap { symptom in
            SpecialtyRecommendation(
                specialty: symptom.primarySpecialty,
                confidence: calculateConfidence(for: symptom),
                urgency: calculateUrgency()
            )
        }
    }
}

// Domain/ValueObjects/VTLUrgencyLevel.swift
enum VTLUrgencyLevel: Int, CaseIterable {
    case red = 1      // Immediate - life-threatening
    case orange = 2   // Very urgent - 15 minutes
    case yellow = 3   // Urgent - 60 minutes
    case green = 4    // Standard - 4 hours
    case blue = 5     // Non-urgent - 24 hours
    
    var maxWaitTime: TimeInterval {
        switch self {
        case .red: return 0
        case .orange: return .minutes(15)
        case .yellow: return .minutes(60)
        case .green: return .hours(4)
        case .blue: return .hours(24)
        }
    }
    
    var colorCode: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        }
    }
}
```

### Public Interface

```swift
public protocol TriageModuleInterface {
    func startAssessment(for patientId: UUID) async throws -> AssessmentSessionDTO
    func submitAssessment(_ assessment: TriageSubmissionDTO) async throws -> TriageResultDTO
    func getAssessmentHistory(for patientId: UUID) async -> [TriageHistoryDTO]
    func calculateComplexity(_ symptoms: [SymptomDTO]) async -> ComplexityScoreDTO
}
```

### Key Use Cases
- **VTLAssessmentUseCase**: Apply VTL protocols for urgency classification
- **ABCDEEvaluationUseCase**: Systematic clinical assessment workflow
- **ComplexityScoringUseCase**: AI-powered case complexity calculation
- **SpecialistMatchingUseCase**: Recommend optimal specialists based on assessment

## Patient Records Module

### Bounded Context
Patient information and comprehensive medical history management.

### Core Responsibilities
- Patient demographics and identification management
- Medical history tracking with species-specific protocols
- Owner information and contact management
- Breed-specific health considerations and alerts
- Document and medical image storage with HIPAA compliance

### Internal Domain Models

```swift
// Domain/Models/Patient.swift (Internal)
struct Patient {
    let id: PatientId
    let name: String
    let species: Species
    let breed: Breed?
    let dateOfBirth: Date?
    let medicalRecord: MedicalRecord
    let owner: Owner
    let registrationDate: Date
    
    // Business logic
    func calculateAge() -> Age? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        return Age(from: dateOfBirth, to: Date())
    }
    
    func isVaccinationDue() -> Bool {
        return medicalRecord.vaccinations
            .filter { !$0.isExpired }
            .isEmpty
    }
    
    func getSpeciesSpecificProtocols() -> [Protocol] {
        return species.protocols + (breed?.specificProtocols ?? [])
    }
}

// Domain/Models/MedicalRecord.swift
struct MedicalRecord {
    let recordNumber: String
    let conditions: [MedicalCondition]
    let medications: [Medication]
    let allergies: [Allergy]
    let vaccinations: [Vaccination]
    let surgicalHistory: [Surgery]
    let diagnosticImages: [DiagnosticImage]
    
    func hasActiveCondition(_ condition: MedicalCondition.Type) -> Bool {
        return conditions.contains { type(of: $0) == condition && $0.isActive }
    }
    
    func getAllergicTo(_ medication: Medication) -> Bool {
        return allergies.contains { $0.isTriggeredBy(medication) }
    }
}
```

### Public Interface

```swift
public protocol PatientRecordsModuleInterface {
    func createPatient(_ request: CreatePatientRequest) async throws -> PatientDTO
    func updatePatient(_ patientId: UUID, updates: PatientUpdateRequest) async throws -> PatientDTO
    func getPatient(_ patientId: UUID) async throws -> PatientDTO
    func searchPatients(_ criteria: SearchCriteria) async -> [PatientSummaryDTO]
    func addMedicalRecord(_ patientId: UUID, record: MedicalRecordDTO) async throws
    func uploadDocument(_ patientId: UUID, document: DocumentDTO) async throws
}
```

## Specialist Management Module

### Bounded Context
Veterinary staff profiles, availability, and expertise management.

### Core Responsibilities
- Specialist profile management with credentials and certifications
- Availability schedule configuration and real-time updates
- Expertise area tracking with proficiency levels
- Workload preferences and capacity management
- Performance metrics and appointment outcome tracking

### Internal Domain Models

```swift
// Domain/Models/Specialist.swift (Internal)
struct Specialist {
    let id: SpecialistId
    let name: String
    let credentials: Credentials
    let expertiseAreas: [ExpertiseArea]
    let availability: AvailabilitySchedule
    let preferences: WorkPreferences
    let performanceMetrics: PerformanceMetrics
    
    // Business logic
    func canHandleCase(_ complexity: ComplexityScore) -> Bool {
        let maxComplexity = expertiseAreas
            .map(\.maxComplexityHandling)
            .max() ?? 0
        return complexity.value <= maxComplexity
    }
    
    func isAvailable(at timeSlot: TimeSlot) -> Bool {
        return availability.isAvailable(at: timeSlot) && 
               !preferences.avoidsTimeSlot(timeSlot)
    }
    
    func calculateWorkload(for date: Date) -> WorkloadScore {
        let scheduledAppointments = getScheduledAppointments(for: date)
        let totalDuration = scheduledAppointments.map(\.estimatedDuration).reduce(0, +)
        let availableDuration = availability.totalAvailableTime(for: date)
        
        return WorkloadScore(
            utilization: totalDuration / availableDuration,
            appointmentCount: scheduledAppointments.count,
            complexityAverage: scheduledAppointments.map(\.complexityScore).average()
        )
    }
}

// Domain/ValueObjects/ExpertiseArea.swift
struct ExpertiseArea {
    let specialty: VeterinarySpecialty
    let proficiencyLevel: ProficiencyLevel
    let yearsExperience: Int
    let certifications: [Certification]
    
    var maxComplexityHandling: Float {
        return proficiencyLevel.baseComplexity * 
               min(1.5, 1.0 + Float(yearsExperience) * 0.05)
    }
}
```

### Public Interface

```swift
public protocol SpecialistManagementInterface {
    func getSpecialist(_ specialistId: UUID) async throws -> SpecialistDTO
    func updateAvailability(_ specialistId: UUID, schedule: AvailabilityScheduleDTO) async throws
    func findSpecialists(for expertise: String) async -> [SpecialistSummaryDTO]
    func updatePreferences(_ specialistId: UUID, preferences: WorkPreferencesDTO) async throws
    func getPerformanceMetrics(_ specialistId: UUID) async -> PerformanceMetricsDTO
}
```

## Analytics Module

### Bounded Context
Practice performance insights and predictive analytics.

### Core Responsibilities
- Appointment metrics tracking and trend analysis
- Practice efficiency analysis with bottleneck identification
- Revenue reporting and financial performance tracking
- Patient flow visualization and optimization recommendations
- Predictive analytics for capacity planning and resource allocation

### Internal Domain Models

```swift
// Domain/Models/PracticeMetrics.swift (Internal)
struct PracticeMetrics {
    let period: DateRange
    let appointmentMetrics: AppointmentMetrics
    let patientFlowMetrics: PatientFlowMetrics
    let specialistUtilization: [SpecialistUtilization]
    let financialMetrics: FinancialMetrics
    let qualityMetrics: QualityMetrics
    
    // Analytics logic
    func calculateEfficiencyScore() -> EfficiencyScore {
        let appointmentEfficiency = appointmentMetrics.completionRate * appointmentMetrics.onTimeRate
        let resourceEfficiency = specialistUtilization.map(\.utilizationRate).average()
        let patientSatisfaction = qualityMetrics.satisfactionScore
        
        return EfficiencyScore(
            overall: (appointmentEfficiency + resourceEfficiency + patientSatisfaction) / 3,
            breakdown: EfficiencyBreakdown(
                appointments: appointmentEfficiency,
                resources: resourceEfficiency,
                satisfaction: patientSatisfaction
            )
        )
    }
    
    func identifyBottlenecks() -> [Bottleneck] {
        var bottlenecks: [Bottleneck] = []
        
        if patientFlowMetrics.averageWaitTime > .minutes(30) {
            bottlenecks.append(.excessiveWaitTimes(patientFlowMetrics.averageWaitTime))
        }
        
        let overutilizedSpecialists = specialistUtilization.filter { $0.utilizationRate > 0.9 }
        if !overutilizedSpecialists.isEmpty {
            bottlenecks.append(.overutilizedSpecialists(overutilizedSpecialists))
        }
        
        return bottlenecks
    }
    
    func generateInsights() -> [Insight] {
        let trends = calculateTrends()
        let predictions = generatePredictions()
        let recommendations = createRecommendations()
        
        return [trends, predictions, recommendations].flatMap { $0 }
    }
}
```

### Public Interface

```swift
public protocol AnalyticsModuleInterface {
    func getDashboardMetrics() async -> DashboardMetricsDTO
    func generateReport(_ type: ReportType, period: DateRange) async -> ReportDTO
    func subscribeToMetrics(_ metrics: [MetricType]) -> AsyncStream<MetricUpdateDTO>
    func predictCapacityNeeds(for period: DateRange) async -> CapacityPredictionDTO
    func identifyOptimizationOpportunities() async -> [OptimizationOpportunityDTO]
}
```

## Module Dependencies and Communication

### Inter-Module Communication Matrix

| Source Module | Target Module | Communication Type | Purpose |
|---------------|---------------|-------------------|---------|
| Triage | Patient Records | Direct Interface | Get patient medical history |
| Triage | Scheduling | Direct Interface | Create appointment from assessment |
| Scheduling | Specialist Management | Direct Interface | Check availability and expertise |
| Analytics | All Modules | Event Subscription | Collect metrics and performance data |
| Patient Records | All Modules | Domain Events | Notify of patient data changes |

### Event-Driven Communication

```swift
// Domain events published by modules
public struct AppointmentScheduledEvent: DomainEvent {
    public let appointmentId: UUID
    public let patientId: UUID
    public let specialistId: UUID
    public let scheduledTime: Date
    public let vtlLevel: VTLUrgencyLevel
}

public struct PatientRecordUpdatedEvent: DomainEvent {
    public let patientId: UUID
    public let updateType: PatientUpdateType
    public let timestamp: Date
}

public struct TriageCompletedEvent: DomainEvent {
    public let assessmentId: UUID
    public let patientId: UUID
    public let vtlLevel: VTLUrgencyLevel
    public let recommendedSpecialists: [UUID]
}
```

## Module Integration Testing Strategy

Each module includes integration points that must be tested:

### Scheduling Module Integration Points
- **With Triage**: Accept assessment results and create appropriate appointments
- **With Specialist Management**: Query availability and expertise for optimal matching
- **With Patient Records**: Validate patient information and update appointment history

### Triage Module Integration Points  
- **With Patient Records**: Access medical history for informed assessments
- **With Scheduling**: Seamlessly transition from assessment to appointment creation
- **With Specialist Management**: Get specialist recommendations based on expertise

### Patient Records Integration Points
- **With All Modules**: Provide consistent patient data access through DTOs
- **With Analytics**: Supply patient demographics and outcome data for reporting

## Related Documentation

- **[01-modular-design.md](01-modular-design.md)**: Modular architecture principles and patterns
- **[04-data-models.md](04-data-models.md)**: Persistence models supporting these domain models  
- **[06-workflows.md](06-workflows.md)**: Business workflows involving these modules
- **[09-testing-strategy.md](09-testing-strategy.md)**: Module testing strategies and integration testing