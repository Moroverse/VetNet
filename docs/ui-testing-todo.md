# UI Testing Development Todo List - Story 1.1 Patient Creation

**Last Updated:** 2025-08-06  
**Status:** In Progress  
**Approach:** Incremental development of VetNetUITestKit library alongside test implementation

## Overview

This document tracks the incremental development of automated end-to-end UI tests for Story 1.1 Patient Creation & Profile Management. The strategy is to build the VetNetUITestKit library iteratively while implementing specific tests, allowing us to discover and solve real-world testing challenges.

---

## Phase 1: Foundation & First Test 🚀

### 1.1 Setup UI Test Target
- [x] Add `VetNetUITests` target to `Project.swift` with XCTest dependencies
- [x] Configure proper app launch and reset infrastructure
- [ ] Set up basic test runner configuration

### 1.2 Basic Library Foundation + Happy Path Test
- [ ] Create `VetNetUITestCase` base class with basic app launch/reset
- [ ] Create `VetNetScreen` base class with simple element finding
- [ ] **Implement Test**: Complete patient creation happy path
  - [ ] Launch app
  - [ ] Navigate to patient creation form
  - [ ] Fill all required fields (name, species, breed, birth date, owner info)
  - [ ] Tap save button
  - [ ] Verify patient created successfully
- [ ] **Library Improvements Discovered**: Document element finding strategies, wait patterns, navigation helpers

---

## Phase 2: Form Validation 📝

### 2.1 Validation Error Test + Library Enhancements
- [ ] **Implement Test**: Name field validation
  - [ ] Test empty name field → show validation error
  - [ ] Test name too short → show validation error
  - [ ] Test name too long → show validation error
- [ ] **Library Improvements**: Custom assertions for validation errors, better error message detection

### 2.2 Date Validation Test + Enhanced Waits
- [ ] **Implement Test**: Birth date validation
  - [ ] Test future date selection → show validation error
  - [ ] Test valid past date → no error
- [ ] **Library Improvements**: Date picker interaction helpers, calendar navigation support

### 2.3 Species-Breed Dependency Test + Dynamic UI Handling
- [ ] **Implement Test**: Species selection triggers breed list update
  - [ ] Select dog → verify dog breeds appear
  - [ ] Select cat → verify cat breeds appear
  - [ ] Select exotic → verify exotic breeds appear
- [ ] **Library Improvements**: Dynamic content waiting, dropdown/picker interaction helpers

---

## Phase 3: Complex Interactions & Error Handling ⚙️

### 3.1 Medical ID Generation Test + Button Interactions
- [ ] **Implement Test**: Generate Medical ID button functionality
  - [ ] Tap generate button → verify ID populated
  - [ ] Verify ID format follows expected pattern
  - [ ] Test multiple generations produce unique IDs
- [ ] **Library Improvements**: Button state detection, generated content verification helpers

### 3.2 Edit Mode Test + Data Population Verification
- [ ] **Implement Test**: Load existing patient and verify fields populated
  - [ ] Navigate to edit existing patient
  - [ ] Verify all fields populated with correct data
  - [ ] Modify fields and save successfully
- [ ] **Library Improvements**: Field value verification helpers, pre-populated form handling

### 3.3 Save Button State Test + Form State Management
- [ ] **Implement Test**: Save button enabled/disabled based on form completion
  - [ ] Empty form → save button disabled
  - [ ] Fill required fields → save button enabled
  - [ ] Clear required field → save button disabled again
- [ ] **Library Improvements**: Button state waiting, form completion detection patterns

---

## Phase 4: Error Recovery & Network Scenarios 🔄

### 4.1 Network Error Recovery Test + Alert Handling
- [ ] **Implement Test**: Simulate network failure and retry
  - [ ] Attempt save with network disabled → show error dialog
  - [ ] Tap retry button → successful save
  - [ ] Test cancel behavior → return to form with data preserved
- [ ] **Library Improvements**: Alert interaction helpers, network simulation, retry logic testing

### 4.2 Duplicate Patient Error Test + Error Dialog Management
- [ ] **Implement Test**: Handle duplicate patient creation
  - [ ] Create patient with existing name → show duplicate error
  - [ ] Modify name and retry → successful creation
- [ ] **Library Improvements**: Error-specific dialog handling, error recovery flow patterns

---

## Phase 5: Advanced Interactions & Accessibility ♿

