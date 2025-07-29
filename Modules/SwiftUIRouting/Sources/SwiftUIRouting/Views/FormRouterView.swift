// FormRouterView.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:57 GMT.

import SwiftUI

/// A generic view that handles form presentation routing
///
/// This view wraps content and provides form presentation capabilities using a router
/// that conforms to `FormRouting`. It handles both navigation stack and modal sheet
/// presentations based on the presentation style.
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @State private var userRouter = UserRouter()
///
///     var body: some View {
///         FormRouterView(router: userRouter) {
///             UserListView()
///         } formContent: { mode in
///             AnyView(UserFormView(mode: mode) { result in
///                 userRouter.handleResult(result)
///             })
///         }
///     }
/// }
/// ```
public struct FormRouterView<FormContent: View, Content: View, Router: FormRouting>: View {
    /// The router handling form presentations
    @Bindable private var router: Router

    /// The main content to display
    private let content: Content

    /// Factory function to create form content for a given mode
    private let formContent: (Router.FormMode) -> FormContent

    /// The presentation style for forms
    private let presentationStyle: FormPresentationStyle

    /// Initialize a form router view
    ///
    /// - Parameters:
    ///   - router: The router conforming to FormRouting
    ///   - presentationStyle: How forms should be presented (defaults to .sheet)
    ///   - content: A view builder that creates the main content
    ///   - formContent: A factory function that creates form content for a given mode
    public init(
        router: Router,
        presentationStyle: FormPresentationStyle = .sheet,
        @ViewBuilder content: () -> Content,
        @ViewBuilder formContent: @escaping (Router.FormMode) -> FormContent
    ) {
        self.router = router
        self.presentationStyle = presentationStyle
        self.content = content()
        self.formContent = formContent
    }

    public var body: some View {
        switch presentationStyle {
        case .sheet:
            sheetPresentationView
        case .navigation:
            navigationPresentationView
        case .fullScreenCover:
            fullScreenCoverPresentationView
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var sheetPresentationView: some View {
        NavigationStack(path: $router.navigationPath) {
            content
        }
        .sheet(item: $router.presentedForm) { mode in
            NavigationStack {
                formContent(mode)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                handleCancellation()
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var navigationPresentationView: some View {
        NavigationStack(path: $router.navigationPath) {
            content
                .navigationDestination(for: Router.FormMode.self) { mode in
                    formContent(mode)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    handleCancellation()
                                }
                            }
                        }
                }
        }
    }

    @ViewBuilder
    private var fullScreenCoverPresentationView: some View {
        NavigationStack(path: $router.navigationPath) {
            content
        }
        #if os(iOS) || os(tvOS) || os(visionOS)
        .fullScreenCover(item: $router.presentedForm) { mode in
            NavigationStack {
                formContent(mode)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                handleCancellation()
                            }
                        }
                    }
            }
        }
        #elseif os(macOS)
        .sheet(item: $router.presentedForm) { mode in
            NavigationStack {
                formContent(mode)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                handleCancellation()
                            }
                        }
                    }
            }
        }
        #endif
    }

    // MARK: - Private Methods

    private func handleCancellation() {
        // We need to create a cancelled result, but the exact type depends on the router
        // This is handled by the specific router implementation through handleResult
        router.dismissForm()
    }
}

// MARK: - Form Presentation Style

/// The style used for presenting forms
public enum FormPresentationStyle {
    /// Present forms as modal sheets (default)
    case sheet

    /// Present forms by pushing to navigation stack
    case navigation

    /// Present forms as full-screen covers
    case fullScreenCover
}

// MARK: - Convenience Initializers

public extension FormRouterView {
    /// Initialize with sheet presentation style
    ///
    /// - Parameters:
    ///   - router: The router conforming to FormRouting
    ///   - content: A view builder that creates the main content
    ///   - formContent: A factory function that creates form content
    static func sheet(
        router: Router,
         @ViewBuilder content: () -> Content,
        @ViewBuilder formContent: @escaping (Router.FormMode) -> FormContent
    ) -> FormRouterView {
        FormRouterView(
            router: router,
            presentationStyle: .sheet,
            content: content,
            formContent: formContent
        )
    }

