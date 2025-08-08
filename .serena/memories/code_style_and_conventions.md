# VetNet Code Style and Conventions

## Swift Language Standards
- **Swift Version**: 6.2+ with structured concurrency
- **iOS Target**: 26.0 for main app, 17.0+ for modules
- **Concurrency**: Prefer async/await over completion handlers
- **Actor Isolation**: Most classes implicitly MainActor-isolated via build settings

## Build Settings (Applied Project-wide)
```swift
"SWIFT_APPROACHABLE_CONCURRENCY": true
"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"  
"SWIFT_STRICT_CONCURRENCY": "Complete"
```

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Domain Models | PascalCase descriptive | `Appointment`, `Patient` (Domain layer) |
| SwiftData Entities | PascalCase + 'Entity' | `AppointmentEntity` (Infrastructure) |
| Service Protocols | PascalCase + 'Service' | `TriageAssessmentService` |
| SwiftUI Views | PascalCase + 'View' | `GlassScheduleCalendarView` |
| State Properties | camelCase + @Observable | `@Observable var currentState` |

## Architecture Patterns

### Domain-Driven Design with Clean Architecture
- Pure domain models in feature module Domain layers (no persistence dependencies)
- SwiftData entities in shared Infrastructure layer at Application level
- Repository pattern for clean domain/persistence abstraction
- DTOs for inter-module communication

### Dependency Injection (FactoryKit)
```swift
// Container registration pattern
extension Container {
    var serviceName: Factory<ServiceProtocol> {
        Factory(self) { ServiceImplementation() }
    }
}

// Preview mock registration
let _ = Container.shared.serviceName.register { MockImplementation() }
```

### SwiftUI Patterns
- MVVM + @Observable for state management
- Custom SwiftUIRouting for type-safe navigation
- GlassEffectContainer for Liquid Glass UI elements
- Accessibility identifiers format: "component_type_identifier"

## SwiftLint Configuration
- Comprehensive rules in `.swiftlint.yml`
- Most rules set to `error` severity for strict enforcement
- Disabled rules are marked for future enablement
- Excludes generated and build directories

## SwiftFormat Configuration
- 4-space indentation
- Header template with copyright and creation date
- Inline comma formatting
- Arguments wrapped before-first
- Specific rule customizations for readability

## File Organization
```
App/Sources/
├── Core/                    # Shared application components
├── Features/               # Feature modules with Domain/UI/Infrastructure
└── Infrastructure/         # Cross-cutting concerns, persistence

Modules/
└── SwiftUIRouting/         # Custom navigation framework

docs/
├── architecture/           # Technical documentation (sharded)
└── prd/                   # Product requirements (sharded)
```

## Testing Conventions
- Swift Testing framework with @Suite and @Test
- ViewInspector for SwiftUI component testing
- Mockable for service layer testing
- Accessibility identifiers required for all testable components
- TestableView for eliminating ViewInspector boilerplate
- Screen Object pattern for UI tests (when implemented)

## Comments and Documentation
- Code should be self-documenting through clear naming
- Comments used sparingly for complex business logic
- SwiftDoc comments for public APIs
- MARK: comments for organizing large files

## Error Handling
- Structured error types with retry capability flags
- CloudKit fallback patterns with graceful degradation
- Feature flags for environment-specific behavior
- Comprehensive logging for troubleshooting