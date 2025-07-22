# Swift Best Practices for VetNet

This document outlines Swift-specific best practices and patterns used throughout the VetNet codebase, including dependency injection, formatting, and measurement handling.

## FactoryKit Dependency Injection

VetNet uses FactoryKit for dependency injection, providing clean, testable, and SwiftUI-optimized patterns.

### Core Concepts

**Container-Based Architecture**
```swift
extension Container {
    var triageService: Factory<TriageService> {
        self { DefaultTriageService() }
    }
}
```

### Service Registration Patterns

```swift
extension Container {
    // Cached service - reused within container lifecycle
    var schedulingService: Factory<SchedulingOptimizationService> {
        self { DefaultSchedulingService() }
            .cached
    }
    
    // Singleton - one instance across app
    var vtlService: Factory<VTLService> {
        self { VTLServiceImpl() }
            .singleton
    }
    
    // Repository with dependencies
    var appointmentRepository: Factory<AppointmentRepository> {
        self { SwiftDataAppointmentRepository(modelContext: modelContext()) }
            .cached
    }
}
```

### SwiftUI Integration

**With @Observable ViewModels**
```swift
@Observable
class AppointmentViewModel {
    @ObservationIgnored
    @Injected(\.schedulingService) private var scheduler
    
    @ObservationIgnored
    @Injected(\.appointmentRepository) private var repository
    
    var appointments: [Appointment] = []
    
    func loadAppointments() async {
        appointments = await repository.fetchTodaysAppointments()
    }
}
```

**In SwiftUI Views**
```swift
struct AppointmentListView: View {
    @InjectedObject(\.appointmentViewModel) private var viewModel
    
    var body: some View {
        List(viewModel.appointments) { appointment in
            AppointmentRow(appointment: appointment)
        }
        .task {
            await viewModel.loadAppointments()
        }
    }
}
```

### Testing with FactoryKit

**Test Container Isolation**
```swift
@Suite(.container)
struct SchedulingTests {
    @Test
    func testOptimization() async throws {
        // Register test-specific mock
        Container.shared.schedulingService.register { 
            MockSchedulingService(scenario: .conflictResolution) 
        }
        
        let scheduler = Container.shared.schedulingService()
        let result = await scheduler.optimize(appointments)
        
        #expect(result.conflicts.isEmpty)
    }
}
```

**Preview Support**
```swift
extension Container: AutoRegistering {
    func autoRegister() {
        #if DEBUG
        triageService
            .onPreview { MockTriageService(testData: .preview) }
            .onTest { MockTriageService(testData: .unitTest) }
        #endif
    }
}
```

### Scoping Guidelines

- **`.unique`** (default): New instance each time
- **`.cached`**: Reuse within container lifecycle (recommended for services)
- **`.singleton`**: Global single instance (use sparingly)
- **`.shared`**: Weak reference, released when no strong refs

## FormatStyle Usage

VetNet leverages Swift's modern FormatStyle API for consistent, locale-aware formatting throughout the application.

### Date and Time Formatting

```swift
extension FormatStyle where Self == Date.FormatStyle {
    /// Standard appointment time format (e.g., "9:30 AM")
    static var appointmentTime: Self {
        .dateTime
            .hour(.defaultDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
    
    /// Appointment date header (e.g., "Monday, March 15")
    static var appointmentDate: Self {
        .dateTime
            .weekday(.wide)
            .month(.wide)
            .day()
    }
    
    /// Schedule duration (e.g., "1h 30m")
    static var scheduleDuration: Duration.TimeFormatStyle {
        .units(allowed: [.hours, .minutes], 
               width: .abbreviated,
               maximumUnitCount: 2)
    }
}

// Usage
Text(appointment.scheduledTime.formatted(.appointmentTime))
Text(appointment.duration.formatted(.scheduleDuration))
```

### Veterinary-Specific Formatters

