// AppRouting.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:51 GMT.

import SwiftUI

/// Protocol for app-level routing including alerts and overlays
///
/// This protocol extends the base `Router` protocol to provide app-level
/// navigation capabilities such as alert presentations and overlay management.
/// These are typically global UI elements that can be triggered from anywhere
/// in the application.
///
/// Example implementation:
/// ```swift
/// @Observable
/// class AppRouter: BaseAppRouter, AppRouting {
///
///     func showSuccess(message: String) {
///         presentAlert(.info(title: "Success", message: message))
///     }
///
///     func showError(_ error: Error) {
///         presentAlert(.error(error))
///     }
///
///     func showLoading(message: String = "Loading...") {
///         showOverlay {
///             LoadingView(message: message)
///         }
///     }
/// }
/// ```
@MainActor
public protocol AppRouting: Router {
    /// The currently presented alert, if any
    ///
    /// This property is used for SwiftUI alert binding and should be
    /// set when presenting an alert and cleared when dismissing.
    var presentedAlert: AppAlert? { get set }

    /// The currently presented overlay view, if any
    ///
    /// This property holds the overlay content and should be
    /// set when showing an overlay and cleared when hiding.
    var overlayView: AnyView? { get set }

    // MARK: - Alert Methods

    /// Present an alert to the user
    ///
    /// - Parameter alert: The alert to present
    func presentAlert(_ alert: AppAlert)

    /// Dismiss the currently presented alert
    func dismissAlert()

    // MARK: - Overlay Methods

    /// Show an overlay with custom content
    ///
    /// - Parameter content: A view builder that creates the overlay content
    func showOverlay(@ViewBuilder content: () -> some View)

    /// Hide the currently presented overlay
    func hideOverlay()
}

/// Default implementations for AppRouting
public extension AppRouting {
    /// Present an alert to the user
    func presentAlert(_ alert: AppAlert) {
        presentedAlert = alert
    }

    /// Dismiss the currently presented alert
    func dismissAlert() {
        presentedAlert = nil
    }

    /// Show an overlay with custom content
    func showOverlay(@ViewBuilder content: () -> some View) {
        overlayView = AnyView(content())
    }

    /// Hide the currently presented overlay
    func hideOverlay() {
        overlayView = nil
    }

    // MARK: - Convenience Methods

    /// Show a loading overlay with a message
    ///
    /// - Parameter message: The loading message to display
    func showLoadingOverlay(message: String = "Loading...") {
        showOverlay {
            LoadingOverlayView(message: message)
        }
    }

    /// Show an info alert
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    func showInfo(title: String, message: String) {
        presentAlert(.info(title: title, message: message))
    }

    /// Show an error alert
    ///
    /// - Parameter error: The error to display
    func showError(_ error: any Error) {
        presentAlert(.error(error))
    }

    /// Show a confirmation alert
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    ///   - onConfirm: Callback called when user confirms
    func showConfirmation(title: String, message: String, onConfirm: @escaping () -> Void) {
        presentAlert(.confirmation(title: title, message: message, onConfirm: onConfirm))
    }
}

// MARK: - Internal Loading Overlay View

/// Internal loading overlay view used by the convenience method
private struct LoadingOverlayView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)

            Text(message)
                .foregroundStyle(.white)
                .font(.body)
        }
        .padding(24)
        .background(Material.thick)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
