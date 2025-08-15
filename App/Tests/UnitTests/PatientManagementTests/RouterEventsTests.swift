// RouterEventsTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-14 15:56 GMT.

import FactoryKit
import Foundation
import StateKit
import Testing
@testable import VetNet

@Suite("Router Events Tests")
struct RouterEventsTests {
    @MainActor
    private func makeSUT(date: Date, uuid: UUID) -> RouterEventFactory {
        Container.shared.dateProvider.register {
            MockDateProvider(date: date)
        }

        Container.shared.uuidProvider.register {
            MockUUIDProvider(uuid: uuid)
        }

        let eventFactory = RouterEventFactory()

        return eventFactory
    }

    @Test("RouterEventFactory creates FormPresentationRequested with controlled dependencies")
    @MainActor func formPresentationRequestedEventCreation() {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let fixedUUID = UUID(uuidString: "12345678-1234-5678-9012-123456789012")!
        let sut = makeSUT(date: fixedDate, uuid: fixedUUID)
        let mode = PatientFormMode.create

        // When
        let event = sut.formPresentationRequested(mode: mode)

        // Then
        #expect(event.mode == mode)
        #expect(event.eventId == fixedUUID)
        #expect(event.timestamp == fixedDate)
        #expect(event.version == "1.0")
    }

    @Test("RouterEventFactory creates FormPresentationCompleted with controlled dependencies")
    @MainActor func formPresentationCompletedEventCreation() {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let fixedUUID = UUID(uuidString: "12345678-1234-5678-9012-123456789012")!
        let sut = makeSUT(date: fixedDate, uuid: fixedUUID)
        let mode = PatientFormMode.create
        let result = PatientFormResult.created(Patient.mock)

        // When
        let event = sut.formPresentationCompleted(mode: mode, result: result)

        // Then
        #expect(event.mode == mode)
        #expect(event.result.isCreated)
        #expect(event.eventId == fixedUUID)
        #expect(event.timestamp == fixedDate)
        #expect(event.version == "1.0")
    }
}

// MARK: - Test Extensions

extension Patient {
    static let mock = Patient(
        id: .init(),
        name: "Test Patient",
        species: .dog,
        breed: .dogLabrador,
        birthDate: Date(),
        weight: .init(value: 10, unit: .kilograms),
        ownerName: "Test Owner",
        ownerPhoneNumber: "555-0123"
    )
}

extension PatientFormResult {
    var isCreated: Bool {
        if case .created = self { return true }
        return false
    }
}

// MARK: - Mock Providers

private final class MockDateProvider: DateProvider {
    let fixedDate: Date

    init(date: Date) {
        fixedDate = date
    }

    func now() -> Date {
        fixedDate
    }

    var calendar: Calendar {
        Calendar.current
    }
}

private final class MockUUIDProvider: UUIDProvider {
    let fixedUUID: UUID

    init(uuid: UUID) {
        fixedUUID = uuid
    }

    func generate() -> UUID {
        fixedUUID
    }
}