### 5.1 Form Navigation Test + Keyboard/Focus Management
- [ ] **Implement Test**: Tab through form fields
  - [ ] Verify proper focus order through all fields
  - [ ] Test return key navigation between fields
  - [ ] Verify save button accessible via keyboard
- [ ] **Library Improvements**: Focus detection helpers, keyboard navigation support

### 5.2 VoiceOver Navigation Test + Accessibility Support
- [ ] **Implement Test**: Complete patient creation using VoiceOver
  - [ ] Navigate form using VoiceOver gestures
  - [ ] Verify all elements have proper accessibility labels
  - [ ] Complete full patient creation workflow
- [ ] **Library Improvements**: VoiceOver interaction patterns, accessibility verification helpers

### 5.3 Dynamic Type Test + UI Scaling Verification
- [ ] **Implement Test**: Verify form functionality with different text sizes
  - [ ] Change to largest text size → verify form still functional
  - [ ] Change to smallest text size → verify all elements visible
  - [ ] Test form completion at different scales
- [ ] **Library Improvements**: Dynamic Type testing helpers, UI scaling verification

---

## Phase 6: Performance & Edge Cases 🚀

### 6.1 Large Dataset Performance Test + List Handling
- [ ] **Implement Test**: Performance with large breed lists
  - [ ] Test species with many breeds (e.g., dog breeds)
  - [ ] Measure picker interaction performance
  - [ ] Verify smooth scrolling and selection
- [ ] **Library Improvements**: Performance measurement helpers, large list interaction patterns

### 6.2 Background/Foreground Test + App Lifecycle
- [ ] **Implement Test**: App lifecycle during form completion
  - [ ] Start filling form → background app → foreground
  - [ ] Verify form state preserved
  - [ ] Complete form submission successfully
- [ ] **Library Improvements**: App lifecycle testing support, state persistence verification

---

## Library Components (Built Incrementally)

### Core Classes
- [ ] `VetNetUITestCase` - Base test class with app lifecycle management
- [ ] `VetNetScreen` - Screen object base with element finding and interactions
- [ ] `VetNetAssertions` - Custom assertions with smart waiting
- [ ] `VetNetElements` - Robust element location with multiple strategies

### Specialized Helpers (Added as needed)
- [ ] `FormInteractionHelper` - Form-specific interactions (fields, validation)
- [ ] `NavigationHelper` - App navigation and routing verification
- [ ] `AlertHelper` - Dialog and alert interaction patterns
- [ ] `AccessibilityHelper` - VoiceOver and accessibility testing support
- [ ] `DataHelper` - Test data creation and cleanup
- [ ] `NetworkStubHelper` - Network condition simulation

---

## Success Criteria for Each Phase

- [ ] **Phase 1**: Basic happy path test passes consistently (3+ runs)
- [ ] **Phase 2**: All validation scenarios covered with stable tests
- [ ] **Phase 3**: Complex interactions work reliably
- [ ] **Phase 4**: Error scenarios properly handled and recoverable
- [ ] **Phase 5**: Accessibility features fully tested and verified
- [ ] **Phase 6**: Performance and edge cases covered

## Overall Success Metrics
- ✅ All tests pass consistently (3+ consecutive runs without flakes)
- ✅ Library components are reusable across tests
- ✅ Test execution time stays under 30 seconds per test
- ✅ Clear, readable test code using screen object pattern
- ✅ Comprehensive coverage of critical user flows

---

## Notes & Discoveries

### Phase 1 Learnings
*To be filled as we progress*

### Phase 2 Learnings  
*To be filled as we progress*

### Phase 3 Learnings
*To be filled as we progress*

### Phase 4 Learnings
*To be filled as we progress*

### Phase 5 Learnings
*To be filled as we progress*

### Phase 6 Learnings
*To be filled as we progress*

---

## Quick Reference

### Current Focus
**Phase:** 1 - Foundation & First Test  
**Next Task:** Set up UI Test target in Project.swift

### Key Files to Create
- `Project.swift` - Add VetNetUITests target
- `App/Tests/UITests/VetNetUITestCase.swift` - Base test class
- `App/Tests/UITests/VetNetScreen.swift` - Screen object base
- `App/Tests/UITests/PatientCreationTests.swift` - Patient creation test suite
- `App/Tests/UITests/Helpers/` - Testing helper classes

### Testing Strategy
1. **Start simple** - Get basic happy path working first
2. **Build incrementally** - Each test improves the library
3. **Focus on stability** - Non-flaky tests are the priority
4. **Document learnings** - Capture insights for future development