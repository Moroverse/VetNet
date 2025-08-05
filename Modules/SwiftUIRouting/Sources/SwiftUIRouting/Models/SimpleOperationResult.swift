// SimpleOperationResult.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import Foundation

/// Simple result type for basic success/failure operations
///
/// This enum provides a standardized way to handle results from simple operations
/// that don't return complex data, such as authentication, logout, or basic confirmations.
/// It conforms to `RouteResult` to enable bidirectional routing patterns.
///
/// Example usage:
/// ```swift
/// @Observable
/// class AuthRouter: BaseFormRouter<AuthFormMode, SimpleOperationResult> {
///
///     func signIn() async -> SimpleOperationResult {
///         return await presentForm(.signIn)
///     }
///
///     func signOut() async -> SimpleOperationResult {
///         return await presentForm(.signOut)
///     }
/// }
/// ```
public enum SimpleOperationResult: RouteResult {
    /// The operation completed successfully
    case success

    /// The operation was cancelled by the user
    case cancelled

    /// The operation failed with an error
    case error(any Error)

    // MARK: - RouteResult Conformance

    public typealias SuccessType = Void
    public typealias ErrorType = Error

    /// Whether this result represents a successful operation
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    /// Whether this result represents a cancelled operation
    public var isCancelled: Bool {
        if case .cancelled = self {
            return true
        }
        return false
    }

    /// Whether this result represents an error
    public var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }

    /// Extract the error from the result, if present
    public var error: (any Error)? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }
}

// MARK: - Convenience Initializers

public extension SimpleOperationResult {
    /// Create a success result
    static var successResult: SimpleOperationResult {
        .success
    }

    /// Create a cancelled result
    static var cancelledResult: SimpleOperationResult {
        .cancelled
    }

    /// Create an error result
    ///
    /// - Parameter error: The error that occurred
    /// - Returns: An error result
    static func errorResult(_ error: any Error) -> SimpleOperationResult {
        .error(error)
    }

    /// Create an error result with a message
    ///
    /// - Parameter message: The error message
    /// - Returns: An error result with a generic error
    static func errorResult(message: String) -> SimpleOperationResult {
        .error(SimpleOperationError.message(message))
    }
}

// MARK: - Simple Operation Error

/// Simple error type for basic operations
public nonisolated enum SimpleOperationError: LocalizedError {
    case message(String)
    case unknown

    public var errorDescription: String? {
        switch self {
        case let .message(message):
            message
        case .unknown:
            "An unknown error occurred"
        }
    }
}

// MARK: - Equatable Conformance

extension SimpleOperationResult: Equatable {
    public static func == (lhs: SimpleOperationResult, rhs: SimpleOperationResult) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            true
        case (.cancelled, .cancelled):
            true
        case let (.error(lhsError), .error(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        default:
            false
        }
    }
}

// MARK: - Hashable Conformance

extension SimpleOperationResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .success:
            hasher.combine("success")
        case .cancelled:
            hasher.combine("cancelled")
        case let .error(error):
            hasher.combine("error")
            hasher.combine(error.localizedDescription)
        }
    }
}

// MARK: - CustomStringConvertible Conformance

extension SimpleOperationResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success:
            "SimpleOperationResult.success"
        case .cancelled:
            "SimpleOperationResult.cancelled"
        case let .error(error):
            "SimpleOperationResult.error(\(error.localizedDescription))"
        }
    }
}
