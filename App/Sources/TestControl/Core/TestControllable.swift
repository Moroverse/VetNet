// TestControllable.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 19:36 GMT.

import Foundation

// MARK: - Test Controllable Protocol

/// Protocol for services that can be controlled during testing
/// Each service defines its own behavior type and implements application logic
public protocol TestControllable: AnyObject {
    /// The type of behavior this service supports
    associatedtype Behavior

    /// Apply a test behavior to this service
    /// - Parameter behavior: The behavior to apply
    func applyBehavior(_ behavior: Behavior)

    /// Reset to default behavior
    func resetBehavior()
}

// MARK: - Type-Erased Wrapper

/// Type-erased wrapper for TestControllable services
final class AnyTestControllable {
    private let _applyBehavior: (Any) -> Void
    private let _resetBehavior: () -> Void

    init<T: TestControllable>(_ controllable: T) {
        _applyBehavior = { behavior in
            if let typedBehavior = behavior as? T.Behavior {
                controllable.applyBehavior(typedBehavior)
            }
        }
        _resetBehavior = controllable.resetBehavior
    }

    func applyBehavior(_ behavior: Any) {
        _applyBehavior(behavior)
    }

    func resetBehavior() {
        _resetBehavior()
    }
}