```swift
extension FormatStyle {
    /// Patient weight formatter (e.g., "12.5 kg" or "27.6 lbs")
    struct WeightFormatStyle: FormatStyle {
        let unit: UnitMass
        
        func format(_ value: Measurement<UnitMass>) -> String {
            value.converted(to: unit)
                .formatted(.measurement(width: .abbreviated, 
                                      numberFormatStyle: .number.precision(.fractionLength(1))))
        }
    }
    
    /// Body temperature formatter (e.g., "101.5°F")
    struct TemperatureFormatStyle: FormatStyle {
        let unit: UnitTemperature
        
        func format(_ value: Measurement<UnitTemperature>) -> String {
            value.converted(to: unit)
                .formatted(.measurement(width: .narrow,
                                      numberFormatStyle: .number.precision(.fractionLength(1))))
        }
    }
}

// Extension for convenience
extension Measurement where UnitType == UnitMass {
    func formatted(unit: UnitMass = .kilograms) -> String {
        FormatStyle.WeightFormatStyle(unit: unit).format(self)
    }
}

// Usage
Text(patient.weight.formatted(unit: .kilograms)) // "12.5 kg"
Text(vitals.temperature.formatted()) // "101.5°F"
```

### Currency Formatting

```swift
extension FormatStyle where Self == FloatingPointFormatStyle<Decimal>.Currency {
    /// Standard invoice currency
    static var invoice: Self {
        .currency(code: "USD")
            .precision(.fractionLength(2))
    }
    
    /// Estimate ranges
    static var estimate: Self {
        .currency(code: "USD")
            .precision(.fractionLength(0...2))
    }
}

// Usage
Text(invoice.total.formatted(.invoice)) // "$125.50"
Text(estimate.lowEnd.formatted(.estimate)) // "$100"
```

## Measurement and Unit Patterns

VetNet uses Swift's Measurement API for type-safe, unit-aware calculations throughout the veterinary domain.

### Core Veterinary Measurements

```swift
// Patient measurements
struct PatientVitals {
    let weight: Measurement<UnitMass>
    let temperature: Measurement<UnitTemperature>
    let heartRate: Measurement<UnitFrequency>
    let respiratoryRate: Measurement<UnitFrequency>
    
    // Type-safe calculations
    var bmi: Double {
        // Calculate BMI with proper unit conversions
        let weightInKg = weight.converted(to: .kilograms).value
        let heightInM = height.converted(to: .meters).value
        return weightInKg / (heightInM * heightInM)
    }
}

// Medication dosing
struct MedicationDose {
    let amount: Measurement<UnitVolume>
    let concentration: Measurement<UnitConcentrationMass>
    
    func dose(for weight: Measurement<UnitMass>) -> Measurement<UnitVolume> {
        // Type-safe dosage calculation
        let weightInKg = weight.converted(to: .kilograms)
        let mgPerKg = 0.5 // Example dosage rate
        let totalMg = weightInKg.value * mgPerKg
        
        return Measurement(value: totalMg / concentration.value, 
                         unit: .milliliters)
    }
}
```

### Custom Veterinary Units

```swift
// Define custom dimensions for veterinary-specific measurements
extension Dimension {
    /// Breaths per minute
    static let breathsPerMinute = UnitFrequency(symbol: "bpm", 
                                               converter: UnitConverterLinear(coefficient: 1.0/60.0))
    
    /// Beats per minute (heart rate)
    static let beatsPerMinute = UnitFrequency(symbol: "bpm", 
                                            converter: UnitConverterLinear(coefficient: 1.0/60.0))
}

// Custom unit for veterinary scoring
class UnitBodyConditionScore: Dimension {
    static let score = UnitBodyConditionScore(symbol: "BCS", 
                                            converter: UnitConverterLinear(coefficient: 1.0))
    
    override class func baseUnit() -> Self {
        return score as! Self
    }
}
```

### Practical Usage Examples

```swift
// In ViewModels
@Observable
class VitalsViewModel {
    var temperature = Measurement(value: 101.5, unit: UnitTemperature.fahrenheit)
    var weight = Measurement(value: 25.0, unit: UnitMass.pounds)
    
    var temperatureInCelsius: Measurement<UnitTemperature> {
        temperature.converted(to: .celsius)
    }
    
    var isFebrile: Bool {
        temperature.converted(to: .fahrenheit).value > 102.5
    }
}

// In SwiftUI Views
struct VitalsView: View {
    @Bindable var vitals: VitalsViewModel
    @AppStorage("preferredWeightUnit") var weightUnit = UnitMass.kilograms
    
    var body: some View {
        Form {
            LabeledContent("Weight") {
                Text(vitals.weight.converted(to: weightUnit).formatted())
            }
            
            LabeledContent("Temperature") {
                Text(vitals.temperature.formatted())
                    .foregroundStyle(vitals.isFebrile ? .red : .primary)
            }
        }
    }
}
```

