# Coding Standards and Swift 6.2+ Guidelines

## Overview

This document establishes the coding standards and development guidelines for VetNet, emphasizing Swift 6.2+ modern patterns, iOS 26 best practices, and veterinary-specific naming conventions. These standards ensure code consistency, maintainability, and architectural coherence across the modular codebase.

Related documents: [02-tech-stack.md](02-tech-stack.md) | [01-modular-design.md](01-modular-design.md) | [07-ios26-specifications.md](07-ios26-specifications.md)

## Critical Architecture Rules

### SwiftData + CloudKit Integration Rule

**Rule**: All data models must use @Model macro with proper relationships and CloudKit-compatible types

**Implementation**: Use compound uniqueness constraints (@Attribute(.unique)) to prevent scheduling conflicts

**Rationale**: Ensures data integrity across devices and prevents double-booking scenarios critical for veterinary practices

```swift
// Correct: Proper SwiftData model with constraints
@Model
final class Appointment {
    @Attribute(.unique) var appointmentID: UUID
    var scheduledDateTime: Date
    var estimatedDuration: TimeInterval
    
    // Compound constraint preventing double-booking
    @Attribute(.unique) var scheduleKey: String { 
        "\(specialist?.specialistID.uuidString ?? "")_\(scheduledDateTime.timeIntervalSince1970)"
    }
    
    @Relationship(inverse: \Patient.appointments) var patient: Patient?
    @Relationship(inverse: \Specialist.appointments) var specialist: Specialist?
}

// Incorrect: Missing constraints and relationships
@Model
class BadAppointment {
    var id: UUID
    var time: Date
    // Missing relationships and constraints
}
```

### Liquid Glass Implementation Rule

**Rule**: All UI components must use GlassEffectContainer when implementing multiple glass elements

**Implementation**: Group related glass effects within containers, use glassEffectID for morphing animations

**Rationale**: Prevents visual inconsistencies and achieves research-validated performance improvements

```swift
// Correct: Proper glass effect grouping
struct SchedulingInterface: View {
    var body: some View {
        GlassEffectContainer {
            VStack {
                CalendarView()
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                    .glassEffectID("calendar")
                
                SpecialistList()
                    .glassEffect(.thin, in: .rect(cornerRadius: 12))
                    .glassEffectID("specialists")
            }
        }
    }
}

// Incorrect: Individual glass effects without container
struct BadSchedulingInterface: View {
    var body: some View {
        VStack {
            CalendarView()
                .glassEffect(.regular, in: .rect(cornerRadius: 16))
            SpecialistList()
                .glassEffect(.thin, in: .rect(cornerRadius: 12))
        }
    }
}
```

### Structured Concurrency Rule

**Rule**: All scheduling algorithms must use Swift 6.2+ structured concurrency patterns with proper task group management

**Implementation**: Use TaskGroup for parallel specialist optimization, async/await for all service calls

**Rationale**: Maximizes iOS 26 performance improvements and prevents data races in complex scheduling logic

```swift
// Correct: Structured concurrency for scheduling operations
func optimizeAllSpecialistSchedules() async -> [ScheduleOptimization] {
    await withTaskGroup(of: ScheduleOptimization.self) { group in
        for specialist in specialists {
            group.addTask {
                await optimizeIndividualSchedule(specialist)
            }
        }
        
        var results: [ScheduleOptimization] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}

// Incorrect: Legacy completion handlers or unstructured tasks
func optimizeLegacySchedule(completion: @escaping ([ScheduleOptimization]) -> Void) {
    // Avoid this pattern in iOS 26 architecture
    DispatchQueue.global().async {
        // Legacy async pattern - don't use
    }
}
```

### Accessibility Integration Rule

**Rule**: All custom UI components must integrate iOS 26 accessibility features with proper semantic markup

**Implementation**: Implement VoiceOver descriptions, Dynamic Type support, and Accessibility Reader compatibility

**Rationale**: Ensures professional medical software compliance and usability for all veterinary staff

```swift
// Correct: Comprehensive accessibility implementation
struct AccessibleSpecialistCard: View {
    let specialist: Specialist
    
    var body: some View {
        VStack {
            Text(specialist.name)
                .accessibilityLabel("Specialist name: \(specialist.name)")
                .accessibilityIdentifier("specialist_name_\(specialist.id)")
            
            Text(specialist.credentials)
                .accessibilityLabel("Credentials: \(specialist.credentials)")
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            selectSpecialist(specialist)
        }
    }
}

// Incorrect: Missing accessibility implementation
struct InaccessibleCard: View {
    let specialist: Specialist
    
    var body: some View {
        VStack {
            Text(specialist.name)
            Text(specialist.credentials)
        }
        // Missing accessibility labels and identifiers
    }
}
```

