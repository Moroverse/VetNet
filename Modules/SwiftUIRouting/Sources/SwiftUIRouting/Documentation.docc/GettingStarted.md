# Getting Started with SwiftUIRouting

Learn how to build a complete SwiftUI application using SwiftUIRouting's type-safe, bidirectional routing architecture.

## Overview

SwiftUIRouting provides a comprehensive routing solution that solves common navigation challenges in SwiftUI applications. This guide will walk you through building a complete patient management app, demonstrating best practices and architectural patterns.

### Key Concepts

Before diving in, let's understand the core components:

- **Router**: Manages navigation state and form presentations
- **Repository**: Single source of truth for data (recommended pattern)
- **ViewModels**: Business logic layer with injected dependencies
- **Router Views**: SwiftUI views that handle navigation and form presentation

## Building Your First App

Let's build a patient management system step by step.

### Step 1: Create Your Data Model

Start with a simple, identifiable data model:

```swift
import Foundation

struct Patient: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var age: Int
    var medicalRecordNumber: String
    var condition: String
    var lastVisit: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        medicalRecordNumber: String,
        condition: String,
        lastVisit: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.medicalRecordNumber = medicalRecordNumber
        self.condition = condition
        self.lastVisit = lastVisit
    }
}
```

### Step 2: Implement the Repository Pattern

Create a central repository to manage all data operations:

```swift
import Observation
import Foundation

@Observable
class PatientRepository {
    var patients: [Patient] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    init() {
        loadPatients()
    }
    
    func loadPatients() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Load sample data
            self.patients = Patient.sampleData
            self.isLoading = false
        }
    }
    
    func addPatient(_ patient: Patient) {
        patients.append(patient)
    }
    
    func updatePatient(_ patient: Patient) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index] = patient
        }
    }
    
    func deletePatient(_ patient: Patient) {
        patients.removeAll { $0.id == patient.id }
    }
    
    func patient(withId id: UUID) -> Patient? {
        patients.first { $0.id == id }
    }
}
```

### Step 3: Define Routing Types

Create enums for form modes and navigation routes:

```swift
import Foundation
import SwiftUIRouting

enum PatientFormMode: Identifiable, Hashable {
    case create
    case edit(Patient)
    
    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let patient):
            return "edit-\(patient.id.uuidString)"
        }
    }
}

// Use the built-in FormOperationResult for standard CRUD operations
typealias PatientFormResult = FormOperationResult<Patient>

// Define navigation routes
enum PatientRoute: Hashable {
    case patientDetail(Patient)
}
```

### Step 4: Create Your Router

Extend `BaseFormRouter` with your specific routing methods:

```swift
import SwiftUI
import SwiftUIRouting

@Observable
class PatientRouter: BaseFormRouter<PatientFormMode, PatientFormResult> {
    
    func createPatient() async -> PatientFormResult {
        await presentForm(.create)
    }
    
    func editPatient(_ patient: Patient) async -> PatientFormResult {
        await presentForm(.edit(patient))
    }
    
    func navigateToPatientDetail(_ patient: Patient) {
        navigate(to: PatientRoute.patientDetail(patient))
    }
}
```

### Step 5: Build ViewModels with Dependency Injection

Create ViewModels that receive both repository and router as dependencies:

```swift
import SwiftUI
import SwiftUIRouting

@Observable
class PatientListViewModel {
    private let repository: PatientRepository
    private let router: PatientRouter
    
    var searchText: String = ""
    
    var patients: [Patient] {
        repository.patients
    }
    
    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patients
        }
        return patients.filter { patient in
            patient.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(repository: PatientRepository, router: PatientRouter) {
        self.repository = repository
        self.router = router
    }
    
    func addNewPatient() async {
        let result = await router.createPatient()
        
        switch result {
        case .created(let patient):
            repository.addPatient(patient)
        case .cancelled:
            break
        case .error(let error):
            repository.errorMessage = error.localizedDescription
        default:
            break
        }
    }
    
    func navigateToPatient(_ patient: Patient) {
        router.navigateToPatientDetail(patient)
    }
}
```

### Step 6: Create Your Views

Build views that use ViewModels for all business logic:

```swift
struct PatientListView: View {
    @Bindable var viewModel: PatientListViewModel
    
    var body: some View {
        List(viewModel.filteredPatients) { patient in
            PatientRowView(patient: patient)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.navigateToPatient(patient)
                }
        }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("Patients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await viewModel.addNewPatient()
                    }
                } label: {
                    Label("Add Patient", systemImage: "plus")
                }
            }
        }
    }
}
```

### Step 7: Wire Everything Together

Use `FormRouterView` and `NavigationRouterView` to handle routing:

