// AppAlert.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-15 06:53 GMT.

import SwiftUI

/// Model representing an alert that can be presented to the user
///
/// This struct provides a standardized way to define alerts across the application
/// with support for different alert types and actions. It conforms to `Identifiable`
/// for SwiftUI alert binding.
///
/// Example usage:
/// ```swift
/// // Info alert
/// let infoAlert = AppAlert.info(title: "Success", message: "Operation completed")
///
/// // Error alert
/// let errorAlert = AppAlert.error(someError)
///
/// // Confirmation alert
/// let confirmAlert = AppAlert.confirmation(
///     title: "Delete Item",
///     message: "Are you sure you want to delete this item?",
///     onConfirm: { deleteItem() }
/// )
///
/// // Present the alert
/// router.presentAlert(confirmAlert)
/// ```
public struct AppAlert: Identifiable {
    /// Unique identifier for the alert
    public let id = UUID()

    /// The alert title
    public let title: String

    /// The alert message
    public let message: String

    /// The primary action for the alert
    public let primaryAction: AppAlertAction

    /// The secondary action for the alert (optional)
    public let secondaryAction: AppAlertAction?

    /// Initialize an alert with title, message, and actions
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    ///   - primaryAction: The primary action
    ///   - secondaryAction: The secondary action (optional)
    public init(
        title: String,
        message: String,
        primaryAction: AppAlertAction,
        secondaryAction: AppAlertAction? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}

// MARK: - Convenience Initializers

public extension AppAlert {
    /// Create an informational alert with an OK button
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    /// - Returns: An informational alert
    static func info(title: String, message: String) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primaryAction: .default(title: "OK")
        )
    }

    /// Create an error alert from an Error object
    ///
    /// - Parameter error: The error to display
    /// - Returns: An error alert
    static func error(_ error: any Error) -> AppAlert {
        AppAlert(
            title: "Error",
            message: error.localizedDescription,
            primaryAction: .default(title: "OK")
        )
    }

    /// Create an error alert with a custom title and message
    ///
    /// - Parameters:
    ///   - title: The alert title (defaults to "Error")
    ///   - message: The error message
    /// - Returns: An error alert
    static func error(title: String = "Error", message: String) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primaryAction: .default(title: "OK")
        )
    }

    /// Create a confirmation alert with OK/Cancel actions
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    ///   - confirmTitle: The title for the confirm button (defaults to "OK")
    ///   - cancelTitle: The title for the cancel button (defaults to "Cancel")
    ///   - onConfirm: The action to perform when confirmed
    /// - Returns: A confirmation alert
    static func confirmation(
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void
    ) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primaryAction: .default(title: confirmTitle, action: onConfirm),
            secondaryAction: .cancel(title: cancelTitle)
        )
    }

    /// Create a destructive confirmation alert
    ///
    /// - Parameters:
    ///   - title: The alert title
    ///   - message: The alert message
    ///   - destructiveTitle: The title for the destructive button (defaults to "Delete")
    ///   - cancelTitle: The title for the cancel button (defaults to "Cancel")
    ///   - onConfirm: The action to perform when confirmed
    /// - Returns: A destructive confirmation alert
    static func destructiveConfirmation(
        title: String,
        message: String,
        destructiveTitle: String = "Delete",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void
    ) -> AppAlert {
        AppAlert(
            title: title,
            message: message,
            primaryAction: .destructive(title: destructiveTitle, action: onConfirm),
            secondaryAction: .cancel(title: cancelTitle)
        )
    }
}

// MARK: - SwiftUI Integration

public extension AppAlert {
    /// Convert this AppAlert to a SwiftUI Alert
    ///
    /// - Returns: A SwiftUI Alert configured with this alert's properties
    func toSwiftUIAlert() -> Alert {
        if let secondaryAction {
            Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: primaryAction.toSwiftUIButton(),
                secondaryButton: secondaryAction.toSwiftUIButton()
            )
        } else {
            Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: primaryAction.toSwiftUIButton()
            )
        }
    }
}

// MARK: - Equatable Conformance

extension AppAlert: Equatable {
    public static func == (lhs: AppAlert, rhs: AppAlert) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable Conformance

extension AppAlert: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
