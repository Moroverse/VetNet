# Epic 4: Intelligent Triage Integration

**Epic Goal**: Implement VTL (Veterinary Triage List) protocol-based assessment system with intelligent specialist recommendations, adding clinical intelligence to the scheduling workflow.

## Epic Overview

This epic transforms the scheduling system from basic calendar management to an intelligent, clinically-driven platform. By implementing comprehensive triage integration, we:
- Standardize case assessment with VTL protocols
- Enable evidence-based routing decisions
- Automate specialist recommendations
- Improve medical outcomes through better matching
- Create the foundation for AI-powered optimization

## Success Criteria

- Clinical assessments drive intelligent specialist recommendations
- Standardized VTL protocols implemented with 5-level urgency system
- Multi-factor matching algorithm operational
- Seamless triage-to-appointment workflow
- Measurable improvement in case-specialist matching accuracy
- Foundation for machine learning enhancements

## User Stories

### Story 4.1: VTL Protocol Assessment System

**Feature Flag**: `vtl_triage_v1`

**As a** veterinary practice staff member,  
**I want** standardized triage protocols built into the system,  
**So that** I can consistently assess case urgency and make evidence-based routing decisions.

#### Acceptance Criteria

1. **UI Layer**
   - VTL assessment interface:
     - Urgency level selection:
       - Red: Life-threatening emergency
       - Orange: Urgent condition
       - Yellow: Moderate urgency
       - Green: Non-urgent routine
       - Blue: Elective procedure
     - Guided assessment flow:
       - Species-specific pathways
       - Progressive questionnaire
       - Visual urgency indicators
       - Real-time scoring display
     - ABCDE assessment integration:
       - Airway status
       - Breathing evaluation
       - Circulation check
       - Disability assessment
       - Environment factors
   - Assessment features:
     - Save partial assessments
     - Quick templates
     - Voice input support
     - Photo attachment
     - Previous assessment history

2. **Business Layer**
   - VTL protocol logic:
     - Scoring algorithms:
       - Symptom weighting
       - Duration factors
       - Progression indicators
       - Combination effects
     - ABCDE integration:
       - Systematic evaluation
       - Critical findings flags
       - Automatic escalation
       - Override capabilities
   - Clinical rules engine:
     - Species-specific protocols
     - Age adjustments
     - Breed considerations
     - Medical history impact
   - Six Perfusion Parameters:
     - Heart rate assessment
     - Pulse quality
     - Mucous membrane color
     - Capillary refill time
     - Temperature
     - Blood pressure indicators

3. **Data Layer**
   - Triage assessment entity:
     - Assessment details:
       - Urgency level
       - Symptom checklist
       - Vital signs
       - Clinical observations
     - Relationships:
       - Patient linkage
       - Appointment connection
       - Specialist assignment
       - Outcome tracking
   - Audit trail:
     - Assessment history
     - Decision tracking
     - Override documentation
     - Time stamps

4. **Clinical Integration**
   - Protocol library:
     - VTL standard protocols
     - Custom practice protocols
     - Emergency procedures
     - Species guidelines
   - Decision support:
     - Red flag symptoms
     - Automatic alerts
     - Escalation triggers
     - Reference materials
   - Quality assurance:
     - Protocol compliance
     - Assessment accuracy
     - Outcome correlation
     - Continuous improvement

5. **Testing**
   - Clinical validation:
     - Protocol accuracy
     - Urgency classification
     - Edge case handling
   - User workflow tests:
     - Assessment completion
     - Time efficiency
     - Error handling
   - Integration tests:
     - Data persistence
     - Sync verification
     - Audit completeness

6. **Feature Flag**
   - `vtl_triage_v1` enables:
     - Triage functionality
     - Protocol selection
     - Advanced features
     - Training mode

**Definition of Done**: Staff can complete standardized triage assessments with clear urgency level recommendations

### Story 4.2: Case Complexity Analysis & Specialist Recommendations

**Feature Flag**: `intelligent_matching_v1`

**As a** veterinary practice staff member,  
**I want** automated case analysis with specialist recommendations,  
**So that** I can quickly identify the most appropriate care provider for each case.

#### Acceptance Criteria

