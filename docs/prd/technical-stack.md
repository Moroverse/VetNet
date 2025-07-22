# Technical Stack & Architecture

This document outlines the technical assumptions, architecture decisions, and technology stack for the Veterinary Practice Intelligence App, focusing on iOS 26 platform capabilities and modern Swift development practices.

## Technical Assumptions

### Repository Structure
**Approach**: Monorepo structure optimized for iOS ecosystem with shared packages for cross-platform features
- Single repository for all platform targets
- Shared business logic packages
- Platform-specific UI implementations
- Unified testing infrastructure
- Consistent tooling and configuration

### Service Architecture
**CRITICAL DECISION**: Native iOS client with cloud-based backend services
- Designed for single-practice excellence
- Future multi-practice network expansion capability
- RESTful API communication
- Real-time synchronization via CloudKit
- Offline-first architecture
- Progressive enhancement strategy

### Testing Requirements
**CRITICAL DECISION**: Comprehensive testing strategy
- Swift Testing framework for modern test authoring
- Mockable package for service layer testing
- ViewInspector for SwiftUI testing
- Performance benchmark suite
- Automated UI testing with XCUITest
- Continuous integration testing pipeline

## iOS-Specific Technical Stack

### Core iOS Technologies

#### Language & Runtime
- **Language**: Swift 6.2+ with modern features
  - Structured concurrency throughout
  - Actor-based isolation
  - Sendable conformance
  - Strict concurrency checking
  - Modern error handling

#### UI Framework
- **SwiftUI** with iOS 26 enhancements
  - Native declarative UI
  - Liquid Glass design system
  - Improved performance
  - Enhanced animations
  - Better previews

#### Architecture Pattern
- **MVVM** optimized for SwiftUI
  - @Observable for view models
  - Clear separation of concerns
  - Testable business logic
  - Reactive data flow
  - Dependency injection

### iOS 26 Liquid Glass Integration

#### Primary Glass APIs
- **glassEffect()** modifier
  - Shape and style parameters
  - Core interface elements
  - Dynamic adaptations
  - Performance optimizations
  - Accessibility compliance

#### Container Management
- **GlassEffectContainer** for grouping
  - Multiple glass elements
  - Consistent visual results
  - Performance batching
  - Memory efficiency
  - Rendering optimization

#### Interactive Elements
- **interactive** modifier enabling
  - Scaling animations
  - Bouncing effects
  - Shimmering highlights
  - Custom scheduling controls
  - Touch feedback

#### Morphing Effects
- **glassEffectID** modifier for
  - Fluid transitions
  - State change animations
  - View morphing
  - Navigation effects
  - Loading states

#### Performance Benefits
- Metal Performance Shaders integration
- 40% GPU usage reduction
- 39% faster rendering
- 38% memory reduction
- Battery life improvement

### Dependency Integration

