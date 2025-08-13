// LaunchArgumentParser.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 19:33 GMT.

import Foundation

// MARK: - Launch Argument Parser

/// Parses launch arguments and environment variables to configure test scenarios
public struct LaunchArgumentParser {
    // MARK: - Configuration Keys

    public enum ArgumentKey: String, CaseIterable {
        /// Activate a specific test scenario by ID
        case testScenario = "TEST_SCENARIO"

        /// Enable UI testing mode
        case uiTesting = "UI_TESTING"

        /// Set UUID provider behavior
        case uuidBehavior = "UUID_BEHAVIOR"

        /// Set date provider behavior
        case dateBehavior = "DATE_BEHAVIOR"

        /// Force specific repository behavior
        case repositoryBehavior = "REPOSITORY_BEHAVIOR"

        /// Enable verbose test logging
        case verboseLogging = "VERBOSE_TEST_LOGGING"

        /// JSON configuration for complex scenarios
        case testConfiguration = "TEST_CONFIGURATION"
    }

    // MARK: - Properties

    private let processInfo: ProcessInfo

    // MARK: - Initialization

    public init(processInfo: ProcessInfo = .processInfo) {
        self.processInfo = processInfo
    }

    // MARK: - Parsing

    /// Parse launch arguments and return test configuration
    /// - Returns: Test configuration based on launch arguments
    public func parseTestConfiguration() -> TestConfiguration {
        var configuration = TestConfiguration()

        // Check if UI testing is enabled
        configuration.isUITesting = hasArgument(.uiTesting) || hasEnvironment(.uiTesting)

        // Parse test scenario
        if let scenarioId = getValue(for: .testScenario) {
            configuration.scenarioId = scenarioId
        }

        // Parse UUID behavior
        if let uuidBehavior = getValue(for: .uuidBehavior) {
            configuration.uuidBehavior = parseUUIDBehavior(from: uuidBehavior)
        }

        // Parse date behavior
        if let dateBehavior = getValue(for: .dateBehavior) {
            configuration.dateBehavior = parseDateBehavior(from: dateBehavior)
        }

        // Parse repository behavior
        if let repositoryBehavior = getValue(for: .repositoryBehavior) {
            configuration.repositoryBehavior = parseRepositoryBehavior(from: repositoryBehavior)
        }

        // Check verbose logging
        configuration.verboseLogging = hasArgument(.verboseLogging) || hasEnvironment(.verboseLogging)

        // Parse JSON configuration
        if let jsonConfig = getValue(for: .testConfiguration) {
            if let jsonData = jsonConfig.data(using: .utf8),
               let parsed = try? JSONDecoder().decode(JSONTestConfiguration.self, from: jsonData) {
                configuration.merge(with: parsed)
            }
        }

        return configuration
    }

    /// Get the test scenario to activate based on launch arguments
    /// - Returns: Test scenario if specified in arguments
    public func getTestScenario() -> TestScenario? {
        guard let scenarioId = getValue(for: .testScenario) else { return nil }

        // Try to find predefined scenario
        return TestScenario.Predefined.all.first { $0.id == scenarioId }
    }

    /// Check if test control should be enabled
    /// - Returns: True if any test control arguments are present
    public func shouldEnableTestControl() -> Bool {
        ArgumentKey.allCases.contains { key in
            hasArgument(key) || hasEnvironment(key)
        }
    }

    // MARK: - Private Methods

    private func hasArgument(_ key: ArgumentKey) -> Bool {
        processInfo.arguments.contains("-\(key.rawValue)") ||
            processInfo.arguments.contains("--\(key.rawValue)")
    }

    private func hasEnvironment(_ key: ArgumentKey) -> Bool {
        processInfo.environment[key.rawValue] != nil
    }

    private func getValue(for key: ArgumentKey) -> String? {
        // Check environment variables first
        if let envValue = processInfo.environment[key.rawValue] {
            return envValue
        }

        // Check launch arguments
        let args = processInfo.arguments
        let keyVariants = ["-\(key.rawValue)", "--\(key.rawValue)"]

        for variant in keyVariants {
            if let index = args.firstIndex(of: variant),
               index + 1 < args.count {
                return args[index + 1]
            }
        }

        return nil
    }