1. **UI Layer**
   - Case complexity display:
     - Visual complexity score
     - Key factors breakdown
     - Confidence indicators
     - Match explanations
   - Specialist recommendations:
     - Ranked specialist list
     - Match score display (0-100)
     - Expertise alignment
     - Availability status
     - Alternative options
   - Recommendation details:
     - Why this specialist
     - Key qualifications
     - Similar case history
     - Success metrics
   - User controls:
     - Override options
     - Preference settings
     - Feedback mechanism
     - Manual selection

2. **Business Layer**
   - Multi-factor matching algorithm:
     - Expertise scoring:
       - Primary specialty match
       - Secondary skills
       - Certification relevance
       - Experience level
     - Availability weighting:
       - Urgency alignment
       - Schedule openness
       - Wait time impact
       - Alternative slots
     - Historical performance:
       - Similar case outcomes
       - Client satisfaction
       - Treatment success
       - Efficiency metrics
   - Case complexity scoring:
     - Medical factors:
       - Symptom severity
       - Comorbidities
       - Diagnostic needs
       - Treatment complexity
     - Resource requirements:
       - Equipment needs
       - Time estimates
       - Support staff
       - Follow-up intensity

3. **Data Layer**
   - Matching model storage:
     - Algorithm parameters
     - Weight configurations
     - Performance history
     - Learning data
   - Recommendation tracking:
     - Suggested specialists
     - Actual selections
     - Override reasons
     - Outcome correlation
   - Performance metrics:
     - Match accuracy
     - User acceptance
     - Time savings
     - Quality improvements

4. **Algorithm Integration**
   - Machine learning foundation:
     - Feature extraction
     - Model training data
     - Prediction accuracy
     - Continuous learning
   - Scoring mechanisms:
     - Real-time calculation
     - Multi-criteria optimization
     - Confidence scoring
     - Explainable results
   - Performance optimization:
     - Caching strategies
     - Parallel processing
     - Response time < 1s
     - Scalability design

5. **Testing**
   - Algorithm accuracy:
     - Match quality tests
     - Edge case handling
     - Bias detection
   - Performance validation:
     - Response time
     - Concurrent users
     - Large datasets
   - User acceptance:
     - Recommendation quality
     - Override frequency
     - Satisfaction metrics

6. **Feature Flag**
   - `intelligent_matching_v1` controls:
     - Recommendation engine
     - Algorithm versions
     - Learning features
     - Manual fallback

**Definition of Done**: System provides ranked specialist recommendations based on case complexity and availability

### Story 4.3: Triage-Driven Appointment Creation

**Feature Flag**: `triage_scheduling_v1`

**As a** veterinary practice staff member,  
**I want** triage assessments to automatically guide appointment scheduling,  
**So that** I can efficiently route cases from assessment to appropriate specialist appointment.

#### Acceptance Criteria

1. **UI Layer**
   - Integrated workflow:
     - Seamless transition:
       - Complete triage
       - View recommendations
       - Select specialist
       - Book appointment
     - Pre-filled information:
       - Patient details
       - Urgency level
       - Recommended duration
       - Special requirements
     - Smart scheduling:
       - Urgency-based slots
       - Next available
       - Override options
       - Waitlist placement
   - Visual continuity:
     - Context preservation
     - Progress indicators
     - Back navigation
     - Save and resume

2. **Business Layer**
   - Workflow orchestration:
     - State management:
       - Assessment data
       - Recommendations
       - User selections
       - Appointment details
     - Business rules:
       - Urgency priorities
       - Time constraints
       - Policy enforcement
       - Exception handling
   - Scheduling intelligence:
     - Duration estimation:
       - Case complexity
       - Procedure type
       - Historical data
       - Buffer time
     - Slot optimization:
       - Urgency alignment
       - Specialist matching
       - Resource availability
       - Schedule efficiency

3. **Data Layer**
   - Connected entities:
     - Triage linkage:
       - Assessment reference
       - Recommendation history
       - Decision audit
       - Outcome tracking
     - Data persistence:
       - Workflow state
       - Partial progress
       - Recovery points
       - Archive policies
   - Query optimization:
     - Joined queries
     - Eager loading
     - Cache strategies
     - Performance indexes

