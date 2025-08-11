// TestControlPlane.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-11 06:16 GMT.

import Foundation
import os.log

// MARK: - Test Control Plane

/// Central control plane for managing test behaviors across all controllable services
/// This singleton coordinates test scenarios and service behaviors for both UI and manual testing
@MainActor
public final class TestControlPlane {
    // MARK: - Singleton

    public static let shared = TestControlPlane()

    // MARK: - Properties

    /// Registry of controllable services
    private var registry: [ServiceIdentifier: AnyTestControllable] = [:]

    /// Current behaviors applied to services
    private var behaviors: [ServiceIdentifier: BehaviorTrait] = [:]

    /// Pending behaviors to apply when services are registered
    private var pendingBehaviors: [ServiceIdentifier: BehaviorTrait] = [:]

    /// Currently active test scenario
    private var activeScenario: TestScenario?

    /// Logger for test control events
    private let logger = Logger(subsystem: "com.moroverse.VetNet", category: "TestControl")

    // MARK: - Initialization

    private init() {
        logger.debug("TestControlPlane initialized")
    }

    // MARK: - Service Registration

    /// Register a controllable service with the test control plane
    /// - Parameters:
    ///   - service: The controllable service
    ///   - identifier: The service identifier
    public func register(_ service: some TestControllable, as identifier: ServiceIdentifier) {
        let wrappedService = AnyTestControllable(service)
        registry[identifier] = wrappedService
        logger.debug("Registered service: \(identifier.description)")

        // Apply any pending behavior for this service
        if let pendingBehavior = pendingBehaviors.removeValue(forKey: identifier) {
            behaviors[identifier] = pendingBehavior
            applyBehaviorToService(wrappedService, trait: pendingBehavior)
            logger.debug("Applied pending behavior \(pendingBehavior.description) to \(identifier.description)")
        }
    }

    /// Unregister a service from the test control plane
    /// - Parameter identifier: The service identifier
    func unregister(_ identifier: ServiceIdentifier) {
        registry.removeValue(forKey: identifier)
        behaviors.removeValue(forKey: identifier)
        logger.debug("Unregistered service: \(identifier.description)")
    }

    // MARK: - Behavior Management

    /// Set a behavior for a specific service
    /// - Parameters:
    ///   - identifier: The service identifier
    ///   - trait: The behavior trait to apply
    func setBehavior(for identifier: ServiceIdentifier, trait: BehaviorTrait) {
        // Apply to registered service if available
        if let service = registry[identifier] {
            behaviors[identifier] = trait
            applyBehaviorToService(service, trait: trait)
            logger.debug("Applied behavior \(trait.description) to \(identifier.description)")
        } else {
            // Store as pending behavior for when service is registered
            pendingBehaviors[identifier] = trait
            logger.debug("Stored pending behavior \(trait.description) for \(identifier.description)")
        }
    }

    /// Get the current behavior for a service
    /// - Parameter identifier: The service identifier
    /// - Returns: The current behavior trait, if any
    func getBehavior(for identifier: ServiceIdentifier) -> BehaviorTrait? {
        behaviors[identifier]
    }

    /// Reset a specific service to default behavior
    /// - Parameter identifier: The service identifier
    func resetBehavior(for identifier: ServiceIdentifier) {
        behaviors.removeValue(forKey: identifier)
        registry[identifier]?.resetBehavior()
        logger.debug("Reset behavior for \(identifier.description)")
    }

    /// Reset all services to default behavior
    func resetAll() {
        behaviors.removeAll()
        pendingBehaviors.removeAll()
        registry.values.forEach { $0.resetBehavior() }
        activeScenario = nil
        logger.debug("Reset all behaviors and pending behaviors")
    }

    // MARK: - Scenario Management

    /// Activate a test scenario
    /// - Parameter scenario: The test scenario to activate
    public func activateScenario(_ scenario: TestScenario) {
        logger.info("Activating scenario: \(scenario.name)")

        // Deactivate current scenario
        deactivateScenario()

        // Apply new scenario behaviors
        activeScenario = scenario
        for (identifier, trait) in scenario.serviceBehaviors {
            setBehavior(for: identifier, trait: trait)
        }
    }

    /// Deactivate the current scenario
    func deactivateScenario() {
        if let scenario = activeScenario {
            logger.info("Deactivating scenario: \(scenario.name)")
            resetAll()
        }
    }

    /// Get the currently active scenario
    /// - Returns: The active test scenario, if any
    public func getActiveScenario() -> TestScenario? {
        activeScenario
    }

    // MARK: - Inspection

    /// Get all registered services
    /// - Returns: Array of registered service identifiers
    func registeredServices() -> [ServiceIdentifier] {
        Array(registry.keys)
    }

    /// Get all current behaviors
    /// - Returns: Dictionary of service identifiers to behavior traits
    func currentBehaviors() -> [ServiceIdentifier: BehaviorTrait] {
        behaviors
    }

    /// Check if a service is registered
    /// - Parameter identifier: The service identifier
    /// - Returns: True if the service is registered
    func isRegistered(_ identifier: ServiceIdentifier) -> Bool {
        registry[identifier] != nil
    }

    // MARK: - Private Methods

    private func applyBehaviorToService(_ service: AnyTestControllable, trait: BehaviorTrait) {
        switch trait {
        case let .custom(behavior):
            service.applyBehavior(behavior)
        default:
            // For non-custom behaviors, services need to interpret the trait
            // This would be handled by service-specific implementations
            service.applyBehavior(trait)
        }
    }
}
