// Router.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import SwiftUI

/// Base protocol for all routers providing navigation and dismissal capabilities
///
/// This protocol defines the fundamental navigation operations that all routers should support.
/// It uses SwiftUI's `NavigationPath` for type-safe navigation and requires conformance to
/// `Observable` for SwiftUI integration.
///
/// Example implementation:
/// ```swift
/// @Observable
/// class MyRouter: Router {
///     var navigationPath = NavigationPath()
///
///     func goToRoot() {
///         navigationPath = NavigationPath()
///     }
///
///     func dismissCurrentView() {
///         if !navigationPath.isEmpty {
///             navigationPath.removeLast()
///         }
///     }
/// }
/// ```
@MainActor
public protocol Router: AnyObject, Observable {
    /// The current navigation path for the router
    ///
    /// This path represents the current navigation stack state and should be
    /// bound to a `NavigationStack` in your SwiftUI views.
    var navigationPath: NavigationPath { get set }

    /// Navigate to the root of the navigation stack
    ///
    /// This method clears the entire navigation path, returning the user
    /// to the root view of the navigation hierarchy.
    func goToRoot()

    /// Dismiss the current view in the navigation stack
    ///
    /// This method removes the last item from the navigation path,
    /// effectively going back one level in the navigation hierarchy.
    /// If the path is empty, this method should have no effect.
    func dismissCurrentView()
}

/// Default implementations for common Router operations
public extension Router {
    /// Navigate to the root of the navigation stack
    func goToRoot() {
        navigationPath = NavigationPath()
    }

    /// Dismiss the current view in the navigation stack
    func dismissCurrentView() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    /// Navigate to a specific route
    ///
    /// - Parameter route: The route to navigate to
    func navigate(to route: some Hashable) {
        navigationPath.append(route)
    }

    /// Check if the navigation stack is empty
    var isAtRoot: Bool {
        navigationPath.isEmpty
    }

    /// Get the current depth of the navigation stack
    var navigationDepth: Int {
        navigationPath.count
    }
}
