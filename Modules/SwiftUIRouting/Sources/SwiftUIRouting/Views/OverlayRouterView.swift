// OverlayRouterView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:56 GMT.

import SwiftUI

/// A view that handles overlay presentation routing
///
/// This view wraps content and provides overlay presentation capabilities
/// using a router that conforms to `AppRouting`. It uses constructor injection
/// for the router dependency and provides smooth animations for overlay transitions.
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @State private var appRouter = AppRouter()
///
///     var body: some View {
///         OverlayRouterView(router: appRouter) {
///             VStack {
///                 Text("Content")
///
///                 Button("Show Loading") {
///                     appRouter.showLoadingOverlay(message: "Please wait...")
///                 }
///
///                 Button("Show Custom Overlay") {
///                     appRouter.showOverlay {
///                         CustomOverlayView()
///                     }
///                 }
///             }
///         }
///     }
/// }
/// ```
public struct OverlayRouterView<Content: View, Router: AppRouting>: View {
    /// The router handling overlay presentations
    @Bindable private var router: Router

    /// The content to wrap with overlay functionality
    private let content: Content

    /// The alignment for overlay presentation
    private let overlayAlignment: Alignment

    /// Initialize an overlay router view
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - overlayAlignment: The alignment for overlay presentation (defaults to center)
    ///   - content: A view builder that creates the wrapped content
    public init(
        router: Router,
        overlayAlignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.router = router
        self.overlayAlignment = overlayAlignment
        self.content = content()
    }

    public var body: some View {
        content
            .overlay(alignment: overlayAlignment) {
                if let overlayView = router.overlayView {
                    overlayView
                        .transition(.overlayTransition)
                        .animation(.overlayAnimation, value: router.overlayView != nil)
                }
            }
    }
}

// MARK: - Animation Extensions

public extension AnyTransition {
    /// The default transition for overlay presentations
    static var overlayTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .scale(scale: 1.1))
        )
    }
}

public extension Animation {
    /// The default animation for overlay presentations
    static var overlayAnimation: Animation {
        .spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.1)
    }
}

// MARK: - Convenience Initializers

public extension OverlayRouterView {
    /// Initialize an overlay router view with top alignment
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - content: A view builder that creates the wrapped content
    static func top(router: Router, @ViewBuilder content: () -> Content) -> OverlayRouterView {
        OverlayRouterView(router: router, overlayAlignment: .top, content: content)
    }

    /// Initialize an overlay router view with bottom alignment
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - content: A view builder that creates the wrapped content
    static func bottom(router: Router, @ViewBuilder content: () -> Content) -> OverlayRouterView {
        OverlayRouterView(router: router, overlayAlignment: .bottom, content: content)
    }

    /// Initialize an overlay router view with leading alignment
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - content: A view builder that creates the wrapped content
    static func leading(router: Router, @ViewBuilder content: () -> Content) -> OverlayRouterView {
        OverlayRouterView(router: router, overlayAlignment: .leading, content: content)
    }

    /// Initialize an overlay router view with trailing alignment
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - content: A view builder that creates the wrapped content
    static func trailing(router: Router, @ViewBuilder content: () -> Content) -> OverlayRouterView {
        OverlayRouterView(router: router, overlayAlignment: .trailing, content: content)
    }
}

// MARK: - Preview Support

#if DEBUG
    #Preview("Overlay Router View") {
        @Previewable @State var appRouter = PreviewAppRouter()

        OverlayRouterView(router: appRouter) {
            VStack(spacing: 20) {
                Text("Overlay Router Demo")
                    .font(.title)

                Button("Show Loading Overlay") {
                    appRouter.showLoadingOverlay(message: "Processing...")

                    // Auto-hide after 3 seconds for demo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        appRouter.hideOverlay()
                    }
                }

                Button("Show Success Message") {
                    appRouter.showTemporaryMessage(
                        "Operation completed successfully!",
                        style: .success
                    )
                }

                Button("Show Error Message") {
                    appRouter.showTemporaryMessage(
                        "Something went wrong. Please try again.",
                        style: .error
                    )
                }

                Button("Show Custom Overlay") {
                    appRouter.showOverlay {
                        VStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.yellow)

                            Text("Custom Overlay")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Button("Dismiss") {
                                appRouter.hideOverlay()
                            }
                            .foregroundStyle(.blue)
                        }
                        .padding(24)
                        .background(Material.thick)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }

                Button("Hide Overlay") {
                    appRouter.hideOverlay()
                }
            }
            .padding()
        }
    }

    /// Preview-only router implementation
    @Observable
    private class PreviewAppRouter: BaseAppRouter {
        // BaseAppRouter provides the implementation
    }
#endif
