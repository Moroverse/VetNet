# Testing Strategy

## iOS 26 Testing Architecture

**Swift Testing Framework Integration**:
```swift
import Testing
import Mockable

@Suite("Veterinary Scheduling Intelligence")
struct SchedulingEngineTests {
    
    @Test("VTL Triage Assessment Accuracy")
    func testVTLTriageAssessment() async throws {
        // Given
        let mockTriageService = MockTriageService()
        let engine = SchedulingEngine(triageService: mockTriageService)
        let symptoms = [Symptom.lameness, Symptom.pain]
        
        // When
        let assessment = await engine.assessCase(symptoms: symptoms)
        
        // Then
        #expect(assessment.vtlLevel == .yellow)
        #expect(assessment.specialistRecommendations.contains(.orthopedic))
    }
    
    @Test("Specialist Matching Algorithm Performance")
    func testSpecialistMatchingPerformance() async throws {
        // Performance testing for complex scheduling scenarios
        let specialists = createTestSpecialists(count: 20)
        let appointments = createTestAppointments(count: 100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = await schedulingEngine.optimizeSchedule(specialists: specialists, appointments: appointments)
        let executionTime = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(executionTime < 1.0) // Must complete within 1 second per PRD requirements
        #expect(result.optimizationScore > 0.8) // High-quality optimization required
    }
}
```

**Mockable Service Testing**:
```swift
@Mockable
protocol TriageService {
    func assessUrgency(symptoms: [Symptom], vitals: VitalSigns) async -> VTLUrgencyLevel
    func calculateComplexity(assessment: TriageAssessment) async -> Float
}

@Mockable
protocol SpecialistMatchingService {
    func findOptimalMatch(assessment: TriageAssessment, specialists: [Specialist]) async -> SpecialistMatchResult
    func balanceWorkload(specialists: [Specialist]) async -> WorkloadOptimization
}
```

