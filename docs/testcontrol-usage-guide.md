# TestControl Usage Guide

## Overview

TestControl is VetNet's sophisticated testing infrastructure that allows UI tests and manual testing to control service behaviors through launch arguments and test scenarios. This guide provides comprehensive documentation on using the TestControl system.

## Architecture

### Core Components

- **TestControlPlane**: Central control plane for managing test behaviors
- **TestControllable**: Protocol for services that can be controlled during testing
- **BehaviorTrait**: Universal behavior traits (success, failure, delayed, etc.)
- **ServiceIdentifier**: Service identification system
- **TestScenario**: Predefined test scenarios with specific service behaviors
- **LaunchArgumentParser**: Parse launch arguments for test configuration

### Service Integration

TestControl integrates with the following VetNet services:
- **UUID Provider**: Controls UUID generation (sequential, fixed, random)
- **Date Provider**: Controls date/time behavior (fixed dates, incrementing)
- **Patient Repository**: Controls patient data operations (success, errors, delays)

## Usage Patterns

### 1. Launch Arguments (UI Tests)

#### Basic Test Scenarios
```bash
# Happy path with sequential UUIDs
-TEST_SCENARIO happy_path

# Network error scenario
-TEST_SCENARIO network_errors

# Validation error scenario  
-TEST_SCENARIO validation_errors

# Slow network scenario
-TEST_SCENARIO slow_network
```

#### Individual Service Control
```bash
# Control UUID behavior
-UUID_BEHAVIOR sequential:100
-UUID_BEHAVIOR fixed
-UUID_BEHAVIOR random

# Control date behavior
-DATE_BEHAVIOR fixed
-DATE_BEHAVIOR "2023-08-09T08:00:00Z"

# Control repository behavior
-REPOSITORY_BEHAVIOR success
-REPOSITORY_BEHAVIOR error
-REPOSITORY_BEHAVIOR slow
-REPOSITORY_BEHAVIOR empty
```

#### UI Test Implementation
```swift
// In UI tests
let app = makeApp(testScenario: "validation_errors")
// This activates the validation_errors scenario which:
// - Uses fixed UUID for predictable results
// - Makes repository succeed initially then fail with duplicate key error

// Custom arguments
let app = makeApp(additionalArguments: [
    "-UUID_BEHAVIOR", "sequential:1000",
    "-REPOSITORY_BEHAVIOR", "slow"
])
```

### 2. Manual Activation (Programmatic)

#### Direct Service Control
```swift
// Get the test control plane
let testControl = TestControlPlane.shared

// Apply behaviors to specific services
testControl.setBehavior(for: .uuidProvider, trait: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1)))
testControl.setBehavior(for: .patientRepository, trait: .delayed(2.0))
testControl.setBehavior(for: .dateProvider, trait: .custom(FixedDateProviderBehavior.fixed(Date())))
```

#### Scenario Activation
```swift
// Activate predefined scenarios
testControl.activateScenario(.Predefined.networkErrors)
testControl.activateScenario(.Predefined.largeDataset)
testControl.activateScenario(.Predefined.validationErrors)

// Deactivate scenario (reset all behaviors)
testControl.deactivateScenario()
```

### 3. Creating Custom Scenarios

```swift
// Define custom test scenario
let customScenario = TestScenario(
    id: "custom_patient_test",
    name: "Custom Patient Test",
    description: "Custom scenario for patient testing",
    serviceBehaviors: [
        .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 500)),
        .patientRepository: .sequential([
            .success,  // First operation succeeds
            .success,  // Second operation succeeds
            .failure(TestControlError.Network.connectionTimeout)  // Third fails
        ]),
        .dateProvider: .custom(FixedDateProviderBehavior.fixed(Date()))
    ],
    duration: 300.0  // Auto-reset after 5 minutes
)

// Activate the custom scenario
testControl.activateScenario(customScenario)
```

## Predefined Test Scenarios

### Happy Path
- **ID**: `happy_path`
- **Purpose**: All services work perfectly with predictable results
- **Behaviors**: Sequential UUID generation starting from 1

### Network Errors
- **ID**: `network_errors`
- **Purpose**: Repository operations fail with network errors
- **Behaviors**: Sequential UUIDs + connection timeout errors

### Slow Network
- **ID**: `slow_network`
- **Purpose**: All network operations are significantly delayed
- **Behaviors**: Sequential UUIDs + 3-second delays

### Validation Errors
- **ID**: `validation_errors`
- **Purpose**: Repository operations fail with validation errors
- **Behaviors**: Fixed UUID + sequential behaviors (success then duplicate key error)

### Large Dataset
- **ID**: `large_dataset`
- **Purpose**: Repository returns large dataset for performance testing
- **Behaviors**: Sequential UUIDs starting from 1000 + 500 patient dataset

### Empty State
- **ID**: `empty_state`
- **Purpose**: All repositories return empty results
- **Behaviors**: Sequential UUIDs + empty datasets

### Fixed Date
- **ID**: `fixed_date`
- **Purpose**: Date provider returns fixed date for time-based tests
- **Behaviors**: Sequential UUIDs + fixed date (Aug 9, 2023)

## Testing Strategies

### UI Test Validation

```swift
// Test with controlled UUIDs
let app = makeApp(testScenario: "happy_path")
// Creates patient with predictable ID: "00000000-0000-0000-0000-000000000001"

// Test error handling
let app = makeApp(testScenario: "validation_errors")
// First operations succeed, then duplicate key error when saving
```

### Integration Testing

