# VetNet Comprehensive Architecture Overview

## Overall Architecture Philosophy
VetNet follows **Domain-Driven Design with Clean Architecture** principles, emphasizing **Test-Driven Development (TDD)**, **Swift 6.2+ best practices**, and **veterinary domain expertise**. The architecture prioritizes **type safety**, **testability**, **performance**, and **developer experience**.

## Core Development Principles

### TDD Cycle Integration
- **Red → Green → Refactor**: All features developed using strict TDD methodology
- **Tidy First Approach**: Structural changes separate from behavioral changes
- **Test Automation**: Continuous testing with `tuist test` after every change
- **Quality Gates**: No commits without passing tests and zero warnings

### Swift 6.2+ Patterns
- **Structured Concurrency**: async/await throughout with MainActor isolation by default
- **@Observable**: Primary state management replacing @ObservableObject
- **Type Safety**: Leveraging Swift's type system for domain validation
- **Memory Safety**: Proper actor isolation and weak references prevent retain cycles

## Project Structure

### Main Application (`App/Sources/`)
```
App/Sources/
├── VetNetApp.swift          # App entry point with CloudKit configuration
├── Core/                    # Shared application components
│   ├── Services/           # Cross-cutting services (DateProvider, ValidationEngine)
│   └── Extensions/         # Swift extensions (FormatStyle, Measurement)
├── Features/               # Feature modules with layered architecture
│   ├── [FeatureName]/
│   │   ├── Domain/         # Pure business logic (models, protocols, validators)
│   │   ├── UI/            # SwiftUI views, view models, QuickForm integration
│   │   └── Infrastructure/ # Repositories, services, external integrations
└── Infrastructure/         # Cross-cutting shared components
    ├── Persistence/
    │   ├── Entities/      # SwiftData entities (shared across all features)
    │   └── DataStore/     # HIPAA-compliant data store protocols
    ├── Repositories/      # Repository implementations with FactoryKit DI
    ├── Mocks/            # StateKit mock services for testing/previews
    └── Services/         # Infrastructure services (CloudKit, networking)
```

### Custom Modules (`Modules/`)
```
Modules/
└── SwiftUIRouting/         # Custom bidirectional navigation framework
    ├── Sources/           # Pure SwiftUI + Foundation (zero dependencies)
    │   ├── Router/       # Core routing protocols (Router, FormRouting, AppRouting)
    │   ├── FormRouting/  # Form-based navigation with result communication
    │   └── AppRouting/   # App-level routing (alerts, sheets, overlays)
    └── Tests/            # Comprehensive module test suite
```

## Advanced Architectural Patterns

### 1. FactoryKit Dependency Injection Architecture

VetNet uses **FactoryKit** for sophisticated dependency management with automatic environment detection:

```swift
extension Container {
    // Service registration with proper scoping
    var schedulingService: Factory<SchedulingOptimizationService> {
        self { DefaultSchedulingService(dateProvider: dateProvider()) }
            .cached  // Reuse within container lifecycle
    }
    
    // Environment-aware registration
    var patientRepository: Factory<PatientRepository> {
        self { 
            #if DEBUG
            if Container.shared.featureFlagService().isEnabled(.useMockData) {
                return MockPatientRepository()
            }
            #endif
            return SwiftDataPatientRepository(modelContext: modelContext())
        }
        .cached
    }
}
```

**Integration Patterns**:
- **@Injected**: Property wrapper for service injection
- **@InjectedObject**: For @Observable view models
- **Test Isolation**: `.container` trait provides clean test environments
- **Preview Support**: Automatic mock registration for SwiftUI previews

### 2. QuickForm Architecture Integration

**Revolutionary Form Development** using Swift macros for veterinary workflows:

#### Core QuickForm Pattern
```swift
// Component struct separates form data from domain models
struct PatientComponents: Sendable {
    var name: String = ""
    var species: Species = .dog
    var birthDate: Date = .now
    var weight: Measurement<UnitMass> = .init(value: 0, unit: .kilograms)
}

@QuickForm(PatientComponents.self)
final class PatientFormViewModel: Validatable {
    @PropertyEditor(keyPath: \PatientComponents.name)
    var name = FormFieldViewModel(
        type: String.self,
        title: "Patient Name",
        placeholder: "Enter patient name"
    )
    
    @PropertyEditor(keyPath: \PatientComponents.species)
    var species = PickerFieldViewModel(
        value: Species.dog,
        allValues: Species.allCases,
        title: "Species"
    )
    
    @Injected(\.patientValidator)
    private var validator: PatientValidator
    
    @PostInit
    private func configure() {
        // Setup validation and reactive relationships
        name.validation = validator.nameValidation
        species.onValueChanged { [weak self] newSpecies in
            self?.weight.validation = self?.validator.weightValidation(for: newSpecies)
        }
    }
}
```

#### Form State Management
```swift
enum FormState: Equatable {
    case idle           // Initial state, no changes
    case editing        // User has made unsaved changes
    case saving         // Save operation in progress
    case saved          // Successfully saved
    case error(String)  // Save failed with error message
    case validationError(String) // Form validation failed
}
```

**Benefits**:
- **Macro-Driven**: Eliminates boilerplate with @QuickForm, @PropertyEditor
- **Type Safety**: Compile-time validation of form field bindings
- **Reactive Validation**: Real-time validation with field dependencies
- **SwiftUI Integration**: Native SwiftUI components with accessibility support

### 3. Advanced Swift Best Practices

#### FormatStyle Integration for Veterinary Domain
```swift
extension FormatStyle where Self == Date.FormatStyle {
    /// Standard appointment time format (e.g., "9:30 AM")
    static var appointmentTime: Self {
        .dateTime
            .hour(.defaultDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
}

extension FormatStyle {
    /// Patient weight formatter (e.g., "12.5 kg")
    struct WeightFormatStyle: FormatStyle {
        let unit: UnitMass
        
        func format(_ value: Measurement<UnitMass>) -> String {
            value.converted(to: unit)
                .formatted(.measurement(width: .abbreviated, 
                                      numberFormatStyle: .number.precision(.fractionLength(1))))
        }
    }
}
```

#### Measurement API for Type-Safe Veterinary Calculations
```swift
// Patient vitals with type-safe calculations
struct PatientVitals {
    let weight: Measurement<UnitMass>
    let temperature: Measurement<UnitTemperature>
    let heartRate: Measurement<UnitFrequency>
    let respiratoryRate: Measurement<UnitFrequency>
    
    var isFebrile: Bool {
        temperature.converted(to: .fahrenheit).value > 102.5
    }
}

// Custom veterinary units
extension Dimension {
    static let breathsPerMinute = UnitFrequency(
        symbol: "bpm", 
        converter: UnitConverterLinear(coefficient: 1.0/60.0)
    )
}
```

### 4. Advanced Testing Architecture

#### TestKit + StateKit Integration
```swift
// Memory leak detection for ViewModels
@Test("No memory leaks in ViewModel", .teardownTracking())
func testViewModelMemoryManagement() async throws {
    let viewModel = AppointmentViewModel()
    await Test.trackForMemoryLeaks(viewModel)
    
    await viewModel.loadAppointments()
    // Test fails if viewModel is not deallocated
}

// AsyncSpy for precise async testing
@Test
func testLoadingStateTransitions() async throws {
    let spy = AsyncSpy<[Appointment]>()
    
    try await spy.async {
        await viewModel.loadTodaysAppointments()
    } expectationBeforeCompletion: {
        #expect(viewModel.isLoading == true)
    } completeWith: {
        .success([Appointment.mock1, Appointment.mock2])
    } expectationAfterCompletion: { _ in
        #expect(viewModel.isLoading == false)
        #expect(viewModel.appointments.count == 2)
    }
}
```

