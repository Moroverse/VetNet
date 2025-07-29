// AlertRouterView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:56 GMT.

import SwiftUI

/// A view that handles alert presentation routing
///
/// This view wraps content and provides alert presentation capabilities
/// using a router that conforms to `AppRouting`. It uses constructor injection
/// for the router dependency, making it independent of any specific DI framework.
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @State private var appRouter = AppRouter()
///
///     var body: some View {
///         AlertRouterView(router: appRouter) {
///             VStack {
///                 Text("Content")
///
///                 Button("Show Alert") {
///                     appRouter.showInfo(title: "Info", message: "Hello!")
///                 }
///             }
///         }
///     }
/// }
/// ```
public struct AlertRouterView<Content: View, Router: AppRouting>: View {
    /// The router handling 3alert presentations
    @Bindable private var router: Router

    /// The content to wrap with alert functionality
    private let content: Content

    /// Initialize an alert router view
    ///
    /// - Parameters:
    ///   - router: The router conforming to AppRouting
    ///   - content: A view builder that creates the wrapped content
    public init(router: Router, @ViewBuilder content: () -> Content) {
        self.router = router
        self.content = content()
    }

    public var body: some View {
        content
            .alert(item: $router.presentedAlert) { alert in
                alert.toSwiftUIAlert()
            }
    }
}

// MARK: - Preview Support

#if DEBUG
    #Preview("Alert Router View") {
        @Previewable @State var appRouter = PreviewAppRouter()

        AlertRouterView(router: appRouter) {
            VStack(spacing: 20) {
                Text("Alert Router Demo")
                    .font(.title)

                Button("Show Info Alert") {
                    appRouter.presentAlert(.info(
                        title: "Information",
                        message: "This is an informational alert."
                    ))
                }

                Button("Show Error Alert") {
                    appRouter.presentAlert(.error(
                        title: "Error",
                        message: "Something went wrong!"
                    ))
                }

                Button("Show Confirmation Alert") {
                    appRouter.presentAlert(.confirmation(
                        title: "Confirm Action",
                        message: "Are you sure you want to proceed?",
                        onConfirm: {
                            print("User confirmed")
                        }
                    ))
                }

                Button("Show Destructive Alert") {
                    appRouter.presentAlert(.destructiveConfirmation(
                        title: "Delete Item",
                        message: "This action cannot be undone.",
                        onConfirm: {
                            print("User confirmed deletion")
                        }
                    ))
                }
            }
            .padding()
        }
    }

    /// Preview-only router implementation
    @Observable
    private class PreviewAppRouter: AppRouting {
        var navigationPath = NavigationPath()
        var presentedAlert: AppAlert?
        var overlayView: AnyView?
    }
#endif