```swift
struct ContentView: View {
    @State private var patientRepository = PatientRepository()
    @State private var patientRouter = PatientRouter()
    @State private var patientListViewModel: PatientListViewModel
    
    init() {
        let repository = PatientRepository()
        let router = PatientRouter()
        self._patientRepository = State(initialValue: repository)
        self._patientRouter = State(initialValue: router)
        self._patientListViewModel = State(initialValue: PatientListViewModel(
            repository: repository,
            router: router
        ))
    }
    
    var body: some View {
        FormRouterView(router: patientRouter) {
            NavigationRouterView(router: patientRouter) {
                PatientListView(viewModel: patientListViewModel)
            } destination: { (route: PatientRoute) in
                switch route {
                case .patientDetail(let patient):
                    PatientDetailView(
                        patient: patient,
                        repository: patientRepository,
                        router: patientRouter
                    )
                }
            }
        } formContent: { mode in
            NavigationStack {
                CreatePatientForm(mode: mode) { result in
                    patientRouter.handleResult(result)
                }
            }
        }
    }
}
```

## Best Practices

### 1. Use Async/Await Exclusively

SwiftUIRouting provides both async/await and callback-based APIs. We recommend using only async/await for cleaner, more maintainable code:

```swift
// ✅ Recommended
func addPatient() async {
    let result = await router.createPatient()
    handleResult(result)
}

// ❌ Avoid callback-based approach
func addPatient() {
    router.createPatient { result in
        handleResult(result)
    }
}
```

### 2. Repository Pattern for Data Management

Always use a central repository for data management:

- **Single Source of Truth**: All data lives in one place
- **Automatic Updates**: Changes propagate automatically to all observers
- **Testability**: Easy to mock for testing
- **Scalability**: Simple to add persistence or networking later

### 3. Dependency Injection for ViewModels

Inject dependencies into ViewModels rather than creating them internally:

```swift
// ✅ Good: Dependencies injected
class PatientListViewModel {
    private let repository: PatientRepository
    private let router: PatientRouter
    
    init(repository: PatientRepository, router: PatientRouter) {
        self.repository = repository
        self.router = router
    }
}

// ❌ Bad: Creating dependencies internally
class PatientListViewModel {
    private let repository = PatientRepository()
    private let router = PatientRouter()
}
```

### 4. Keep Views Simple

Views should only handle presentation logic. All business logic belongs in ViewModels:

```swift
// ✅ Good: View delegates to ViewModel
Button("Add") {
    Task {
        await viewModel.addNewPatient()
    }
}

// ❌ Bad: Business logic in View
Button("Add") {
    Task {
        let result = await router.createPatient()
        if case .created(let patient) = result {
            repository.addPatient(patient)
        }
    }
}
```

### 5. Type-Safe Navigation

Define explicit route types for navigation:

```swift
enum AppRoute: Hashable {
    case patientDetail(Patient)
    case settings
    case about
}
```

## Common Patterns

### Handling Form Results

Use pattern matching to handle different result cases:

```swift
func handleFormResult(_ result: PatientFormResult) async {
    switch result {
    case .created(let patient):
        repository.addPatient(patient)
        showSuccessMessage("Patient created")
        
    case .updated(let patient):
        repository.updatePatient(patient)
        showSuccessMessage("Patient updated")
        
    case .cancelled:
        // User cancelled, no action needed
        break
        
    case .error(let error):
        showErrorAlert(error)
    }
}
```

### Custom Result Types

For complex operations, create custom result types:

```swift
enum ImportResult: RouteResult {
    case imported(count: Int)
    case partialImport(imported: Int, failed: Int)
    case cancelled
    case error(Error)
    
    // Implement RouteResult requirements...
}
```

### Error Handling

Centralize error handling in your repository or ViewModels:

```swift
@Observable
class PatientRepository {
    var errorMessage: String?
    
    func performOperation() async {
        do {
            // Perform operation
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## Testing Strategies

### 1. Mock Dependencies

Create mock versions of your dependencies for testing:

```swift
class MockPatientRepository: PatientRepository {
    override func loadPatients() {
        patients = Patient.testData
    }
}

class MockPatientRouter: PatientRouter {
    var didNavigateToDetail = false
    
    override func navigateToPatientDetail(_ patient: Patient) {
        didNavigateToDetail = true
        super.navigateToPatientDetail(patient)
    }
}
```

### 2. Test ViewModels in Isolation

```swift
func testAddPatient() async {
    let repository = MockPatientRepository()
    let router = MockPatientRouter()
    let viewModel = PatientListViewModel(
        repository: repository,
        router: router
    )
    
    await viewModel.addNewPatient()
    
    XCTAssertEqual(repository.patients.count, 1)
}
```

## Summary

SwiftUIRouting provides a robust foundation for building scalable SwiftUI applications. By following these patterns:

1. Use the repository pattern for data management
2. Inject dependencies into ViewModels
3. Keep views simple and focused on presentation
4. Use async/await for all asynchronous operations
5. Define type-safe routes and results

You'll create maintainable, testable applications with clean separation of concerns and excellent user experience.