### Unit Conversion Helpers

```swift
extension Measurement where UnitType: Dimension {
    /// Convert between common veterinary units with validation
    func safelyConverted(to unit: UnitType) -> Measurement<UnitType>? {
        guard self.value.isFinite && self.value > 0 else { return nil }
        return self.converted(to: unit)
    }
}

// Usage with validation
if let weightInKg = patientWeight.safelyConverted(to: .kilograms) {
    calculateDosage(for: weightInKg)
}
```

## Integration Guidelines

### Combining Patterns

```swift
@Observable
class MedicationCalculatorViewModel {
    @ObservationIgnored
    @Injected(\.medicationService) private var service
    
    var patientWeight = Measurement(value: 0, unit: UnitMass.kilograms)
    var dosageRate = Measurement(value: 0, unit: UnitMass.milligrams)
    
    var calculatedDose: String {
        let dose = service.calculateDose(weight: patientWeight, rate: dosageRate)
        return dose.formatted(.measurement(width: .abbreviated))
    }
}
```

### Best Practices Summary

1. **Dependency Injection**
   - Use `.cached` scope for services
   - Prefer protocol-based factories
   - Always use `.container` trait in tests

2. **FormatStyle**
   - Create semantic format styles for domain concepts
   - Leverage built-in styles before creating custom ones
   - Always consider localization

3. **Measurements**
   - Use Measurement<T> for all physical quantities
   - Define custom units for domain-specific concepts
   - Perform calculations with proper unit conversions
   - Validate measurements before calculations

4. **Testing**
   - Mock services with FactoryTesting
   - Test format output with multiple locales
   - Verify unit conversions in critical calculations

## Advanced Testing Utilities

VetNet leverages TestKit and StateKit for comprehensive testing capabilities beyond basic mocking.

### TestKit Memory Leak Detection

Ensure proper memory management and prevent retain cycles:

```swift
@Test("No memory leaks in ViewModel", .teardownTracking())
func testViewModelMemoryManagement() async throws {
    let viewModel = AppointmentViewModel()
    await Test.trackForMemoryLeaks(viewModel)
    
    // Perform operations
    await viewModel.loadAppointments()
    
    // Test fails if viewModel is not deallocated after test completion
}
```

### AsyncSpy for Async Operation Testing

Control and verify async operations with precise timing:

```swift
// Define service conformance
extension AsyncSpy: SchedulingService where Result == [Appointment] {
    func fetchAppointments(for date: Date) async throws -> [Appointment] {
        try await perform(date)
    }
}

// In tests
@Test
func testLoadingStateTransitions() async throws {
    let spy = AsyncSpy<[Appointment]>()
    let viewModel = AppointmentViewModel(service: spy)
    
    try await spy.async {
        await viewModel.loadTodaysAppointments()
    } expectationBeforeCompletion: {
        #expect(viewModel.isLoading == true)
        #expect(viewModel.appointments.isEmpty)
    } completeWith: {
        .success([Appointment.mock1, Appointment.mock2])
    } expectationAfterCompletion: { _ in
        #expect(viewModel.isLoading == false)
        #expect(viewModel.appointments.count == 2)
    }
}
```

### StateKit MockService for Previews and Demos

Create rich, configurable mock services for SwiftUI previews and demos:

```swift
// Define service protocols
protocol PatientServiceProtocol: PatientLoader, PatientCreator {}

protocol PatientLoader: Sendable {
    func fetchPatients(query: PatientQuery) async throws -> Paginated<Patient>
}

protocol PatientCreator: Sendable {
    func createPatient(_ patient: Patient) async throws -> Patient
}

// MockService implementation
#if DEBUG
extension MockService: PatientLoader where T == Paginated<Patient> {
    func fetchPatients(query: PatientQuery) async throws -> Paginated<Patient> {
        try await perform()
    }
    
    static func mock() -> Self {
        Self(result: .success(MockService.patients(with: Container.shared.dateProvider())))
    }
    
    static func error() -> Self {
        Self(result: .failure(URLError(.badServerResponse)))
    }
    
    static func slow() -> Self {
        Self(result: .success(MockService.patients(with: Container.shared.dateProvider())), 
             delay: .seconds(3))
    }
    
    static func empty() -> Self {
        Self(result: .success(Paginated(items: [])))
    }
    
    // Rich test data generation
    static func patients(with dateProvider: DateProvider) -> Paginated<Patient> {
        let calendar = dateProvider.calendar
        let now = dateProvider.now()
        
        return Paginated(items: [
            Patient(
                name: "Bella",
                species: .dog,
                birthDate: calendar.date(byAdding: .year, value: -3, to: now)!,
                weight: Measurement(value: 25.5, unit: .kilograms)
            ),
            Patient(
                name: "Luna",
                species: .cat,
                birthDate: calendar.date(byAdding: .year, value: -2, to: now)!,
                weight: Measurement(value: 4.1, unit: .kilograms)
            )
            // ... more test data
        ])
    }
}

// Preview usage
struct PatientListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PatientListView()
                .environment(\.patientService, MockService<Paginated<Patient>>.mock())
                .previewDisplayName("Success")
            
            PatientListView()
                .environment(\.patientService, MockService<Paginated<Patient>>.slow())
                .previewDisplayName("Loading")
            
            PatientListView()
                .environment(\.patientService, MockService<Paginated<Patient>>.error())
                .previewDisplayName("Error")
        }
    }
}
#endif
```

### Combining Testing Utilities

Comprehensive test example using multiple utilities:

```swift
@Suite("Appointment Scheduling", .container, .teardownTracking())
struct AppointmentSchedulingTests {
    @Test("Schedule optimization with no conflicts")
    func testConflictFreeScheduling() async throws {
        // Setup mocks with FactoryKit
        Container.shared.schedulingService.register { 
            MockService<ScheduleOptimizationResult>.mock() 
        }
        
        // Track memory leaks
        let viewModel = SchedulingViewModel()
        await Test.trackForMemoryLeaks(viewModel)
        
        // Test async operation with spy
        let spy = AsyncSpy<ScheduleOptimizationResult>()
        
        try await spy.async(yieldCount: 2) {
            await viewModel.optimizeSchedule()
        } expectationBeforeCompletion: {
            #expect(viewModel.state == .optimizing)
        } completeWith: {
            .success(ScheduleOptimizationResult(conflicts: []))
        } expectationAfterCompletion: { result in
            #expect(viewModel.state == .optimized)
            #expect(viewModel.conflicts.isEmpty)
        }
    }
}
```

### TestKit Additional Utilities

**Sequential UUID Generation** for deterministic tests:
```swift
@Test(.sequentialUUIDGeneration())
func testAppointmentCreation() async throws {
    await UUID.reset()
    
    let appointment1 = Appointment()
    let appointment2 = Appointment()
    
    #expect(appointment1.id.uuidString == "00000000-0000-0000-0000-000000000000")
    #expect(appointment2.id.uuidString == "00000000-0000-0000-0000-000000000001")
}
```

**Expectation Tracking** for fluent async testing:
```swift
await Test.expect { try await service.fetchPatients() }
    .toCompleteWith { .success(testPatients) }
    .when { await spy.completeWith(.success(testPatients)) }
    .execute()
```

### Best Practices for Testing

1. **Memory Management**
   - Always use `.teardownTracking()` trait when testing ViewModels
   - Track objects that should be deallocated after test completion
   - Investigate any memory leak failures immediately

2. **Async Testing**
   - Use AsyncSpy for precise control over async operation timing
   - Test loading states, error states, and success states separately
   - Verify state transitions before and after async operations

3. **Mock Services**
   - Create rich mock implementations with StateKit's MockService
   - Provide multiple scenarios (success, error, slow, empty)
   - Use date providers for consistent time-based data
   - Leverage for both tests and SwiftUI previews

4. **Test Organization**
   - Group related tests in @Suite with appropriate traits
   - Use `.container` trait for FactoryKit isolation
   - Combine multiple testing utilities for comprehensive coverage

## Data Validation with QuickForm

VetNet uses QuickForm's ValidationRule pattern for comprehensive, reusable data validation throughout the application.

### Core Validation Concepts

