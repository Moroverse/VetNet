// TestScenario.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-11 11:15 GMT.

import Foundation

// MARK: - Test Scenario

/// Defines a complete test scenario with specific service behaviors
/// A scenario represents a coherent test setup (e.g., "patient creation happy path", "network error recovery")
public struct TestScenario: Sendable {
    /// Unique identifier for the scenario
    public let id: String

    /// Human-readable name for the scenario
    public let name: String

    /// Description of what this scenario tests
    public let description: String

    /// Service behaviors to apply for this scenario
    public let serviceBehaviors: [ServiceIdentifier: BehaviorTrait]

    /// Optional delay before scenario activation
    public let activationDelay: TimeInterval?

    /// Optional duration for the scenario (auto-reset after this time)
    public let duration: TimeInterval?

    public init(
        id: String,
        name: String,
        description: String,
        serviceBehaviors: [ServiceIdentifier: BehaviorTrait] = [:],
        activationDelay: TimeInterval? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.serviceBehaviors = serviceBehaviors
        self.activationDelay = activationDelay
        self.duration = duration
    }
}

// MARK: - Predefined Test Scenarios

public extension TestScenario {
    /// Standard scenarios for common test cases
    enum Predefined {
        /// Happy path scenario - all services work perfectly
        public static let happyPath = TestScenario(
            id: "happy_path",
            name: "Happy Path",
            description: "All services work perfectly with predictable IDs",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1))
            ]
        )

        /// Network error scenario - repositories fail with network errors
        public static let networkErrors = TestScenario(
            id: "network_errors",
            name: "Network Errors",
            description: "Repository operations fail with network errors",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1)),
                .patientRepository: .failure(TestControlError.Network.connectionTimeout)
            ]
        )

        /// Slow network scenario - operations are delayed
        public static let slowNetwork = TestScenario(
            id: "slow_network",
            name: "Slow Network",
            description: "All network operations are significantly delayed",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1)),
                .patientRepository: .delayed(3.0)
            ]
        )

        /// Intermittent failures scenario - operations succeed/fail randomly
        public static let intermittentFailures = TestScenario(
            id: "intermittent_failures",
            name: "Intermittent Failures",
            description: "Services fail intermittently (70% success rate)",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1)),
                .patientRepository: .intermittent(successRate: 0.7)
            ]
        )

        /// Validation errors scenario - duplicate key errors
        public static let validationErrors = TestScenario(
            id: "validation_errors",
            name: "Validation Errors",
            description: "Repository operations succeed initially then fail with validation errors",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.fixed(UUID(uuidString: "12345678-1234-1234-1234-123456789012")!)),
                .patientCRUDRepository: .sequential([
                    .success, // First operations succeed (app initialization, list loading)
                    .failure(TestControlError.Validation.duplicateKey) // Finally fail when test tries to save
                ])
            ]
        )

        /// Fixed date scenario - time-based tests with predictable dates
        public static let fixedDate = TestScenario(
            id: "fixed_date",
            name: "Fixed Date",
            description: "Date provider returns fixed date for consistent time-based tests",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1)),
                .dateProvider: .custom(FixedDateProviderBehavior.fixed(Date(timeIntervalSince1970: 1_700_000_000)))
            ]
        )

        /// Data loading scenario - large dataset with pagination
        public static let largeDataset = TestScenario(
            id: "large_dataset",
            name: "Large Dataset",
            description: "Repository returns large dataset for performance testing",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1000)),
                .patientRepository: .custom(LargeDatasetBehavior(patientCount: 500))
            ]
        )

        /// Empty state scenario - repositories return empty results
        public static let emptyState = TestScenario(
            id: "empty_state",
            name: "Empty State",
            description: "All repositories return empty results",
            serviceBehaviors: [
                .uuidProvider: .custom(ControllableUUIDProvider.Behavior.sequential(start: 1)),
                .patientRepository: .custom(EmptyDatasetBehavior())
            ]
        )

        /// All predefined scenarios for easy access
        public static let all: [TestScenario] = [
            happyPath,
            networkErrors,
            slowNetwork,
            intermittentFailures,
            validationErrors,
            fixedDate,
            largeDataset,
            emptyState
        ]
    }
}

// MARK: - Scenario Collection

/// Collection of scenarios for organizational purposes
public struct ScenarioCollection: Sendable {
    public let name: String
    public let description: String
    public let scenarios: [TestScenario]

    public init(name: String, description: String, scenarios: [TestScenario]) {
        self.name = name
        self.description = description
        self.scenarios = scenarios
    }
}

public extension ScenarioCollection {
    /// Patient management specific scenarios
    static let patientManagement = ScenarioCollection(
        name: "Patient Management",
        description: "Scenarios for testing patient creation, editing, and validation",
        scenarios: [
            .Predefined.happyPath,
            .Predefined.validationErrors,
            .Predefined.networkErrors
        ]
    )

    /// Performance testing scenarios
    static let performance = ScenarioCollection(
        name: "Performance Testing",
        description: "Scenarios for testing app performance under various conditions",
        scenarios: [
            .Predefined.slowNetwork,
            .Predefined.largeDataset,
            .Predefined.intermittentFailures
        ]
    )

    /// Edge cases and error handling scenarios
    static let edgeCases = ScenarioCollection(
        name: "Edge Cases",
        description: "Scenarios for testing edge cases and error handling",
        scenarios: [
            .Predefined.emptyState,
            .Predefined.validationErrors,
            .Predefined.intermittentFailures
        ]
    )
}

// MARK: - Custom Behavior Types

/// Custom behavior for repositories that return large datasets
public struct LargeDatasetBehavior: Sendable, Hashable {
    public let patientCount: Int

    public init(patientCount: Int = 100) {
        self.patientCount = patientCount
    }
}

/// Custom behavior for repositories that return empty datasets
public struct EmptyDatasetBehavior: Sendable, Hashable {
    public init() {}
}

/// Custom behavior for fixed date provider
public enum FixedDateProviderBehavior: Sendable, Hashable {
    case fixed(Date)
    case incrementing(start: Date, increment: TimeInterval)
    case businessHoursOnly(Date) // Only return dates during business hours
}
