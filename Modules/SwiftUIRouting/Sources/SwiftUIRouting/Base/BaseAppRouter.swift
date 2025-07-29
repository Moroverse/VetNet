// BaseAppRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:55 GMT.

import SwiftUI

/// Base implementation of an app-level router for alerts and overlays
///
/// This class provides a complete implementation of the `AppRouting` protocol
/// with support for alert presentations, overlay management, and navigation.
/// It serves as the foundation for app-level routing concerns.
///
/// Example usage:
/// ```swift
/// @Observable
/// class AppRouter: BaseAppRouter {
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
///         showLoadingOverlay(message: message)
///     }
/// }
/// ```
@Observable @MainActor
open class BaseAppRouter: @MainActor AppRouting {
    // MARK: - Router Properties

    /// The current navigation path for the router
    public var navigationPath = NavigationPath()

    /// The currently presented alert, if any
    public var presentedAlert: AppAlert?

    /// The currently presented overlay view, if any
    public var overlayView: AnyView?

    // MARK: - Private Properties

    /// Task for auto-dismissing alerts (if needed)
    @ObservationIgnored private nonisolated(unsafe) var alertDismissTask: Task<Void, Never>?

    /// Task for auto-dismissing overlays (if needed)
    @ObservationIgnored private nonisolated(unsafe) var overlayDismissTask: Task<Void, Never>?

    // MARK: - Initialization

    /// Initialize a new app router
    public init() {}

    // MARK: - Alert Management

    /// Present an alert to the user
    ///
    /// - Parameter alert: The alert to present
    public func presentAlert(_ alert: AppAlert) {
        // Cancel any existing task
        alertDismissTask?.cancel()
        alertDismissTask = nil

        presentedAlert = alert
    }

    /// Dismiss the currently presented alert
    public func dismissAlert() {
        alertDismissTask?.cancel()
        alertDismissTask = nil
        presentedAlert = nil
    }

    /// Present an alert with auto-dismiss after a delay
    ///
    /// - Parameters:
    ///   - alert: The alert to present
    ///   - delay: The delay in seconds before auto-dismissing
    public func presentAlert(_ alert: AppAlert, autoDismissAfter delay: TimeInterval) {
        presentAlert(alert)

        alertDismissTask?.cancel()
        alertDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            await MainActor.run { self?.dismissAlert() }
        }
    }

    // MARK: - Overlay Management

    /// Show an overlay with custom content
    ///
    /// - Parameter content: A view builder that creates the overlay content
    public func showOverlay(@ViewBuilder content: () -> some View) {
        // Cancel any existing task
        overlayDismissTask?.cancel()
        overlayDismissTask = nil

        overlayView = AnyView(content())
    }

    /// Hide the currently presented overlay
    public func hideOverlay() {
        overlayDismissTask?.cancel()
        overlayDismissTask = nil
        overlayView = nil
    }

    /// Show an overlay with auto-dismiss after a delay
    ///
    /// - Parameters:
    ///   - delay: The delay in seconds before auto-dismissing
    ///   - content: A view builder that creates the overlay content
    public func showOverlay(
        autoDismissAfter delay: TimeInterval,
        @ViewBuilder content: () -> some View
    ) {
        showOverlay(content: content)

        overlayDismissTask?.cancel()
        overlayDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            await MainActor.run { self?.hideOverlay() }
        }
    }

    // MARK: - Deinitializer

    deinit {
        alertDismissTask?.cancel()
        overlayDismissTask?.cancel()
    }
}

// MARK: - Enhanced Convenience Methods

public extension BaseAppRouter {
    /// Show a success alert with auto-dismiss
    ///
    /// - Parameters:
    ///   - title: The alert title (defaults to "Success")
    ///   - message: The success message
    ///   - autoDismiss: Whether to auto-dismiss after 2 seconds
    func showSuccess(title: String = "Success", message: String, autoDismiss: Bool = true) {
        let alert = AppAlert.info(title: title, message: message)
        if autoDismiss {
            presentAlert(alert, autoDismissAfter: 2.0)
        } else {
            presentAlert(alert)
        }
    }

    /// Show a warning alert
    ///
    /// - Parameters:
    ///   - title: The alert title (defaults to "Warning")
    ///   - message: The warning message
    func showWarning(title: String = "Warning", message: String) {
        presentAlert(.error(title: title, message: message))
    }

    /// Show a loading overlay with progress
    ///
    /// - Parameters:
    ///   - message: The loading message
    ///   - showProgress: Whether to show a progress indicator
    func showLoadingOverlay(message: String = "Loading...", showProgress: Bool = true) {
        showOverlay {
            LoadingOverlayView(message: message, showProgress: showProgress)
        }
    }

    /// Show a temporary overlay message
    ///
    /// - Parameters:
    ///   - message: The message to display
    ///   - duration: How long to show the message (defaults to 2 seconds)
    ///   - style: The message style
    func showTemporaryMessage(
        _ message: String,
        duration: TimeInterval = 2.0,
        style: TemporaryMessageStyle = .info
    ) {
        showOverlay(autoDismissAfter: duration) {
            TemporaryMessageView(message: message, style: style)
        }
    }
}

// MARK: - Temporary Message Style

public enum TemporaryMessageStyle {
    case info
    case success
    case warning
    case error

    var backgroundColor: Color {
        switch self {
        case .info: .blue
        case .success: .green
        case .warning: .orange
        case .error: .red
        }
    }

    var iconName: String {
        switch self {
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.circle.fill"
        }
    }
}

// MARK: - Internal Overlay Views

/// Internal loading overlay view
private struct LoadingOverlayView: View {
    let message: String
    let showProgress: Bool

    var body: some View {
        VStack(spacing: 16) {
            if showProgress {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
            }

            Text(message)
                .foregroundStyle(.white)
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(Material.thick)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

/// Internal temporary message view
private struct TemporaryMessageView: View {
    let message: String
    let style: TemporaryMessageStyle

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: style.iconName)
                .foregroundStyle(.white)
                .font(.title2)

            Text(message)
                .foregroundStyle(.white)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(style.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - State Management Extensions

public extension BaseAppRouter {
    /// Check if any UI elements are currently presented
    var hasActivePresentation: Bool {
        presentedAlert != nil || overlayView != nil
    }

    /// Dismiss all currently presented UI elements
    func dismissAll() {
        dismissAlert()
        hideOverlay()
    }

    /// Check if an alert is currently presented
    var isShowingAlert: Bool {
        presentedAlert != nil
    }

    /// Check if an overlay is currently presented
    var isShowingOverlay: Bool {
        overlayView != nil
    }
}

// MARK: - Debug Extensions

#if DEBUG
    public extension BaseAppRouter {
        /// Debug information about the router state
        var debugInfo: String {
            var info = ["BaseAppRouter Debug Info:"]
            info.append("- Navigation depth: \(navigationPath.count)")
            info.append("- Has alert: \(presentedAlert != nil)")
            info.append("- Has overlay: \(overlayView != nil)")
            info.append("- Alert task active: \(alertDismissTask != nil)")
            info.append("- Overlay task active: \(overlayDismissTask != nil)")
            return info.joined(separator: "\n")
        }
    }
#endif