    /// Initialize with navigation presentation style
    ///
    /// - Parameters:
    ///   - router: The router conforming to FormRouting
    ///   - content: A view builder that creates the main content
    ///   - formContent: A factory function that creates form content
    static func navigation(
        router: Router,
        @ViewBuilder content: () -> Content,
        @ViewBuilder formContent: @escaping (Router.FormMode) -> FormContent
    ) -> FormRouterView {
        FormRouterView(
            router: router,
            presentationStyle: .navigation,
            content: content,
            formContent: formContent
        )
    }

    /// Initialize with full-screen cover presentation style
    ///
    /// - Parameters:
    ///   - router: The router conforming to FormRouting
    ///   - content: A view builder that creates the main content
    ///   - formContent: A factory function that creates form content
    static func fullScreenCover(
        router: Router,
        @ViewBuilder content: () -> Content,
        @ViewBuilder formContent: @escaping (Router.FormMode) -> FormContent
    ) -> FormRouterView {
        FormRouterView(
            router: router,
            presentationStyle: .fullScreenCover,
            content: content,
            formContent: formContent
        )
    }
}

// MARK: - Preview Support

#if DEBUG
    // Preview types
    enum PreviewFormMode: String, Identifiable, CaseIterable, Hashable {
        case create
        case edit

        var id: String { rawValue }

        var title: String {
            switch self {
            case .create: "Create Item"
            case .edit: "Edit Item"
            }
        }
    }

    enum PreviewFormResult: RouteResult {
        case created(String)
        case updated(String)
        case cancelled
        case error(any Error)

        typealias SuccessType = String
        typealias ErrorType = Error

        var isSuccess: Bool {
            switch self {
            case .created, .updated: true
            case .cancelled, .error: false
            }
        }

        var isCancelled: Bool {
            if case .cancelled = self { return true }
            return false
        }

        var isError: Bool {
            if case .error = self { return true }
            return false
        }

        var error: (any Error)? {
            if case let .error(error) = self { return error }
            return nil
        }
    }

    @Observable
    class PreviewFormRouter: BaseFormRouter<PreviewFormMode, PreviewFormResult> {
        func createItem() async -> PreviewFormResult {
            await presentForm(.create)
        }

        func editItem() async -> PreviewFormResult {
            await presentForm(.edit)
        }
    }

    #Preview("Form Router View - Sheet") {
        @Previewable @State var router = PreviewFormRouter()

        FormRouterView.sheet(router: router) {
            VStack(spacing: 20) {
                Text("Form Router Demo")
                    .font(.title)

                Button("Create Item") {
                    Task {
                        let result = await router.createItem()
                        print("Create result: \(result)")
                    }
                }

                Button("Edit Item") {
                    Task {
                        let result = await router.editItem()
                        print("Edit result: \(result)")
                    }
                }
            }
            .padding()
        } formContent: { mode in
            AnyView(
                VStack(spacing: 20) {
                    Text(mode.title)
                        .font(.title2)

                    Text("This is a \(mode.rawValue) form")
                        .foregroundStyle(.secondary)

                    VStack(spacing: 16) {
                        Button("Save") {
                            let result: PreviewFormResult = mode == .create
                                ? .created("New Item")
                                : .updated("Updated Item")
                            router.handleResult(result)
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancel") {
                            router.handleResult(.cancelled)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            )
        }
    }

    #Preview("Form Router View - Navigation") {
        @Previewable @State var router = PreviewFormRouter()

        FormRouterView.navigation(router: router) {
            VStack(spacing: 20) {
                Text("Navigation Form Router")
                    .font(.title)

                Button("Create Item (Navigation)") {
                    router.presentForm(.create)
                }

                Button("Edit Item (Navigation)") {
                    router.presentForm(.edit)
                }
            }
            .padding()
        } formContent: { mode in
            AnyView(
                VStack(spacing: 20) {
                    Text(mode.title)
                        .font(.title2)

                    Text("Navigation-based form")
                        .foregroundStyle(.secondary)

                    Button("Done") {
                        router.dismissForm()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            )
        }
    }
#endif