#### MockService for Rich Preview Data
```swift
extension MockService: PatientLoader where T == Paginated<Patient> {
    static func mock() -> Self {
        Self(result: .success(MockService.patients(with: Container.shared.dateProvider())))
    }
    
    static func slow() -> Self {
        Self(result: .success(MockService.patients(with: Container.shared.dateProvider())), 
             delay: .seconds(3))
    }
    
    static func error() -> Self {
        Self(result: .failure(URLError(.badServerResponse)))
    }
}
```

### 5. Data Validation Architecture with QuickForm

#### Domain-Specific Validators
```swift
final class PatientValidator: Sendable {
    private let dateProvider: DateProvider
    
    var nameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(50),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-")))
        )
    }
    
    func weightValidation(for species: Species) -> AnyValidationRule<Measurement<UnitMass>> {
        .of(SpeciesMaxWeightRangeRule(species))
    }
}

// Species-specific validation rules
struct SpeciesMaxWeightRangeRule: ValidationRule {
    let species: Species
    
    func validate(_ value: Measurement<UnitMass>) -> ValidationResult {
        let weightInKg = value.converted(to: .kilograms).value
        
        switch species {
        case .dog:
            return (0.5...100).contains(weightInKg) ? 
                .success : 
                .failure("Dogs must weigh between 0.5kg and 100kg")
        // ... other species validations
        }
    }
}
```

## Clean Architecture Layers (Enhanced)

### 1. Domain Layer (Pure Swift Business Logic)
- **Entities**: Core business objects (Patient, Appointment, Treatment)
- **Value Objects**: Immutable objects (VitalSigns, MedicationDose)
- **Domain Services**: Complex business logic (TriageAssessment, SchedulingOptimization)
- **Validators**: QuickForm ValidationRule implementations
- **Repositories**: Protocol definitions for data access

### 2. UI Layer (SwiftUI + MVVM + QuickForm)
- **Views**: SwiftUI views with accessibility identifiers
- **ViewModels**: @Observable view models with FactoryKit injection
- **Form ViewModels**: QuickForm-based form management
- **Routing**: SwiftUIRouting for navigation
- **State Management**: FormState enums and @Observable patterns

### 3. Infrastructure Layer (External Integrations)
- **SwiftData Entities**: Centralized persistence models
- **Repository Implementations**: SwiftData + CloudKit integration
- **Services**: External API integrations and system services
- **Mocks**: StateKit MockService implementations
- **Data Store**: HIPAA-compliant data handling protocols

## Technology Integration (Enhanced)

### SwiftData + CloudKit with Fallback Strategy
```swift
// Enhanced CloudKit capability detection
let cloudKitAvailable = !isPreview && !isTest && !forceLocalOnly && hasCloudKitEntitlements()

if cloudKitAvailable {
    // Use CloudKit with VetNetSecure private database
    modelContainer = try ModelContainer(
        for: schema,
        configurations: [
            ModelConfiguration(
                schema: schema,
                url: nil, // CloudKit
                cloudKitDatabase: .private("VetNetSecure")
            )
        ]
    )
} else {
    // Graceful fallback with detailed logging
    modelContainer = try ModelContainer(for: schema)
}
```

### Concurrency Architecture (Swift 6.2+)
- **MainActor Isolation**: Default isolation via build settings (`SWIFT_DEFAULT_ACTOR_ISOLATION: "MainActor"`)
- **Structured Concurrency**: TaskGroup for parallel operations
- **Actor Safety**: Proper nonisolated declarations for background work
- **Async Sequences**: For reactive data streams

### UI Architecture (iOS 26 + Liquid Glass)
- **GlassEffectContainer**: Multiple glass elements with morphing animations
- **Accessibility Reader**: iOS 26 compatibility
- **Dynamic Type**: Full support for accessibility text sizes
- **VoiceOver**: Comprehensive screen reader support

## Development Workflow Integration

### TDD Workflow Automation
```yaml
PostToolUse Automation:
  - swiftformat .           # Code formatting
  - swiftlint              # Code quality checks
  - tuist generate         # Project regeneration
  - tuist build            # Build validation
  - tuist test --platform ios --skip-ui-tests  # Test execution

Commit Requirements:
  - All tests passing
  - Zero compiler warnings
  - Zero SwiftLint violations
  - Single logical unit of work
```

