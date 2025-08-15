// RouterEventFactory.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-14 15:56 GMT.

import FactoryKit
import Foundation
import StateKit

/// Factory for creating router events with controlled dependencies
/// Enables predictable testing by injecting DateProvider and UUIDProvider
final class RouterEventFactory: Sendable {
    @Injected(\.dateProvider)
    private var dateProvider: DateProvider
    @Injected(\.uuidProvider)
    private var uuidProvider: UUIDProvider

    func formPresentationRequested(mode: PatientFormMode) -> FormPresentationRequested {
        FormPresentationRequested(
            mode: mode,
            eventId: uuidProvider.generate(),
            timestamp: dateProvider.now(),
            version: "1.0"
        )
    }

    func formPresentationCompleted(mode: PatientFormMode, result: PatientFormResult) -> FormPresentationCompleted {
        FormPresentationCompleted(
            mode: mode,
            result: result,
            eventId: uuidProvider.generate(),
            timestamp: dateProvider.now(),
            version: "1.0"
        )
    }

    func navigationRequested(route: PatientRoute) -> NavigationRequested {
        NavigationRequested(
            route: route,
            eventId: uuidProvider.generate(),
            timestamp: dateProvider.now(),
            version: "1.0"
        )
    }

    func navigationCompleted(route: PatientRoute) -> NavigationCompleted {
        NavigationCompleted(
            route: route,
            eventId: uuidProvider.generate(),
            timestamp: dateProvider.now(),
            version: "1.0"
        )
    }
}

// MARK: - Router Events

struct FormPresentationRequested: Event, Sendable {
    let mode: PatientFormMode
    let eventId: UUID
    let timestamp: Date
    let version: String
}

struct FormPresentationCompleted: Event, Sendable {
    let mode: PatientFormMode
    let result: PatientFormResult
    let eventId: UUID
    let timestamp: Date
    let version: String
}

struct NavigationRequested: Event, Sendable {
    let route: PatientRoute
    let eventId: UUID
    let timestamp: Date
    let version: String
}

struct NavigationCompleted: Event, Sendable {
    let route: PatientRoute
    let eventId: UUID
    let timestamp: Date
    let version: String
}
