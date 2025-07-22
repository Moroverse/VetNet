// AppAlertAction.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:52 GMT.

import SwiftUI

/// Model representing an action that can be performed in an alert
///
/// This struct provides a standardized way to define alert actions with different
/// styles and behaviors. It can be converted to SwiftUI Alert.Button for presentation.
///
/// Example usage:
/// ```swift
/// // Default action
/// let okAction = AppAlertAction.default(title: "OK")
///
/// // Cancel action
/// let cancelAction = AppAlertAction.cancel(title: "Cancel")
///
/// // Destructive action
/// let deleteAction = AppAlertAction.destructive(title: "Delete") {
///     deleteItem()
/// }
///
/// // Create alert with actions
/// let alert = AppAlert(
///     title: "Confirm Delete",
///     message: "This action cannot be undone.",
///     primaryAction: deleteAction,
///     secondaryAction: cancelAction
/// )
/// ```
public struct AppAlertAction {
    /// The action title displayed to the user
    public let title: String

    /// The action style determining appearance
    public let style: Style

    /// The action to perform when the button is tapped
    public let action: (() -> Void)?

    /// Initialize an alert action
    ///
    /// - Parameters:
    ///   - title: The action title
    ///   - style: The action style
    ///   - action: The action to perform (optional)
    public init(title: String, style: Style, action: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.action = action
    }
}

// MARK: - Action Style

public extension AppAlertAction {
    /// The style of an alert action
    enum Style {
        /// Default action style
        case `default`

        /// Cancel action style
        case cancel

        /// Destructive action style (typically red)
        case destructive
    }
}

// MARK: - Convenience Initializers

public extension AppAlertAction {
    /// Create a default action
    ///
    /// - Parameters:
    ///   - title: The action title
    ///   - action: The action to perform (optional)
    /// - Returns: A default action
    static func `default`(title: String, action: (() -> Void)? = nil) -> AppAlertAction {
        AppAlertAction(title: title, style: .default, action: action)
    }

    /// Create a cancel action
    ///
    /// - Parameters:
    ///   - title: The action title (defaults to "Cancel")
    ///   - action: The action to perform (optional)
    /// - Returns: A cancel action
    static func cancel(title: String = "Cancel", action: (() -> Void)? = nil) -> AppAlertAction {
        AppAlertAction(title: title, style: .cancel, action: action)
    }

    /// Create a destructive action
    ///
    /// - Parameters:
    ///   - title: The action title
    ///   - action: The action to perform (optional)
    /// - Returns: A destructive action
    static func destructive(title: String, action: (() -> Void)? = nil) -> AppAlertAction {
        AppAlertAction(title: title, style: .destructive, action: action)
    }
}

// MARK: - SwiftUI Integration

public extension AppAlertAction {
    /// Convert this action to a SwiftUI Alert.Button
    ///
    /// - Returns: A SwiftUI Alert.Button configured with this action's properties
    func toSwiftUIButton() -> Alert.Button {
        switch style {
        case .default:
            if let action {
                .default(Text(title), action: action)
            } else {
                .default(Text(title))
            }

        case .cancel:
            if let action {
                .cancel(Text(title), action: action)
            } else {
                .cancel(Text(title))
            }

        case .destructive:
            if let action {
                .destructive(Text(title), action: action)
            } else {
                .destructive(Text(title))
            }
        }
    }
}

// MARK: - Equatable Conformance

extension AppAlertAction: Equatable {
    public static func == (lhs: AppAlertAction, rhs: AppAlertAction) -> Bool {
        lhs.title == rhs.title && lhs.style == rhs.style
    }
}

// MARK: - Hashable Conformance

extension AppAlertAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(style)
    }
}

// MARK: - Style Equatable and Hashable

extension AppAlertAction.Style: Equatable, Hashable {}
