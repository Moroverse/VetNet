// LoggingService.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-05 06:57 GMT.

import Foundation
import OSLog

// MARK: - Logging Protocol

protocol LoggingService: Sendable {
    func debug(_ message: String, category: LogCategory?, file: String, function: String, line: Int)
    func info(_ message: String, category: LogCategory?, file: String, function: String, line: Int)
    func notice(_ message: String, category: LogCategory?, file: String, function: String, line: Int)
    func warning(_ message: String, category: LogCategory?, file: String, function: String, line: Int)
    func error(_ message: String, category: LogCategory?, file: String, function: String, line: Int)
    func critical(_ message: String, category: LogCategory?, file: String, function: String, line: Int)
}

// MARK: - Log Categories

nonisolated enum LogCategory: String, CaseIterable {
    case app = "App"
    case ui = "UI"
    case data = "Data"
    case network = "Network"
    case cloudKit = "CloudKit"
    case routing = "Routing"
    case authentication = "Authentication"
    case scheduling = "Scheduling"
    case patients = "Patients"
    case appointments = "Appointments"
    case development = "Development"
    case testing = "Testing"

    var subsystem: String {
        "com.moroverse.VetNet"
    }
}

// MARK: - Convenience Extensions

extension LoggingService {
    func debug(_ message: String, category: LogCategory? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        debug(message, category: category, file: file, function: function, line: line)
    }

    func info(_ message: String, category: LogCategory? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        info(message, category: category, file: file, function: function, line: line)
    }

    func notice(_ message: String, category: LogCategory? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        notice(message, category: category, file: file, function: function, line: line)
    }

    func warning(_ message: String, category: LogCategory? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        warning(message, category: category, file: file, function: function, line: line)
    }

    func error(_ message: String, category: LogCategory? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        error(message, category: category, file: file, function: function, line: line)
    }

    func critical(_ message: String, category: LogCategory? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        critical(message, category: category, file: file, function: function, line: line)
    }
}

// MARK: - System Logger Implementation

final nonisolated class SystemLoggingService: LoggingService {
    private let loggers: [LogCategory: Logger]
    private let defaultLogger: Logger

    init() {
        var loggers: [LogCategory: Logger] = [:]
        for category in LogCategory.allCases {
            loggers[category] = Logger(subsystem: category.subsystem, category: category.rawValue)
        }
        self.loggers = loggers
        defaultLogger = Logger(subsystem: LogCategory.app.subsystem, category: LogCategory.app.rawValue)
    }

    private func logger(for category: LogCategory?) -> Logger {
        guard let category else { return defaultLogger }
        return loggers[category] ?? defaultLogger
    }

    private func formatMessage(_ message: String, file: String, function: String, line: Int) -> String {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        return "[\(filename):\(line)] \(function) - \(message)"
    }

    func debug(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        logger(for: category).debug("\(formattedMessage)")
    }

    func info(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        logger(for: category).info("\(formattedMessage)")
    }

    func notice(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        logger(for: category).notice("\(formattedMessage)")
    }

    func warning(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        logger(for: category).warning("\(formattedMessage)")
    }

    func error(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        logger(for: category).error("\(formattedMessage)")
    }

    func critical(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
        let formattedMessage = formatMessage(message, file: file, function: function, line: line)
        logger(for: category).critical("\(formattedMessage)")
    }
}

// MARK: - Development Console Logger

#if DEBUG
    final class ConsoleLoggingService: LoggingService {
        func debug(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
            log("🔍 DEBUG", message: message, category: category, file: file, function: function, line: line)
        }

        func info(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
            log("ℹ️ INFO", message: message, category: category, file: file, function: function, line: line)
        }

        func notice(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
            log("📢 NOTICE", message: message, category: category, file: file, function: function, line: line)
        }

        func warning(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
            log("⚠️ WARNING", message: message, category: category, file: file, function: function, line: line)
        }

        func error(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
            log("❌ ERROR", message: message, category: category, file: file, function: function, line: line)
        }

        func critical(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {
            log("💥 CRITICAL", message: message, category: category, file: file, function: function, line: line)
        }

        private func log(_ level: String, message: String, category: LogCategory?, file: String, function: String, line: Int) {
            let filename = URL(fileURLWithPath: file).lastPathComponent
            let categoryStr = category?.rawValue ?? "App"
            let timestamp = DateFormatter.logTimestamp.string(from: Date())
            print("[\(timestamp)] \(level) [\(categoryStr)] [\(filename):\(line)] \(function) - \(message)")
        }
    }

    private extension DateFormatter {
        static let logTimestamp: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter
        }()
    }
#endif

// MARK: - Silent Logger for Tests

final class SilentLoggingService: LoggingService {
    func debug(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {}
    func info(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {}
    func notice(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {}
    func warning(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {}
    func error(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {}
    func critical(_ message: String, category: LogCategory?, file: String, function: String, line: Int) {}
}
