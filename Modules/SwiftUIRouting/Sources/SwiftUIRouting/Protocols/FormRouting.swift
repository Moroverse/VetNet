// FormRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:50 GMT.

import SwiftUI

/// Protocol for routers that handle form-based navigation with result handling
///
/// This protocol extends the base `Router` protocol to provide form-specific
/// routing capabilities including modal presentations and bidirectional result handling.
/// It supports both async/await patterns and callback-based patterns for maximum flexibility.
///
/// Example implementation:
/// ```swift
/// enum UserFormMode: Identifiable {
///     case create
///     case edit(User.ID)
///
///     var id: String {
///         switch self {
///         case .create: return "create"
///         case .edit(let id): return "edit-\(id)"
///         }
///     }
/// }
///
/// @Observable
/// class UserRouter: BaseFormRouter<UserFormMode, UserFormResult>, FormRouting {
///
///     func createUser() async -> UserFormResult {
///         return await presentForm(.create)
///     }
///
///     func editUser(_ id: User.ID) async -> UserFormResult {
///         return await presentForm(.edit(id))
///     }
/// }
/// ```
@MainActor
public protocol FormRouting: Router {
    /// The type representing different form modes (create, edit, etc.)
    /// Must conform to `Identifiable` for SwiftUI sheet binding
    associatedtype FormMode: Identifiable, Hashable

    /// The result type returned by form operations
    associatedtype FormResult: RouteResult

    /// The currently presented form mode, if any
    ///
    /// This property is used for SwiftUI sheet binding and should be
    /// set when presenting a form and cleared when dismissing.
    var presentedForm: FormMode? { get set }

    // MARK: - Async Methods

    /// Present a form and wait for its result asynchronously
    ///
    /// This method uses Swift's async/await pattern to present a form
    /// and suspend execution until a result is provided via `handleResult(_:)`.
    ///
    /// - Parameter mode: The form mode to present
    /// - Returns: The result of the form operation
    ///
    /// Example usage:
    /// ```swift
    /// let result = await router.presentForm(.create)
    /// switch result {
    /// case .created(let user):
    ///     // Handle successful creation
    /// case .cancelled:
    ///     // Handle cancellation
    /// case .error(let error):
    ///     // Handle error
    /// }
    /// ```
    func presentForm(_ mode: FormMode) async -> FormResult

    // MARK: - Callback Methods

    /// Present a form with a callback for the result
    ///
    /// This method provides a callback-based alternative to the async version,
    /// useful in contexts where async/await is not appropriate.
    ///
    /// - Parameters:
    ///   - mode: The form mode to present
    ///   - onResult: Callback called when a result is available
    ///
    /// Example usage:
    /// ```swift
    /// router.presentForm(.create) { result in
    ///     switch result {
    ///     case .created(let user):
    ///         // Handle successful creation
    ///     case .cancelled:
    ///         // Handle cancellation
    ///     case .error(let error):
    ///         // Handle error
    ///     }
    /// }
    /// ```
    func presentForm(_ mode: FormMode, onResult: @escaping (FormResult) -> Void)

    // MARK: - Result Handling

    /// Handle a result from a form operation
    ///
    /// This method should be called by form views to provide results
    /// back to the router. It will resume any awaiting async operations
    /// and call any registered callbacks.
    ///
    /// - Parameter result: The result to handle
    func handleResult(_ result: FormResult)
}

/// Default implementations for FormRouting
public extension FormRouting {
    /// Present a form without result handling (legacy compatibility)
    func presentForm(_ mode: FormMode) {
        presentedForm = mode
    }

    /// Dismiss the currently presented form
    func dismissForm() {
        presentedForm = nil
    }
}
