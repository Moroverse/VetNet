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

### Key Architectural Decisions

**SwiftData + CloudKit Integration**:
- All data models use @Model macro with proper relationships
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
| Data Models | PascalCase descriptive | `VeterinarySpecialist`, `AppointmentSchedule` |
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
```

## QuickForm Implementation Guidelines

- When working with QuickForm you should always consult @docs/architecture/quickform-patterns.mdc for best approaches to the implementation