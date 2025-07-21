# Coding Standards

## iOS 26 + Swift 6.2+ Development Standards

**Critical Architecture Rules**:

**SwiftData + CloudKit Integration Rule**:
- **Rule**: All data models must use @Model macro with proper relationships and CloudKit-compatible types
- **Implementation**: Use compound uniqueness constraints (@Attribute(.unique)) to prevent scheduling conflicts
- **Rationale**: Ensures data integrity across devices and prevents double-booking scenarios critical for veterinary practices

**Liquid Glass Implementation Rule**:
- **Rule**: All UI components must use GlassEffectContainer when implementing multiple glass elements
- **Implementation**: Group related glass effects within containers, use glassEffectID for morphing animations
- **Rationale**: Prevents visual inconsistencies and achieves research-validated performance improvements

**Structured Concurrency Rule**:
- **Rule**: All scheduling algorithms must use Swift 6.2+ structured concurrency patterns with proper task group management
- **Implementation**: Use TaskGroup for parallel specialist optimization, async/await for all service calls
- **Rationale**: Maximizes iOS 26 performance improvements and prevents data races in complex scheduling logic

**Accessibility Integration Rule**:
- **Rule**: All custom UI components must integrate iOS 26 accessibility features with proper semantic markup
- **Implementation**: Implement VoiceOver descriptions, Dynamic Type support, and Accessibility Reader compatibility
- **Rationale**: Ensures professional medical software compliance and usability for all veterinary staff

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| **Data Models** | PascalCase with descriptive names | `VeterinarySpecialist`, `AppointmentSchedule` |
| **Service Protocols** | PascalCase ending with 'Service' | `TriageAssessmentService`, `SchedulingOptimizationService` |
| **SwiftUI Views** | PascalCase ending with 'View' | `GlassScheduleCalendarView`, `SpecialistMatchingView` |
| **State Properties** | camelCase with @Observable | `@Observable var currentSchedulingState` |
| **Core ML Models** | PascalCase ending with 'Model' | `CaseComplexityModel`, `SpecialistMatchingModel` |

## Language-Specific Guidelines

**Swift 6.2+ Concurrency Patterns**:
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
}
```

**SwiftData Relationship Patterns**:
```swift
// Correct: Proper relationship definition with delete rules
@Model
final class Appointment {
    @Relationship(inverse: \Patient.appointments, deleteRule: .nullify) 
    var patient: Patient?
    
    @Relationship(inverse: \Specialist.appointments, deleteRule: .nullify) 
    var specialist: Specialist?
}

// Correct: Compound uniqueness for conflict prevention
@Model
final class ScheduleSlot {
    @Attribute(.unique) var scheduleKey: String {
        "\(specialistID)_\(timeSlot.timeIntervalSince1970)"
    }
}
```