**ValidationRule Protocol**
```swift
import QuickForm

// Custom validation rules conform to ValidationRule
struct MaxDateRule: ValidationRule {
    let dateProvider: DateProvider
    
    init(_ dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }
    
    func validate(_ value: Date) -> ValidationResult {
        if value > dateProvider.now() {
            .failure("Date must be before \(dateProvider.now().formatted())")
        } else {
            .success
        }
    }
}
```

### Domain-Specific Validators

Create centralized validators for domain entities:

```swift
final class PatientValidator: Sendable {
    private let dateProvider: DateProvider
    
    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }
    
    func isValidName(_ name: String) -> Bool {
        nameValidation.validate(name) == .success
    }
    
    func isValidBirthDate(_ birthDate: Date) -> Bool {
        birthdayValidation.validate(birthDate) == .success
    }
    
    func isValidWeight(_ weight: Measurement<UnitMass>, for species: Species) -> Bool {
        weightValidation(for: species).validate(weight) == .success
    }
}
```

### Custom Validation Rules

**Date Range Validation**
```swift
struct MaxDateRangeRule: ValidationRule {
    let dateProvider: DateProvider
    let range: DateComponents
    
    init(maxRange: DateComponents, _ dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
        range = maxRange
    }
    
    func validate(_ value: Date) -> ValidationResult {
        guard let minDate = dateProvider.calendar.date(byAdding: range, to: dateProvider.now()) else {
            return .failure("Invalid date range")
        }
        
        let result = dateProvider.calendar.compare(value, to: minDate, toGranularity: .second)
        switch result {
        case .orderedDescending, .orderedSame:
            return .success
        case .orderedAscending:
            return .failure("Date must be after \(minDate.formatted())")
        }
    }
}
```

**Character Set Validation**
```swift
struct AllowedCharactersRule: ValidationRule {
    let allowedCharacters: CharacterSet
    
    init(_ allowedCharacters: CharacterSet) {
        self.allowedCharacters = allowedCharacters
    }
    
    func validate(_ value: String) -> ValidationResult {
        let filteredText = value.filter { char in
            let unicodeScalars = String(char).unicodeScalars
            return !unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        }
        
        if filteredText.isEmpty {
            return .success
        } else {
            return .failure("Contains invalid characters: \(filteredText)")
        }
    }
}
```

**Species-Specific Weight Validation**
```swift
struct SpeciesMaxWeightRangeRule: ValidationRule {
    let species: Species
    
    init(_ species: Species) {
        self.species = species
    }
    
    func validate(_ value: Measurement<UnitMass>) -> ValidationResult {
        let weightInKg = value.converted(to: .kilograms).value
        
        switch species {
        case .dog:
            if weightInKg >= 0.5, weightInKg <= 100 {
                return .success
            } else {
                return .failure("Dogs must weigh between 0.5kg and 100kg")
            }
            
        case .cat:
            if weightInKg >= 0.5, weightInKg <= 15 {
                return .success
            } else {
                return .failure("Cats must weigh between 0.5kg and 15kg")
            }
            
        case .bird:
            if weightInKg >= 0.01, weightInKg <= 20 {
                return .success
            } else {
                return .failure("Birds must weigh between 0.01kg and 20kg")
            }
            
        case .other:
            if weightInKg >= 0.01, weightInKg <= 1000 {
                return .success
            } else {
                return .failure("Weight must be between 0.01kg and 1000kg")
            }
        }
    }
}
```

### Composing Validation Rules

Combine multiple rules for comprehensive validation:

```swift
extension PatientValidator {
    var nameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(50),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-")))
        )
    }
    
    var birthdayValidation: AnyValidationRule<Date> {
        .combined(
            MaxDateRule(dateProvider),
            MaxDateRangeRule(maxRange: .init(year: -30), dateProvider)
        )
    }
    
    func weightValidation(for species: Species) -> AnyValidationRule<Measurement<UnitMass>> {
        .of(SpeciesMaxWeightRangeRule(species))
    }
}
```

### Integration with SwiftUI Forms

