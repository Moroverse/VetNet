// RouterEventBroker.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-14 09:57 GMT.

import FactoryKit
import Foundation
import StateKit

private struct RouterEventSubscription: EventSubscription {
    private let _unsubscribe: () -> Void

    init(unsubscribe: @escaping () -> Void) {
        _unsubscribe = unsubscribe
    }

    func unsubscribe() {
        _unsubscribe()
    }
}

final class RouterEventBroker: EventBroker {
    private protocol AnyHandler {
        var id: UUID { get }
    }

    private struct TypedHandler<T>: AnyHandler {
        let id: UUID = .init()
        let handler: (T) -> Void
    }

    private lazy var registrations: [String: [AnyHandler]] = [:]

    // Logger for debugging event flow
    @Injected(\.loggingService) private var logger

    func publish<T: Event>(_ event: T) {
        let eventKey = String(describing: T.self)
        let handlers = registrations[eventKey] ?? []

        logger.debug("Publishing event: \(eventKey)", category: .routing)

        if handlers.isEmpty {
            logger.debug("No subscribers for event: \(eventKey)", category: .routing)
            return
        }

        var deliveredCount = 0
        for anyHandler in handlers {
            if let typedHandler = anyHandler as? TypedHandler<T> {
                typedHandler.handler(event)
                deliveredCount += 1
            }
        }

        logger.debug("Event published to \(deliveredCount) subscribers: \(eventKey)", category: .routing)
    }

    func subscribe<T: Event>(_ eventType: T.Type, handler: @escaping @Sendable (T) -> Void) -> EventSubscription {
        let eventKey = String(describing: T.self)
        let typedHandler = TypedHandler(handler: handler)
        let handlerId = typedHandler.id

        // Initialize array if needed
        if registrations[eventKey] == nil {
            registrations[eventKey] = []
        }

        registrations[eventKey]?.append(typedHandler)

        logger.debug("New subscription for: \(eventKey) (ID: \(handlerId))", category: .routing)
        logger.debug("Total subscribers for \(eventKey): \(registrations[eventKey]?.count ?? 0)", category: .routing)

        return RouterEventSubscription { [weak self] in
            self?.unsubscribe(eventKey: eventKey, handlerId: handlerId)
        }
    }

    private func unsubscribe(eventKey: String, handlerId: UUID) {
        guard var handlers = registrations[eventKey] else { return }

        // Remove handler with matching ID
        handlers.removeAll { $0.id == handlerId }

        if handlers.isEmpty {
            registrations[eventKey] = nil
            logger.debug("Removed empty subscription array for event: \(eventKey)", category: .routing)
        } else {
            registrations[eventKey] = handlers
        }

        logger.debug("Unsubscribed: \(handlerId) from \(eventKey)", category: .routing)
    }
}

#if DEBUG
    extension RouterEventBroker {
        /// Debug information about the current state
        var debugInfo: String {
            var info = ["RouterEventBroker Debug Info:"]
            info.append("- Total event types: \(registrations.keys.count)")

            for (eventKey, handlers) in registrations {
                info.append("- \(eventKey): \(handlers.count) subscribers")
            }

            return info.joined(separator: "\n")
        }

        /// Get subscription count for a specific event type
        func subscriptionCount<T: Event>(for eventType: T.Type) -> Int {
            let key = String(describing: T.self)
            return registrations[key]?.count ?? 0
        }
    }
#endif
