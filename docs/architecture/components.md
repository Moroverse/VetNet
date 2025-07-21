# Components

## Intelligent Scheduling Engine
**Responsibility**: Core scheduling intelligence combining VTL protocols, specialist matching algorithms, and schedule optimization for optimal appointment routing

**Key Interfaces**:
- `assessCaseComplexity(symptoms: [Symptom], patient: Patient) -> CaseComplexityScore`
- `findOptimalSpecialist(assessment: TriageAssessment, availability: AvailabilityWindow) -> SpecialistMatchResult`
- `optimizeSchedule(appointments: [Appointment], constraints: SchedulingConstraints) -> ScheduleOptimization`

**Dependencies**: TriageProtocols package, CoreML integration, Metal Performance Shaders
**Technology Stack**: Swift 6.2+ structured concurrency, Core ML for predictive analytics, SwiftData for real-time data access

**Implementation Architecture**:
```swift
@MainActor
final class SchedulingEngine: ObservableObject {
    private let triageService: TriageService
    private let specialistMatcher: SpecialistMatchingService
    private let scheduleOptimizer: ScheduleOptimizationService
    
    @Published var currentOptimization: ScheduleOptimization?
    @Published var availableSpecialists: [SpecialistAvailability] = []
    
    func processAppointmentRequest(_ request: AppointmentRequest) async -> SchedulingRecommendation {
        // Implement intelligent scheduling workflow
    }
}
```

## Liquid Glass UI Framework
**Responsibility**: iOS 26 Liquid Glass design system implementation with veterinary-specific components and accessibility compliance

**Key Interfaces**:
- `GlassScheduleCalendar`: Interactive calendar with glass morphing effects
- `GlassSpecialistCard`: Specialist information with interactive glass presentation
- `GlassTriageForm`: QuickForm integration with glass visual effects
- `GlassAppointmentSheet`: Floating appointment details with glass background

**Dependencies**: SwiftUI iOS 26, Liquid Glass APIs, StateKit for complex states
**Technology Stack**: glassEffect() modifiers, GlassEffectContainer, interactive animations

**Implementation Architecture**:
```swift
struct GlassScheduleCalendar: View {
    @State private var selectedDate: Date = Date()
    @State private var appointments: [Appointment] = []
    
    var body: some View {
        GlassEffectContainer {
            CalendarView(selection: $selectedDate)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
            
            AppointmentListView(appointments: appointments)
                .glassEffect(.thin, in: .rect(cornerRadius: 12))
        }
    }
}
```

## VTL Triage Protocol Engine
**Responsibility**: Implementation of Veterinary Triage List protocols with ABCDE assessment integration and case complexity analysis

**Key Interfaces**:
- `assessVTLUrgency(symptoms: [Symptom], vitals: VitalSigns) -> VTLUrgencyLevel`
- `performABCDEAssessment(patient: Patient, observations: [ClinicalObservation]) -> ABCDEResult`
- `calculateComplexityScore(assessment: TriageAssessment, history: MedicalHistory) -> Float`

**Dependencies**: Medical protocol databases, Core ML for pattern recognition
**Technology Stack**: Structured assessment algorithms, machine learning integration

## SwiftUIRouting Navigation Service
**Responsibility**: Custom navigation framework optimized for veterinary workflows with deep linking and state preservation

**Key Interfaces**:
- `navigateToSchedule(appointmentID: UUID?) -> NavigationResult`
- `presentTriageFlow(patientID: UUID) -> TriageNavigationController`
- `handleDeepLink(url: URL) async -> DeepLinkResult`
- `preserveNavigationState() -> NavigationSnapshot`

**Dependencies**: SwiftUI NavigationStack, StateKit for complex navigation states
**Technology Stack**: Custom routing with deep link handling, veterinary workflow optimization
**Module Location**: `Modules/SwiftUIRouting`

**Implementation Architecture**:
```swift
@MainActor
final class VeterinaryNavigationController: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var currentFlow: VeterinaryWorkflow?
    
    private let router: SwiftUIRouter
    
    func navigateToPatientDetail(_ patientID: UUID) {
        navigationPath.append(VeterinaryDestination.patientDetail(patientID))
    }
    
    func startTriageWorkflow(for patient: Patient) {
        currentFlow = .triage(patient)
        navigationPath.append(VeterinaryDestination.triageAssessment(patient.id))
    }
}

enum VeterinaryDestination: Hashable {
    case scheduleCalendar
    case patientDetail(UUID)
    case triageAssessment(UUID)
    case specialistSelection(TriageAssessment)
    case appointmentConfirmation(Appointment)
}
```

## Real-time Synchronization Service
**Responsibility**: CloudKit-based multi-device synchronization with conflict resolution and offline capability

**Key Interfaces**:
- `syncAppointmentChanges() async -> SyncResult`
- `resolveSchedulingConflicts([ConflictingAppointment]) async -> ConflictResolution`
- `enableOfflineMode() -> OfflineCapabilities`

**Dependencies**: CloudKit, SwiftData custom DataStore protocol
**Technology Stack**: iOS 26 background sync, compound uniqueness constraints

## Specialist Matching Algorithm
**Responsibility**: AI-powered specialist-to-case matching considering expertise, availability, and practice optimization factors

**Key Interfaces**:
- `calculateSpecialistMatch(specialist: Specialist, assessment: TriageAssessment) -> MatchScore`
- `findOptimalTimeSlot(specialist: Specialist, duration: TimeInterval, urgency: VTLUrgencyLevel) -> TimeSlot?`
- `balanceWorkload(specialists: [Specialist], newAppointment: Appointment) -> WorkloadOptimization`

**Dependencies**: Core ML, historical outcome data, practice efficiency metrics
**Technology Stack**: Metal Performance Shaders for optimization, structured concurrency
