# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VetNet is a native iOS 26 veterinary practice intelligence application built with Swift 6.2+ and Tuist project management. The app leverages cutting-edge iOS capabilities including Liquid Glass design system, SwiftData with CloudKit synchronization, and AI-powered scheduling algorithms for veterinary practices.

## Development Commands

### Project Setup & Building
```bash
# Install Tuist (managed via mise)
mise install

# Generate Xcode project from Tuist configuration
tuist generate

# Build the main app target
tuist build VetNet

# Run tests
tuist test VetNet
```

### Module Development (SwiftUIRouting)
```bash
# Build the custom routing module
cd Modules/SwiftUIRouting
swift build

# Run module tests
swift test

# Generate documentation
swift package generate-documentation
```

### Testing Commands
```bash
# Run all tests with coverage
tuist test --coverage

# Run specific test target
tuist test VetNetTests

# Run SwiftUIRouting module tests
cd Modules/SwiftUIRouting && swift test
```

## Architecture Overview

### Modular Structure
- **Main App Target**: `App/Sources/` - Core iOS application using SwiftUI + MVVM architecture
- **Custom Modules**: `Modules/SwiftUIRouting/` - Custom navigation framework for veterinary workflows
- **Documentation**: `docs/` - Comprehensive architecture and PRD documentation (sharded into focused sections)

### Technology Stack
- **Language**: Swift 6.2+ with structured concurrency patterns
- **UI Framework**: SwiftUI with iOS 26 Liquid Glass design system
- **Architecture**: MVVM + @Observable for optimal SwiftUI integration
- **Navigation**: Custom SwiftUIRouting module (bidirectional, type-safe routing)
- **Data**: SwiftData with CloudKit for HIPAA-compliant synchronization
- **Testing**: Swift Testing + Mockable + ViewInspector for comprehensive coverage
- **Dependency Injection**: FactoryKit for clean, testable service layer
- **Formatting**: FormatStyle API for consistent, locale-aware formatting
- **Measurements**: Type-safe Measurement API for veterinary calculations

### Key Architectural Decisions

**Domain-Driven Design with Clean Architecture**:
- Pure domain models in each feature module's Domain layer (no persistence dependencies)
- SwiftData `@Model` entities isolated in shared Infrastructure layer at Application level
- Repository pattern provides clean abstraction between domain logic and persistence
- DTOs for inter-module communication to maintain module boundaries

**SwiftData in Infrastructure Layer**:
- SwiftData entities located in `Infrastructure/Persistence/Entities/` (shared across all features)
- Repository implementations in `Infrastructure/Repositories/` map between domain models and SwiftData entities
- Domain layer defines repository protocols, Infrastructure layer provides SwiftData implementations
- Compound uniqueness constraints (@Attribute(.unique)) prevent scheduling conflicts
- Custom DataStore protocol for HIPAA compliance

**Liquid Glass UI Implementation**:
- Use GlassEffectContainer for multiple glass elements
- Group related effects within containers
- glassEffectID for morphing animations

**Structured Concurrency Patterns**:
- TaskGroup for parallel specialist optimization
- async/await for all service calls
- Swift 6.2+ concurrency patterns throughout

### Custom SwiftUIRouting Module

Located in `Modules/SwiftUIRouting/`, this is a pure SwiftUI navigation framework with:
- **Bidirectional Routing**: Result-aware navigation with immediate feedback
- **Type Safety**: Compile-time validation for routing operations
- **Zero Dependencies**: Pure SwiftUI + Foundation implementation
- **Modern Patterns**: async/await, @Observable, Swift 6.0 concurrency

Key protocols:
- `Router`: Base navigation protocol
- `FormRouting`: Form-based routing with results
- `AppRouting`: App-level routing (alerts, overlays)
- `RouteResult`: Type-safe result communication

### Testing Strategy

