# Epic 2: Basic Specialist Management

**Epic Goal**: Enable complete specialist profile management and availability tracking, providing the foundation for manual appointment assignment and future intelligent matching.

## Epic Overview

This epic builds upon the patient management foundation to introduce specialist profiles and availability management. By implementing comprehensive specialist management, we:
- Enable basic appointment assignment capabilities
- Establish expertise categorization system
- Create availability tracking patterns
- Build scheduling foundation
- Prepare for intelligent matching features

## Success Criteria

- Practice managers can track specialist capacity and assignments
- Complete specialist profile management (CRUD operations)
- Real-time availability tracking across devices
- Expertise categorization and search
- Manual specialist-patient assignment
- Foundation for intelligent matching algorithms

## User Stories

### Story 2.1: Specialist Profile Creation & Management

**Feature Flag**: `specialist_profiles_v1`

**As a** veterinary practice manager,  
**I want to** create and manage detailed specialist profiles,  
**So that** I can track our team's expertise and assign cases appropriately.

#### Acceptance Criteria

1. **UI Layer**
   - Specialist creation form with:
     - Personal information:
       - Full name (required)
       - Title/credentials (required)
       - License number (required)
       - Contact information (email, phone)
       - Professional photo upload
     - Professional details:
       - Years of experience
       - Education history
       - Certifications
       - Languages spoken
     - Expertise areas:
       - Primary specializations
       - Secondary skills
       - Procedure competencies
       - Species preferences
   - Profile management features:
     - Create new profiles
     - Edit existing profiles
     - Deactivate/reactivate
     - Profile duplication
     - Bulk import capability

2. **Business Layer**
   - Specialist domain model:
     - Validation rules:
       - License number format
       - Email validation
       - Phone number formatting
     - Expertise categorization:
       - Predefined specialties
       - Custom categories
       - Proficiency levels (1-5)
       - Certification tracking
   - Business logic:
     - Duplicate detection
     - License verification
     - Credential expiration tracking
     - Expertise matching algorithms

3. **Data Layer**
   - SwiftData Specialist entity:
     - CloudKit synchronization
     - Relationships:
       - Appointments (one-to-many)
       - Availability (one-to-many)
       - Expertise (many-to-many)
     - Indexed fields:
       - Name
       - Specializations
       - License number
   - Data integrity:
     - Unique constraints
     - Referential integrity
     - Cascade rules

4. **Feature Integration**
   - Specialty categories:
     - Surgery (Orthopedic, Soft Tissue, Neurological)
     - Internal Medicine (Cardiology, Oncology, Endocrinology)
     - Dermatology
     - Emergency & Critical Care
     - Dentistry
     - Ophthalmology
     - Behavioral Medicine
     - Exotic Animal Medicine
   - Experience levels:
     - Resident (0-2 years)
     - Associate (2-5 years)
     - Senior (5-10 years)
     - Expert (10+ years)
     - Board Certified

5. **Mock Services**
   - In-memory specialist service:
     - CRUD operations
     - Search by expertise
     - Availability checking
     - Performance simulation
   - Service protocols:
     - SpecialistService
     - ExpertiseService
     - AvailabilityService

6. **Sample Data**
   - Pre-populated specialists:
     - **Dr. Sarah Chen**: Orthopedic Surgery, Board Certified, 12 years
     - **Dr. Michael Rodriguez**: Internal Medicine, Cardiology focus, 8 years
     - **Dr. Lisa Park**: Dermatology, Allergy specialist, 6 years
     - **Dr. James Wilson**: Emergency Medicine, Critical Care, 15 years
     - **Dr. Emily Thompson**: Exotic Animals, Avian specialist, 5 years
     - **Dr. Robert Martinez**: Dentistry, Oral Surgery, 10 years
     - **Dr. Jennifer Lee**: Oncology, Chemotherapy certified, 7 years
     - **Dr. David Brown**: Neurology, MRI interpretation, 9 years
   - Varied expertise combinations
   - Different availability patterns
   - Certification statuses

7. **Testing**
   - Unit tests:
     - Profile validation
     - Expertise categorization
     - Business rule enforcement
   - Integration tests:
     - Profile persistence
     - CloudKit sync
     - Relationship integrity
   - UI tests:
     - Profile creation flow
     - Expertise selection
     - Photo upload

8. **Feature Flag**
   - `specialist_profiles_v1` controls:
     - Profile management access
     - Advanced features
     - Mock/real data toggle
     - Gradual rollout

**Definition of Done**: Practice managers can create, view, edit, and organize specialist profiles with realistic sample veterinary team data

### Story 2.2: Specialist Availability & Schedule Management

**Feature Flag**: `specialist_scheduling_v1`

**As a** veterinary practice staff member,  
**I want to** view and manage specialist availability,  
**So that** I can make informed scheduling decisions based on current capacity.

#### Acceptance Criteria

1. **UI Layer**
   - Availability calendar view:
     - Week/day/month views
     - Working hours display
     - Break time indicators
     - Time off blocks
     - Appointment slots
   - Schedule management:
     - Drag-to-adjust hours
     - Recurring patterns
     - Exception handling
     - Bulk updates
     - Template application
   - Visual indicators:
     - Availability status colors
     - Capacity percentages
     - Conflict warnings
     - Override options

2. **Business Layer**
   - Availability calculation:
     - Working hours rules
     - Break time enforcement
     - Capacity algorithms
     - Conflict detection
   - Schedule patterns:
     - Daily templates
     - Weekly patterns
     - Monthly variations
     - Holiday handling
   - Business rules:
     - Minimum break times
     - Maximum hours/day
     - On-call rotations
     - Emergency availability

