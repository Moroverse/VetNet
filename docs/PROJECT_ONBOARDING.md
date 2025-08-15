# VetNet Project Onboarding Guide

> **Comprehensive documentation for developers joining the VetNet veterinary practice intelligence application**

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Development Environment Setup](#development-environment-setup)
3. [Architecture Overview](#architecture-overview)
4. [Key Technologies & Patterns](#key-technologies--patterns)
5. [Development Workflow](#development-workflow)
6. [Coding Standards & Conventions](#coding-standards--conventions)
7. [Feature Development Guide](#feature-development-guide)
8. [Testing Strategy](#testing-strategy)
9. [Debugging & Troubleshooting](#debugging--troubleshooting)
10. [Advanced Topics](#advanced-topics)
11. [Resources & References](#resources--references)
12. [Team Onboarding Checklist](#team-onboarding-checklist)
13. [Appendices](#appendices)

---

## Executive Summary

### Project Overview
VetNet is a cutting-edge iOS 26 veterinary practice intelligence application that revolutionizes how veterinary clinics manage patient care, appointments, and medical workflows. Built with Swift 6.2+ and leveraging the latest iOS capabilities, VetNet provides an intuitive, performant, and HIPAA-compliant solution for modern veterinary practices.

### Technology Stack at a Glance
- **Language**: Swift 6.2+ with structured concurrency
- **UI Framework**: SwiftUI with iOS 26 Liquid Glass design system
- **Architecture**: Clean Architecture + Domain-Driven Design (DDD)
- **State Management**: MVVM + @Observable
- **Navigation**: Custom SwiftUIRouting module (bidirectional, type-safe)
- **Data Layer**: SwiftData with CloudKit synchronization
- **Forms**: QuickForm (macro-driven form framework)
- **DI**: FactoryKit dependency injection
- **Testing**: Swift Testing + ViewInspector + TestKit
- **Build System**: Tuist project management

### Key Features
- **Patient Management**: Comprehensive patient profiles with medical history
- **Intelligent Scheduling**: AI-powered appointment optimization
- **Specialist Matching**: Smart veterinary specialist recommendations
- **Triage Assessment**: Urgency evaluation using VTL (Veterinary Triage Level) system
- **Real-time Sync**: CloudKit-powered data synchronization across devices
- **Offline Support**: Full functionality with local storage fallback
- **HIPAA Compliance**: Enterprise-grade security and audit trails

### Target Platforms
- **Primary**: iOS 26.0+ (iPhone, iPad)
- **Secondary**: Mac Catalyst
- **Module Support**: iOS 17.0+ (SwiftUIRouting)
- **Bundle ID**: `com.moroverse.VetNet`

---

## Development Environment Setup

### Prerequisites

#### System Requirements
- **macOS**: 15.0 (Sequoia) or later
- **Xcode**: 16.2 or later
- **Swift**: 6.2+
- **Storage**: ~5GB for project and dependencies

#### Required Tools
The project uses `mise` for tool version management. All required tools are specified in `mise.toml`:
- **Tuist**: 4.55.6+ (project generation)
- **SwiftFormat**: Latest (code formatting)
- **SwiftLint**: Latest (code quality)

### Initial Setup Steps

#### 1. Clone the Repository
```bash
git clone [repository-url]
cd VetNet
```

#### 2. Install mise (Tool Version Manager)
```bash
# Install mise if not already installed
curl https://mise.run | sh

# Add to your shell profile
echo 'eval "$(mise activate bash)"' >> ~/.bashrc  # or ~/.zshrc for zsh
source ~/.bashrc
```

#### 3. Install Project Tools
```bash
# This installs all tools specified in mise.toml
mise install

# Verify installation
mise list
```

#### 4. Generate Xcode Project
```bash
# Generate the Xcode workspace using Tuist
tuist install
tuist generate

# This creates VetNet.xcworkspace with all dependencies configured
```

#### 5. Open in Xcode
```bash
# Open the generated workspace
open VetNet.xcworkspace

# Or use Xcode directly: File → Open → VetNet.xcworkspace
```

#### 6. Build and Run
1. Select the **VetNet** scheme in Xcode
2. Choose your target device (iPhone/iPad simulator or device)
3. Press **⌘R** to build and run

### CloudKit Configuration (Optional)

For CloudKit synchronization features:

1. **Enable CloudKit in Apple Developer Portal**:
   - Sign in to developer.apple.com
   - Navigate to Certificates, IDs & Profiles
   - Select your App ID
   - Enable CloudKit capability
   - Create container: `iCloud.com.moroverse.VetNet`

2. **Configure Xcode Signing**:
   - Select VetNet target → Signing & Capabilities
   - Ensure automatic signing is enabled
   - CloudKit entitlements are already configured in `Project.swift`

3. **Test CloudKit**:
   - CloudKit works only on real devices or logged-in simulators
   - For local development, the app automatically falls back to local storage

### Troubleshooting Setup Issues

| Issue | Solution |
|-------|----------|
| `mise: command not found` | Ensure mise is in PATH, restart terminal |
| `tuist: command not found` | Run `mise install` to install tools |
| Build fails with signing error | Enable automatic signing in Xcode |
| CloudKit crashes on launch | Normal in simulator, app falls back to local storage |
| SwiftData migration error | Clean build folder (⌘⇧K) and rebuild |

---

## Architecture Overview

### Core Architectural Principles

VetNet follows a **Clean Architecture** approach with **Domain-Driven Design (DDD)** principles, ensuring:

1. **Separation of Concerns**: Clear boundaries between layers
2. **Dependency Inversion**: Domain layer has no external dependencies
3. **Testability**: All business logic is independently testable
4. **Scalability**: Features can be added/modified without affecting others
5. **Type Safety**: Leveraging Swift's type system for compile-time validation

### Project Structure

```
VetNet/
├── App/
│   ├── Sources/
│   │   ├── VetNetApp.swift                 # App entry point
│   │   ├── Core/                          # Shared components
│   │   │   └── DesignSystem/              # UI components
│   │   │       └── LiquidGlass.swift     # iOS 26 glass effects
│   │   ├── Features/                      # Feature modules
│   │   │   ├── PatientManagement/
│   │   │   │   ├── Domain/               # Business logic
│   │   │   │   │   ├── Models/          # Domain entities
│   │   │   │   │   │   ├── Patient.swift
│   │   │   │   │   │   ├── Species.swift
│   │   │   │   │   │   ├── Breed.swift
│   │   │   │   │   │   ├── PatientValidator.swift
│   │   │   │   │   │   ├── PatientValidationRules.swift
│   │   │   │   │   │   ├── DateProvider.swift
│   │   │   │   │   │   └── MedicalIDGenerator.swift
│   │   │   │   │   └── Repositories/    # Repository interfaces
│   │   │   │   │       └── PatientRepository.swift
│   │   │   │   ├── Navigation/          # Routing layer
│   │   │   │   │   ├── PatientRoute.swift
│   │   │   │   │   ├── PatientFormMode.swift
│   │   │   │   │   ├── PatientFormResult.swift
│   │   │   │   │   ├── PatientManagementFormRouter.swift
│   │   │   │   │   └── RouterEventFactory.swift
│   │   │   │   └── Presentation/        # UI layer
│   │   │   │       ├── Views/          # SwiftUI views
│   │   │   │       │   ├── PatientManagementView.swift
│   │   │   │       │   ├── PatientDetailsView.swift
│   │   │   │       │   ├── PatientFormView.swift
│   │   │   │       │   ├── BasicList.swift        # Generic list component
│   │   │   │       │   └── ConditionallySearchable.swift
│   │   │   │       └── ViewModels/     # View models
│   │   │   │           ├── PatientListViewModel.swift
│   │   │   │           ├── PatientDetailsViewModel.swift
│   │   │   │           ├── PatientFormViewModel.swift
│   │   │   │           ├── SearchScopeListModel.swift  # Search list model
│   │   │   │           └── PatientLoaderAdapter.swift
│   │   │   └── Settings/
│   │   │       └── [Similar structure]
│   │   ├── Infrastructure/                # Shared infrastructure
│   │   │   ├── Persistence/
│   │   │   │   └── Entities/           # SwiftData models (shared)
│   │   │   │       └── PatientEntity.swift
│   │   │   ├── Repositories/           # Repository implementations
│   │   │   │   └── SwiftDataPatientRepository.swift
│   │   │   ├── Services/               # External services
│   │   │   │   ├── RouterEventBroker.swift
│   │   │   │   └── UUIDProvider.swift
│   │   │   ├── Configuration/          # DI container setup
│   │   │   │   ├── Container+VetNet.swift
│   │   │   │   ├── FeatureFlagService.swift
│   │   │   │   └── DevelopmentConfigurationService.swift
│   │   │   ├── SampleData/             # Development data
│   │   │   │   ├── PatientSampleDataService.swift
│   │   │   │   └── DataSeedingService.swift
│   │   │   ├── Logging/                # Logging service
│   │   │   │   └── LoggingService.swift
│   │   │   └── Mocks/                  # Test doubles
│   │   │       └── MockPatientRepository.swift
│   │   └── TestControl/                   # Debug-only features
│   └── Tests/                             # Test suites
│       ├── UnitTests/
│       ├── IntegrationTests/
│       └── Mocks/
├── Modules/
│   └── SwiftUIRouting/                    # Custom navigation
│       ├── Sources/
│       └── Tests/
├── docs/                                   # Documentation
│   ├── architecture/                      # Technical specs
│   ├── prd/                              # Product requirements
│   └── stories/                          # User stories
├── Scripts/                               # Build scripts
├── Tuist/                                 # Tuist helpers
├── Project.swift                          # Tuist configuration
├── mise.toml                             # Tool versions
├── .swiftformat                          # Format rules
├── .swiftlint.yml                        # Lint rules
└── CLAUDE.md                             # AI assistant guide
```

### Architectural Layers

#### 1. Domain Layer (Pure Business Logic)
- **Location**: `Features/[Feature]/Domain/`
- **Responsibilities**:
  - Define business entities and value objects
  - Implement business rules and validation
  - Define repository protocols (interfaces)
  - Domain services for complex operations
- **Key Principle**: No dependencies on external frameworks
- **Example**:
  ```swift
  // Domain/Models/Patient.swift
  struct Patient: Sendable, Identifiable {
      let id: ID
      var name: String
      var species: Species
      var birthDate: Date
      var weight: Measurement<UnitMass>
  }
  
  // Domain/Protocols/PatientRepository.swift
  protocol PatientRepository: Sendable {
      func create(_ patient: Patient) async throws -> Patient
      func findById(_ id: Patient.ID) async throws -> Patient?
  }
  ```

#### 2. Presentation Layer (UI)
- **Location**: `Features/[Feature]/Presentation/`
- **Responsibilities**:
  - SwiftUI views and components
  - View models with @Observable
  - Form handling with QuickForm
  - StateKit ListModel integration
- **Technologies**: SwiftUI, QuickForm, StateKit
- **Example**:
  ```swift
  @Observable
  final class PatientListViewModel {
      @ObservationIgnored
      @Injected(\.patientLoader) private var loader
      
      var listModel: SearchScopeListModel<Paginated<Patient>, PatientQuery, SearchScope>
      
      init() {
          listModel = SearchScopeListModel(
              searchScope: .all,
              loader: { query in try await loader.load(query: query) },
              queryBuilder: { text, scope in PatientQuery(searchText: text, scope: scope) }
          )
      }
  }
  ```

#### 3. Navigation Layer
- **Location**: `Features/[Feature]/Navigation/`
- **Responsibilities**:
  - Route definitions and navigation logic
  - Form routing with result handling
  - Router event coordination
  - Navigation state management
- **Technologies**: SwiftUIRouting, StateKit
- **Example**:
  ```swift
  // Navigation/PatientManagementFormRouter.swift
  final class PatientManagementFormRouter: ObservableObject {
      @Published var patientFormMode: PatientFormMode?
      
      func presentPatientForm(mode: PatientFormMode) async -> PatientFormResult? {
          patientFormMode = mode
          // Wait for form completion and return result
      }
  }
  ```

#### 4. Infrastructure Layer (External World)
- **Location**: `Infrastructure/` and `Features/[Feature]/Infrastructure/`
- **Responsibilities**:
  - SwiftData entity definitions
  - Repository implementations
  - External service integrations
  - CloudKit synchronization
- **Key Pattern**: Implements domain protocols
- **Example**:
  ```swift
  // Infrastructure/Persistence/Entities/PatientEntity.swift
  @Model
  final class PatientEntity {
      @Attribute(.unique) var id: String
      var name: String
      var species: String
      var birthDate: Date
      var weightValue: Double
      var weightUnit: String
  }
  
  // Infrastructure/Repositories/SwiftDataPatientRepository.swift
  final class SwiftDataPatientRepository: PatientRepository {
      func create(_ patient: Patient) async throws -> Patient {
          // Convert domain model to entity, save, return
      }
  }
  ```

### Data Flow Architecture

```
User Interaction → View → ViewModel → Domain Service → Repository Protocol
                                                              ↓
                                                    Repository Implementation
                                                              ↓
                                                        SwiftData/CloudKit
```

### Key Architectural Decisions

1. **SwiftData Entities in Shared Infrastructure**
   - All persistence entities centralized in `Infrastructure/Persistence/Entities/`
   - Prevents duplication and ensures consistency
   - Repository pattern provides clean abstraction

2. **QuickForm for Complex Forms**
   - Macro-driven development eliminates boilerplate
   - Separate component structs from domain models
   - Reactive validation with field dependencies

3. **Custom SwiftUIRouting Module**
   - Bidirectional navigation with result passing
   - Type-safe routing without string-based URLs
   - Zero external dependencies

4. **FactoryKit for Dependency Injection**
   - Container-based registration
   - Environment-aware (debug/release/test)
   - Clean SwiftUI integration

---

## Key Technologies & Patterns

### QuickForm Framework

QuickForm revolutionizes form development in VetNet through Swift macros, eliminating boilerplate while providing type-safe, reactive forms.

#### Core Concepts

##### 1. Component-Based Architecture
```swift
// Separate form data from domain models
struct PatientComponents {
    var name: String = ""
    var species: Species = .dog
    var birthDate: Date = .now
    var weight: Measurement<UnitMass> = .init(value: 0, unit: .kilograms)
}

// QuickForm macro generates all boilerplate
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
}
```

##### 2. Validation Integration
```swift
@PostInit
private func configure() {
    // Setup validation rules
    name.validation = validator.nameValidation
    birthDate.validation = validator.birthdayValidation
    
    // Dynamic validation based on other fields
    species.onValueChanged { [weak self] newSpecies in
        guard let self else { return }
        weight.validation = validator.weightValidation(for: newSpecies)
        formState = .editing
    }
}
```

##### 3. Form State Management
```swift
enum FormState: Equatable {
    case idle           // No changes
    case editing        // Has unsaved changes
    case saving         // Save in progress
    case saved          // Successfully saved
    case error(String)  // Error occurred
    case validationError(String)
}

// Single source of truth for form state
private(set) var formState: FormState = .idle
```

#### QuickForm Best Practices
- Always use component structs, not domain models directly
- Implement validation in @PostInit
- Use weak self in callbacks to prevent retain cycles
- Track state changes with FormState enum
- See `/docs/architecture/quickform-patterns.mdc` for detailed patterns

### FactoryKit Dependency Injection

FactoryKit provides a powerful, SwiftUI-optimized dependency injection system.

#### Container Registration
```swift
// Infrastructure/Configuration/Container+VetNet.swift
extension Container {
    // Service with dependencies
    var patientManager: Factory<PatientManager> {
        self { 
            PatientManager(
                repository: self.patientRepository(),
                validator: self.patientValidator(),
                dateProvider: self.dateProvider()
            )
        }
        .cached  // Reuse within container lifecycle
    }
    
    // Repository with environment awareness
    var patientRepository: Factory<PatientRepository> {
        self {
            #if DEBUG
            if self.featureFlagService().isEnabled(.useMockData) {
                return MockPatientRepository()
            }
            #endif
            return SwiftDataPatientRepository(
                modelContext: self.modelContext()
            )
        }
        .cached
    }
}
```

#### Usage in ViewModels
```swift
@Observable
final class PatientListViewModel {
    @ObservationIgnored
    @Injected(\.patientManager) private var manager
    
    var patients: [Patient] = []
    
    func loadPatients() async {
        patients = await manager.fetchAll()
    }
}
```

#### Testing with FactoryKit
```swift
@Suite(.container)  // Clean container for each test
struct PatientManagerTests {
    @Test
    func testPatientCreation() async throws {
        // Register mock for this test
        Container.shared.patientRepository.register {
            MockPatientRepository(scenario: .success)
        }
        
        let manager = Container.shared.patientManager()
        let patient = try await manager.create(testPatient)
        
        #expect(patient.id != nil)
    }
}
```

### SwiftData + CloudKit Integration

VetNet uses SwiftData for local persistence with automatic CloudKit synchronization for multi-device support.

#### Entity Definition
```swift
// Infrastructure/Persistence/Entities/PatientEntity.swift
@Model
final class PatientEntity {
    @Attribute(.unique) var id: String
    var name: String
    var species: String
    var birthDate: Date
    var weightValue: Double
    var weightUnit: String
    
    // Computed property for domain conversion
    var weight: Measurement<UnitMass> {
        Measurement(value: weightValue, unit: UnitMass(symbol: weightUnit))
    }
}
```

#### Repository Pattern
```swift
final class SwiftDataPatientRepository: PatientRepository {
    private let modelContext: ModelContext
    
    func create(_ patient: Patient) async throws -> Patient {
        let entity = PatientEntity()
        entity.id = patient.id.rawValue
        entity.name = patient.name
        entity.species = patient.species.rawValue
        entity.birthDate = patient.birthDate
        entity.weightValue = patient.weight.value
        entity.weightUnit = patient.weight.unit.symbol
        
        modelContext.insert(entity)
        try modelContext.save()
        
        return entity.toDomainModel()
    }
}
```

#### CloudKit Configuration
```swift
// VetNetApp.swift
let cloudKitAvailable = !isPreview && !isTest && hasCloudKitEntitlements()

if cloudKitAvailable {
    modelContainer = try ModelContainer(
        for: schema,
        configurations: [
            ModelConfiguration(
                schema: schema,
                url: nil,
                cloudKitDatabase: .private("VetNetSecure")
            )
        ]
    )
} else {
    // Fallback to local storage
    modelContainer = try ModelContainer(for: schema)
}
```

### Custom SwiftUIRouting Module

A zero-dependency, type-safe navigation framework built specifically for VetNet's complex workflows.

#### Core Concepts
```swift
// Bidirectional routing with result passing
protocol FormRouting: Router {
    associatedtype FormResult
    func presentForm() async -> FormResult?
}

// Type-safe route definitions
enum AppRoute: Hashable {
    case patientDetail(Patient.ID)
    case appointmentEdit(Appointment.ID)
    case settings
}

// Usage in views
struct PatientListView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        List(patients) { patient in
            Button(patient.name) {
                router.navigate(to: .patientDetail(patient.id))
            }
        }
    }
}
```

### StateKit List Management Patterns

VetNet uses StateKit's `ListModel` for sophisticated list state management with search, pagination, and error handling.

#### ListModel Architecture

`ListModel` provides a complete solution for list management including:
- Loading states (empty, loading, loaded, error)
- Search functionality with debouncing
- Pagination support
- Error recovery with previous state preservation
- Selection tracking

#### Core Components

##### 1. SearchScopeListModel
A specialized `ListModel` that adds search scope filtering:

```swift
// SearchScopeListModel.swift
final class SearchScopeListModel<Model: RandomAccessCollection, Query: Sendable, V: Hashable>: ListModel<Model, Query>
    where Model: Sendable, Query: Sendable & Equatable, Model.Element: Identifiable & Sendable {
    
    var selectedScope: V {
        didSet {
            Task {
                await load(forceReload: true)
            }
        }
    }
    
    init(
        selection: Model.Element.ID? = nil,
        searchScope: V,
        configuration: ListModelConfiguration = .default,
        loader: @escaping ModelLoader<Query, Model>,
        queryBuilder: @escaping (String, V) -> Query,
        onSelectionChange: ((Model.Element?) -> Void)? = nil
    )
}
```

##### 2. BasicList View
A reusable SwiftUI view that integrates with `SearchScopeListModel`:

```swift
struct BasicList<Model: RandomAccessCollection, Query: Sendable, R: View, V: Hashable>: View 
    where Model: Sendable, Query: Sendable & Equatable, Model.Element: Identifiable & Sendable {
    
    @State var viewModel: SearchScopeListModel<Model, Query, V>
    private let listRow: (Model.Element) -> R
    
    var body: some View {
        ZStack {
            // Always render list when content available
            if let model = viewModel.currentContent {
                list(model)
            } else if case let .empty(label, imageResource) = viewModel.state {
                ContentUnavailableView(
                    String(localized: label),
                    systemImage: imageResource
                )
            }
            
            // Overlay progress indicator when loading
            if case let .inProgress(task, _) = viewModel.state {
                ContentUnavailableView {
                    ProgressView()
                } description: {
                    Text("Loading")
                }
            }
        }
        .conditionallySearchable(isSearchable: isSearchable, text: $searchText)
    }
}
```

##### 3. ListModel Extensions
Convenience properties for state management:

```swift
extension ListModel {
    /// Returns current content regardless of loading state
    var currentContent: Model? {
        switch state {
        case .empty: nil
        case let .loaded(model, _): model
        case let .inProgress(_, previousState):
            // Preserve content during loading
            if case let .loaded(model, _) = previousState {
                return model
            }
            return nil
        case let .error(_, previousState):
            // Preserve content during error
            if case let .loaded(model, _) = previousState {
                return model
            }
            return nil
        }
    }
    
    var isError: Bool {
        if case .error = state { true } else { false }
    }
}
```

#### Integration Example

```swift
// PatientListViewModel.swift
@Observable
final class PatientListViewModel {
    var listModel: SearchScopeListModel<Paginated<Patient>, PatientQuery, SearchScope>
    
    init(patientLoader: PatientLoaderAdapter) {
        listModel = SearchScopeListModel(
            searchScope: .all,
            configuration: .init(
                searchDebounceTime: 0.3,
                emptyStateMessage: "No patients found",
                emptyStateImage: "person.2.slash"
            ),
            loader: { query in
                try await patientLoader.load(query: query)
            },
            queryBuilder: { searchText, scope in
                PatientQuery(searchText: searchText, scope: scope)
            },
            onSelectionChange: { patient in
                // Handle selection
            }
        )
    }
}

// Usage in SwiftUI
struct PatientManagementView: View {
    @StateObject private var viewModel = PatientListViewModel()
    
    var body: some View {
        BasicList(
            viewModel: viewModel.listModel,
            isSearchable: true
        ) { patient in
            PatientRow(patient: patient)
        }
        .searchScopes($viewModel.listModel.selectedScope) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.description).tag(scope)
            }
        }
    }
}
```

#### Best Practices for List Management

1. **State Preservation**: ListModel preserves previous content during loading/error states
2. **Search Debouncing**: Configure appropriate debounce time (0.3s default)
3. **Error Recovery**: Users can retry while viewing cached content
4. **Pagination**: Use StateKit's `Paginated` type with `LoadMoreCompletion`
5. **Component Extraction**: Extract `BasicList` to Core level for reuse across features

**Note**: The `BasicList` component should be moved to `App/Sources/Core/Components/` for better reusability across features.

### Swift Best Practices

#### FormatStyle for Consistent Formatting
```swift
extension FormatStyle where Self == Date.FormatStyle {
    static var appointmentTime: Self {
        .dateTime
            .hour(.defaultDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
}

// Usage
Text(appointment.time.formatted(.appointmentTime))  // "9:30 AM"
```

#### Measurement API for Veterinary Calculations
```swift
struct MedicationDose {
    func calculate(for weight: Measurement<UnitMass>) -> Measurement<UnitVolume> {
        let weightInKg = weight.converted(to: .kilograms)
        let mgPerKg = 0.5  // Dosage rate
        let totalMg = weightInKg.value * mgPerKg
        
        return Measurement(value: totalMg / concentration, unit: .milliliters)
    }
}
```

#### Structured Concurrency
```swift
// Parallel operations with TaskGroup
func optimizeSchedule(appointments: [Appointment]) async -> Schedule {
    await withTaskGroup(of: OptimizationResult.self) { group in
        for specialist in specialists {
            group.addTask {
                await optimizeForSpecialist(specialist, appointments)
            }
        }
        
        var results: [OptimizationResult] = []
        for await result in group {
            results.append(result)
        }
        
        return combineResults(results)
    }
}
```

---

## Development Workflow

### Essential Commands

#### Building and Running
```bash
# Generate Xcode project (required after adding/removing files)
tuist generate

# Build the main app
tuist build VetNet

# Build specific platform
tuist build VetNet --platform ios

# Clean build
tuist clean
```

#### Testing
```bash
# Run all tests
tuist test

# Run with coverage report
tuist test --coverage

# Run specific test target
tuist test VetNetTests

# Skip UI tests (faster)
tuist test --platform ios --skip-ui-tests

# Test custom module
cd Modules/SwiftUIRouting
swift test
```

#### Code Quality
```bash
# Format all Swift files
swiftformat .

# Run linter
swiftlint

# Auto-fix linter issues
swiftlint --fix
```

### Test-Driven Development (TDD) Workflow

VetNet follows strict TDD principles based on Kent Beck's methodology:

#### The TDD Cycle
1. **🔴 Red**: Write a failing test first
2. **🟢 Green**: Write minimal code to pass
3. **♻️ Refactor**: Improve code with tests passing
4. **🔄 Repeat**: Continue for next feature

#### Example TDD Flow
```swift
// 1. RED: Write failing test
@Test("Patient name validation")
func testPatientNameValidation() {
    let validator = PatientValidator()
    
    #expect(validator.isValidName(""))           // Empty should fail
    #expect(validator.isValidName("A"))          // Too short
    #expect(!validator.isValidName("Bella123"))  // Numbers not allowed
    #expect(validator.isValidName("Bella"))      // Valid name
}

// 2. GREEN: Minimal implementation
struct PatientValidator {
    func isValidName(_ name: String) -> Bool {
        !name.isEmpty && 
        name.count >= 2 && 
        name.allSatisfy { $0.isLetter || $0.isWhitespace }
    }
}

// 3. REFACTOR: Improve with validation rules
var nameValidation: AnyValidationRule<String> {
    .combined(
        .notEmpty,
        .minLength(2),
        .maxLength(50),
        AllowedCharactersRule(.letters.union(.whitespaces))
    )
}
```

### Commit Discipline

#### Commit Requirements
✅ **Before committing, ensure**:
- All tests pass (`tuist test`)
- No compiler warnings
- SwiftLint violations resolved
- Code properly formatted
- Single logical unit of work

#### Commit Message Format
```bash
# Structural changes (refactoring)
[STRUCTURAL] Refactor: Extract PatientValidator to separate file

# Behavioral changes (features)
[BEHAVIORAL] Feature: Add patient weight validation

# Test additions
[TEST] Test: Add unit tests for appointment scheduling

# Bug fixes
[FIX] Fix: Resolve CloudKit entitlement crash on launch
```

### Feature Development Workflow

#### 1. Create Feature Branch
```bash
git checkout -b feature/patient-medication-tracking
```

#### 2. Implement Feature (TDD)
1. Write failing tests
2. Implement domain models
3. Create QuickForm view models
4. Build SwiftUI views
5. Add repository implementation
6. Ensure all tests pass

#### 3. Code Quality Check
```bash
# Format code
swiftformat .

# Lint check
swiftlint

# Run tests
tuist test --platform ios --skip-ui-tests
```

#### 4. Commit Changes
```bash
# Stage changes
git add .

# Commit with proper message
git commit -m "[BEHAVIORAL] Feature: Add medication tracking for patients"
```

### Debugging Workflow

#### Using Feature Flags
```swift
// Enable mock data for testing
Container.shared.featureFlagService().setEnabled(.useMockData, true)

// Check flag in code
if featureFlags.isEnabled(.experimentalFeature) {
    // New feature code
}
```

#### Debug Menu (Shake Gesture)
In debug builds, shake the device to access:
- Feature flag toggles
- Sample data seeding
- CloudKit sync status
- Performance metrics

#### Logging
```swift
@Injected(\.logger) private var logger

logger.debug("Loading patients", metadata: ["count": patients.count])
logger.error("Failed to save", error: error)
```

---

## Coding Standards & Conventions

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| **Domain Models** | PascalCase, descriptive | `Patient`, `Appointment`, `Treatment` |
| **SwiftData Entities** | PascalCase + 'Entity' suffix | `PatientEntity`, `AppointmentEntity` |
| **Service Protocols** | PascalCase + 'Service' suffix | `TriageService`, `SchedulingService` |
| **Repository Protocols** | PascalCase + 'Repository' suffix | `PatientRepository` |
| **SwiftUI Views** | PascalCase + 'View' suffix | `PatientDetailView`, `AppointmentListView` |
| **View Models** | PascalCase + 'ViewModel' suffix | `PatientFormViewModel` |
| **State Properties** | camelCase with @Observable | `@Observable var isLoading` |
| **Constants** | camelCase or UPPER_SNAKE | `defaultTimeout`, `MAX_RETRIES` |
| **Feature Flags** | camelCase | `useMockData`, `enableCloudSync` |

### Swift Language Standards

#### Concurrency Settings (Project-wide)
```swift
// Configured in Project.swift
"SWIFT_APPROACHABLE_CONCURRENCY": true
"SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor"  // Most classes are MainActor by default
"SWIFT_STRICT_CONCURRENCY": "Complete"
```

#### Actor Isolation
```swift
// Most UI code is implicitly MainActor-isolated
@Observable
class PatientViewModel {  // Implicitly @MainActor
    var patients: [Patient] = []
    
    // Opt-out for background work
    nonisolated func processDataInBackground() async {
        // Runs off main actor
    }
}
```

### Code Organization

#### File Structure Template
```swift
// PatientDetailView.swift
// Copyright (c) 2025 Moroverse

import SwiftUI
import FactoryKit
import QuickForm

// MARK: - View Model

@Observable
final class PatientDetailViewModel {
    // Properties
    // Methods
}

// MARK: - View

struct PatientDetailView: View {
    @Bindable private var viewModel: PatientDetailViewModel
    
    var body: some View {
        // View implementation
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Patient Detail") {
    PatientDetailView(viewModel: .mock)
}
#endif
```

### SwiftUI Best Practices

#### Accessibility
```swift
struct PatientRow: View {
    let patient: Patient
    
    var body: some View {
        HStack {
            Text(patient.name)
                .accessibilityIdentifier("patient_row_name")
                .accessibilityLabel("Patient name: \(patient.name)")
            
            Text(patient.species.description)
                .accessibilityIdentifier("patient_row_species")
        }
        .accessibilityElement(children: .combine)
    }
}
```

#### View Composition
```swift
// Prefer small, focused views
struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading) {
            AppointmentHeader(appointment: appointment)
            AppointmentDetails(appointment: appointment)
            AppointmentActions(appointment: appointment)
        }
    }
}
```

### Testing Standards

#### Test Naming
```swift
@Suite("Patient Validation")
struct PatientValidationTests {
    @Test("Valid patient names pass validation")
    func testValidPatientNames() { }
    
    @Test("Empty name fails validation")
    func testEmptyNameValidation() { }
}
```

#### Test Organization (AAA Pattern)
```swift
@Test
func testAppointmentScheduling() async throws {
    // Arrange
    let repository = MockAppointmentRepository()
    let scheduler = SchedulingService(repository: repository)
    let appointment = Appointment.mock
    
    // Act
    let scheduled = try await scheduler.schedule(appointment)
    
    // Assert
    #expect(scheduled.id != nil)
    #expect(scheduled.status == .confirmed)
}
```

### Documentation Standards

#### Public API Documentation
```swift
/// Calculates the appropriate medication dosage for a patient
/// - Parameters:
///   - medication: The medication to administer
///   - patient: The patient receiving medication
/// - Returns: Calculated dosage with units
/// - Throws: `DosageError` if patient weight is invalid
public func calculateDosage(
    for medication: Medication,
    patient: Patient
) throws -> Measurement<UnitVolume> {
    // Implementation
}
```

#### Complex Logic Comments
```swift
// Only use comments for non-obvious logic
func optimizeSchedule() {
    // Use dynamic programming to find optimal slot allocation
    // considering specialist availability and patient urgency
    
    // Implementation details...
}
```

---

## Feature Development Guide

### Creating a New Feature

#### Step 1: Domain Layer Design
```swift
// Features/MedicationTracking/Domain/Models/Medication.swift
struct Medication: Identifiable, Sendable {
    let id: ID
    var name: String
    var dosage: Measurement<UnitMass>
    var frequency: Frequency
    var startDate: Date
    var endDate: Date?
    
    enum Frequency: String, CaseIterable {
        case daily, twiceDaily, threeTimesDaily, asNeeded
    }
}

// Features/MedicationTracking/Domain/Protocols/MedicationRepository.swift
protocol MedicationRepository: Sendable {
    func create(_ medication: Medication) async throws -> Medication
    func update(_ medication: Medication) async throws -> Medication
    func delete(_ id: Medication.ID) async throws
    func findByPatient(_ patientId: Patient.ID) async throws -> [Medication]
}
```

#### Step 2: QuickForm Integration
```swift
// Features/MedicationTracking/UI/ViewModels/MedicationFormViewModel.swift

struct MedicationComponents {
    var name: String = ""
    var dosage: Measurement<UnitMass> = .init(value: 0, unit: .milligrams)
    var frequency: Medication.Frequency = .daily
    var startDate: Date = .now
    var hasEndDate: Bool = false
    var endDate: Date = .now
}

@QuickForm(MedicationComponents.self)
final class MedicationFormViewModel: Validatable {
    @PropertyEditor(keyPath: \MedicationComponents.name)
    var name = FormFieldViewModel(
        type: String.self,
        title: "Medication Name",
        placeholder: "e.g., Amoxicillin"
    )
    
    @PropertyEditor(keyPath: \MedicationComponents.dosage)
    var dosage = FormFieldViewModel(
        value: Measurement(value: 0, unit: UnitMass.milligrams),
        title: "Dosage",
        placeholder: "0.0"
    )
    
    @Injected(\.medicationValidator)
    private var validator
    
    private(set) var formState: FormState = .idle
    
    @PostInit
    private func configure() {
        name.validation = validator.nameValidation
        dosage.validation = validator.dosageValidation
    }
    
    func save() async {
        formState = .saving
        
        guard validate() == .success else {
            formState = .validationError("Please correct the errors")
            return
        }
        
        do {
            let medication = Medication(
                name: name.value,
                dosage: dosage.value,
                frequency: frequency.value,
                startDate: startDate.value,
                endDate: hasEndDate.value ? endDate.value : nil
            )
            
            _ = try await repository.create(medication)
            formState = .saved
        } catch {
            formState = .error(error.localizedDescription)
        }
    }
}
```

#### Step 3: SwiftUI View
```swift
// Features/MedicationTracking/UI/Views/MedicationFormView.swift
struct MedicationFormView: View {
    @Bindable private var viewModel: MedicationFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(patientId: Patient.ID) {
        self.viewModel = MedicationFormViewModel(patientId: patientId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Medication Details") {
                    FormTextField(viewModel.name)
                    FormValueDimensionField(viewModel.dosage)
                    FormPickerField(viewModel.frequency)
                }
                
                Section("Schedule") {
                    FormDatePickerField(
                        viewModel.startDate,
                        title: "Start Date"
                    )
                    
                    Toggle("Set End Date", isOn: $viewModel.hasEndDate.value)
                    
                    if viewModel.hasEndDate.value {
                        FormDatePickerField(
                            viewModel.endDate,
                            title: "End Date"
                        )
                    }
                }
            }
            .navigationTitle("New Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .disabled(viewModel.formState == .saving)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.formState.isError)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if case .error(let message) = viewModel.formState {
                    Text(message)
                }
            }
        }
    }
}
```

#### Step 4: Repository Implementation
```swift
// Infrastructure/Repositories/SwiftDataMedicationRepository.swift
final class SwiftDataMedicationRepository: MedicationRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func create(_ medication: Medication) async throws -> Medication {
        let entity = MedicationEntity()
        entity.updateFrom(medication)
        
        modelContext.insert(entity)
        try modelContext.save()
        
        return entity.toDomainModel()
    }
    
    func findByPatient(_ patientId: Patient.ID) async throws -> [Medication] {
        let descriptor = FetchDescriptor<MedicationEntity>(
            predicate: #Predicate { $0.patientId == patientId.rawValue },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomainModel() }
    }
}
```

#### Step 5: Testing
```swift
// Tests/Unit/MedicationValidatorTests.swift
@Suite("Medication Validation")
struct MedicationValidatorTests {
    @Test("Valid medication names")
    func testValidMedicationNames() {
        let validator = MedicationValidator()
        
        #expect(validator.isValidName("Amoxicillin"))
        #expect(validator.isValidName("Vitamin B-12"))
        #expect(!validator.isValidName(""))
        #expect(!validator.isValidName("A"))  // Too short
    }
    
    @Test("Dosage validation")
    func testDosageValidation() {
        let validator = MedicationValidator()
        
        let valid = Measurement(value: 500, unit: UnitMass.milligrams)
        let invalid = Measurement(value: -10, unit: UnitMass.milligrams)
        
        #expect(validator.isValidDosage(valid))
        #expect(!validator.isValidDosage(invalid))
    }
}
```

### Common Implementation Patterns

#### Error Handling with Retry
```swift
enum RepositoryError: Error {
    case notFound
    case duplicateKey
    case networkError(Error)
    
    var isRetryable: Bool {
        switch self {
        case .networkError:
            return true
        case .notFound, .duplicateKey:
            return false
        }
    }
}

// In view model
func save() async {
    do {
        try await repository.save(patient)
    } catch let error as RepositoryError where error.isRetryable {
        formState = .error(error.localizedDescription, isRetryable: true)
    } catch {
        formState = .error(error.localizedDescription, isRetryable: false)
    }
}
```

#### Feature Flags for Gradual Rollout
```swift
// Check feature availability
if Container.shared.featureFlagService().isEnabled(.medicationTrackingV2) {
    // New implementation
    MedicationFormV2View()
} else {
    // Existing implementation
    MedicationFormView()
}

// Toggle in debug menu
struct DebugSettingsView: View {
    @Injected(\.featureFlagService) var flags
    
    var body: some View {
        Toggle("Medication Tracking V2", 
               isOn: flags.binding(for: .medicationTrackingV2))
    }
}
```

---

## Testing Strategy

### Test Types and Coverage Goals

| Test Type | Coverage Target | Tools | Purpose |
|-----------|----------------|-------|---------|
| **Unit Tests** | >80% | Swift Testing | Business logic, validators, calculations |
| **Integration Tests** | >60% | Swift Testing + TestKit | Repository, service integration |
| **UI Tests** | Critical paths | ViewInspector | View behavior, user interactions |
| **Snapshot Tests** | Key screens | SnapshotTesting | Visual regression |
| **Performance Tests** | Hot paths | XCTest | Algorithm efficiency |

### Unit Testing

#### Swift Testing Framework
```swift
// Modern Swift Testing with @Suite and @Test
@Suite("Patient Manager")
struct PatientManagerTests {
    // Setup/teardown if needed
    init() async throws { }
    deinit { }
    
    @Test("Create patient with valid data")
    func testCreatePatient() async throws {
        let manager = PatientManager(repository: MockPatientRepository())
        
        let patient = Patient(
            name: "Bella",
            species: .dog,
            birthDate: Date(),
            weight: Measurement(value: 25, unit: .kilograms)
        )
        
        let created = try await manager.create(patient)
        
        #expect(created.id != nil)
        #expect(created.name == "Bella")
    }
    
    @Test("Validation fails for invalid weight", arguments: [
        (-5.0, "Negative weight"),
        (0.0, "Zero weight"),
        (1000.0, "Excessive weight")
    ])
    func testWeightValidation(weight: Double, scenario: String) {
        let validator = PatientValidator()
        let measurement = Measurement(value: weight, unit: UnitMass.kilograms)
        
        #expect(!validator.isValidWeight(measurement, for: .dog))
    }
}
```

### UI Testing with ViewInspector

#### Setup ViewInspector
```swift
// Tests/UI/PatientFormViewTests.swift
import ViewInspector
import XCTest

@Suite("Patient Form View")
struct PatientFormViewTests {
    @Test("Form displays all required fields")
    func testFormFields() throws {
        let viewModel = PatientFormViewModel(value: PatientComponents())
        let view = PatientFormView(viewModel: viewModel)
        
        let form = try view.inspect().find(ViewType.Form.self)
        
        // Find fields by accessibility identifier
        let nameField = try form.find(viewWithAccessibilityIdentifier: "patient_name_field")
        let speciesField = try form.find(viewWithAccessibilityIdentifier: "patient_species_picker")
        
        #expect(try nameField.string() == "Patient Name")
        #expect(try speciesField.picker().count == Species.allCases.count)
    }
    
    @Test("Save button disabled when form invalid")
    func testSaveButtonState() throws {
        let viewModel = PatientFormViewModel(value: PatientComponents())
        let view = PatientFormView(viewModel: viewModel)
        
        let saveButton = try view.inspect()
            .find(button: "Save")
        
        #expect(try saveButton.isDisabled() == true)
        
        // Fill required fields
        viewModel.name.value = "Bella"
        viewModel.weight.value = Measurement(value: 25, unit: .kilograms)
        
        #expect(try saveButton.isDisabled() == false)
    }
}
```

### Advanced Testing Utilities

#### Memory Leak Detection with TestKit
```swift
import TestKit

@Test("View model has no memory leaks", .teardownTracking())
func testMemoryLeaks() async throws {
    let viewModel = PatientListViewModel()
    
    // Track for leaks
    await Test.trackForMemoryLeaks(viewModel)
    
    // Perform operations
    await viewModel.loadPatients()
    
    // Test automatically fails if viewModel isn't deallocated
}
```

#### Async Testing with AsyncSpy
```swift
@Test("Loading state transitions correctly")
func testLoadingStates() async throws {
    let spy = AsyncSpy<[Patient]>()
    let viewModel = PatientListViewModel(service: spy)
    
    try await spy.async {
        await viewModel.loadPatients()
    } expectationBeforeCompletion: {
        #expect(viewModel.isLoading == true)
        #expect(viewModel.patients.isEmpty)
    } completeWith: {
        .success([Patient.mock1, Patient.mock2])
    } expectationAfterCompletion: { _ in
        #expect(viewModel.isLoading == false)
        #expect(viewModel.patients.count == 2)
    }
}
```

### Mock Strategies

#### StateKit MockService
```swift
#if DEBUG
extension MockService: PatientService where T == [Patient] {
    static func mock() -> Self {
        Self(result: .success(Patient.sampleData))
    }
    
    static func error() -> Self {
        Self(result: .failure(ServiceError.networkError))
    }
    
    static func slow() -> Self {
        Self(result: .success(Patient.sampleData), delay: .seconds(2))
    }
    
    static func empty() -> Self {
        Self(result: .success([]))
    }
}

// Usage in previews
#Preview("Loading State") {
    PatientListView()
        .environment(\.patientService, MockService<[Patient]>.slow())
}
#endif
```

#### Custom Mock Repositories
```swift
final class MockPatientRepository: PatientRepository {
    enum Scenario {
        case success
        case notFound
        case networkError
        case duplicateKey
    }
    
    var scenario: Scenario = .success
    private var storage: [Patient.ID: Patient] = [:]
    
    func create(_ patient: Patient) async throws -> Patient {
        switch scenario {
        case .success:
            var newPatient = patient
            newPatient.id = Patient.ID()
            storage[newPatient.id] = newPatient
            return newPatient
            
        case .duplicateKey:
            throw RepositoryError.duplicateKey
            
        case .networkError:
            throw RepositoryError.networkError(URLError(.notConnectedToInternet))
            
        case .notFound:
            throw RepositoryError.notFound
        }
    }
}
```

### Test Data Generation

#### Sample Data Service
```swift
struct PatientSampleDataService {
    static func generateSamplePatients() -> [Patient] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            // Dogs
            Patient(
                name: "Max",
                species: .dog,
                breed: "Golden Retriever",
                birthDate: calendar.date(byAdding: .year, value: -3, to: now)!,
                weight: Measurement(value: 30.5, unit: .kilograms)
            ),
            Patient(
                name: "Bella",
                species: .dog,
                breed: "Labrador",
                birthDate: calendar.date(byAdding: .year, value: -5, to: now)!,
                weight: Measurement(value: 28.0, unit: .kilograms)
            ),
            
            // Cats
            Patient(
                name: "Luna",
                species: .cat,
                breed: "Persian",
                birthDate: calendar.date(byAdding: .year, value: -2, to: now)!,
                weight: Measurement(value: 4.2, unit: .kilograms)
            ),
            
            // Exotic
            Patient(
                name: "Coco",
                species: .bird,
                breed: "African Grey Parrot",
                birthDate: calendar.date(byAdding: .year, value: -15, to: now)!,
                weight: Measurement(value: 0.4, unit: .kilograms)
            )
        ]
    }
}
```

### Testing Best Practices

1. **Test Isolation**: Use `.container` trait for clean DI container
2. **Descriptive Names**: Clear test names that describe behavior
3. **AAA Pattern**: Arrange, Act, Assert structure
4. **Mock Boundaries**: Mock at repository/service level, not domain
5. **Async Safety**: Use AsyncSpy for controlled async testing
6. **Memory Management**: Track leaks with TestKit
7. **Preview Testing**: Use MockService for SwiftUI previews

---

## Debugging & Troubleshooting

### Common Issues and Solutions

#### CloudKit Entitlement Errors

**Issue**: App crashes on launch with CloudKit entitlement error

**Solution**:
```swift
// The app automatically detects and handles this
// Check VetNetApp.swift for the fallback logic:

private func hasCloudKitEntitlements() -> Bool {
    guard let entitlements = Bundle.main.infoDictionary?["Entitlements"] as? [String: Any] else {
        return false
    }
    return entitlements["com.apple.developer.icloud-services"] != nil
}

// If CloudKit unavailable, app falls back to local storage
// This is normal in:
// - Simulator without iCloud login
// - Debug builds without proper provisioning
// - Tests and previews
```

**To enable CloudKit**:
1. Sign into iCloud on simulator/device
2. Ensure proper provisioning profile
3. Check entitlements in Project.swift

#### SwiftData Migration Issues

**Issue**: App crashes with SwiftData schema mismatch

**Solution**:
```bash
# Clean build folder
Command + Shift + K in Xcode
# Or
tuist clean

# Delete app from simulator/device
# Reinstall fresh
```

**For production migrations**:
```swift
// Add migration plan in ModelContainer
let migrationPlan = SchemaMigrationPlan(
    from: SchemaV1.self,
    to: SchemaV2.self,
    stages: [
        MigrateV1ToV2.self
    ]
)
```

#### QuickForm Validation Not Triggering

**Issue**: Form validation doesn't update when expected

**Solution**:
```swift
// Ensure validation is set in @PostInit
@PostInit
private func configure() {
    // Set up validations here, not in init
    name.validation = validator.nameValidation
    
    // For dynamic validation
    species.onValueChanged { [weak self] newValue in
        guard let self else { return }
        // Update dependent field validation
        weight.validation = validator.weightValidation(for: newValue)
    }
}

// Always use weak self in callbacks
```

#### Memory Leaks in View Models

**Issue**: View models not deallocating

**Solution**:
```swift
// 1. Use @ObservationIgnored for injected properties
@Observable
final class PatientViewModel {
    @ObservationIgnored  // Prevents retain cycle
    @Injected(\.patientService) private var service
}

// 2. Use weak self in all closures
Task { [weak self] in
    guard let self else { return }
    await self.loadData()
}

// 3. Test for leaks
@Test(.teardownTracking())
func testNoMemoryLeaks() async {
    let viewModel = PatientViewModel()
    await Test.trackForMemoryLeaks(viewModel)
}
```

### Debug Tools

#### Feature Flags

Access via shake gesture in debug builds:

```swift
// Toggle features at runtime
Container.shared.featureFlagService().setEnabled(.useMockData, true)
Container.shared.featureFlagService().setEnabled(.debugLogging, true)

// Check in code
if featureFlags.isEnabled(.experimentalFeature) {
    // New code path
}
```

#### Sample Data Seeding

```swift
// Seed sample data for testing
let seeder = DataSeedingService()
await seeder.seedSampleData()

// Access in debug menu
struct DebugMenu: View {
    @Injected(\.dataSeedingService) var seeder
    
    Button("Seed Sample Data") {
        Task { await seeder.seedSampleData() }
    }
}
```

#### Logging System

```swift
// Configure logging levels
LoggingService.shared.setLevel(.debug)

// Use semantic logging
logger.debug("Loading patients", metadata: [
    "count": patients.count,
    "source": "CloudKit"
])

logger.error("Save failed", 
    error: error,
    metadata: ["patientId": patient.id])

// View logs in Console.app with subsystem filter:
// subsystem: com.moroverse.VetNet
```

#### Performance Debugging

```swift
// Measure operation time
let start = CFAbsoluteTimeGetCurrent()
await expensiveOperation()
let elapsed = CFAbsoluteTimeGetCurrent() - start
logger.performance("Operation completed", duration: elapsed)

// Use Instruments for detailed profiling:
// 1. Product → Profile in Xcode
// 2. Choose Time Profiler or Allocations
// 3. Record and analyze
```

### Build Configuration Issues

#### Tuist Generation Fails

```bash
# Clear Tuist cache
tuist clean

# Update dependencies
tuist install

# Regenerate with verbose output
tuist generate --verbose
```

#### SwiftLint/SwiftFormat Issues

```bash
# Update tools
mise install

# Check versions
swiftlint version
swiftformat --version

# Run with auto-fix
swiftlint --fix
swiftformat . --swiftversion 6.0
```

### Network and Data Issues

#### CloudKit Sync Not Working

1. Check CloudKit Dashboard at https://icloud.developer.apple.com
2. Verify container exists: `iCloud.com.moroverse.VetNet`
3. Check device has network connection
4. Ensure user is signed into iCloud
5. Look for sync errors in logs:

```swift
// Add CloudKit error logging
modelContainer.cloudKitDatabase?.errorHandler = { error in
    logger.error("CloudKit sync error", error: error)
}
```

#### Repository Errors

```swift
// Add detailed error handling
do {
    try await repository.save(patient)
} catch RepositoryError.duplicateKey {
    // Handle duplicate
    showAlert("A patient with this ID already exists")
} catch RepositoryError.notFound {
    // Handle not found
    showAlert("Patient not found")
} catch {
    // Log full error
    logger.error("Repository error", error: error)
    showAlert("An error occurred: \(error.localizedDescription)")
}
```

---

## Advanced Topics

### Performance Optimization

#### Debounced Search
```swift
// Prevent excessive API calls during typing
@Observable
final class SearchViewModel {
    var searchText = "" {
        didSet { debounceSearch() }
    }
    
    private var searchTask: Task<Void, Never>?
    
    private func debounceSearch() {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            await performSearch()
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            results = []
            return
        }
        
        results = await repository.search(searchText)
    }
}
```

#### Lazy Loading with Pagination
```swift
// StateKit's Paginated type for efficient data loading
struct PatientListView: View {
    @State private var patients = Paginated<Patient>(items: [])
    
    var body: some View {
        List {
            ForEach(patients.items) { patient in
                PatientRow(patient: patient)
            }
            
            if patients.hasMore {
                ProgressView()
                    .onAppear {
                        Task { await loadMore() }
                    }
            }
        }
    }
    
    func loadMore() async {
        guard let loadMore = patients.loadMore else { return }
        patients = await loadMore()
    }
}
```

#### Background Processing
```swift
// Use nonisolated for CPU-intensive work
@Observable
final class DataProcessor {
    // UI properties on MainActor
    var progress: Double = 0
    var isProcessing = false
    
    // Background processing off MainActor
    nonisolated func processLargeDataset(_ data: [RawData]) async -> [ProcessedData] {
        await withTaskGroup(of: ProcessedData.self) { group in
            for item in data {
                group.addTask {
                    await self.processItem(item)
                }
            }
            
            var results: [ProcessedData] = []
            for await result in group {
                results.append(result)
                await MainActor.run {
                    self.progress = Double(results.count) / Double(data.count)
                }
            }
            
            return results
        }
    }
}
```

### Security & HIPAA Compliance

#### Data Encryption
```swift
// SwiftData + CloudKit provides automatic encryption
// Additional app-level encryption for sensitive fields:

extension Patient {
    var encryptedMedicalNotes: Data? {
        get {
            guard let notes = medicalNotes else { return nil }
            return CryptoKit.seal(notes, using: symmetricKey)
        }
        set {
            guard let encrypted = newValue else {
                medicalNotes = nil
                return
            }
            medicalNotes = CryptoKit.open(encrypted, using: symmetricKey)
        }
    }
}
```

#### Access Control
```swift
protocol HIPAACompliantAccess {
    func auditAccess(to record: any MedicalRecord, by user: User)
    func validateAccess(to record: any MedicalRecord, for user: User) -> Bool
}

struct AuditLogger: HIPAACompliantAccess {
    func auditAccess(to record: any MedicalRecord, by user: User) {
        logger.audit("Medical record accessed", metadata: [
            "recordId": record.id,
            "recordType": String(describing: type(of: record)),
            "userId": user.id,
            "timestamp": Date().ISO8601Format(),
            "action": "view"
        ])
    }
}
```

#### Data Retention
```swift
// Automatic cleanup of old records per HIPAA requirements
struct DataRetentionService {
    let retentionPeriod = DateComponents(year: 7)  // HIPAA minimum
    
    func cleanupExpiredRecords() async throws {
        let cutoffDate = Calendar.current.date(
            byAdding: retentionPeriod.negated(), 
            to: Date()
        )!
        
        let descriptor = FetchDescriptor<PatientEntity>(
            predicate: #Predicate { 
                $0.lastAccessDate < cutoffDate && 
                $0.isArchived == true 
            }
        )
        
        let expired = try modelContext.fetch(descriptor)
        for entity in expired {
            modelContext.delete(entity)
        }
        
        try modelContext.save()
    }
}
```

### Advanced SwiftUI Patterns

#### Liquid Glass Design Implementation
```swift
struct GlassScheduleView: View {
    @State private var selectedDate = Date()
    @Namespace private var animation
    
    var body: some View {
        GlassEffectContainer {
            VStack {
                // Glass morphing calendar
                GlassCalendar(
                    selectedDate: $selectedDate,
                    glassEffectID: "calendar"
                )
                .glassEffect(in: animation)
                
                // Glass appointment cards
                ScrollView {
                    ForEach(appointments) { appointment in
                        GlassAppointmentCard(
                            appointment: appointment,
                            glassEffectID: "card_\(appointment.id)"
                        )
                        .glassEffect(in: animation)
                    }
                }
            }
        }
        .animation(.smooth, value: selectedDate)
    }
}
```

#### Custom Environment Values
```swift
// Define custom environment keys
private struct VeterinarySettingsKey: EnvironmentKey {
    static let defaultValue = VeterinarySettings()
}

extension EnvironmentValues {
    var veterinarySettings: VeterinarySettings {
        get { self[VeterinarySettingsKey.self] }
        set { self[VeterinarySettingsKey.self] = newValue }
    }
}

// Usage
struct ClinicView: View {
    @Environment(\.veterinarySettings) var settings
    
    var body: some View {
        Text("Clinic: \(settings.clinicName)")
    }
}
```

---

## Resources & References

### Internal Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| **CLAUDE.md** | `/CLAUDE.md` | AI assistant configuration and project context |
| **Architecture Docs** | `/docs/architecture/` | Technical specifications (15 files) |
| **Product Requirements** | `/docs/prd/` | Business requirements and epics |
| **QuickForm Patterns** | `/docs/architecture/quickform-patterns.mdc` | Form implementation guide |
| **Swift Best Practices** | `/docs/architecture/swift-best-practices.md` | Coding standards and patterns |
| **Testing Strategy** | `/docs/architecture/09-testing-strategy.md` | Comprehensive testing approach |
| **Development Rules** | `/.claude/rules.md` | TDD principles and automation |

### Key Source Files to Study

#### Core Architecture Examples
- `App/Sources/VetNetApp.swift` - App configuration and CloudKit setup
- `Infrastructure/Configuration/Container+VetNet.swift` - DI container setup
- `Features/PatientManagement/UI/ViewModels/PatientFormViewModel.swift` - QuickForm example
- `Infrastructure/Repositories/SwiftDataPatientRepository.swift` - Repository pattern

#### Testing Examples
- `App/Tests/Unit/PatientValidatorTests.swift` - Validation testing
- `App/Tests/Integration/PatientRepositoryTests.swift` - Repository testing
- `App/Tests/UI/PatientFormViewTests.swift` - ViewInspector UI testing

### External Resources

#### Apple Documentation
- [Swift 6.2 Language Guide](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Framework](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Swift Testing](https://developer.apple.com/documentation/testing)

#### Third-Party Libraries
- [QuickForm Documentation](https://github.com/Moroverse/quick-form)
- [FactoryKit Guide](https://github.com/hmlongco/Factory)
- [StateKit Documentation](https://github.com/StateKit/StateKit)
- [ViewInspector Guide](https://github.com/nalexn/ViewInspector)
- [Tuist Documentation](https://docs.tuist.io)

#### Learning Resources
- [Test-Driven Development by Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) - Kent Beck
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - Robert C. Martin
- [Domain-Driven Design](https://www.domainlanguage.com/ddd/) - Eric Evans
- [Swift Concurrency](https://www.swift.org/documentation/concurrency/) - Swift.org

### Community and Support

#### Project Resources
- **Issue Tracker**: [GitHub Issues]
- **Pull Request Template**: `.github/pull_request_template.md`
- **Code Review Guidelines**: `docs/code-review.md`

#### Development Team Contacts
- **Technical Lead**: [Contact Information]
- **Project Manager**: [Contact Information]
- **DevOps**: [Contact Information]

---

## Team Onboarding Checklist

### Week 1: Environment Setup
- [ ] Install Xcode 16.2+
- [ ] Clone repository
- [ ] Install mise and project tools
- [ ] Successfully build project with `tuist generate`
- [ ] Run test suite with `tuist test`
- [ ] Review CLAUDE.md and project documentation
- [ ] Set up CloudKit entitlements (optional)
- [ ] Join team Slack/Discord channels

### Week 2: Architecture Understanding
- [ ] Study project structure and modules
- [ ] Understand Clean Architecture layers
- [ ] Review QuickForm patterns document
- [ ] Explore FactoryKit DI setup
- [ ] Study SwiftUIRouting module
- [ ] Run and explore sample data
- [ ] Review existing features (PatientManagement, Settings)

### Week 3: Development Practice
- [ ] Complete a small bug fix using TDD
- [ ] Implement a simple form with QuickForm
- [ ] Write unit tests for a validator
- [ ] Create a mock service for testing
- [ ] Practice using feature flags
- [ ] Submit first pull request
- [ ] Participate in code review

### Week 4: Feature Development
- [ ] Plan a small feature using domain modeling
- [ ] Implement complete feature with tests
- [ ] Integrate with SwiftData repository
- [ ] Add UI with accessibility support
- [ ] Document feature in appropriate location
- [ ] Demo feature to team
- [ ] Address code review feedback

### Ongoing Learning
- [ ] Attend team architecture discussions
- [ ] Contribute to documentation improvements
- [ ] Share learnings with team
- [ ] Explore advanced patterns as needed
- [ ] Stay updated with Swift evolution
- [ ] Participate in retrospectives

---

## Appendices

### Appendix A: Glossary of Terms

| Term | Definition |
|------|------------|
| **DDD** | Domain-Driven Design - Software design approach focusing on business domain |
| **TDD** | Test-Driven Development - Write tests before implementation |
| **MVVM** | Model-View-ViewModel - UI architecture pattern |
| **DI** | Dependency Injection - Technique for achieving Inversion of Control |
| **VTL** | Veterinary Triage Level - Urgency classification system |
| **HIPAA** | Health Insurance Portability and Accountability Act |
| **Repository** | Pattern that encapsulates data access logic |
| **Entity** | SwiftData model representing persisted data |
| **Domain Model** | Business logic representation independent of persistence |
| **View Model** | Presentation logic and state management |
| **Form Components** | QuickForm data structure for form fields |
| **Feature Flag** | Toggle for enabling/disabling features |
| **Mock** | Test double that simulates real implementation |
| **Spy** | Test double that records interactions |
| **Actor** | Swift concurrency primitive for thread-safe state |

### Appendix B: Quick Reference

#### Common Commands
```bash
# Project Management
tuist generate              # Generate Xcode project
tuist build                 # Build app
tuist test                  # Run tests
tuist clean                # Clean build

# Code Quality
swiftformat .              # Format code
swiftlint                  # Lint code
swiftlint --fix           # Auto-fix issues

# Module Development
cd Modules/SwiftUIRouting
swift build               # Build module
swift test                # Test module

# Git Workflow
git checkout -b feature/name     # Create feature branch
git add .                        # Stage changes
git commit -m "[TYPE] Message"   # Commit with type
git push origin feature/name    # Push branch
```

#### QuickForm Patterns
```swift
// Basic form setup
@QuickForm(ComponentType.self)
class FormViewModel: Validatable {
    @PropertyEditor(keyPath: \ComponentType.field)
    var field = FormFieldViewModel(...)
    
    @PostInit
    private func configure() {
        // Setup validation
    }
}

// Form state handling
enum FormState {
    case idle, editing, saving, saved, error(String)
}

// Validation rules
.combined(.notEmpty, .minLength(2), CustomRule())
```

#### Testing Patterns
```swift
// Swift Testing
@Suite("Feature")
struct FeatureTests {
    @Test("Description")
    func testBehavior() { }
}

// ViewInspector
let view = try sut.inspect()
let button = try view.find(button: "Save")
#expect(try button.isDisabled())

// Memory leak detection
@Test(.teardownTracking())
func testNoLeaks() async {
    await Test.trackForMemoryLeaks(viewModel)
}
```

### Appendix C: Migration Guides

#### Adding a New Feature Module

1. **Create folder structure**:
```
Features/NewFeature/
├── Domain/
│   ├── Models/
│   ├── Protocols/
│   └── Validators/
├── UI/
│   ├── Views/
│   ├── ViewModels/
│   └── Components/
└── Infrastructure/
    └── Services/
```

2. **Register in DI container**:
```swift
extension Container {
    var newFeatureService: Factory<NewFeatureService> {
        self { DefaultNewFeatureService() }.cached
    }
}
```

3. **Add navigation route**:
```swift
enum AppRoute {
    case newFeature(NewFeature.ID)
}
```

4. **Create tests**:
```
Tests/
├── Unit/NewFeature/
├── Integration/NewFeature/
└── UI/NewFeature/
```

#### Updating Dependencies

1. **Update Package.swift** for modules:
```swift
dependencies: [
    .package(url: "...", from: "2.0.0")
]
```

2. **Update Project.swift** for main app:
```swift
packages: [
    .package(url: "...", .upToNextMajor(from: "2.0.0"))
]
```

3. **Regenerate project**:
```bash
tuist generate
```

#### SwiftData Schema Migration

1. **Define new schema version**:
```swift
enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [PatientEntity.self, NewEntity.self]
    }
}
```

2. **Create migration**:
```swift
enum MigrateV1ToV2: SchemaMigrationPlan {
    static func migrate(from context: ModelContext) throws {
        // Migration logic
    }
}
```

3. **Update ModelContainer**:
```swift
let migrationPlan = SchemaMigrationPlan(
    from: SchemaV1.self,
    to: SchemaV2.self,
    stages: [MigrateV1ToV2.self]
)
```

---

> **Last Updated**: January 2025
> 
> **Version**: 1.0.0
> 
> **Maintained By**: VetNet Development Team
> 
> This document is a living guide and will be updated as the project evolves. For the latest information, always refer to the version in the main branch.