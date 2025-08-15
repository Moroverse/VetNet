// MockEventBroker.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-14 16:04 GMT.

import Foundation
import StateKit
@testable import VetNet

/// Mock implementation of EventBroker for testing
final class MockEventBroker: EventBroker {
    /// All published events
    var publishedEvents: [any Event] = []

    /// Current subscription count
    var subscriptionCount = 0

    /// Track subscription handlers for testing
    private var handlers: [String: [(any Event) -> Void]] = [:]

    func publish<T: Event>(_ event: T) {
        publishedEvents.append(event)

        // Notify subscribers for testing
        let eventKey = String(describing: T.self)
        if let typeHandlers = handlers[eventKey] {
            for handler in typeHandlers {
                handler(event)
            }
        }
    }

    func subscribe<T: Event>(_ eventType: T.Type, handler: @escaping @Sendable (T) -> Void) -> EventSubscription {
        subscriptionCount += 1

        let eventKey = String(describing: T.self)

        // Store handler for testing
        let wrappedHandler: (any Event) -> Void = { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }

        if handlers[eventKey] == nil {
            handlers[eventKey] = []
        }
        handlers[eventKey]?.append(wrappedHandler)

        // For testing, immediately call handler with any matching published events
        for event in publishedEvents {
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }

        return MockEventSubscription { [weak self] in
            self?.subscriptionCount -= 1
        }
    }

    /// Reset mock state
    func reset() {
        publishedEvents.removeAll()
        subscriptionCount = 0
        handlers.removeAll()
    }

    /// Verify specific event was published
    func verifyEventPublished<T: Event>(_ eventType: T.Type) -> Bool {
        publishedEvents.contains { $0 is T }
    }

    /// Get all events of a specific type
    func events<T: Event>(of type: T.Type) -> [T] {
        publishedEvents.compactMap { $0 as? T }
    }
}

private struct MockEventSubscription: EventSubscription {
    let onUnsubscribe: () -> Void

    func unsubscribe() {
        onUnsubscribe()
    }
}