### Feature Flag Architecture
```swift
enum FeatureFlag: String, CaseIterable {
    case patientManagementV1 = "patient_management_v1"
    case useMockData = "use_mock_data"
    case quickFormValidation = "quickform_validation_v2"
    
    var description: String {
        // Automatic descriptions for debug UI
    }
}

// DebugFeatureFlagService for testing
// UserDefaultsFeatureFlagService for development/production
```

### Sample Data Architecture
```swift
// Comprehensive 22-patient dataset
PatientSampleDataService.generateSamplePatients()
// - 10 Dogs (realistic breeds and characteristics)
// - 8 Cats (diverse breeds and ages)
// - 4 Exotic pets (specialized veterinary cases)

// Development-only seeding with graceful error handling
Container.shared.developmentConfigurationService()
    .seedSampleDataIfNeeded()
```

## Security & HIPAA Compliance (Enhanced)

### Data Protection Layers
1. **Form Validation**: QuickForm sanitizes all inputs before processing
2. **Transport Security**: CloudKit private database encryption
3. **Storage Security**: SwiftData with CloudKit encryption at rest
4. **Access Control**: Feature flags control sensitive functionality
5. **Audit Trail**: Comprehensive logging of medical data access

### HIPAA-Compliant Patterns
```swift
protocol HIPAACompliantDataStore {
    func store<T: MedicalRecord>(_ record: T) async throws
    func retrieve<T: MedicalRecord>(_ type: T.Type, id: UUID) async throws -> T?
    func auditAccess(for recordId: UUID, by userId: UUID) async throws
}
```

## Performance Architecture

### Memory Management
- **Weak References**: All QuickForm callbacks use `[weak self]`
- **Actor Isolation**: Prevents data races and retain cycles
- **TestKit Tracking**: Automated memory leak detection in tests
- **Lazy Loading**: StateKit Paginated for large datasets

### Optimization Patterns
- **Debounced Search**: AsyncPickerFieldViewModel with 300ms debouncing
- **Caching Strategy**: FactoryKit `.cached` scope for services
- **Background Processing**: nonisolated functions for heavy computation
- **CloudKit Optimization**: Compound uniqueness constraints prevent conflicts

## Documentation Architecture (Sharded Approach)

### Technical Documentation (`docs/architecture/`)
- **swift-best-practices.md**: FactoryKit, FormatStyle, Measurement patterns
- **quickform-integration.md**: Comprehensive form architecture
- **quickform-patterns.mdc**: Practical implementation patterns
- **testing-strategy.md**: TestKit, StateKit, ViewInspector integration
- **data-models.md**: SwiftData + CloudKit architecture
- **security-compliance.md**: HIPAA and data protection measures

### Development Workflow (`/.claude/rules.md`)
- **TDD Principles**: Red → Green → Refactor methodology
- **Code Quality Standards**: SwiftFormat, SwiftLint, commit discipline
- **Automation Rules**: PostToolUse hooks and quality gates
- **Testing Workflow**: Comprehensive testing strategy implementation

## Development Environment Configuration

### Build Settings Integration
```swift
// Project-wide Swift concurrency configuration
SWIFT_APPROACHABLE_CONCURRENCY: true
SWIFT_DEFAULT_ACTOR_ISOLATION: "MainActor"
SWIFT_STRICT_CONCURRENCY: "Complete"
```

### Tuist Configuration Management
- **Multi-platform Targets**: iPad, iPhone, Mac catalyst support
- **Bundle Management**: `com.moroverse.VetNet` with proper versioning
- **Dependency Resolution**: Swift Package Manager integration
- **Test Configuration**: Separate test targets with mock data

This architecture represents a **mature, production-ready veterinary practice management system** that leverages cutting-edge Swift technologies while maintaining strict quality standards, comprehensive testing, and veterinary domain expertise. The integration of QuickForm, advanced testing utilities, and sophisticated dependency management creates a robust foundation for complex veterinary workflows.