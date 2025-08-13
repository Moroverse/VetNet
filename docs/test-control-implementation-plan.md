# TestControl Implementation Plan

## Overview
The TestControl system is a sophisticated testing infrastructure that allows UI tests and manual testing to control service behaviors through launch arguments and test scenarios. The core architecture is complete but needs integration with existing services and UI tests.

## Current Status

### ✅ Completed Components
- **Core Infrastructure**
  - `TestControlPlane.swift` - Central control plane for managing test behaviors
  - `TestControllable.swift` - Protocol for controllable services
  - `BehaviorTrait.swift` - Universal behavior traits (success, failure, delayed, etc.)
  - `ServiceIdentifier.swift` - Service identification system
  - `TestError.swift` - Test-specific error types
  - `TestScenario.swift` - Predefined test scenarios
  - `LaunchArgumentParser.swift` - Parse launch arguments for test configuration
  - `TestControlInitializer.swift` - Initialize test control during app startup

- **Partial Implementations**
  - `ControllableUUIDProvider` - UUID provider with test control support
  - `VetNetApp.swift` - TestControl initialization in app startup
  - Basic UI test infrastructure (`VetNetUITestCase`, `VetNetScreen`)

### 🚧 Missing/Incomplete Components
- Service registration with TestControlPlane
- TestControllable implementation on mock repositories
- Date provider with test control support
- Debug settings UI for manual control

## Implementation Tasks

### ✅ Phase 1: Core Service Integration (COMPLETED)
**Goal**: Connect existing services to TestControl system

#### ✅ Task 1.1: Create ControllableDateProvider
- [x] Found existing `DateProvider.swift` in domain models
- [x] Added `ControllableDateProvider` with TestControllable protocol
- [x] Implemented behaviors: system, fixed date, incrementing, business hours only
- [x] Added test helpers for fixed and incrementing date providers

#### ✅ Task 1.2: MockPatientRepository TestControllable
- [x] Confirmed `MockPatientRepository` already implements `TestControllable`
- [x] Comprehensive behavior handling already in place:
  - Success/failure modes ✅
  - Delayed responses ✅
  - Empty datasets ✅
  - Large datasets ✅
  - Validation errors ✅
- [x] Sequential behaviors already supported for complex test scenarios

#### ✅ Task 1.3: Register Services with TestControlPlane
- [x] Updated `Container+VetNet.swift` to register controllable services
- [x] Services now registered on creation:
  - UUID Provider ✅ (was already implemented)
  - Date Provider ✅ (newly added)
  - Patient Repository ✅ (was already implemented for UI tests)
- [x] Proper service identifiers used (.uuidProvider, .dateProvider, .patientRepository, .patientCRUDRepository)

### ✅ Phase 2: UI Test Integration (COMPLETED)
**Goal**: Ensure TestControl scenarios work with UI tests

#### ✅ Task 2.1: Fix Accessibility Identifiers  
- [x] Update `PatientFormView.swift` with correct accessibility identifiers:
  - `patient_creation_name_field` ✅ (already implemented)
  - `patient_creation_species_picker` ✅ (already implemented)
  - `patient_creation_breed_picker` ✅ (already implemented)
  - `patient_creation_weight_field` ✅ (already implemented)
  - `patient_creation_owner_name_field` ✅ (already implemented)
  - `patient_creation_owner_phone_field` ✅ (already implemented)
  - `patient_creation_save_button` ✅ (already implemented)
- [x] Add patient row identifiers in list view (verified existing implementation)

#### ✅ Task 2.2: Verify Test Scenario Activation
- [x] Ensure test scenarios activate properly from launch arguments
- [x] Verify sequential UUID generation works
- [x] Confirm repository behaviors apply correctly  
- [x] Test error scenario activation

### Phase 3: Advanced Test Scenarios (Priority: Medium)
**Goal**: Implement complex test behaviors and scenarios

#### Task 3.1: Implement Repository Behaviors
- [ ] Create behavior handlers for:
  - Network errors (connection timeout, server unreachable)
  - Validation errors (duplicate key, invalid data)
  - Slow responses (configurable delay)
  - Intermittent failures (success rate based)
  - Empty/large datasets

#### Task 3.2: Create Additional Test Scenarios
- [ ] Patient search scenarios
- [ ] Concurrent operation scenarios
- [ ] Data migration scenarios
- [ ] CloudKit sync failure scenarios

### Phase 4: Debug UI Integration (Priority: Low)
**Goal**: Add TestControl management to debug settings

#### Task 4.1: Enhance DebugSettingsView
- [ ] Add TestControl section showing:
  - Active scenario (if any)
  - Registered services and their behaviors
  - Manual scenario activation/deactivation
- [ ] Create scenario picker UI
- [ ] Add behavior customization controls