#### Dependency Injection
**FactoryKit** (https://github.com/hmlongco/Factory)

- **Clean architecture support**: Repository pattern implementation
- **Compile-time safety**: Type-safe repository interfaces
- **Testing flexibility**: Mock repository implementations for domain testing
- **Scope management**: Infrastructure layer service registration  
- **Lazy initialization**: Repository instantiation on-demand
- **Domain isolation**: Feature modules depend only on repository protocols

#### Form Management
**QuickForm** (https://github.com/Moroverse/quick-form)
- Smart triage intake forms
- Validation framework
- Dynamic field generation
- Accessibility support
- Error handling

#### State Management
**StateKit** (https://github.com/Moroverse/state-kit)
- Complex view state handling
- Complements @Observable
- State persistence
- Undo/redo support
- Debug tooling

#### Service Testing
**Mockable** (https://github.com/Kolos65/Mockable)
- Protocol-based mocking
- Compile-time generation
- Type-safe testing
- Async support
- Verification APIs

#### Navigation
**SwiftUIRouting** (local package)
- Veterinary workflow optimization
- Type-safe routing
- Deep linking support
- State restoration
- Transition management

### Repository Pattern Architecture

#### Clean Architecture Implementation
**Three-Layer Data Architecture**:
1. **Domain Models**: Pure Swift objects in feature modules (`Features/*/Domain/Models/`)
   - No persistence or framework dependencies
   - Rich business logic and domain operations
   - Testable in complete isolation

2. **Repository Protocols**: Domain-defined interfaces (`Features/*/Domain/Repositories/`)
   - Abstract persistence operations
   - Domain-centric method signatures
   - Enable mockable testing

3. **SwiftData Entities**: Infrastructure layer persistence (`Infrastructure/Persistence/Entities/`)
   - `@Model` entities with CloudKit integration
   - Compound constraints and relationships
   - Optimized for storage and synchronization

#### Repository Implementation Pattern
```swift
// Domain Layer (Features/Scheduling/Domain/Repositories/)
protocol AppointmentRepository {
    func save(_ appointment: Appointment) async throws
    func findById(_ id: AppointmentId) async throws -> Appointment?
    func findConflicts(for appointment: Appointment) async throws -> [Appointment]
}

// Infrastructure Layer (Infrastructure/Repositories/)
final class SwiftDataAppointmentRepository: AppointmentRepository {
    // Maps between domain models and SwiftData entities
    // Handles all persistence concerns
    // Provides clean abstraction
}
```

#### Benefits
- **Testability**: Domain logic tested without persistence dependencies
- **Clean Architecture**: Business rules isolated from technical concerns  
- **SwiftData Power**: Advanced constraints, relationships, CloudKit sync
- **Maintainability**: Changes to persistence don't affect business logic

### Backend Integration

#### API Communication
- RESTful APIs with async/await
- URLSession with modern APIs
- Codable for serialization
- Request/response interceptors
- Automatic retry logic
- Progress tracking

#### Data Persistence
**SwiftData with Repository Pattern Architecture**:
- **Domain-Driven Design**: Pure domain models in feature modules' Domain layers
- **Infrastructure Layer**: SwiftData `@Model` entities in shared `Infrastructure/Persistence/Entities/`
- **Repository Pattern**: Clean abstraction between domain logic and persistence concerns
- **Custom DataStore protocol**: HIPAA compliance at Infrastructure boundary
- **Real-time synchronization**: CloudKit integration through Infrastructure layer
- **Compound uniqueness**: Business rule enforcement via `@Attribute(.unique)`
- **Query performance**: Optimized through repository implementations
- **Migration support**: Handled at Infrastructure layer
- **Conflict resolution**: Repository-managed with domain model mapping

#### Authentication
- Apple Sign-In integration
- Practice-level access control
- Secure token management
- Biometric authentication
- Session persistence
- iOS 26 privacy features

## Additional Technical Considerations

### Platform Optimization
- Native iOS 26 performance features
- Metal Performance Shaders
- Automatic Xcode 26 optimizations
- Compiler optimizations
- Binary size reduction
- Launch time improvements

### Design Implementation
- Research-validated improvements
- Professional accessibility
- Medical software standards
- Performance benchmarks
- User experience metrics
- Consistent visual language

### Accessibility Integration
- System-wide reading mode
- Improved VoiceOver
- Live Recognition
- Braille Access support
- Professional compliance
- Custom pronunciations

### Cross-Platform Support
- Unified design language
- iOS 26 compatibility
- iPadOS 26 optimization
- macOS 26 support
- Seamless transitions
- Shared components

### Real-time Features
- SwiftData synchronization
- Compound constraints
- Appointment deduplication
- Conflict prevention
- Optimistic updates
- Background sync

## Development Tools & Infrastructure

### Build System
- Tuist for project generation
- Modular architecture
- Dependency management
- Build configurations
- Environment handling

### Code Quality
- SwiftLint integration
- Swift-format standards
- Code review process
- Architecture guidelines
- Documentation standards

### Performance Monitoring
- Instruments integration
- Memory profiling
- Energy impact analysis
- Network monitoring
- Crash reporting

### Analytics & Telemetry
- Privacy-focused analytics
- Performance metrics
- Usage patterns
- Error tracking
- User feedback

## Security Architecture

### Data Protection
- End-to-end encryption
- Keychain integration
- Secure Enclave usage
- Certificate pinning
- Data isolation

### Compliance
- HIPAA requirements
- Audit logging
- Access controls
- Data retention
- Privacy policies

## Related Documents

- [Non-Functional Requirements](requirements-non-functional.md)
- [Development Approach](development-approach.md)
- [Implementation Strategy](implementation-strategy.md)
- [Architecture Documentation](../architecture/)