## Naming Conventions

| Element | Convention | Example | Rationale |
|---------|------------|---------|----------|
| **Data Models** | PascalCase with descriptive names | `VeterinarySpecialist`, `AppointmentSchedule` | Clear domain representation |
| **Service Protocols** | PascalCase ending with 'Service' | `TriageAssessmentService`, `SchedulingOptimizationService` | Consistent service identification |
| **SwiftUI Views** | PascalCase ending with 'View' | `GlassScheduleCalendarView`, `SpecialistMatchingView` | Clear UI component identification |
| **State Properties** | camelCase with @Observable | `@Observable var currentSchedulingState` | Swift property conventions |
| **Core ML Models** | PascalCase ending with 'Model' | `CaseComplexityModel`, `SpecialistMatchingModel` | ML model identification |
| **Accessibility IDs** | snake_case with component hierarchy | `schedule_calendar_grid`, `specialist_card_123` | Consistent testing identification |

## Swift 6.2+ Language Patterns

### Modern Concurrency Patterns

```swift
// Correct: TaskGroup for parallel operations
func processMultiplePatients(_ patients: [Patient]) async -> [ProcessingResult] {
    await withTaskGroup(of: ProcessingResult.self) { group in
        for patient in patients {
            group.addTask {
                await processPatient(patient)
            }
        }
        
        var results: [ProcessingResult] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}

// Correct: AsyncSequence for streaming data
func appointmentUpdates() -> AsyncStream<AppointmentUpdate> {
    AsyncStream { continuation in
        let observer = NotificationCenter.default.addObserver(
            forName: .appointmentUpdated,
            object: nil,
            queue: .main
        ) { notification in
            if let update = notification.object as? AppointmentUpdate {
                continuation.yield(update)
            }
        }
        
        continuation.onTermination = { _ in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// Incorrect: Legacy concurrency patterns
func legacyProcessing() {
    DispatchQueue.global().async {
        // Don't use raw GCD in Swift 6.2+
    }
}
```

### @Observable State Management

```swift
// Correct: @Observable with proper encapsulation
@Observable
final class SchedulingViewModel {
    private(set) var appointments: [Appointment] = []
    private(set) var selectedDate: Date = Date()
    private(set) var isLoading: Bool = false
    
    private let schedulingService: SchedulingService
    
    init(schedulingService: SchedulingService) {
        self.schedulingService = schedulingService
    }
    
    func selectDate(_ date: Date) {
        selectedDate = date
        Task {
            await loadAppointments(for: date)
        }
    }
    
    @MainActor
    private func loadAppointments(for date: Date) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            appointments = try await schedulingService.getAppointments(for: date)
        } catch {
            // Handle error appropriately
            appointments = []
        }
    }
}

// Incorrect: ObservableObject with legacy patterns
class LegacyViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []
    // Using ObservableObject instead of @Observable
}
```

### SwiftData Relationship Patterns

```swift
// Correct: Proper relationship definition with delete rules
@Model
final class Patient {
    @Attribute(.unique) var patientID: UUID
    var name: String
    var species: AnimalSpecies
    
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(inverse: \Owner.patients) var owner: Owner?
    
    init(name: String, species: AnimalSpecies) {
        self.patientID = UUID()
        self.name = name
        self.species = species
    }
}

@Model
final class Appointment {
    @Relationship(inverse: \Patient.appointments, deleteRule: .nullify) 
    var patient: Patient?
    
    @Relationship(inverse: \Specialist.appointments, deleteRule: .nullify) 
    var specialist: Specialist?
}

// Incorrect: Missing relationships or improper delete rules
@Model
class BadPatient {
    var id: UUID
    var name: String
    // Missing proper relationships
}
```

## Module Organization Standards

### Feature Module Structure

