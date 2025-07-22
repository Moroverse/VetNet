# Modular Architecture Design

## Overview

The VetNet application follows a **Domain-Driven Design (DDD)** approach with **Clean Architecture** principles, ensuring each feature module is self-contained with clear boundaries and explicit dependencies. This document details the modular architecture design, inter-module communication patterns, and architectural benefits.

Related documents: [00-overview.md](00-overview.md) | [03-feature-modules.md](03-feature-modules.md)

## Architecture Overview

The application employs a modular iOS 26-native architecture with clear separation of concerns across three primary layers:

### Core Principles

- **Bounded Contexts**: Each feature module represents a distinct bounded context with its own ubiquitous language
- **Dependency Rule**: Dependencies point inward - Presentation depends on Application, Application depends on Domain
- **Interface Segregation**: Modules communicate only through well-defined public interfaces
- **Single Responsibility**: Each module handles one cohesive set of business capabilities

### Three-Layer Architecture

```mermaid
graph TB
    subgraph "Feature Modules Layer"
        Scheduling[Scheduling Module]
        Triage[Triage Module] 
        Patient[Patient Records Module]
        Specialist[Specialist Management Module]
        Analytics[Analytics Module]
    end
    
    subgraph "Infrastructure Layer"
        Persistence[SwiftData + CloudKit]
        Networking[API Clients]
        Auth[Authentication]
        Device[Device Services]
        Monitor[Monitoring]
    end
    
    subgraph "Application Layer"
        DI[Dependency Injection]
        Orchestration[Module Orchestration]
        Navigation[App Coordinator]
        Lifecycle[App Lifecycle]
    end
    
    Scheduling --> Infrastructure
    Triage --> Infrastructure
    Patient --> Infrastructure
    Specialist --> Infrastructure
    Analytics --> Infrastructure
    
    Application --> Scheduling
    Application --> Triage
    Application --> Patient
    Application --> Specialist
    Application --> Analytics
    
    style "Feature Modules Layer" fill:#FFE4B5
    style "Infrastructure Layer" fill:#ADD8E6
    style "Application Layer" fill:#E6E6FA
```

## Feature Module Structure

Each feature module follows a consistent internal architecture based on Clean Architecture principles:

### Standard Module Layout

```
Features/Scheduling/                 # Example module
├── Package.swift                    # Module definition
├── Sources/
│   ├── Domain/                     # Core business logic (no external dependencies)
│   │   ├── Models/
│   │   │   ├── Appointment.swift   # Internal domain model
│   │   │   ├── TimeSlot.swift
│   │   │   └── ScheduleRules.swift
│   │   ├── Services/
│   │   │   └── SchedulingPolicy.swift
│   │   └── Repositories/
│   │       └── AppointmentRepository.swift  # Protocol only
│   ├── Application/                # Use cases & application services
│   │   ├── UseCases/
│   │   │   ├── ScheduleAppointmentUseCase.swift
│   │   │   └── RescheduleAppointmentUseCase.swift
│   │   └── Services/
│   │       └── ConflictResolutionService.swift
│   ├── Infrastructure/             # Technical implementations
│   │   ├── Persistence/
│   │   │   └── SwiftDataAppointmentRepository.swift
│   │   └── External/
│   │       └── CalendarIntegration.swift
│   ├── Presentation/              # UI Layer
│   │   ├── ViewModels/
│   │   │   └── SchedulingViewModel.swift
│   │   └── Views/
│   │       └── ScheduleCalendarView.swift
│   └── Public/                    # Public API
│       ├── SchedulingModuleInterface.swift
│       ├── DTOs/
│       │   └── AppointmentDTO.swift
│       └── Events/
│           └── AppointmentScheduledEvent.swift
```

### Layer Responsibilities

**Domain Layer Rules**:
- Pure Swift with no framework dependencies
- Contains business logic and domain models
- Defines repository interfaces (not implementations)
- Rich domain models with business methods

**Application Layer Rules**:
- Orchestrates domain objects
- Implements use cases and application services
- No UI or infrastructure concerns
- Handles cross-cutting concerns within the module

**Infrastructure Layer Rules**:
- Implements repository interfaces
- Handles persistence, networking, external services
- Framework-specific code lives here
- Module-specific technical implementations

**Presentation Layer Rules**:
- SwiftUI views and view models using @Observable
- Depends only on Application layer
- Uses DTOs for external communication
- iOS 26 Liquid Glass integration

