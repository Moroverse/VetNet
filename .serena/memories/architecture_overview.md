# VetNet Architecture Overview

## Overall Architecture
VetNet follows **Domain-Driven Design with Clean Architecture** principles, organizing code into distinct layers with clear boundaries and dependencies.

## Project Structure

### Main Application (`App/Sources/`)
```
App/Sources/
├── VetNetApp.swift          # App entry point
├── Core/                    # Shared application components
├── Features/               # Feature modules with layered architecture
│   ├── [FeatureName]/
│   │   ├── Domain/         # Pure business logic, no dependencies
│   │   ├── UI/            # SwiftUI views and view models
│   │   └── Infrastructure/ # Repositories, services, external integrations
└── Infrastructure/         # Cross-cutting shared components
    ├── Persistence/
    │   └── Entities/      # SwiftData entities (shared across features)
    ├── Repositories/      # Repository implementations
    └── Mocks/            # Test mocks and sample data
```

### Custom Modules (`Modules/`)
```
Modules/
└── SwiftUIRouting/         # Custom navigation framework
    ├── Sources/           # Pure SwiftUI + Foundation
    │   ├── Router/       # Core routing protocols
    │   ├── FormRouting/  # Form-based navigation
    │   └── AppRouting/   # App-level routing
    └── Tests/            # Module-specific tests
```

## Key Architectural Patterns

### 1. Clean Architecture Layers
- **Domain Layer**: Pure Swift business logic, no external dependencies
- **UI Layer**: SwiftUI views, view models with @Observable
- **Infrastructure Layer**: External integrations, persistence, services

### 2. Data Architecture
- **SwiftData Entities**: Centralized in `Infrastructure/Persistence/Entities/`
- **Domain Models**: Feature-specific pure Swift models
- **Repository Pattern**: Clean abstraction between domain and persistence
- **DTOs**: For inter-module communication and API boundaries

### 3. Dependency Management
- **FactoryKit**: Type-safe dependency injection container
- **Protocol-Based**: All services defined as protocols
- **Environment-Aware**: Automatic mock injection in tests/previews

### 4. State Management
- **@Observable**: Primary state management for SwiftUI integration
- **MVVM Pattern**: Views + ViewModels with clear separation
- **StateKit**: For complex state scenarios (paginated data, etc.)

### 5. Navigation Architecture
- **SwiftUIRouting Module**: Custom bidirectional routing framework
- **Type-Safe**: Compile-time validation of navigation operations
- **Result-Aware**: Navigation with immediate feedback
- **Zero Dependencies**: Pure SwiftUI implementation

## Technology Integration

### SwiftData + CloudKit
```swift
// CloudKit configuration with fallback
let cloudKitAvailable = !isPreview && !isTest && !forceLocalOnly && hasCloudKitEntitlements()

if cloudKitAvailable {
    // Use CloudKit with VetNetSecure private database
} else {
    // Graceful fallback to local-only storage
}
```

### Concurrency Patterns
- **Structured Concurrency**: async/await throughout
- **Actor Isolation**: MainActor by default via build settings
- **TaskGroup**: For parallel operations (e.g., specialist optimization)

### UI Architecture
- **Liquid Glass Design**: iOS 26 glass effects with GlassEffectContainer
- **Accessibility First**: All components include proper identifiers and labels
- **Dynamic Type**: Support for all text size variations
- **Responsive Design**: Multi-platform support (iPad, iPhone, Mac)

## Testing Strategy

### Testing Pyramid
1. **Unit Tests**: Swift Testing for business logic and services
2. **Integration Tests**: Repository and service integration with mocks
3. **UI Tests**: ViewInspector for component testing
4. **End-to-End Tests**: XCTest UI tests (via VetNetUITestKit - in development)

### Testing Tools Integration
- **Mockable**: Automatic mock generation for protocols
- **TestableView**: ViewInspector boilerplate elimination
- **Swift Testing**: Modern testing framework with @Suite/@Test
- **Screen Object Pattern**: Planned for UI test library

## Development Configuration

### Feature Flags
```swift
enum FeatureFlag: String, CaseIterable {
    case patientManagementV1 = "patient_management_v1"
    case useMockData = "use_mock_data"
    // Environment-specific behaviors
}
```

### Sample Data Integration
- **PatientSampleDataService**: 22-patient comprehensive dataset
- **Development-Only**: Automatically disabled in release builds
- **Mock Repository**: Respects feature flag configuration

## Security & Compliance
- **HIPAA Compliance**: Custom DataStore protocol for medical data
- **CloudKit Security**: Private database with proper entitlements
- **Sandbox Security**: App sandbox with minimal required permissions
- **Data Isolation**: Clear boundaries between features and data layers

## Performance Considerations
- **Lazy Loading**: Paginated data with StateKit
- **Efficient Navigation**: SwiftUIRouting optimized for SwiftUI lifecycle
- **Memory Management**: Proper async/await patterns prevent retain cycles
- **CloudKit Optimization**: Compound uniqueness constraints prevent conflicts

## Documentation Architecture
The project maintains **sharded documentation** for focused expertise:
- `docs/architecture/` - Technical implementation details (15 focused files)
- `docs/prd/` - Product requirements and epics (12 focused files)
- Each document maintains context while being focused for specific concerns