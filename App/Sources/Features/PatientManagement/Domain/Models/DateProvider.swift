// DateProvider.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:40 GMT.

import Foundation
import Mockable

// MARK: - Date Provider Protocol

/// Protocol for providing current date/time - enables testing with mock dates
protocol DateProvider: Sendable {
    /// Current date and time
    func now() -> Date

    /// Calendar to use for date calculations
    var calendar: Calendar { get }
}

// MARK: - System Date Provider

/// Production implementation using system date/time
struct SystemDateProvider: DateProvider {
    func now() -> Date {
        Date()
    }

    var calendar: Calendar {
        .current
    }
}