    private func parseUUIDBehavior(from string: String) -> ControllableUUIDProvider.Behavior {
        switch string.lowercased() {
        case "sequential":
            return .sequential(start: 1)
        case "fixed":
            // Use a fixed UUID for testing
            return .fixed(UUID(uuidString: "12345678-1234-1234-1234-123456789012")!)
        case "random":
            return .random
        default:
            // Try to parse as sequential with custom start
            if string.hasPrefix("sequential:"),
               let startString = string.components(separatedBy: ":").last,
               let start = Int(startString) {
                return .sequential(start: start)
            }
            return .random
        }
    }

    private func parseDateBehavior(from string: String) -> ControllableDateProvider.Behavior {
        switch string.lowercased() {
        case "fixed":
            // Use a fixed date for testing (Aug 9, 2023)
            return .fixed(Date(timeIntervalSince1970: 1_691_568_000))
        default:
            // Try to parse as ISO date string
            if let date = ISO8601DateFormatter().date(from: string) {
                return .fixed(date)
            }
            return .fixed(Date(timeIntervalSince1970: 1_691_568_000))
        }
    }

    private func parseRepositoryBehavior(from string: String) -> RepositoryBehavior {
        switch string.lowercased() {
        case "success":
            .success
        case "error":
            .error
        case "slow":
            .slow
        case "empty":
            .empty
        default:
            .success
        }
    }
}

// MARK: - Test Configuration

/// Configuration parsed from launch arguments
public struct TestConfiguration {
    public var isUITesting = false
    public var scenarioId: String?
    public var uuidBehavior: ControllableUUIDProvider.Behavior?
    public var dateBehavior: ControllableDateProvider.Behavior?
    public var repositoryBehavior: RepositoryBehavior?
    public var verboseLogging = false

    /// Merge with JSON configuration
    public mutating func merge(with jsonConfig: JSONTestConfiguration) {
        if let scenarioId = jsonConfig.scenarioId {
            self.scenarioId = scenarioId
        }
        if let verboseLogging = jsonConfig.verboseLogging {
            self.verboseLogging = verboseLogging
        }
        // Additional merging as needed
    }
}

// MARK: - JSON Configuration Support

/// JSON configuration structure for complex test setups
public struct JSONTestConfiguration: Codable {
    public let scenarioId: String?
    public let verboseLogging: Bool?
    public let customBehaviors: [String: String]?

    public init(scenarioId: String? = nil, verboseLogging: Bool? = nil, customBehaviors: [String: String]? = nil) {
        self.scenarioId = scenarioId
        self.verboseLogging = verboseLogging
        self.customBehaviors = customBehaviors
    }
}

// MARK: - Repository Behavior

/// Simple repository behavior options
public enum RepositoryBehavior: String, CaseIterable {
    case success
    case error
    case slow
    case empty
}

// MARK: - Test Control Activation

public extension LaunchArgumentParser {
    /// Apply parsed configuration to TestControlPlane
    /// - Parameter testControlPlane: The test control plane to configure
    @MainActor
    func applyConfiguration(to testControlPlane: TestControlPlane) {
        let configuration = parseTestConfiguration()

        // Apply test scenario if specified
        if let scenarioId = configuration.scenarioId,
           let scenario = TestScenario.Predefined.all.first(where: { $0.id == scenarioId }) {
            testControlPlane.activateScenario(scenario)
        }

        // Apply individual behaviors
        if let uuidBehavior = configuration.uuidBehavior {
            testControlPlane.setBehavior(for: .uuidProvider, trait: .custom(uuidBehavior))
        }

        if let dateBehavior = configuration.dateBehavior {
            testControlPlane.setBehavior(for: .dateProvider, trait: .custom(dateBehavior))
        }

        if let repositoryBehavior = configuration.repositoryBehavior {
            let trait: BehaviorTrait = switch repositoryBehavior {
            case .success:
                .success
            case .error:
                .failure(TestControlError.Network.connectionTimeout)
            case .slow:
                .delayed(2.0)
            case .empty:
                .custom(EmptyDatasetBehavior())
            }
            testControlPlane.setBehavior(for: .patientRepository, trait: trait)
        }
    }
}
