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

// MARK: - Controllable Date Provider

/// Date provider that can be controlled during testing via TestControl system
public final class ControllableDateProvider: DateProvider, TestControllable, @unchecked Sendable {
    // MARK: - Behavior Definition

    public enum Behavior: Sendable {
        /// Use system date (default)
        case system

        /// Use fixed date for all calls
        case fixed(Date)

        /// Start at a date and increment by interval on each call
        case incrementing(start: Date, increment: TimeInterval)

        /// Only return dates during business hours (9 AM - 5 PM)
        case businessHoursOnly(Date)
    }

    // MARK: - Properties

    private var behavior: Behavior = .system
    private var currentDate: Date?
    private let systemProvider = SystemDateProvider()

    // MARK: - DateProvider

    func now() -> Date {
        switch behavior {
        case .system:
            return systemProvider.now()

        case let .fixed(date):
            return date

        case let .incrementing(start, increment):
            if let current = currentDate {
                let nextDate = current.addingTimeInterval(increment)
                currentDate = nextDate
                return nextDate
            } else {
                currentDate = start
                return start
            }

        case let .businessHoursOnly(baseDate):
            let cal = calendar
            let hour = cal.component(.hour, from: baseDate)

            // If outside business hours (9 AM - 5 PM), adjust to 9 AM next day
            if hour < 9 || hour >= 17 {
                let nextDay = cal.date(byAdding: .day, value: 1, to: baseDate) ?? baseDate
                let businessStart = cal.date(bySettingHour: 9, minute: 0, second: 0, of: nextDay) ?? baseDate
                return businessStart
            }

            return baseDate
        }
    }

    var calendar: Calendar {
        systemProvider.calendar
    }

    // MARK: - TestControllable

    public func applyBehavior(_ behavior: Behavior) {
        self.behavior = behavior
        currentDate = nil // Reset incrementing state
    }

    public func resetBehavior() {
        behavior = .system
        currentDate = nil
    }
}

// MARK: - Test Helpers

#if DEBUG
    extension ControllableDateProvider {
        /// Create a date provider with fixed date for testing
        static func fixed(_ date: Date) -> ControllableDateProvider {
            let provider = ControllableDateProvider()
            provider.applyBehavior(.fixed(date))
            return provider
        }

        /// Create a date provider that increments for testing
        static func incrementing(start: Date, by interval: TimeInterval) -> ControllableDateProvider {
            let provider = ControllableDateProvider()
            provider.applyBehavior(.incrementing(start: start, increment: interval))
            return provider
        }

}
#endif
