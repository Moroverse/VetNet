// NavigationRouterView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:58 GMT.

import SwiftUI

/// A view that provides navigation stack routing capabilities
///
/// This view wraps content in a NavigationStack and binds it to a router's
/// navigation path. It provides type-safe navigation using any Hashable route type.
///
/// Example usage:
/// ```swift
/// enum AppRoute: Hashable {
///     case profile
///     case settings
///     case detail(String)
/// }
///
/// struct ContentView: View {
///     @State private var router = AppRouter()
///
///     var body: some View {
///         NavigationRouterView(router: router) {
///             HomeView()
///         } destination: { route in
///             switch route {
///             case .profile:
///                 ProfileView()
///             case .settings:
///                 SettingsView()
///             case .detail(let id):
///                 DetailView(id: id)
///             }
///         }
///     }
/// }
/// ```
public struct NavigationRouterView<Destination: View, Content: View, Router: SwiftUIRouting.Router, Route: Hashable>: View {
    /// The router managing navigation state
    @Bindable private var router: Router

    /// The root content of the navigation stack
    private let content: Content

    /// Factory function to create destination views for routes
    private let destination: (Route) -> Destination

    /// Initialize a navigation router view
    ///
    /// - Parameters:
    ///   - router: The router conforming to Router protocol
    ///   - content: A view builder that creates the root content
    ///   - destination: A factory function that creates destination views for routes
    public init(
        router: Router,
        @ViewBuilder content: () -> Content,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.router = router
        self.content = content()
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $router.navigationPath) {
            content
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                }
        }
    }
}

// MARK: - Preview Support

#if DEBUG
    // Preview route types
    enum PreviewRoute: String, Hashable, CaseIterable {
        case profile
        case settings
        case detail

        var title: String {
            switch self {
            case .profile: "Profile"
            case .settings: "Settings"
            case .detail: "Detail"
            }
        }
    }

    @Observable
    class PreviewRouter: Router {
        var navigationPath = NavigationPath()
    }

    #Preview("Navigation Router View") {
        @Previewable @State var router = PreviewRouter()

        NavigationRouterView(router: router) {
            VStack(spacing: 20) {
                Text("Navigation Demo")
                    .font(.title)

                ForEach(PreviewRoute.allCases, id: \.self) { route in
                    Button("Go to \(route.title)") {
                        router.navigate(to: route)
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !router.isAtRoot {
                    Button("Go to Root") {
                        router.goToRoot()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Home")
        } destination: { (route: PreviewRoute) in
            VStack(spacing: 20) {
                Text(route.title)
                    .font(.title)

                Text("This is the \(route.title.lowercased()) view")
                    .foregroundStyle(.secondary)

                Button("Go Back") {
                    router.dismissCurrentView()
                }
                .buttonStyle(.bordered)

                if route != .detail {
                    Button("Go to Detail") {
                        router.navigate(to: PreviewRoute.detail)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle(route.title)
        }
    }
#endif
