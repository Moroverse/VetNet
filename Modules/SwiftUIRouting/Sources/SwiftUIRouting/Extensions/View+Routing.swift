// View+Routing.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import SwiftUI

// MARK: - View Extensions for Routing

public extension View {
    /// Add alert routing capabilities to this view
    ///
    /// This modifier wraps the view with `AlertRouterView` to provide
    /// alert presentation capabilities using the specified router.
    ///
    /// - Parameter router: The router conforming to AppRouting
    /// - Returns: A view with alert routing capabilities
    ///
    /// Example usage:
    /// ```swift
    /// ContentView()
    ///     .alertRouting(router: appRouter)
    /// ```
    func alertRouting(router: some AppRouting) -> some View {
        AlertRouterView(router: router) {
            self
        }
    }

    /// Add overlay routing capabilities to this view
    ///
    /// This modifier wraps the view with `OverlayRouterView` to provide
    /// overlay presentation capabilities using the specified router.
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - alignment: The alignment for overlay presentation (defaults to center)
    /// - Returns: A view with overlay routing capabilities
    ///
    /// Example usage:
    /// ```swift
    /// ContentView()
    ///     .overlayRouting(router: appRouter, alignment: .top)
    /// ```
    func overlayRouting(
        router: some AppRouting,
        alignment: Alignment = .center
    ) -> some View {
        OverlayRouterView(router: router, overlayAlignment: alignment) {
            self
        }
    }

    /// Add both alert and overlay routing capabilities to this view
    ///
    /// This modifier combines both alert and overlay routing in the correct order
    /// for optimal user experience.
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - overlayAlignment: The alignment for overlay presentation (defaults to center)
    /// - Returns: A view with both alert and overlay routing capabilities
    ///
    /// Example usage:
    /// ```swift
    /// ContentView()
    ///     .appRouting(router: appRouter)
    /// ```
    func appRouting(
        router: some AppRouting,
        overlayAlignment: Alignment = .center
    ) -> some View {
        overlayRouting(router: router, alignment: overlayAlignment)
            .alertRouting(router: router)
    }

    /// Add navigation routing capabilities to this view
    ///
    /// This modifier wraps the view with `NavigationRouterView` to provide
    /// navigation stack routing with the specified destination factory.
    ///
    /// - Parameters:
    ///   - router: The router conforming to Router protocol
    ///   - destination: Factory function to create destination views for routes
    /// - Returns: A view with navigation routing capabilities
    ///
    /// Example usage:
    /// ```swift
    /// ContentView()
    ///     .navigationRouting(router: router) { route in
    ///         AnyView(destinationView(for: route))
    ///     }
    /// ```
    func navigationRouting<Router: SwiftUIRouting.Router, Route: Hashable>(
        router: Router,
        @ViewBuilder destination: @escaping (Route) -> AnyView
    ) -> some View {
        NavigationRouterView(router: router) {
            self
        } destination: { route in
            destination(route)
        }
    }
}

// MARK: - Result Handling Extensions

public extension View {
    /// Handle form results from async operations
    ///
    /// This modifier provides a convenient way to handle form results
    /// from async router operations with automatic error handling.
    ///
    /// - Parameters:
    ///   - result: A binding to the optional result
    ///   - onSuccess: Callback for successful results
    ///   - onError: Callback for error results (optional)
    ///   - onCancel: Callback for cancelled results (optional)
    ///
    /// Example usage:
    /// ```swift
    /// ContentView()
    ///     .handleFormResult($formResult) { user in
    ///         // Handle successful user creation/update
    ///         users.append(user)
    ///     } onError: { error in
    ///         // Handle error
    ///         showError(error)
    ///     }
    /// ```
    func handleFormResult<T>(
        _ result: Binding<FormOperationResult<T>?>,
        onSuccess: @escaping (T) -> Void,
        onError: ((any Error) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        onChange(of: result.wrappedValue) { _, newResult in
            guard let newResult else { return }

            switch newResult {
            case let .created(entity), let .updated(entity):
                onSuccess(entity)
            case let .error(error):
                onError?(error)
            case .cancelled:
                onCancel?()
            }

            // Clear the result after handling
            result.wrappedValue = nil
        }
    }

    /// Handle simple operation results
    ///
    /// This modifier provides a convenient way to handle simple operation results
    /// with automatic error handling.
    ///
    /// - Parameters:
    ///   - result: A binding to the optional result
    ///   - onSuccess: Callback for successful results
    ///   - onError: Callback for error results (optional)
    ///   - onCancel: Callback for cancelled results (optional)
    ///
    /// Example usage:
    /// ```swift
    /// ContentView()
    ///     .handleSimpleResult($operationResult) {
    ///         // Handle success
    ///         showSuccess("Operation completed")
    ///     } onError: { error in
    ///         // Handle error
    ///         showError(error)
    ///     }
    /// ```
    func handleSimpleResult(
        _ result: Binding<SimpleOperationResult?>,
        onSuccess: @escaping () -> Void,
        onError: ((any Error) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        onChange(of: result.wrappedValue) { _, newResult in
            guard let newResult else { return }

            switch newResult {
            case .success:
                onSuccess()
            case let .error(error):
                onError?(error)
            case .cancelled:
                onCancel?()
            }

            // Clear the result after handling
            result.wrappedValue = nil
        }
    }
}

// MARK: - Animation Extensions

public extension View {
    /// Apply the standard routing transition animation
    ///
    /// This modifier applies the standard transition animation used
    /// throughout SwiftUIRouting for consistent user experience.
    ///
    /// - Parameter isPresented: Whether the view is currently presented
    /// - Returns: A view with routing transition animation
    func routingTransition(isPresented: Bool) -> some View {
        transition(.routingTransition)
            .animation(.routingAnimation, value: isPresented)
    }

    /// Apply a custom routing transition
    ///
    /// - Parameters:
    ///   - transition: The transition to apply
    ///   - animation: The animation to use
    ///   - isPresented: Whether the view is currently presented
    /// - Returns: A view with custom routing transition
    func routingTransition(
        _ transition: AnyTransition,
        animation: Animation = .routingAnimation,
        isPresented: Bool
    ) -> some View {
        self
            .transition(transition)
            .animation(animation, value: isPresented)
    }
}

// MARK: - Default Routing Animations

public extension AnyTransition {
    /// The standard transition used for routing operations
    static var routingTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .scale(scale: 1.05))
        )
    }

    /// Slide transition for sheet-like presentations
    static var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
}

public extension Animation {
    /// The standard animation used for routing operations
    static var routingAnimation: Animation {
        .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
    }

    /// Quick animation for immediate feedback
    static var quickRouting: Animation {
        .spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.05)
    }

    /// Smooth animation for elegant transitions
    static var smoothRouting: Animation {
        .spring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.2)
    }
}
