// BehaviorTrait.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 19:32 GMT.

import Foundation

// MARK: - Behavior Trait

/// Universal behavior traits that can be applied to test-controllable services
/// These represent common testing scenarios across different service types
public enum BehaviorTrait: Sendable {
    /// Service operates normally
    case success

    /// Service fails with an error
    case failure(TestControlError)

    /// Service responds after a delay
    case delayed(TimeInterval)

    /// Service succeeds intermittently based on probability
    case intermittent(successRate: Double)

    /// Service cycles through a sequence of behaviors
    case sequential([BehaviorTrait])

    /// Custom behavior specific to a service
    case custom(Any)
}

// TestError types are now defined in TestError.swift as TestControlError

// MARK: - Behavior Trait Extensions

extension BehaviorTrait {
    /// Common pre-configured behaviors
    static let networkTimeout = BehaviorTrait.failure(.timeoutError(30.0))
    static let validationError = BehaviorTrait.failure(.validationError("Invalid input"))
    static let slowResponse = BehaviorTrait.delayed(3.0)
    static let flaky = BehaviorTrait.intermittent(successRate: 0.7)
}

extension BehaviorTrait: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success:
            "success"
        case let .failure(error):
            "failure(\(error))"
        case let .delayed(interval):
            "delayed(\(interval)s)"
        case let .intermittent(rate):
            "intermittent(\(rate * 100)%)"
        case let .sequential(behaviors):
            "sequential(\(behaviors.count) behaviors)"
        case .custom:
            "custom"
        }
    }
}
