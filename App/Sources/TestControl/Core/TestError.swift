// TestError.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 19:39 GMT.

import Foundation

// MARK: - Test Error

/// Standard test errors that can be used in BehaviorTrait.failure cases
public enum TestControlError: Error, Sendable, Hashable {
    /// Network-related errors
    case networkError(String)

    /// Validation errors (business logic failures)
    case validationError(String)

    /// Authentication/authorization errors
    case authenticationError(String)

    /// Resource not found errors
    case notFoundError(String)

    /// Rate limiting errors
    case rateLimitError(String)

    /// Server errors (5xx)
    case serverError(Int, String)

    /// Client errors (4xx)
    case clientError(Int, String)

    /// Timeout errors
    case timeoutError(TimeInterval)

    /// Database/persistence errors
    case persistenceError(String)

    /// Generic error with custom message
    case genericError(String)
}

// MARK: - LocalizedError

extension TestControlError: LocalizedError {
    public nonisolated var errorDescription: String? {
        switch self {
        case let .networkError(message):
            "Network Error: \(message)"
        case let .validationError(message):
            "Validation Error: \(message)"
        case let .authenticationError(message):
            "Authentication Error: \(message)"
        case let .notFoundError(message):
            "Not Found: \(message)"
        case let .rateLimitError(message):
            "Rate Limit: \(message)"
        case let .serverError(code, message):
            "Server Error \(code): \(message)"
        case let .clientError(code, message):
            "Client Error \(code): \(message)"
        case let .timeoutError(interval):
            "Timeout after \(interval)s"
        case let .persistenceError(message):
            "Persistence Error: \(message)"
        case let .genericError(message):
            "Error: \(message)"
        }
    }
}

// MARK: - Common Test Errors

public extension TestControlError {
    /// Common network errors for testing
    enum Network {
        public static let connectionTimeout = TestControlError.networkError("Connection timeout")
        public static let noInternet = TestControlError.networkError("No internet connection")
        public static let serverUnreachable = TestControlError.networkError("Server unreachable")
        public static let invalidResponse = TestControlError.networkError("Invalid response format")
    }

    /// Common validation errors for testing
    enum Validation {
        public static let duplicateKey = TestControlError.validationError("Duplicate key constraint")
        public static let missingField = TestControlError.validationError("Required field missing")
        public static let invalidFormat = TestControlError.validationError("Invalid data format")
        public static let businessRuleViolation = TestControlError.validationError("Business rule violation")
    }

    /// Common persistence errors for testing
    enum Persistence {
        public static let databaseLocked = TestControlError.persistenceError("Database is locked")
        public static let diskFull = TestControlError.persistenceError("Disk space full")
        public static let corruptedData = TestControlError.persistenceError("Data corruption detected")
        public static let migrationFailed = TestControlError.persistenceError("Database migration failed")
    }

    /// Common authentication errors for testing
    enum Authentication {
        public static let invalidCredentials = TestControlError.authenticationError("Invalid credentials")
        public static let sessionExpired = TestControlError.authenticationError("Session expired")
        public static let accountLocked = TestControlError.authenticationError("Account locked")
        public static let permissionDenied = TestControlError.authenticationError("Permission denied")
    }
}