**Public Layer Rules**:
- Defines module's public interface
- Contains DTOs and domain events
- No internal implementation details exposed
- Version-controlled API contracts

## Inter-Module Communication

Modules communicate through three primary mechanisms to maintain loose coupling:

### 1. Direct Interface Calls

```swift
// Public interface exposed by Scheduling module
public protocol SchedulingModuleInterface {
    func scheduleAppointment(request: SchedulingRequestDTO) async throws -> AppointmentDTO
    func getAvailableSlots(date: Date, duration: TimeInterval) async -> [TimeSlotDTO]
}

// Triage module using Scheduling interface
class TriageCompletionUseCase {
    private let schedulingInterface: SchedulingModuleInterface
    
    func completeTriageAndSchedule(assessment: TriageAssessment) async throws {
        let schedulingRequest = mapToSchedulingRequest(assessment)
        let appointment = try await schedulingInterface.scheduleAppointment(request: schedulingRequest)
    }
}
```

### 2. Domain Events

```swift
// Scheduling module publishes event
public struct AppointmentScheduledEvent: DomainEvent {
    public let appointmentId: UUID
    public let patientId: UUID
    public let specialistId: UUID
    public let scheduledTime: Date
}

// Analytics module subscribes to events
class AnalyticsEventHandler {
    init(eventBus: EventBus) {
        eventBus.subscribe(to: AppointmentScheduledEvent.self) { event in
            await self.trackAppointmentMetrics(event)
        }
    }
}
```

### 3. Shared DTOs

```swift
// Shared DTO for cross-module data transfer
public struct PatientDTO: Codable {
    public let id: UUID
    public let name: String
    public let species: String
    // Only data needed for external communication
}
```

### Cross-Module Data Flow Example

```mermaid
graph LR
    subgraph "Triage Module"
        TD[Triage Domain Model]
        TU[Triage Use Case]
        TDTO[TriageDTO]
    end
    
    subgraph "Patient Module"
        PD[Patient Domain Model]
        PU[Patient Use Case]
        PDTO[PatientDTO]
    end
    
    subgraph "Scheduling Module"
        SD[Schedule Domain Model]
        SU[Schedule Use Case]
        SDTO[ScheduleDTO]
    end
    
    subgraph "Infrastructure"
        DB[(SwiftData)]
        EB{{Event Bus}}
    end
    
    TU -->|Query| PDTO
    PU -->|Return| PDTO
    TU -->|Create| TDTO
    TU -->|Request| SDTO
    SU -->|Return| SDTO
    
    TD -.->|Map| TDTO
    PD -.->|Map| PDTO
    SD -.->|Map| SDTO
    
    SU -->|Persist| DB
    SU -->|Publish| EB
    EB -->|Notify| PU
    
    style TD fill:#FFE4B5
    style PD fill:#E6E6FA
    style SD fill:#ADD8E6
```

## Infrastructure Layer

The Infrastructure layer provides shared technical capabilities that feature modules can utilize:

### Core Infrastructure Components

```swift
// Infrastructure/Persistence/PersistenceProtocol.swift
public protocol PersistenceStore {
    associatedtype Model
    func save(_ model: Model) async throws
    func fetch(id: UUID) async throws -> Model?
    func query(_ predicate: Predicate<Model>) async throws -> [Model]
}

// Infrastructure/Persistence/SwiftDataStore.swift
public final class SwiftDataStore<T: PersistentModel>: PersistenceStore {
    private let modelContainer: ModelContainer
    
    public func save(_ model: T) async throws {
        // SwiftData implementation with CloudKit sync
    }
}

// Infrastructure/EventBus/EventBus.swift
public protocol EventBus {
    func publish<E: DomainEvent>(_ event: E) async
    func subscribe<E: DomainEvent>(to eventType: E.Type, handler: @escaping (E) async -> Void)
}
```

### Key Infrastructure Services

- **Persistence Abstraction**: Generic protocols for data storage with SwiftData + CloudKit
- **Event Bus**: For inter-module communication and loose coupling
- **Device Services**: Camera, location, biometrics wrappers
- **Monitoring**: Centralized logging and analytics
- **Security**: Encryption and authentication services

## Application Layer

The Application layer serves as the composition root that wires modules together:

