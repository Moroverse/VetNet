# Epic 3: Simple Appointment Scheduling

**Epic Goal**: Deliver basic appointment creation and calendar management functionality, enabling staff to schedule appointments manually with conflict detection and basic optimization.

## Epic Overview

This epic builds upon patient and specialist management to deliver core scheduling functionality. By implementing comprehensive appointment scheduling, we:
- Enable immediate scheduling value for practices
- Establish calendar and time management patterns
- Create conflict detection mechanisms
- Build the foundation for intelligent scheduling
- Deliver a complete manual scheduling workflow

## Success Criteria

- Staff can schedule and manage appointments with conflict detection
- Full appointment lifecycle management (create, edit, reschedule, cancel)
- Real-time calendar synchronization across devices
- Basic duration estimation and resource allocation
- Professional calendar interface with multiple views
- Foundation for advanced scheduling optimization

## User Stories

### Story 3.1: Appointment Creation & Basic Scheduling

**Feature Flag**: `appointment_creation_v1`

**As a** veterinary practice staff member,  
**I want to** create appointments for patients with specialists,  
**So that** I can manage the basic scheduling workflow and book patient visits.

#### Acceptance Criteria

1. **UI Layer**
   - Appointment creation form:
     - Patient selection:
       - Search/select existing patient
       - Quick patient creation option
       - Recent patients list
       - Patient details preview
     - Specialist assignment:
       - Available specialists list
       - Expertise match indicators
       - Availability preview
       - Preferred specialist tracking
     - Scheduling details:
       - Date picker with availability
       - Time slot selection
       - Duration estimation
       - Appointment type selection
     - Additional information:
       - Reason for visit
       - Urgency level
       - Special requirements
       - Pre-appointment instructions
   - Form features:
     - Smart defaults
     - Validation feedback
     - Conflict warnings
     - Save as draft option

2. **Business Layer**
   - Appointment domain model:
     - Core properties:
       - Unique appointment ID
       - Patient reference
       - Specialist reference
       - Date and time
       - Duration
       - Status tracking
     - Validation rules:
       - Future date requirement
       - Business hours check
       - Duration limits
       - Double-booking prevention
   - Scheduling logic:
     - Availability checking
     - Conflict detection
     - Duration estimation
     - Buffer time calculation
   - Business rules:
     - Appointment types
     - Minimum notice periods
     - Cancellation policies
     - Emergency overrides

3. **Data Layer**
   - SwiftData Appointment entity:
     - Relationships:
       - Patient (many-to-one)
       - Specialist (many-to-one)
       - Location (many-to-one)
       - Notes (one-to-many)
     - CloudKit synchronization
     - Compound uniqueness:
       - Specialist + DateTime
       - Location + DateTime
   - Indexing strategy:
     - Date-based queries
     - Specialist lookups
     - Patient history
     - Status filtering

4. **Conflict Detection**
   - Real-time validation:
     - Specialist availability
     - Room/resource conflicts
     - Equipment scheduling
     - Patient double-booking
   - Conflict types:
     - Hard conflicts (impossible)
     - Soft conflicts (not recommended)
     - Warnings (consider alternatives)
   - Resolution options:
     - Alternative time slots
     - Different specialists
     - Waitlist placement
     - Override with reason

5. **Mock Services**
   - In-memory appointment service:
     - CRUD operations
     - Availability checking
     - Conflict simulation
     - Duration calculation
   - Service protocols:
     - AppointmentService
     - SchedulingService
     - ConflictService

6. **Sample Data**
   - Pre-populated appointments:
     - Routine checkups (30 min)
     - Surgical consultations (45 min)
     - Emergency slots (variable)
     - Follow-up visits (20 min)
     - Specialty procedures (60-120 min)
   - Typical daily schedules:
     - Morning surgery blocks
     - Afternoon appointments
     - Emergency buffers
     - Lunch breaks
   - Various appointment states:
     - Scheduled
     - Confirmed
     - In-progress
     - Completed
     - Cancelled