```swift
// Correct: Clean module boundaries with proper dependencies
// Features/Scheduling/Public/SchedulingModuleInterface.swift
public protocol SchedulingModuleInterface {
    func scheduleAppointment(_ request: ScheduleAppointmentRequest) async throws -> AppointmentDTO
    func getAvailableSlots(date: Date, duration: TimeInterval) async -> [TimeSlotDTO]
}

// Features/Scheduling/Application/SchedulingModule.swift
final class SchedulingModule: SchedulingModuleInterface {
    private let repository: AppointmentRepository
    private let eventBus: EventBus
    
    init(repository: AppointmentRepository, eventBus: EventBus) {
        self.repository = repository
        self.eventBus = eventBus
    }
    
    public func scheduleAppointment(_ request: ScheduleAppointmentRequest) async throws -> AppointmentDTO {
        // Implementation with proper error handling
    }
}

// Incorrect: Tight coupling and mixed responsibilities
class BadModule {
    // Direct database access from module
    let database: SQLiteDatabase
    
    // Mixed UI and business logic
    func scheduleAndShowAlert() {
        // Don't mix concerns
    }
}
```

### Error Handling Standards

```swift
// Correct: Structured error handling with domain-specific errors
enum SchedulingError: LocalizedError {
    case appointmentConflict(conflictingAppointment: Appointment)
    case specialistUnavailable(specialistId: UUID)
    case invalidTimeSlot(reason: String)
    case patientNotFound(patientId: UUID)
    
    var errorDescription: String? {
        switch self {
        case .appointmentConflict(let appointment):
            return "Appointment conflicts with existing appointment at \(appointment.scheduledDateTime)"
        case .specialistUnavailable(let id):
            return "Specialist \(id) is not available at the requested time"
        case .invalidTimeSlot(let reason):
            return "Invalid time slot: \(reason)"
        case .patientNotFound(let id):
            return "Patient \(id) not found"
        }
    }
}

// Usage with proper error propagation
func scheduleAppointment(_ request: ScheduleAppointmentRequest) async throws -> Appointment {
    guard let patient = await repository.findPatient(request.patientId) else {
        throw SchedulingError.patientNotFound(patientId: request.patientId)
    }
    
    let conflicts = await repository.findConflicts(for: request.timeSlot, specialist: request.specialistId)
    guard conflicts.isEmpty else {
        throw SchedulingError.appointmentConflict(conflictingAppointment: conflicts.first!)
    }
    
    return try await repository.save(createAppointment(from: request))
}

// Incorrect: Generic errors without context
func badScheduling() throws {
    throw NSError(domain: "Error", code: 1) // Not helpful
}
```

## Testing Standards

### Test Naming and Organization

```swift
// Correct: Descriptive test names following Given-When-Then
@Suite("Scheduling Engine Tests")
struct SchedulingEngineTests {
    
    @Test("Given conflicting appointments When scheduling new appointment Then returns conflict error")
    func testSchedulingWithConflicts() async throws {
        // Given
        let existingAppointment = createTestAppointment()
        let mockRepository = MockAppointmentRepository()
        mockRepository.findConflictsReturnValue = [existingAppointment]
        
        let engine = SchedulingEngine(repository: mockRepository)
        
        // When
        let request = ScheduleAppointmentRequest(
            timeSlot: existingAppointment.timeSlot,
            specialistId: existingAppointment.specialistId
        )
        
        // Then
        await #expect(throws: SchedulingError.appointmentConflict) {
            try await engine.scheduleAppointment(request)
        }
    }
}

// Incorrect: Unclear test names and structure
struct BadTests {
    @Test("test1")
    func test1() {
        // What does this test?
    }
}
```

### Accessibility Testing Standards

```swift
// Correct: Comprehensive accessibility testing
@Test("Specialist card has proper accessibility labels and identifiers")
func testSpecialistCardAccessibility() throws {
    let specialist = createTestSpecialist(name: "Dr. Smith")
    let card = SpecialistCard(specialist: specialist)
    
    let inspectedCard = try card.inspect()
    
    // Test accessibility identifier consistency
    #expect(
        try inspectedCard.accessibilityIdentifier() == "specialist_card_\(specialist.id)",
        "Card should have consistent accessibility identifier"
    )
    
    // Test accessibility label descriptiveness
    let expectedLabel = "Dr. Smith, Veterinarian, Specializes in Internal Medicine"
    #expect(
        try inspectedCard.accessibilityLabel() == expectedLabel,
        "Card should have descriptive accessibility label"
    )
    
    // Test VoiceOver navigation
    #expect(
        try inspectedCard.accessibilityTraits().contains(.button),
        "Card should be accessible as button"
    )
}
```

## Code Documentation Standards

### Documentation Comments

