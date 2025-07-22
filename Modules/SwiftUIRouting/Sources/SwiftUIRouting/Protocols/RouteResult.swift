// RouteResult.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import Foundation

/// Protocol defining a result type for routing operations
///
/// This protocol provides type-safe result handling for bidirectional routing,
/// enabling immediate user feedback and proper error handling across navigation flows.
///
/// Example implementation:
/// ```swift
/// enum UserFormResult: RouteResult {
///     case created(User)
///     case updated(User)
///     case cancelled
///     case error(Error)
///
///     typealias SuccessType = User
///     typealias ErrorType = Error
///
///     var isSuccess: Bool {
///         switch self {
///         case .created, .updated: true
///         case .cancelled, .error: false
///         }
///     }
///
///     var isCancelled: Bool {
///         if case .cancelled = self { return true }
///         return false
///     }
///
///     var isError: Bool {
///         if case .error = self { return true }
///         return false
///     }
///
///     var error: Error? {
///         if case .error(let error) = self { return error }
///         return nil
///     }
/// }
/// ```
public protocol RouteResult {
    /// The type returned on successful operations
    associatedtype SuccessType

    /// The error type for failed operations
    associatedtype ErrorType: Error

    /// Whether this result represents a successful operation
    var isSuccess: Bool { get }

    /// Whether this result represents a cancelled operation
    var isCancelled: Bool { get }

    /// Whether this result represents an error
    var isError: Bool { get }

    /// Extract the error from the result, if present
    var error: ErrorType? { get }
}

/// Convenience extensions for RouteResult
public extension RouteResult {
    /// Whether this result represents an operation that completed
    /// (either successfully or with an error, but not cancelled)
    var isCompleted: Bool {
        isSuccess || isError
    }

    /// Whether this result represents an operation that finished
    /// without being cancelled (regardless of success or error)
    var isFinished: Bool {
        !isCancelled
    }
}