7. **Testing**
   - Unit tests:
     - Appointment validation
     - Conflict detection logic
     - Duration calculations
   - Integration tests:
     - Creation workflow
     - Persistence verification
     - Sync simulation
   - UI tests:
     - Form completion
     - Conflict handling
     - Success scenarios

8. **Feature Flag**
   - `appointment_creation_v1` controls:
     - Creation capability
     - Advanced features
     - Mock data usage
     - Rollout percentage

**Definition of Done**: Staff can create appointments using realistic sample data showing typical veterinary practice scheduling patterns

### Story 3.2: Calendar Views & Appointment Management

**Feature Flag**: `calendar_interface_v1`

**As a** veterinary practice staff member,  
**I want to** view appointments in calendar format and manage scheduling conflicts,  
**So that** I can visualize our practice schedule and make informed scheduling decisions.

#### Acceptance Criteria

1. **UI Layer**
   - Calendar interface:
     - View modes:
       - Day view (hourly slots)
       - Week view (5/7 day options)
       - Month view (overview)
       - Agenda view (list format)
     - Visual elements:
       - Appointment blocks
       - Specialist lanes
       - Time grid
       - Current time indicator
     - Interactive features:
       - Tap to view details
       - Long-press for options
       - Drag to reschedule
       - Pinch to zoom
   - Liquid Glass effects:
     - Translucent overlays
     - Depth perception
     - Smooth transitions
     - Focus indicators
   - Navigation:
     - Date picker
     - Quick jump to today
     - Swipe between periods
     - Specialist filtering

2. **Business Layer**
   - Calendar data processing:
     - Efficient data loading
     - View-specific queries
     - Appointment grouping
     - Overlap detection
   - Filtering logic:
     - By specialist
     - By appointment type
     - By status
     - By location
   - Display optimization:
     - Appointment positioning
     - Overlap handling
     - Color coding
     - Priority ordering

3. **Data Layer**
   - Optimized queries:
     - Date range filtering
     - Eager loading
     - Batch fetching
     - Result caching
   - Performance indexing:
     - Date-based indexes
     - Composite indexes
     - Query optimization
   - Memory management:
     - Lazy loading
     - View recycling
     - Cache limits

4. **Real-time Updates**
   - Live synchronization:
     - New appointments appear
     - Changes reflected
     - Cancellations shown
     - Status updates
   - Update mechanisms:
     - Push notifications
     - WebSocket connections
     - Polling fallback
     - Conflict resolution
   - Visual feedback:
     - Loading indicators
     - Sync status
     - Error states
     - Success confirmations

5. **Testing**
   - UI tests:
     - View mode switching
     - Navigation flows
     - Interaction gestures
   - Performance tests:
     - Large dataset handling
     - Scroll performance
     - Memory usage
   - Integration tests:
     - Real-time updates
     - Data consistency
     - Sync reliability

6. **Feature Flag**
   - `calendar_interface_v1` controls:
     - Calendar availability
     - View mode options
     - Advanced features
     - Performance optimizations

**Definition of Done**: Staff can view and navigate appointment schedules with real-time updates across all devices

### Story 3.3: Appointment Editing & Cancellation

**Feature Flag**: `appointment_management_v1`

**As a** veterinary practice staff member,  
**I want to** reschedule, modify, or cancel appointments as needed,  
**So that** I can handle schedule changes and maintain accurate appointment information.

#### Acceptance Criteria

1. **UI Layer**
   - Appointment edit interface:
     - Quick actions menu:
       - Reschedule
       - Change duration
       - Update specialist
       - Add notes
     - Rescheduling flow:
       - Available slots display
       - Drag-and-drop option
       - Conflict checking
       - Confirmation dialog
     - Cancellation process:
       - Reason selection
       - Required reasons list
       - Optional notes
       - Confirmation step
   - Visual feedback:
     - Change indicators
     - Success messages
     - Error handling
     - Undo options

2. **Business Layer**
   - Rescheduling logic:
     - Availability validation
     - Conflict prevention
     - Notification triggers
     - Waitlist checking
   - Modification rules:
     - Allowed changes
     - Time restrictions
     - Permission levels
     - Audit requirements
   - Cancellation workflow:
     - Reason categorization
     - Policy enforcement
     - Refund calculations
     - Follow-up scheduling