**ViewInspector Integration** (Primary UI Testing):
```swift
// Use accessibility identifiers for reliable component finding
let calendarGrid = try calendar.inspect().find(viewWithAccessibilityIdentifier: "schedule_calendar_grid")
let submitButton = try form.inspect().find(viewWithAccessibilityIdentifier: "triage_submit_button")
```

**Mockable Services**:
```swift
@Mockable
protocol TriageService {
    func assessUrgency(symptoms: [Symptom], vitals: VitalSigns) async -> VTLUrgencyLevel
}
```

**Swift Testing Framework**:
- Use @Suite and @Test attributes
- #expect() assertions
- Async testing patterns with structured concurrency

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Domain Models | PascalCase descriptive | `Appointment`, `Patient` (in Domain layer) |
| SwiftData Entities | PascalCase + 'Entity' | `AppointmentEntity`, `PatientEntity` (in Infrastructure layer) |
| Service Protocols | PascalCase + 'Service' | `TriageAssessmentService`, `SchedulingOptimizationService` |
| SwiftUI Views | PascalCase + 'View' | `GlassScheduleCalendarView`, `SpecialistMatchingView` |
| State Properties | camelCase + @Observable | `@Observable var currentSchedulingState` |

### Accessibility Requirements

All UI components must include:
- `accessibilityIdentifier` for reliable testing (format: "component_type_identifier")
- `accessibilityLabel` for VoiceOver descriptions
- Dynamic Type support
- iOS 26 Accessibility Reader compatibility

### Documentation Structure

The `docs/` directory contains sharded documentation:
- `docs/architecture/` - Technical implementation details (15 focused files)
- `docs/prd/` - Product requirements and epics (12 focused files)

Each sharded document maintains context while being focused for specific concerns (security, testing, data models, etc.).

## Project Management

**Tuist Configuration**:
- Multi-platform targets (iPad, iPhone, Mac)
- Bundle ID: `com.moroverse.VetNet`
- Version managed in `Project.swift`
- Dependencies managed through Tuist

**Version Requirements**:
- iOS 17.0+ (SwiftUIRouting module)
- Swift 6.2+
- iOS 26 target for main application
- Tuist 4.55.6 (via mise)

This is a greenfield iOS project with comprehensive architecture documentation and a custom navigation solution optimized for veterinary workflows.

## Tuist Configuration Notes

### Project-wide Swift Concurrency Extensions
- All projects in tuist should have following for build settings:
  - `SWIFT_APPROACHABLE_CONCURRENCY`: true
  - `SWIFT_DEFAULT_ACTOR_ISOLATION`: "MainActor"
  - `SWIFT_STRICT_CONCURRENCY`: "Complete"

**Important**: With `SWIFT_DEFAULT_ACTOR_ISOLATION: "MainActor"`, most classes are implicitly MainActor-isolated, eliminating the need for explicit `@MainActor` annotations in most UI code. Use `nonisolated` when opting out for background operations.
```

## QuickForm Implementation Guidelines

- When working with QuickForm you should always consult @docs/architecture/quickform-patterns.mdc for best approaches to the implementation

## Swift Best Practices

- **Dependency Injection**: Use FactoryKit patterns documented in @docs/architecture/swift-best-practices.md
- **Formatting**: Prefer FormatStyle API for all formatting needs (dates, measurements, currency)
- **Measurements**: Use Swift's Measurement API with proper units for all veterinary calculations
- See @docs/architecture/swift-best-practices.md for comprehensive patterns and examples

## Session Learnings

This section captures valuable insights, patterns, and solutions discovered during development sessions. Each entry includes the date and context for future reference.

### 2025-08-03: Alert Implementation & Preview Fixes

**QuickForm Framework Improvements**:
- Fixed `onValueChanged` behavior to only trigger on meaningful value changes (not focus changes)
- This resolved SwiftUI alert dismissal issues where alerts would immediately close when text fields lost focus
- QuickForm now properly distinguishes between value changes and UI state changes

**FactoryKit Dependency Injection Patterns**:
```swift
// Correct preview mock registration pattern
let _ = Container.shared.serviceName.register { MockImplementation() }