3. **Data Layer**
   - Availability data model:
     - Recurring schedules
     - Exception dates
     - Time slot granularity
     - Capacity tracking
   - Optimization:
     - Efficient queries
     - Cache management
     - Incremental updates
   - Relationships:
     - Specialist linkage
     - Appointment blocking
     - Override tracking

4. **Real-time Updates**
   - Cross-device sync:
     - < 5 second propagation
     - Conflict resolution
     - Offline queuing
   - Push notifications:
     - Schedule changes
     - Availability updates
     - Conflict alerts
   - Live collaboration:
     - Multi-user editing
     - Change attribution
     - Activity indicators

5. **Testing**
   - Concurrency tests:
     - Simultaneous updates
     - Conflict scenarios
     - Race conditions
   - UI tests:
     - Calendar interactions
     - Drag operations
     - Template application
   - Performance tests:
     - Large date ranges
     - Multiple specialists
     - Complex patterns

6. **Feature Flag**
   - `specialist_scheduling_v1` enables:
     - Availability management
     - Advanced scheduling
     - Real-time sync
     - Template features

**Definition of Done**: Staff can view real-time specialist availability and manage scheduling constraints

### Story 2.3: Basic Specialist Assignment

**Feature Flag**: `manual_assignment_v1`

**As a** veterinary practice staff member,  
**I want to** manually assign specialists to patient cases,  
**So that** I can ensure appropriate care provider matching while the intelligent system is being developed.

#### Acceptance Criteria

1. **UI Layer**
   - Specialist selection interface:
     - Available specialists list
     - Expertise badges
     - Availability indicators
     - Quick filters
     - Search functionality
   - Assignment workflow:
     - Patient context display
     - Specialist recommendations
     - Assignment confirmation
     - Notes/reasoning field
   - Visual feedback:
     - Success confirmations
     - Conflict warnings
     - Assignment history
     - Undo capability

2. **Business Layer**
   - Manual assignment logic:
     - Validation rules
     - Conflict detection
     - Expertise matching
     - Availability checking
   - Assignment tracking:
     - History recording
     - Reason capture
     - Performance metrics
     - Pattern analysis
   - Business rules:
     - Double-booking prevention
     - Expertise requirements
     - Emergency overrides
     - Approval workflows

3. **Data Layer**
   - Assignment tracking:
     - Audit trail creation
     - Relationship management
     - History preservation
   - Query optimization:
     - Assignment lookups
     - History retrieval
     - Pattern analysis
   - Data integrity:
     - Referential constraints
     - Cascade rules
     - Archive policies

4. **Integration**
   - Patient record connection:
     - Medical history access
     - Previous assignments
     - Preference tracking
   - Specialist workload:
     - Current assignments
     - Capacity metrics
     - Balance indicators
   - Reporting data:
     - Assignment patterns
     - Success metrics
     - Utilization tracking

5. **Testing**
   - Assignment workflow tests:
     - Happy path scenarios
     - Conflict handling
     - Edge cases
   - Data consistency tests:
     - Relationship integrity
     - History accuracy
     - Audit completeness
   - Integration tests:
     - Patient linkage
     - Specialist updates
     - Cross-entity queries

6. **Feature Flag**
   - `manual_assignment_v1` controls:
     - Assignment capability
     - Advanced features
     - Audit trail access
     - Override permissions

**Definition of Done**: Staff can manually assign specialists to patients with full conflict detection and tracking

## Technical Implementation Notes

### Data Models
```swift
@Model
class Specialist {
    @Attribute(.unique) var licenseNumber: String
    var name: String
    var title: String
    var credentials: [String]
    var yearsExperience: Int
    
    @Relationship(deleteRule: .cascade)
    var expertiseAreas: [Expertise]
    
    @Relationship(deleteRule: .cascade)
    var availability: [AvailabilitySlot]
    
    @Relationship(deleteRule: .nullify)
    var appointments: [Appointment]
}

@Model
class Expertise {
    var category: SpecialtyCategory
    var name: String
    var proficiencyLevel: Int // 1-5
    var certificationDate: Date?
    var expirationDate: Date?
}

@Model
class AvailabilitySlot {
    var date: Date
    var startTime: Date
    var endTime: Date
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var capacity: Int
}
```

### Service Protocols
```swift
@Mockable
protocol SpecialistService {
    func create(_ specialist: Specialist) async throws -> Specialist
    func update(_ specialist: Specialist) async throws -> Specialist
    func findByExpertise(_ expertise: String) async throws -> [Specialist]
    func checkAvailability(for specialist: Specialist, on date: Date) async throws -> [AvailabilitySlot]
}

@Mockable
protocol AssignmentService {
    func assign(patient: Patient, to specialist: Specialist, reason: String?) async throws -> Assignment
    func findAssignments(for patient: Patient) async throws -> [Assignment]
    func findAssignments(for specialist: Specialist) async throws -> [Assignment]
}
```

## Dependencies

- Depends on Epic 1 (Patient Management) for patient entities
- Foundation for Epic 3 (Appointment Scheduling)
- Enables future intelligent matching features

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Complex availability patterns | High | Start with simple daily patterns |
| Multi-timezone support | Medium | Initial single timezone, plan for expansion |
| Performance with many specialists | Medium | Implement pagination and caching |

## Related Documents

- [Epic 1: Patient Management](epic-1-patient-management.md)
- [Epic 3: Appointment Scheduling](epic-3-appointment-scheduling.md)
- [Development Approach](development-approach.md)