4. **Workflow Integration**
   - Context preservation:
     - Assessment summary
     - Key findings
     - Recommendations
     - User decisions
   - Handoff mechanisms:
     - Data transfer
     - State management
     - Error recovery
     - Rollback support
   - Notification triggers:
     - Appointment booked
     - Specialist alerted
     - Follow-up reminders
     - Escalation notices

5. **Testing**
   - End-to-end tests:
     - Complete workflows
     - Edge cases
     - Error scenarios
   - Integration validation:
     - Data consistency
     - State preservation
     - Recovery testing
   - Performance tests:
     - Workflow speed
     - Concurrent users
     - Large volumes

6. **Feature Flag**
   - `triage_scheduling_v1` enables:
     - Integrated workflow
     - Auto-scheduling
     - Smart features
     - Manual override

**Definition of Done**: Staff can complete triage assessment and immediately schedule with recommended specialists

## Technical Implementation Notes

### Data Models
```swift
@Model
class TriageAssessment {
    @Attribute(.unique) var assessmentID: UUID
    var timestamp: Date
    var urgencyLevel: VTLUrgencyLevel
    var symptoms: [Symptom]
    var vitalSigns: VitalSigns
    var abcdeAssessment: ABCDEAssessment
    
    @Relationship(deleteRule: .nullify)
    var patient: Patient
    
    @Relationship(deleteRule: .nullify)
    var performedBy: User
    
    @Relationship(deleteRule: .nullify)
    var resultingAppointment: Appointment?
    
    var recommendations: [SpecialistRecommendation]
    var complexityScore: Int
    var notes: String?
}

enum VTLUrgencyLevel: String, Codable {
    case red = "Life-threatening"
    case orange = "Urgent"
    case yellow = "Moderate"
    case green = "Non-urgent"
    case blue = "Elective"
}

struct SpecialistRecommendation: Codable {
    let specialist: Specialist
    let matchScore: Double
    let factors: [MatchFactor]
    let availability: [TimeSlot]
    let reasoning: String
}
```

### Service Protocols
```swift
@Mockable
protocol TriageService {
    func assessUrgency(symptoms: [Symptom], vitals: VitalSigns) async throws -> VTLUrgencyLevel
    func calculateComplexity(assessment: TriageAssessment) async throws -> Int
    func saveAssessment(_ assessment: TriageAssessment) async throws -> TriageAssessment
}

@Mockable
protocol MatchingService {
    func recommendSpecialists(for assessment: TriageAssessment) async throws -> [SpecialistRecommendation]
    func calculateMatchScore(specialist: Specialist, assessment: TriageAssessment) async throws -> Double
    func explainRecommendation(specialist: Specialist, assessment: TriageAssessment) async throws -> String
}

@Mockable
protocol TriageSchedulingService {
    func createAppointmentFromTriage(assessment: TriageAssessment, specialist: Specialist) async throws -> Appointment
    func estimateDuration(for assessment: TriageAssessment) async throws -> TimeInterval
    func findUrgentSlots(for urgency: VTLUrgencyLevel, specialist: Specialist) async throws -> [TimeSlot]
}
```

### Matching Algorithm Components
```swift
struct MatchingAlgorithm {
    struct Weights {
        let expertiseMatch: Double = 0.35
        let availability: Double = 0.25
        let historicalSuccess: Double = 0.20
        let urgencyAlignment: Double = 0.15
        let clientPreference: Double = 0.05
    }
    
    func calculateScore(
        specialist: Specialist,
        assessment: TriageAssessment,
        context: MatchingContext
    ) async throws -> Double {
        // Multi-factor scoring implementation
    }
}
```

## Dependencies

- Depends on Epic 1-3 for patient, specialist, and appointment entities
- Integrates with existing scheduling infrastructure
- Foundation for Epic 5 advanced optimization

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Clinical protocol accuracy | High | Veterinary expert validation and testing |
| Algorithm bias | High | Diverse training data and bias monitoring |
| User trust in recommendations | Medium | Explainable AI and override options |
| Performance with complex cases | Medium | Caching and progressive enhancement |

## Related Documents

- [Epic 3: Appointment Scheduling](epic-3-appointment-scheduling.md)
- [Epic 5: Scheduling Optimization](epic-5-scheduling-optimization.md)
- [Functional Requirements](requirements-functional.md)