```swift
// Test service behavior switching
testControl.setBehavior(for: .patientRepository, trait: .success)
// Perform operations...

testControl.setBehavior(for: .patientRepository, trait: .failure(TestControlError.Network.connectionTimeout))
// Test error handling...

testControl.resetBehavior(for: .patientRepository)
// Back to normal behavior
```

### Performance Testing

```swift
// Test with large datasets
testControl.activateScenario(.Predefined.largeDataset)
// Repository returns 500 patients

// Test with delays
testControl.setBehavior(for: .patientRepository, trait: .delayed(5.0))
// All operations take 5 seconds
```

## Service-Specific Behaviors

### UUID Provider Behaviors

```swift
// Sequential UUIDs starting from specified number
.sequential(start: 1)  // 00000000-0000-0000-0000-000000000001, ...002, etc.

// Fixed UUID for all operations
.fixed(UUID(uuidString: "12345678-1234-1234-1234-123456789012")!)

// Random UUIDs (default behavior)
.random
```

### Date Provider Behaviors

```swift
// Fixed date for all date operations
.fixed(Date(timeIntervalSince1970: 1691568000))  // Aug 9, 2023

// Incrementing dates
.incrementing(start: Date(), increment: 3600)  // Advance 1 hour each call

// Business hours only
.businessHoursOnly(Date())  // Only return dates during business hours
```

### Repository Behaviors

#### Standard Behaviors
- `.success`: Normal operation
- `.failure(error)`: Always fail with specified error
- `.delayed(seconds)`: Add delay before operation
- `.intermittent(successRate: 0.7)`: Succeed 70% of the time

#### Sequential Behaviors
```swift
.sequential([
    .success,           // First call succeeds
    .success,           // Second call succeeds  
    .delayed(2.0),      // Third call delayed
    .failure(error)     // Fourth call fails
])
```

#### Custom Behaviors
```swift
.custom(LargeDatasetBehavior(patientCount: 500))    // Return 500 patients
.custom(EmptyDatasetBehavior())                      // Return empty results
```

## Error Types

### Network Errors
- `TestControlError.Network.connectionTimeout`: Connection timeout
- `TestControlError.Network.serverUnavailable`: Server unavailable
- `TestControlError.Network.noInternetConnection`: No internet

### Validation Errors
- `TestControlError.Validation.duplicateKey`: Duplicate key constraint
- `TestControlError.Validation.invalidFormat`: Invalid data format
- `TestControlError.Validation.missingRequiredField`: Missing required field

### General Errors
- `TestControlError.General.unexpectedError`: Unexpected error
- `TestControlError.General.serviceUnavailable`: Service unavailable

## Best Practices

### 1. UI Test Design

```swift
// Use scenarios for complete test setups
let app = makeApp(testScenario: "validation_errors")

// Use predictable IDs for assertions
patientCreationScreen.assertPatientCreatedSuccessfully(id: "00000000-0000-0000-0000-000000000001")

// Test error states with appropriate scenarios
let app = makeApp(testScenario: "network_errors")
```

### 2. Service Integration

```swift
// Register services during initialization
testControlPlane.register(uuidProvider, as: .uuidProvider)
testControlPlane.register(dateProvider, as: .dateProvider)
testControlPlane.register(patientRepository, as: .patientRepository)

// Apply behaviors from launch arguments
launchArgumentParser.applyConfiguration(to: testControlPlane)
```

### 3. Debugging

```swift
// Enable verbose logging
-VERBOSE_LOGGING true

// Check current behaviors
let behaviors = testControlPlane.getCurrentBehaviors()
print("Active behaviors: \(behaviors)")

// Monitor scenario activation
testControlPlane.activateScenario(scenario)
print("Activated scenario: \(scenario.name)")
```

## Troubleshooting

### Common Issues

1. **Services not responding to behaviors**
   - Ensure service is registered with TestControlPlane
   - Verify correct ServiceIdentifier is used
   - Check launch arguments are parsed correctly

2. **Inconsistent test results**
   - Use sequential UUID generation for predictable IDs
   - Set fixed dates for time-dependent tests
   - Reset behaviors between test runs

3. **Scenario not activating**
   - Verify scenario ID matches predefined scenarios
   - Check launch arguments format: `-TEST_SCENARIO scenario_id`
   - Ensure TestControlInitializer is called during app startup

### Debug Commands

```swift
// Check registered services
let registeredServices = testControlPlane.getRegisteredServices()

// Verify active scenario
let activeScenario = testControlPlane.getActiveScenario()

// List available scenarios
let scenarios = TestScenario.Predefined.all
```

## Advanced Usage

### Custom Service Integration

```swift
// 1. Make service conform to TestControllable
extension MyCustomService: TestControllable {
    func applyBehavior(_ behavior: CustomBehavior) {
        // Apply behavior logic
    }
    
    func resetBehavior() {
        // Reset to default behavior
    }
}

// 2. Register with TestControlPlane
testControlPlane.register(myService, as: ServiceIdentifier(type: "MyCustomService"))

// 3. Use in scenarios
let customScenario = TestScenario(
    id: "custom_test",
    name: "Custom Test",
    description: "Test custom service",
    serviceBehaviors: [
        ServiceIdentifier(type: "MyCustomService"): .custom(CustomBehavior.slow)
    ]
)
```

### Environment-Specific Configuration

```swift
// Development environment
#if DEBUG
testControlPlane.activateScenario(.Predefined.largeDataset)
#endif

// UI testing environment
if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
    launchArgumentParser.applyConfiguration(to: testControlPlane)
}

// Manual testing mode
if featureFlagService.isEnabled(.manualTestControl) {
    // Enable debug UI for manual scenario control
}
```

This guide provides comprehensive coverage of the TestControl system. For additional questions or advanced use cases, refer to the inline documentation in the TestControl source files.