**ViewInspector SwiftUI Testing with Accessibility Identifiers**:
```swift
import ViewInspector
import Testing

@Suite("SwiftUI Component Testing")
struct SwiftUIComponentTests {
    
    @Test("Glass Schedule Calendar Component Testing")
    func testGlassScheduleCalendarComponents() throws {
        let calendar = GlassScheduleCalendar()
        
        // Find components using accessibility identifiers - most reliable approach
        let calendarGrid = try calendar.inspect().find(viewWithAccessibilityIdentifier: "schedule_calendar_grid")
        #expect(calendarGrid != nil)
        
        let appointmentList = try calendar.inspect().find(viewWithAccessibilityIdentifier: "appointment_list_view")
        #expect(appointmentList != nil)
        
        // Test glass effect container
        let glassContainer = try calendar.inspect().find(viewWithAccessibilityIdentifier: "glass_schedule_container")
        #expect(glassContainer != nil)
    }
    
    @Test("Specialist Card Interaction Testing")
    func testSpecialistCardInteraction() throws {
        let specialist = Specialist(name: "Dr. Smith", credentials: "DVM")
        let card = GlassSpecialistCard(specialist: specialist)
        
        // Use accessibility identifiers for reliable component finding
        let selectButton = try card.inspect().find(viewWithAccessibilityIdentifier: "specialist_select_button_\(specialist.id)")
        let specialistName = try card.inspect().find(viewWithAccessibilityIdentifier: "specialist_name_label")
        let specialistCredentials = try card.inspect().find(viewWithAccessibilityIdentifier: "specialist_credentials_label")
        
        // Test button tap interaction
        try selectButton.button().tap()
        
        // Verify component content
        #expect(try specialistName.text().string() == "Dr. Smith")
        #expect(try specialistCredentials.text().string() == "DVM")
        
        // Test accessibility properties
        #expect(try selectButton.accessibilityLabel() == "Select Dr. Smith for appointment")
        #expect(try selectButton.accessibilityIdentifier() == "specialist_select_button_\(specialist.id)")
    }
    
    @Test("Triage Form Components and Validation")
    func testTriageFormComponents() throws {
        let triageForm = GlassTriageForm()
        
        // Find form elements using accessibility identifiers
        let urgencyPicker = try triageForm.inspect().find(viewWithAccessibilityIdentifier: "triage_urgency_picker")
        let symptomsTextEditor = try triageForm.inspect().find(viewWithAccessibilityIdentifier: "triage_symptoms_input")
        let submitButton = try triageForm.inspect().find(viewWithAccessibilityIdentifier: "triage_submit_button")
        let cancelButton = try triageForm.inspect().find(viewWithAccessibilityIdentifier: "triage_cancel_button")
        
        // Test form state and interactions
        try urgencyPicker.picker().select(value: VTLUrgencyLevel.yellow)
        try symptomsTextEditor.textEditor().setText("Patient showing signs of lameness")
        
        // Verify submit button becomes enabled after valid input
        #expect(try submitButton.button().isDisabled() == false)
        
        // Test QuickForm integration components
        let quickFormContainer = try triageForm.inspect().find(viewWithAccessibilityIdentifier: "quickform_container")
        #expect(quickFormContainer != nil)
    }
    
    @Test("Navigation Flow Testing with Accessibility")
    func testNavigationWithAccessibilityIds() throws {
        let navigationController = VeterinaryNavigationController()
        let rootView = SchedulingRootView()
            .environmentObject(navigationController)
        
        // Find navigation elements using accessibility identifiers
        let scheduleTab = try rootView.inspect().find(viewWithAccessibilityIdentifier: "tab_schedule")
        let patientsTab = try rootView.inspect().find(viewWithAccessibilityIdentifier: "tab_patients")
        let addAppointmentButton = try rootView.inspect().find(viewWithAccessibilityIdentifier: "add_appointment_button")
        
        // Test tab navigation
        try scheduleTab.button().tap()
        #expect(navigationController.currentTab == .schedule)
        
        // Test appointment creation flow
        try addAppointmentButton.button().tap()
        #expect(navigationController.navigationPath.count == 1)
        
        // Verify accessibility labels for VoiceOver
        #expect(try scheduleTab.accessibilityLabel() == "Schedule appointments")
        #expect(try patientsTab.accessibilityLabel() == "View patient records")
    }
    
    @Test("Accessibility Identifier Consistency")
    func testAccessibilityIdConsistency() throws {
        // Test that all major components have proper accessibility identifiers
        let calendar = GlassScheduleCalendar()
        let specialist = Specialist(name: "Test Vet", credentials: "DVM")
        let specialistCard = GlassSpecialistCard(specialist: specialist)
        
        // Verify required accessibility identifiers exist
        let requiredIds = [
            "schedule_calendar_grid",
            "appointment_list_view", 
            "specialist_select_button_\(specialist.id)",
            "specialist_name_label"
        ]
        
        for identifier in requiredIds {
            let component = try? calendar.inspect().find(viewWithAccessibilityIdentifier: identifier) 
                         ?? specialistCard.inspect().find(viewWithAccessibilityIdentifier: identifier)
            #expect(component != nil, "Missing accessibility identifier: \(identifier)")
        }
    }
}

// Example SwiftUI implementation showing proper accessibility identifier usage
struct GlassSpecialistCard: View {
    let specialist: Specialist
    @State private var isSelected = false
    
    var body: some View {
        VStack {
            Text(specialist.name)
                .accessibilityIdentifier("specialist_name_label")
                .accessibilityLabel("Specialist name: \(specialist.name)")
            
            Text(specialist.credentials)
                .accessibilityIdentifier("specialist_credentials_label")
                .accessibilityLabel("Credentials: \(specialist.credentials)")
            
            Button("Select Specialist") {
                isSelected = true
            }
            .accessibilityIdentifier("specialist_select_button_\(specialist.id)")
            .accessibilityLabel("Select \(specialist.name) for appointment")
        }
        .glassEffect(.thin, in: .rect(cornerRadius: 12))
        .accessibilityIdentifier("specialist_card_\(specialist.id)")
    }
}
```

**Accessibility Testing**:
```swift
@Suite("iOS 26 Accessibility Compliance")
struct AccessibilityTests {
    
    @Test("Liquid Glass VoiceOver Compatibility")
    func testGlassComponentsAccessibility() async throws {
        let glassCalendar = GlassScheduleCalendar()
        
        // Verify VoiceOver navigation works with glass effects
        #expect(glassCalendar.accessibilityLabel != nil)
        #expect(glassCalendar.accessibilityTraits.contains(.allowsDirectInteraction))
    }
    
    @Test("Dynamic Type Support")
    func testDynamicTypeCompatibility() async throws {
        // Ensure text scaling works with Liquid Glass components
        let settings = AccessibilitySettings.preferredContentSizeCategory(.accessibilityLarge)
        // Test implementation
    }
}
```

**Performance Testing Strategy**:
- **Scheduling Algorithm Benchmarks**: Ensure <1 second optimization time per PRD
- **UI Responsiveness**: Validate 40% GPU improvement claims in real usage scenarios
- **Memory Usage**: Confirm 38% memory reduction through comprehensive profiling
- **Real-time Sync**: Test CloudKit synchronization performance under load
