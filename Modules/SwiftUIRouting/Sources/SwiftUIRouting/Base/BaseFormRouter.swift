// BaseFormRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import SwiftUI

/// Base implementation of a form router with async/await and callback support
///
/// This class provides a complete implementation of the `FormRouting` protocol
/// with support for both async/await patterns and callback-based patterns.
/// It handles continuation management, result processing, and proper cleanup.
///
/// Example usage:
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
/// class UserRouter: BaseFormRouter<UserFormMode, UserFormResult> {
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
@Observable @MainActor
open class BaseFormRouter<FormMode: Identifiable, FormResult: RouteResult>: @MainActor FormRouting where FormMode: Hashable {
    // MARK: - Router Properties

    /// The current navigation path for the router
    public var navigationPath = NavigationPath()

    /// The currently presented form mode, if any
    public var presentedForm: FormMode?

    // MARK: - Private Properties

    /// Continuation for async operations
    private var resultContinuation: CheckedContinuation<FormResult, Never>?

    /// Callback for non-async operations
    private var resultCallback: ((FormResult) -> Void)?

    /// Set to track active continuations to prevent memory leaks
    private var activeContinuations: Set<UUID> = []

    // MARK: - Initialization

    /// Initialize a new form router
    public init() {}

    // MARK: - FormRouting Implementation

    /// Present a form and wait for its result asynchronously
    ///
    /// This method uses Swift's async/await pattern to present a form
    /// and suspend execution until a result is provided via `handleResult(_:)`.
    ///
    /// - Parameter mode: The form mode to present
    /// - Returns: The result of the form operation
    public func presentForm(_ mode: FormMode) async -> FormResult {
        // Clean up any existing continuation
        cleanupContinuation()

        let continuationId = UUID()

        return await withCheckedContinuation { continuation in
            self.resultContinuation = continuation
            self.activeContinuations.insert(continuationId)
            self.presentedForm = mode
        }
    }

    /// Present a form with a callback for the result
    ///
    /// This method provides a callback-based alternative to the async version,
    /// useful in contexts where async/await is not appropriate.
    ///
    /// - Parameters:
    ///   - mode: The form mode to present
    ///   - onResult: Callback called when a result is available
    public func presentForm(_ mode: FormMode, onResult: @escaping (FormResult) -> Void) {
        // Clean up any existing callback
        cleanupCallback()

        resultCallback = onResult
        presentedForm = mode
    }

    /// Handle a result from a form operation
    ///
    /// This method should be called by form views to provide results
    /// back to the router. It will resume any awaiting async operations
    /// and call any registered callbacks.
    ///
    /// - Parameter result: The result to handle
    public func handleResult(_ result: FormResult) {
        // Resume async continuation if present
        if let continuation = resultContinuation {
            let resultToSend = result
            Task {
                continuation.resume(returning: resultToSend)
            }
            cleanupContinuation()
        }

        // Call callback if present
        if let callback = resultCallback {
            callback(result)
            cleanupCallback()
        }

        // Dismiss the form
        presentedForm = nil
    }

    // MARK: - Private Methods

    /// Clean up the current continuation
    private func cleanupContinuation() {
        resultContinuation = nil
        activeContinuations.removeAll()
    }

    /// Clean up the current callback
    private func cleanupCallback() {
        resultCallback = nil
    }

    // MARK: - Deinitializer

    deinit {
        // Cannot access @MainActor-isolated properties here. Ensure cleanup via cancelActiveOperations():
//        // Resume any pending continuations with a cancelled result
//        if let continuation = resultContinuation {
//            // We need to create a cancelled result, but we don't know the specific FormResult type
//            // This should be handled by the specific router implementation
//            cleanupContinuation()
//        }
//        cleanupCallback()
    }
}

// MARK: - Memory Management Extensions

public extension BaseFormRouter {
    /// Check if there are any active async operations
    var hasActiveOperations: Bool {
        resultContinuation != nil || resultCallback != nil
    }

    /// Cancel any active operations
    ///
    /// This method cancels any pending async operations or callbacks.
    /// It's useful for cleanup when the router is being deallocated
    /// or when you need to cancel ongoing operations.
    func cancelActiveOperations() {
        cleanupContinuation()
        cleanupCallback()
        presentedForm = nil
    }
}

// MARK: - Debug Extensions

#if DEBUG
    public extension BaseFormRouter {
        /// Debug information about the router state
        var debugInfo: String {
            var info = ["BaseFormRouter Debug Info:"]
            info.append("- Navigation depth: \(navigationPath.count)")
            info.append("- Presented form: \(String(describing: presentedForm?.id))")
            info.append("- Has continuation: \(resultContinuation != nil)")
            info.append("- Has callback: \(resultCallback != nil)")
            info.append("- Active continuations: \(activeContinuations.count)")
            return info.joined(separator: "\n")
        }
    }
#endif