3. **Data Layer**
   - Update operations:
     - Atomic transactions
     - History preservation
     - Rollback capability
   - Audit trail:
     - Change tracking
     - User attribution
     - Timestamp recording
     - Reason storage
   - Data integrity:
     - Constraint validation
     - Cascade updates
     - Archive policies

4. **Notification System**
   - Automatic alerts:
     - Patient notifications
     - Specialist updates
     - Staff reminders
     - Waitlist alerts
   - Notification types:
     - In-app messages
     - Push notifications
     - Email summaries
     - SMS options
   - Delivery rules:
     - Timing logic
     - Preference respect
     - Batch processing
     - Failure handling

5. **Testing**
   - Workflow tests:
     - Edit scenarios
     - Reschedule paths
     - Cancellation flows
   - Data consistency:
     - History accuracy
     - Audit completeness
     - Sync verification
   - Edge cases:
     - Same-day changes
     - Past appointments
     - Recurring appointments

6. **Feature Flag**
   - `appointment_management_v1` enables:
     - Editing capabilities
     - Cancellation features
     - Advanced options
     - Notification system

**Definition of Done**: Staff can reschedule, modify, and cancel appointments with full change tracking and notifications

## Technical Implementation Notes

### Data Models
```swift
@Model
class Appointment {
    @Attribute(.unique) var appointmentID: UUID
    var scheduledDate: Date
    var startTime: Date
    var duration: TimeInterval
    var type: AppointmentType
    var status: AppointmentStatus
    
    @Relationship(deleteRule: .nullify)
    var patient: Patient
    
    @Relationship(deleteRule: .nullify)
    var specialist: Specialist
    
    @Relationship(deleteRule: .nullify)
    var location: Location?
    
    var reason: String
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
}

enum AppointmentType: String, Codable {
    case routine = "Routine Checkup"
    case emergency = "Emergency"
    case surgery = "Surgery"
    case followUp = "Follow-up"
    case consultation = "Consultation"
    case procedure = "Procedure"
}

enum AppointmentStatus: String, Codable {
    case scheduled
    case confirmed
    case inProgress
    case completed
    case cancelled
    case noShow
}
```

### Service Protocols
```swift
@Mockable
protocol AppointmentService {
    func create(_ appointment: Appointment) async throws -> Appointment
    func update(_ appointment: Appointment) async throws -> Appointment
    func cancel(_ appointment: Appointment, reason: String) async throws
    func reschedule(_ appointment: Appointment, to newDate: Date) async throws -> Appointment
    func findConflicts(for appointment: Appointment) async throws -> [Conflict]
}

@Mockable
protocol CalendarService {
    func fetchAppointments(for dateRange: DateInterval) async throws -> [Appointment]
    func fetchAppointments(for specialist: Specialist, in dateRange: DateInterval) async throws -> [Appointment]
    func findAvailableSlots(for specialist: Specialist, on date: Date) async throws -> [TimeSlot]
}
```

### Conflict Detection
```swift
struct Conflict {
    enum ConflictType {
        case specialistUnavailable
        case locationOccupied
        case patientDoubleBooked
        case resourceUnavailable
        case outsideBusinessHours
    }
    
    let type: ConflictType
    let severity: Severity
    let conflictingAppointment: Appointment?
    let message: String
    let resolutionOptions: [ResolutionOption]
}
```

## Dependencies

- Depends on Epic 1 (Patient Management) for patient entities
- Depends on Epic 2 (Specialist Management) for specialist entities and availability
- Foundation for Epic 4 (Intelligent Triage) appointment recommendations

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Complex calendar UI performance | High | Implement virtual scrolling and caching |
| Timezone handling complexity | Medium | Start with single timezone support |
| Concurrent edit conflicts | High | Implement optimistic locking and merge strategies |
| Large appointment volume | Medium | Use pagination and lazy loading |

## Related Documents

- [Epic 2: Specialist Management](epic-2-specialist-management.md)
- [Epic 4: Intelligent Triage](epic-4-intelligent-triage.md)
- [UI/UX Design Goals](ui-ux-design.md)