**In ViewModels**
```swift
@Observable
class PatientFormViewModel {
    @ObservationIgnored
    @Injected(\.patientValidator) private var validator
    
    var name = ""
    var birthDate = Date()
    var weight = Measurement(value: 0, unit: UnitMass.kilograms)
    var species: Species = .dog
    
    var nameError: String? {
        guard !name.isEmpty else { return nil }
        if case .failure(let message) = validator.nameValidation.validate(name) {
            return message
        }
        return nil
    }
    
    var isValid: Bool {
        validator.isValidName(name) &&
        validator.isValidBirthDate(birthDate) &&
        validator.isValidWeight(weight, for: species)
    }
}
```

**In SwiftUI Views**
```swift
struct PatientFormView: View {
    @Bindable var viewModel: PatientFormViewModel
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                    .overlay(alignment: .bottomTrailing) {
                        if let error = viewModel.nameError {
                            Label(error, systemImage: "exclamationmark.circle")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                
                DatePicker("Birth Date", 
                          selection: $viewModel.birthDate,
                          in: viewModel.validator.birthDateRange,
                          displayedComponents: .date)
                
                LabeledContent("Weight") {
                    MeasurementField(value: $viewModel.weight, 
                                   unit: .kilograms,
                                   validation: viewModel.validator.weightValidation(for: viewModel.species))
                }
            }
            
            Section {
                Button("Save Patient") {
                    savePatient()
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}
```

### Utility Extensions

**Helper Properties for UI**
```swift
extension PatientValidator {
    var birthDateRange: ClosedRange<Date> {
        let now = dateProvider.now()
        let thirtyYearsAgo = dateProvider.calendar.date(byAdding: .year, value: -30, to: now) ?? now
        return thirtyYearsAgo ... now
    }
    
    func weightRange(for species: Species) -> ClosedRange<Double> {
        switch species {
        case .dog: 0.5...100
        case .cat: 0.5...15
        case .bird: 0.01...20
        case .other: 0.01...1000
        }
    }
}
```

### Testing Validation Rules

```swift
@Suite("Patient Validation")
struct PatientValidationTests {
    let dateProvider = MockDateProvider(date: Date(timeIntervalSince1970: 1_700_000_000))
    
    @Test("Valid patient name")
    func testValidName() {
        let validator = PatientValidator(dateProvider: dateProvider)
        
        #expect(validator.isValidName("Bella"))
        #expect(validator.isValidName("Max Junior"))
        #expect(validator.isValidName("Luna-Mae"))
    }
    
    @Test("Invalid patient names")
    func testInvalidNames() {
        let validator = PatientValidator(dateProvider: dateProvider)
        
        #expect(!validator.isValidName("")) // Empty
        #expect(!validator.isValidName("A")) // Too short
        #expect(!validator.isValidName("Bella123")) // Numbers
        #expect(!validator.isValidName(String(repeating: "A", count: 51))) // Too long
    }
    
    @Test("Species weight validation")
    func testSpeciesWeightRanges() {
        let validator = PatientValidator(dateProvider: dateProvider)
        
        // Dog weights
        #expect(validator.isValidWeight(.init(value: 25, unit: .kilograms), for: .dog))
        #expect(!validator.isValidWeight(.init(value: 0.3, unit: .kilograms), for: .dog))
        #expect(!validator.isValidWeight(.init(value: 150, unit: .kilograms), for: .dog))
        
        // Cat weights
        #expect(validator.isValidWeight(.init(value: 4.5, unit: .kilograms), for: .cat))
        #expect(!validator.isValidWeight(.init(value: 20, unit: .kilograms), for: .cat))
    }
}
```

### Best Practices for Data Validation

1. **Centralized Validation Logic**
   - Create domain-specific validator classes
   - Inject validators via FactoryKit
   - Reuse validation rules across the application

2. **Composable Rules**
   - Build complex validations from simple rules
   - Use `.combined()` for multiple conditions
   - Create custom rules for domain-specific logic

3. **User-Friendly Error Messages**
   - Provide clear, actionable error messages
   - Localize error messages for international users
   - Show errors contextually in the UI

4. **Performance Considerations**
   - Cache validation results when appropriate
   - Validate on-demand rather than continuously
   - Use debouncing for real-time validation

5. **Testing Strategy**
   - Test edge cases for each validation rule
   - Use mock date providers for time-based validations
   - Verify error messages are appropriate

This approach ensures type safety, testability, and maintainability throughout the VetNet codebase while leveraging Swift's modern APIs effectively.