```swift
// App/Sources/CompositionRoot/AppContainer.swift
@MainActor
final class AppContainer {
    // Infrastructure services
    private let persistenceProvider: PersistenceProvider
    private let eventBus: EventBus
    private let authenticationService: AuthenticationService
    
    // Feature modules
    private(set) lazy var schedulingModule = SchedulingModule(
        persistenceStore: persistenceProvider.makeStore(for: Appointment.self),
        eventBus: eventBus
    )
    
    private(set) lazy var triageModule = TriageModule(
        persistenceStore: persistenceProvider.makeStore(for: TriageAssessment.self),
        eventBus: eventBus
    )
    
    private(set) lazy var patientModule = PatientRecordsModule(
        persistenceStore: persistenceProvider.makeStore(for: Patient.self),
        eventBus: eventBus
    )
    
    // App-level coordinator
    private(set) lazy var appCoordinator = AppCoordinator(
        schedulingInterface: schedulingModule.publicInterface,
        triageInterface: triageModule.publicInterface,
        patientInterface: patientModule.publicInterface,
        router: router
    )
}
```

### Application Layer Responsibilities

- **Dependency Injection**: Module wiring and service composition
- **Cross-cutting Concerns**: Authentication, analytics, logging
- **Top-level Navigation**: App-wide routing coordination
- **App Lifecycle Management**: Startup, background, termination handling

## Architectural Patterns

The modular architecture employs several key patterns:

### iOS 26 + SwiftUI MVVM with Modular Boundaries
- **Pattern**: MVVM within each module's Presentation layer, with ViewModels as module boundaries
- **Rationale**: Maintains UI/business logic separation while respecting module isolation

### Repository Pattern with Protocol Abstraction
- **Pattern**: Domain defines repository protocols, Infrastructure provides implementations
- **Rationale**: Allows testing with mocks and swapping implementations without affecting business logic

### Use Case Pattern
- **Pattern**: Each user interaction maps to a specific use case class in the Application layer
- **Rationale**: Encapsulates business workflows and makes testing straightforward

### Event-Driven Architecture
- **Pattern**: Loose coupling between modules through domain events
- **Rationale**: Modules can react to changes without direct dependencies

### DTO Pattern for Boundaries
- **Pattern**: Data Transfer Objects for all inter-module communication
- **Rationale**: Prevents internal model changes from affecting other modules

## Modular Architecture Benefits

### Development Benefits

**Independent Development & Testing**:
- Teams can work on different modules simultaneously without conflicts
- Each module can be developed, tested, and deployed independently
- Mocking module interfaces enables comprehensive unit testing
- Reduced cognitive load - developers focus on one bounded context at a time

**Clear Boundaries & Contracts**:
- Public interfaces define explicit contracts between modules
- Internal implementation changes don't affect other modules
- DTOs prevent leaking internal models across boundaries
- Easy to understand module responsibilities and dependencies

### Maintenance Benefits

**Isolated Changes**:
- Bug fixes remain contained within module boundaries
- Feature additions don't require understanding entire codebase
- Refactoring internal implementation is safe and straightforward
- Technology updates can be done module by module

**Enhanced Testability**:
- Domain logic tested without infrastructure dependencies
- Module integration tests validate inter-module contracts
- Performance testing can isolate bottlenecks to specific modules
- Regression testing focused on affected modules only

### Scalability Benefits

**Team Scalability**:
- New developers onboard faster by focusing on specific modules
- Module ownership can be assigned to specific teams
- Parallel development without stepping on each other's toes
- Clear code review boundaries

**Feature Scalability**:
- New features implemented as new modules
- Existing modules extended through well-defined interfaces
- Easy to experiment with alternative implementations
- Gradual migration paths for legacy code

### Architecture Benefits

**Clean Separation of Concerns**:
- Business logic isolated from technical infrastructure
- UI changes don't affect business rules
- Data persistence changes don't impact domain models
- External service integrations contained in infrastructure layer

**Flexibility & Adaptability**:
- Easy to swap implementations (e.g., different persistence strategies)
- Support for different UI paradigms per module if needed
- Gradual adoption of new technologies
- Clear deprecation paths for old modules

## Related Documentation

- **[03-feature-modules.md](03-feature-modules.md)**: Detailed specifications for each feature module
- **[04-data-models.md](04-data-models.md)**: Data model mapping strategy between modules
- **[05-components.md](05-components.md)**: Infrastructure component implementations
- **[09-testing-strategy.md](09-testing-strategy.md)**: Module isolation and integration testing approaches