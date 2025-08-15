// TestControlInitializer.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-11 11:15 GMT.

import Foundation

// MARK: - Test Control Initializer

/// Initializes test control functionality during app startup
/// This class coordinates between launch arguments, test scenarios, and the TestControlPlane
@MainActor
public final class TestControlInitializer {
    // MARK: - Properties

    private let testControlPlane = TestControlPlane.shared
    private let argumentParser = LaunchArgumentParser()

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Interface

    /// Initialize test control based on launch arguments and environment
    /// Should be called early in app startup process
    public func initialize() {
        #if DEBUG
            guard argumentParser.shouldEnableTestControl() else {
                // No test control arguments present, skip initialization
                return
            }

            print("🧪 Test Control Mode Activated")

            // Apply launch argument configuration
            argumentParser.applyConfiguration(to: testControlPlane)

            // Log current configuration
            logCurrentConfiguration()

            // Set up automatic scenario deactivation if needed
            scheduleAutomaticDeactivation()

        #endif
    }

    /// Get the current test control plane instance
    public func getTestControlPlane() -> TestControlPlane {
        testControlPlane
    }

    /// Check if test control is currently active
    public var isActive: Bool {
        #if DEBUG
            return argumentParser.shouldEnableTestControl()
        #else
            return false
        #endif
    }

    // MARK: - Manual Control (for Debug Settings)

    #if DEBUG
        /// Activate a specific scenario manually (for debug settings UI)
        public func activateScenario(_ scenario: TestScenario) {
            testControlPlane.activateScenario(scenario)
            print("🧪 Manually activated scenario: \(scenario.name)")
        }

        /// Deactivate current scenario manually
        public func deactivateScenario() {
            testControlPlane.deactivateScenario()
            print("🧪 Manually deactivated test scenario")
        }

        /// Get all available predefined scenarios
        public var availableScenarios: [TestScenario] {
            TestScenario.Predefined.all
        }

        /// Get scenario collections for organized presentation
        public var scenarioCollections: [ScenarioCollection] {
            [
                .patientManagement,
                .performance,
                .edgeCases
            ]
        }
    #endif

    // MARK: - Private Methods

    private func logCurrentConfiguration() {
        let configuration = argumentParser.parseTestConfiguration()

        print("🧪 Test Configuration:")
        print("   • UI Testing: \(configuration.isUITesting)")

        if let scenarioId = configuration.scenarioId {
            print("   • Active Scenario: \(scenarioId)")
        }

        if let scenario = testControlPlane.getActiveScenario() {
            print("   • Scenario Description: \(scenario.description)")
            print("   • Service Behaviors: \(scenario.serviceBehaviors.count)")
        }

        if configuration.verboseLogging {
            print("   • Verbose Logging: Enabled")
        }

        // Log registered services
        let registeredServices = testControlPlane.registeredServices()
        if !registeredServices.isEmpty {
            print("   • Registered Services:")
            for service in registeredServices {
                let behavior = testControlPlane.getBehavior(for: service)
                let behaviorDescription = behavior?.description ?? "default"
                print("     - \(service.description): \(behaviorDescription)")
            }
        }
    }

    private func scheduleAutomaticDeactivation() {
        guard let activeScenario = testControlPlane.getActiveScenario(),
              let duration = activeScenario.duration else {
            return
        }

        print("🧪 Scheduling automatic scenario deactivation in \(duration)s")

        Task {
            testControlPlane.deactivateScenario()
            print("🧪 Automatically deactivated scenario after timeout")
        }
    }
}

// BehaviorTrait already has CustomStringConvertible implemented in BehaviorTrait.swift

// MARK: - Example Usage Documentation

// ## Launch Argument Examples
//
// ### Basic Scenarios
// ```
// # Activate happy path scenario with sequential UUIDs
// -TEST_SCENARIO happy_path
//
// # Network error testing
// -TEST_SCENARIO network_errors
//
// # Performance testing with large dataset
// -TEST_SCENARIO large_dataset
// ```
//
// ### Individual Behaviors
// ```
// # Sequential UUIDs starting from 100
// -UUID_BEHAVIOR sequential:100
//
// # Fixed date for consistent time-based tests
// -DATE_BEHAVIOR "2023-08-09T08:00:00Z"
//
// # Repository in error state
// -REPOSITORY_BEHAVIOR error
// ```
//
// ### Environment Variables
// ```bash
// export TEST_SCENARIO="happy_path"
// export UUID_BEHAVIOR="sequential"
// export VERBOSE_TEST_LOGGING="1"
// ```
//
// ### JSON Configuration
// ```
// -TEST_CONFIGURATION '{"scenarioId":"network_errors","verboseLogging":true}'
// ```
//
// ### UI Testing Setup
// ```
// # In VetNetUITestCase.swift
// application.launchArguments = [
//    "UI_TESTING",
//    "-TEST_SCENARIO", "happy_path",
//    "-UUID_BEHAVIOR", "sequential:1"
// ]
// ```
//
// ## Integration in App Delegate / Scene Delegate
//
// ```swift
// @MainActor
// class AppDelegate: UIResponder, UIApplicationDelegate {
//    let testControlInitializer = TestControlInitializer()
//
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        // Initialize test control early in app lifecycle
//        testControlInitializer.initialize()
//
//        return true
//    }
// }
// ```
