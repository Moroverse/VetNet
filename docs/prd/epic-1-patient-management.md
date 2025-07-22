# Epic 1: Patient Management Foundation

**Epic Goal**: Deliver complete patient management functionality as the foundational building block, enabling practice staff to manage their patient database with full CRUD operations and cloud synchronization.

## Epic Overview

This epic establishes the core data foundation for the entire application. By implementing comprehensive patient management first, we:
- Validate the technical architecture
- Establish data synchronization patterns
- Create reusable UI components
- Build testing infrastructure
- Deliver immediate value to users

## Success Criteria

- Practice staff can manage complete patient database
- Full CRUD operations available (Create, Read, Update, Delete)
- Real-time synchronization across devices
- Robust search and filtering capabilities
- Professional data validation and error handling
- Comprehensive audit trail for compliance

## User Stories

### Story 1.1: Patient Creation & Profile Management

**Feature Flag**: `patient_management_v1`

**As a** veterinary practice staff member,  
**I want to** create and manage patient profiles with essential information,  
**So that** I can maintain accurate patient records for scheduling and medical care.

#### Acceptance Criteria

1. **UI Layer**
   - Patient creation form with fields:
     - Name (required)
     - Species (required, dropdown)
     - Breed (required, filtered by species)
     - Date of birth (required, date picker)
     - Weight (optional, with units)
     - Owner information (required)
     - Medical ID (auto-generated)
     - Microchip number (optional)
     - Notes (optional, multiline)
   - Form validation with inline errors
   - Save/Cancel actions
   - Loading states during save
   - Success confirmation

2. **Business Layer**
   - Patient domain model with:
     - Validation rules for all fields
     - Age calculation from birth date
     - Species-specific breed validation
     - Medical ID generation algorithm
     - Data transformation for persistence
   - Business rules enforcement:
     - Future birth dates not allowed
     - Weight within species ranges
     - Owner relationship validation

3. **Data Layer**
   - SwiftData Patient entity with:
     - CloudKit synchronization
     - Compound uniqueness constraints
     - Automatic timestamps
     - Soft delete support
   - Relationships:
     - Owner (many-to-one)
     - Appointments (one-to-many)
     - Medical records (one-to-many)

4. **Infrastructure**
   - Complete iOS project setup:
     - Swift 6.2+ configuration
     - Factory DI container setup
     - SwiftUIRouting integration
     - Liquid Glass design system
   - Development environment:
     - Tuist configuration
     - Git repository setup
     - CI/CD pipeline foundation

5. **Mock Services**
   - In-memory patient service with:
     - CRUD operations
     - Search functionality
     - Validation logic
     - Error simulation
   - Service protocol definition
   - Mockable integration

6. **Sample Data**
   - Pre-populated database with 20+ patients:
     - Dogs: Labrador (Max, Bella), German Shepherd (Rex, Luna), Golden Retriever (Charlie, Daisy)
     - Cats: Persian (Whiskers, Mittens), Maine Coon (Oliver, Sophie), Siamese (Leo, Cleo)
     - Exotic: Rabbit (Bunny), Parrot (Polly), Bearded Dragon (Spike), Guinea Pig (Patches)
   - Varied owner demographics
   - Realistic medical histories
   - Different age ranges

7. **Testing**
   - Unit tests:
     - Patient validation logic
     - Age calculation accuracy
     - Medical ID uniqueness
   - Integration tests:
     - Data persistence verification
     - CloudKit sync simulation
   - UI tests:
     - Form completion flow
     - Validation error display
     - Success path verification

8. **Feature Flag**
   - `patient_management_v1` controls:
     - Feature visibility
     - Mock vs. real data toggle
     - Progressive rollout
     - A/B testing capability

**Definition of Done**: Staff can create new patient records, view patient details, and interact with realistic sample data immediately upon app launch

### Story 1.2: Patient Listing & Search

**Feature Flag**: `patient_search_v1`

**As a** veterinary practice staff member,  
**I want to** quickly find and view patient information,  
**So that** I can access patient records during consultations and scheduling.

#### Acceptance Criteria

1. **UI Layer**
   - Patient list view with:
     - Searchable list interface
     - Search bar with real-time results
     - Filter options (species, breed, active/inactive)
     - Sort options (name, last visit, age)
     - Pull-to-refresh functionality
   - List item display:
     - Patient photo placeholder
     - Name and species
     - Owner name
     - Age
     - Last visit date
   - Liquid Glass visual effects:
     - Glass list background
     - Hover effects on iPad
     - Selection animations