```swift
// Correct: Comprehensive documentation with examples
/// Calculates the optimal scheduling for veterinary appointments using AI-powered algorithms.
///
/// This service leverages Metal Performance Shaders for hardware acceleration and implements
/// the VTL (Veterinary Triage Level) protocol for urgency-based scheduling optimization.
///
/// ## Usage
/// ```swift
/// let engine = SchedulingEngine()
/// let result = await engine.optimizeSchedule(specialists: specialists, appointments: appointments)
/// ```
///
/// ## Performance
/// - Completes optimization in <1 second for up to 500 appointments
/// - Achieves >80% optimization efficiency score
/// - Uses structured concurrency for parallel specialist processing
///
/// - Parameters:
///   - specialists: Array of available veterinary specialists
///   - appointments: Array of appointments to optimize
///   - constraints: Scheduling constraints (operating hours, break times, etc.)
/// - Returns: Optimization result with scheduled appointments and efficiency metrics
/// - Throws: `SchedulingError` for conflicts or invalid constraints
final class SchedulingEngine {
    /// Optimizes appointment scheduling across multiple specialists
    func optimizeSchedule(
        specialists: [Specialist],
        appointments: [Appointment],
        constraints: SchedulingConstraints = .default
    ) async throws -> OptimizationResult {
        // Implementation
    }
}

// Incorrect: Minimal or missing documentation
class BadEngine {
    func doStuff() { } // What does this do?
}
```

## Performance Standards

### Memory Management

```swift
// Correct: Proper memory management with weak references
final class AppointmentViewController: UIViewController {
    private weak var delegate: AppointmentDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Clean up resources
        cancellables.removeAll()
    }
}

// Correct: Efficient data structures for large datasets
final class AppointmentCache {
    private var cache = NSCache<NSString, AppointmentData>()
    
    init() {
        cache.countLimit = 1000
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
}

// Incorrect: Retain cycles and memory leaks
class BadViewController {
    var delegate: SomeDelegate? // Should be weak
    var strongReferences: [AnyObject] = [] // Potential leaks
}
```

## Security Standards

### HIPAA Compliance Code Patterns

```swift
// Correct: Secure data handling with audit trails
final class PatientDataService {
    private let encryption: DataEncryptionService
    private let auditLogger: HIPAAAuditLogger
    
    func accessPatientData(_ patientId: UUID, requestedBy userId: UUID) async throws -> PatientData {
        // Log access attempt
        auditLogger.logAccess(
            userId: userId,
            resourceId: patientId,
            action: .read,
            timestamp: Date()
        )
        
        // Verify permissions
        guard await hasPermission(userId: userId, patientId: patientId) else {
            auditLogger.logUnauthorizedAccess(userId: userId, resourceId: patientId)
            throw SecurityError.insufficientPermissions
        }
        
        // Return encrypted data
        let encryptedData = try await repository.getPatientData(patientId)
        return try encryption.decrypt(encryptedData)
    }
}

// Incorrect: Insecure data access
func badDataAccess(_ patientId: UUID) -> PatientData {
    // No access control or audit trail
    return database.getPatient(patientId)
}
```

## Code Review Standards

### Review Checklist

**Architecture Compliance**:
- [ ] Follows modular boundaries (no cross-module dependencies)
- [ ] Uses proper DTOs for module communication
- [ ] Implements domain events for loose coupling

**iOS 26 Compliance**:
- [ ] Uses @Observable instead of ObservableObject
- [ ] Implements Liquid Glass with proper containers
- [ ] Uses structured concurrency patterns

**Security & HIPAA**:
- [ ] Encrypts sensitive patient data
- [ ] Implements proper access controls
- [ ] Includes audit trail logging

**Accessibility**:
- [ ] Includes accessibility identifiers for testing
- [ ] Provides descriptive accessibility labels
- [ ] Supports Dynamic Type scaling

**Testing**:
- [ ] Includes comprehensive unit tests
- [ ] Uses mocks for external dependencies
- [ ] Tests accessibility features

**Performance**:
- [ ] Uses efficient data structures
- [ ] Implements proper memory management
- [ ] Meets performance requirements (<1s for scheduling)

## Related Documentation

- **[02-tech-stack.md](02-tech-stack.md)**: Technology choices and version requirements
- **[01-modular-design.md](01-modular-design.md)**: Modular architecture patterns and boundaries
- **[07-ios26-specifications.md](07-ios26-specifications.md)**: iOS 26 specific implementation details
- **[09-testing-strategy.md](09-testing-strategy.md)**: Testing patterns and accessibility testing standards