// Register on the specific service the component uses (e.g., patientCRUDRepository, not patientRepository)
// Use proper FactoryKit syntax for preview overrides
```

**StateKit Paginated Type Usage**:
```swift
// StateKit's Paginated structure
Paginated(items: [Item], loadMore: LoadMoreCompletion?)
// - items: Array of items for current page
// - loadMore: Optional closure for loading additional pages
// - Conforms to Collection protocol for easy iteration
```

**SwiftUI Alert State Management Best Practices**:
```swift
// Use @State for alert presentation control
@State private var showingAlert = false

// Watch for error state changes
.onChange(of: viewModel.formState.isError) { _, isError in
    showingAlert = isError
}

// Provide different actions based on error type
.alert("Error", isPresented: $showingAlert) {
    if viewModel.formState.isRetryable {
        Button("Retry") { /* retry logic */ }
        Button("Cancel") { viewModel.clearError() }
    } else {
        Button("OK") { viewModel.clearError() }
    }
}
```

**Enhanced Error State Management**:
```swift
// Include retry capability in error states
enum FormState {
    case error(String, isRetryable: Bool = true)
    // Non-retryable: duplicate key errors (user must fix)
    // Retryable: network/database errors (can retry same operation)
}
```

**Repository Mock Implementation Guidelines**:
- Mock repositories should implement ALL protocol methods, not just CRUD
- Use `#if DEBUG` wrapper for preview-only mocks
- Support multiple behaviors (success, various error types, slow response)
- Properly handle StateKit types like `Paginated`
- Use correct `RepositoryError` enum cases (e.g., `.notFound` has no associated value)

**File Organization Insights**:
- Preview mocks belong in `Infrastructure/Mocks/` directory
- Use descriptive behavior enums for different test scenarios
- Keep mock implementations focused and lightweight

### 2025-08-04: Sample Data & Feature Flag Implementation

**TestableView Integration**:
- TestableView eliminates ViewInspector boilerplate with `@ViewInspectable` macro and `inspectChangingView` helper
- Captures test values outside inspection closures for better safety: `var result: String?`
- Uses `.inspectable(self)` modifier instead of manual hook setup
- Zero runtime overhead in release builds through conditional compilation

**Sample Data Service Architecture**:
```swift
// Comprehensive 22-patient dataset with realistic data
PatientSampleDataService.generateSamplePatients()
// - 10 Dogs (Labrador, German Shepherd, Golden Retriever, etc.)
// - 8 Cats (Persian, Maine Coon, Siamese, Russian Blue, etc.)  
// - 4 Exotic pets (Rabbit, Parrot, Bearded Dragon, Guinea Pig)
```

**Feature Flag Service Design**:
```swift
enum FeatureFlag: String, CaseIterable {
    case patientManagementV1 = "patient_management_v1"
    case useMockData = "use_mock_data"
    // Automatic default values and descriptions
}

// UserDefaults-based persistence with real-time notifications
extension Container {
    var featureFlagService: Factory<FeatureFlagService> {
        // Auto-switches to DebugFeatureFlagService in tests
    }
}
```

**Development Configuration Integration**:
- `DevelopmentConfigurationService` coordinates sample data and feature flags
- Container automatically selects MockPatientRepository when `useMockData` flag enabled
- Repository selection respects feature flags: production data in release, configurable in debug
- Shake gesture access to debug settings in DEBUG builds only

**Data Seeding Patterns**:
```swift
// Graceful error handling during seeding
for patient in samplePatients {
    do {
        _ = try await patientRepository.create(patient)
        successCount += 1
    } catch {
        failureCount += 1
        // Continue with other patients
    }
}
```

**Production Safety**:
- Mock data flag automatically disabled in release builds
- Feature flags persist across app launches via UserDefaults  
- Debug-only functionality isolated with `#if DEBUG` guards
- CloudKit sync controllable via feature flag for staged rollouts