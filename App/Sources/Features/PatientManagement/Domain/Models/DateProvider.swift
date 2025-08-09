// DateProvider.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:58 GMT.

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

// MARK: - Fixed Date Provider

/// Testing implementation using fixed date/time for deterministic UI tests
struct FixedDateProvider: DateProvider {
    private let fixedDate: Date

    nonisolated init(fixedDate: Date) {
        self.fixedDate = fixedDate
    }

    func now() -> Date {
        fixedDate
    }

    var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }
}