#### Task 4.2: Add Visual Indicators
- [ ] Show TestControl status in app (debug builds only)
- [ ] Add overlay showing active behaviors
- [ ] Include reset all behaviors button

### Phase 5: Documentation & Polish (Priority: Low)
**Goal**: Complete documentation and clean up code

#### Task 5.1: Documentation
- [ ] Complete inline documentation for all TestControl components
- [ ] Add usage examples in test files
- [ ] Create TestControl usage guide
- [ ] Document launch argument formats

#### Task 5.2: Code Cleanup
- [ ] Remove TODO/FIXME comments after resolution
- [ ] Ensure consistent error handling
- [ ] Add comprehensive logging
- [ ] Optimize performance for large datasets

## Implementation Order

1. **Phase 1** - Core Service Integration ✅ (30 minutes) - COMPLETED
   - Essential for any testing to work
   - Unblocks advanced test scenarios

2. **Phase 2** - UI Test Integration ✅ (30 minutes) - COMPLETED
   - Ensures TestControl works with UI tests
   - Validates scenario activation

3. **Phase 3** - Advanced Scenarios (45 minutes)
   - Enhances test coverage
   - Enables complex testing scenarios

4. **Phase 4** - Debug UI (30 minutes)
   - Nice to have for manual testing
   - Useful during development

5. **Phase 5** - Documentation (15 minutes)
   - Important for maintainability
   - Can be done incrementally

## Testing Strategy

### Manual Testing
1. Launch app with test arguments: `-TEST_SCENARIO happy_path`
2. Verify UUID generation is sequential
3. Test patient creation with predictable IDs
4. Verify behaviors apply correctly

### UI Test Validation
1. Run validation tests - should show proper error messages
2. Run `testValidationError` - should trigger duplicate key error
3. Verify test scenarios activate correctly
4. All tests should use configured behaviors

### Debug Testing
1. Use shake gesture to open debug settings
2. Manually activate different scenarios
3. Verify service behaviors change dynamically
4. Test scenario deactivation and reset

## Success Criteria

- [ ] TestControl scenarios activate from launch arguments
- [ ] Services respond according to configured behaviors
- [ ] UI tests can control service behaviors
- [ ] Debug UI allows manual scenario control
- [ ] No memory leaks or performance issues
- [ ] Documentation is complete and accurate

## Example Usage

### Launch Arguments
```bash
# Happy path with sequential UUIDs
-TEST_SCENARIO happy_path

# Network errors
-TEST_SCENARIO network_errors

# Custom behaviors
-UUID_BEHAVIOR sequential:100
-REPOSITORY_BEHAVIOR slow
```

### In UI Tests
```swift
let app = makeApp(testScenario: "validation_errors")
// Test will get duplicate key errors from repository
```

### Manual Activation
```swift
testControlInitializer.activateScenario(.Predefined.largeDataset)
```

## Time Estimate

- **Phase 1**: ✅ 30 minutes (COMPLETED)
- **Phase 2**: ✅ 30 minutes (COMPLETED)  
- **Phase 3**: 45 minutes
- **Phase 4**: 30 minutes
- **Phase 5**: 15 minutes

**Total**: ~2.5 hours
**Completed**: 60 minutes
**Remaining**: ~1.5 hours

## Next Steps

1. ✅ Fix patient creation bug (COMPLETED - see patient-creation-bug.md)
2. ✅ Complete Phase 1 implementation (COMPLETED)
3. ✅ Complete Phase 2: UI Test Integration (COMPLETED)
4. Start Phase 3: Advanced Test Scenarios (repository behaviors)
5. Continue with remaining phases as needed
6. Update this document with any discoveries or changes

## Status Summary

### ✅ COMPLETED WORK
- **Patient Creation Bug**: Fixed ListModel cache refresh issue
- **TestControl Phase 1**: Core service integration completed
  - ControllableDateProvider implemented and registered
  - MockPatientRepository already had TestControllable support
  - All services properly registered with TestControlPlane
  - UUID Provider, Date Provider, and Patient Repository all controllable
- **TestControl Phase 2**: UI Test Integration completed
  - All required accessibility identifiers verified in PatientFormView.swift
  - Test scenario activation working correctly with launch arguments
  - Sequential UUID generation confirmed working
  - Repository behaviors applying correctly in UI tests
  - Error scenario activation validated (validation_errors scenario working)

### 🚧 CURRENT STATUS
- All 91 unit tests passing ✅
- TestControl Phase 1 & 2 completed ✅ 
- TestControl infrastructure ready for Phase 3
- Project builds successfully ✅
- UI Test infrastructure validated with test scenarios ✅

### 📋 REMAINING WORK
- Phase 3: Advanced Test Scenarios (additional repository behaviors)
- Phase 4: Debug UI Integration (manual TestControl management)
- Phase 5: Documentation & Polish