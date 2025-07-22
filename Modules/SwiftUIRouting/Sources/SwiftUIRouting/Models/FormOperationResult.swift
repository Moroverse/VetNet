// FormOperationResult.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import Foundation

/// Generic result type for CRUD form operations
///
/// This enum provides a standardized way to handle results from form operations
/// such as creating, updating, or managing entities. It conforms to `RouteResult`
/// to enable bidirectional routing patterns.
///
/// Example usage:
/// ```swift
/// enum UserFormResult {
///     case created(User)
///     case updated(User)
///     case cancelled
///     case error(Error)
/// }
///
/// extension UserFormResult: RouteResult {
///     typealias SuccessType = User
///     typealias ErrorType = Error
///     // ... implement required properties
/// }
/// ```
///
/// Or use the generic version directly:
/// ```swift
/// typealias UserFormResult = FormOperationResult<User>
/// ```
public enum FormOperationResult<EntityType>: RouteResult where EntityType: Equatable {
    /// The entity was successfully created
    case created(EntityType)

    /// The entity was successfully updated
    case updated(EntityType)

    /// The operation was cancelled by the user
    case cancelled

    /// The operation failed with an error
    case error(any Error)

    // MARK: - RouteResult Conformance

    public typealias SuccessType = EntityType
    public typealias ErrorType = Error

    /// Whether this result represents a successful operation
    public var isSuccess: Bool {
        switch self {
        case .created, .updated:
            true
        case .cancelled, .error:
            false
        }
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

    // MARK: - Convenience Properties

    /// Whether this result represents a creation operation
    public var isCreated: Bool {
        if case .created = self {
            return true
        }
        return false
    }

    /// Whether this result represents an update operation
    public var isUpdated: Bool {
        if case .updated = self {
            return true
        }
        return false
    }

    /// Extract the entity from the result, if present
    public var entity: EntityType? {
        switch self {
        case let .created(entity), let .updated(entity):
            entity
        case .cancelled, .error:
            nil
        }
    }
}

// MARK: - Equatable Conformance

extension FormOperationResult: Equatable where EntityType: Equatable {
    public static func == (lhs: FormOperationResult<EntityType>, rhs: FormOperationResult<EntityType>) -> Bool {
        switch (lhs, rhs) {
        case let (.created(lhsEntity), .created(rhsEntity)):
            lhsEntity == rhsEntity
        case let (.updated(lhsEntity), .updated(rhsEntity)):
            lhsEntity == rhsEntity
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

extension FormOperationResult: Hashable where EntityType: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .created(entity):
            hasher.combine("created")
            hasher.combine(entity)

        case let .updated(entity):
            hasher.combine("updated")
            hasher.combine(entity)

        case .cancelled:
            hasher.combine("cancelled")

        case let .error(error):
            hasher.combine("error")
            hasher.combine(error.localizedDescription)
        }
    }
}

// MARK: - CustomStringConvertible Conformance

extension FormOperationResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .created(entity):
            "FormOperationResult.created(\(entity))"
        case let .updated(entity):
            "FormOperationResult.updated(\(entity))"
        case .cancelled:
            "FormOperationResult.cancelled"
        case let .error(error):
            "FormOperationResult.error(\(error.localizedDescription))"
        }
    }
}