2. **Business Layer**
   - Search algorithms:
     - Fuzzy matching for names
     - Owner name search
     - Medical ID lookup
     - Phonetic matching
   - Filtering logic:
     - Multi-criteria filtering
     - Saved filter sets
     - Quick filter presets
   - Sorting implementation:
     - Multiple sort keys
     - Stable sort order
     - Performance optimization

3. **Data Layer**
   - Optimized queries:
     - SwiftData #Index usage
     - Lazy loading
     - Pagination support
     - Cache management
   - Search indexing:
     - Full-text search
     - Denormalized search fields
     - Background indexing

4. **Performance**
   - Search results display:
     - < 500ms for 10,000 patients
     - Incremental loading
     - Smooth scrolling
     - Memory efficiency
   - Optimization techniques:
     - Debounced search
     - Result caching
     - Virtual scrolling

5. **Testing**
   - Performance tests:
     - Large dataset handling
     - Search speed benchmarks
     - Memory usage profiling
   - Accessibility tests:
     - VoiceOver navigation
     - Keyboard navigation
     - Dynamic Type support
   - UI tests:
     - Search workflows
     - Filter combinations
     - Sort verification

6. **Feature Flag**
   - `patient_search_v1` controls:
     - Search functionality
     - Advanced filters
     - Performance features
     - UI enhancements

**Definition of Done**: Staff can search, filter, and quickly locate any patient record in the system

### Story 1.3: Patient Profile Editing & History Tracking

**Feature Flag**: `patient_editing_v1`

**As a** veterinary practice staff member,  
**I want to** update patient information and track changes over time,  
**So that** patient records remain current and I can see the evolution of patient care.

#### Acceptance Criteria

1. **UI Layer**
   - Patient edit form with:
     - Pre-filled current values
     - Field-level validation
     - Change indicators
     - Confirmation dialogs
     - Discard changes option
   - Audit trail display:
     - Change history list
     - User attribution
     - Timestamp display
     - Change details
     - Revert capabilities

2. **Business Layer**
   - Change tracking logic:
     - Field-level changes
     - Before/after values
     - User attribution
     - Timestamp recording
   - Validation rules:
     - Consistency checks
     - Business rule enforcement
     - Conflict detection
   - Update workflows:
     - Optimistic updates
     - Rollback support
     - Batch updates

3. **Data Layer**
   - Update operations:
     - Optimistic locking
     - Version tracking
     - Audit log storage
   - Change history:
     - Immutable audit records
     - Efficient storage
     - Query optimization

4. **Sync Layer**
   - Conflict resolution:
     - Last-write-wins default
     - Manual resolution UI
     - Merge strategies
   - Multi-device coordination:
     - Real-time updates
     - Conflict notifications
     - Sync status display

5. **Testing**
   - Concurrency tests:
     - Simultaneous edits
     - Conflict scenarios
     - Resolution verification
   - Data integrity tests:
     - Change tracking accuracy
     - Audit trail completeness
     - Rollback functionality
   - UI tests:
     - Edit workflows
     - Conflict resolution
     - History navigation

6. **Feature Flag**
   - `patient_editing_v1` enables:
     - Editing capabilities
     - Audit trail access
     - Conflict resolution
     - Advanced features

**Definition of Done**: Staff can edit patient information safely with full change history and conflict resolution

## Technical Implementation Notes

### Data Model
```swift
@Model
class Patient {
    @Attribute(.unique) var medicalID: String
    var name: String
    var species: Species
    var breed: String
    var dateOfBirth: Date
    var weight: Measurement<UnitMass>?
    
    @Relationship(deleteRule: .nullify)
    var owner: Owner?
    
    @Relationship(deleteRule: .cascade)
    var appointments: [Appointment]
    
    var createdAt: Date
    var updatedAt: Date
}
```

### Mock Service Example
```swift
@Mockable
protocol PatientService {
    func create(_ patient: Patient) async throws -> Patient
    func update(_ patient: Patient) async throws -> Patient
    func delete(_ patient: Patient) async throws
    func search(query: String) async throws -> [Patient]
    func fetch(limit: Int, offset: Int) async throws -> [Patient]
}
```

## Dependencies

- No dependencies on other epics
- Foundation for all subsequent features
- Establishes patterns for other entities

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| CloudKit sync complexity | High | Implement offline-first with queue |
| Large dataset performance | Medium | Use pagination and lazy loading |
| Data validation edge cases | Low | Comprehensive test coverage |

## Related Documents

- [Epic 2: Specialist Management](epic-2-specialist-management.md)
- [Development Approach](development-approach.md)
- [Technical Stack](technical-stack.md)