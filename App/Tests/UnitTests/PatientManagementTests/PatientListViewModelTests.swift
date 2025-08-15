// PatientListViewModelTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-15 04:51 GMT.

import FactoryKit
import Foundation
import StateKit
import Testing
@testable import VetNet

@Suite("Patient List ViewModel Tests")
struct PatientListViewModelTests {
    // MARK: - Test Helpers

    @MainActor
    func makeSUT() -> (viewModel: PatientListViewModel, eventBroker: MockEventBroker) {
        let mockEventBroker = MockEventBroker()
        Container.shared.routerEventBroker.register { mockEventBroker }

        let viewModel = PatientListViewModel()

        return (viewModel, mockEventBroker)
    }

    // MARK: - Event Subscription Tests

    @MainActor
    @Test("ViewModel subscribes to FormPresentationCompleted events on initialization")
    func subscribesOnInit() async throws {
        // Given & When
        let (_, eventBroker) = makeSUT()

        // Then
        #expect(eventBroker.subscriptionCount == 1)
        #expect(eventBroker.verifyEventPublished(FormPresentationCompleted.self) == false) // No events published yet
    }

    @MainActor
    @Test("ViewModel refreshes list when patient is created")
    func refreshesListOnPatientCreated() async throws {
        // Given
        let (viewModel, eventBroker) = makeSUT()
        let initialRefreshState = viewModel.isRefreshing

        // When
        let event = FormPresentationCompleted(
            mode: .create,
            result: .created(Patient.mock()),
            eventId: UUID(),
            timestamp: Date(),
            version: "1.0"
        )
        eventBroker.publish(event)

        // Then
        #expect(initialRefreshState == false)
        #expect(eventBroker.publishedEvents.count == 1)
        #expect(eventBroker.verifyEventPublished(FormPresentationCompleted.self))
    }

    @MainActor
    @Test("ViewModel refreshes list when patient is updated")
    func refreshesListOnPatientUpdated() async throws {
        // Given
        let (_, eventBroker) = makeSUT()

        // When
        let event = FormPresentationCompleted(
            mode: .edit(Patient.mock()),
            result: .updated(Patient.mock()),
            eventId: UUID(),
            timestamp: Date(),
            version: "1.0"
        )
        eventBroker.publish(event)

        // Then
        #expect(eventBroker.publishedEvents.count == 1)
        #expect((eventBroker.publishedEvents.first as? FormPresentationCompleted)?.result.isSuccess == true)
    }

    @MainActor
    @Test("ViewModel refreshes list when patient is deleted")
    func refreshesListOnPatientDeleted() async throws {
        // Given
        let (_, eventBroker) = makeSUT()

        // When
        let event = FormPresentationCompleted(
            mode: .edit(Patient.mock()),
            result: .deleted(Patient.mock()),
            eventId: UUID(),
            timestamp: Date(),
            version: "1.0"
        )
        eventBroker.publish(event)

        // Then
        #expect(eventBroker.publishedEvents.count == 1)
    }

    @MainActor
    @Test("ViewModel does not refresh list when form is cancelled")
    func doesNotRefreshOnCancelled() async throws {
        // Given
        let (viewModel, eventBroker) = makeSUT()
        let initialRefreshState = viewModel.isRefreshing

        // When
        let event = FormPresentationCompleted(
            mode: .create,
            result: .cancelled,
            eventId: UUID(),
            timestamp: Date(),
            version: "1.0"
        )
        eventBroker.publish(event)

        // Then
        #expect(initialRefreshState == false)
        #expect(viewModel.isRefreshing == false)
    }

    @MainActor
    @Test("ViewModel does not refresh list when form has error")
    func doesNotRefreshOnError() async throws {
        // Given
        let (viewModel, eventBroker) = makeSUT()
        let initialRefreshState = viewModel.isRefreshing

        // When
        let event = FormPresentationCompleted(
            mode: .create,
            result: .error(TestError.testFailure),
            eventId: UUID(),
            timestamp: Date(),
            version: "1.0"
        )
        eventBroker.publish(event)

        // Then
        #expect(initialRefreshState == false)
        #expect(viewModel.isRefreshing == false)
    }

    @MainActor
    @Test("ViewModel prevents concurrent refreshes")
    func preventsConcurrentRefreshes() async throws {
        // Given
        let (viewModel, _) = makeSUT()

        // When - Start first refresh
        let task1 = Task {
            await viewModel.refreshList()
        }

        // Start second refresh immediately
        let task2 = Task {
            await viewModel.refreshList()
        }

        // Wait for both to complete
        await task1.value
        await task2.value

        // Then
        #expect(viewModel.isRefreshing == false)
    }

    @MainActor
    @Test("ViewModel unsubscribes on deinitialization")
    func unsubscribesOnDeinit() async throws {
        // Given
        let mockEventBroker = MockEventBroker()
        Container.shared.routerEventBroker.register { mockEventBroker }

        // When
        var viewModel: PatientListViewModel? = PatientListViewModel()
        #expect(mockEventBroker.subscriptionCount == 1)

        // Release the view model
        _ = viewModel // Silence warning
        viewModel = nil

        // Then
        #expect(mockEventBroker.subscriptionCount == 0)
    }
}

// MARK: - Mock Extensions

extension Patient {
    static func mock(
        id: ID = ID(),
        name: String = "Buddy",
        species: Species = .dog,
        breed: Breed = .dogLabrador,
        birthDate: Date = Date().addingTimeInterval(-2 * 365 * 24 * 60 * 60),
        weight: Measurement<UnitMass> = Measurement(value: 25.0, unit: .kilograms),
        ownerName: String = "John Doe",
        ownerPhoneNumber: String = "555-0123",
        medicalID: String = "MED-001"
    ) -> Patient {
        Patient(
            id: id,
            name: name,
            species: species,
            breed: breed,
            birthDate: birthDate,
            weight: weight,
            ownerName: ownerName,
            ownerPhoneNumber: ownerPhoneNumber,
            medicalID: medicalID
        )
    }
}

extension PatientFormResult {
    var isSuccess: Bool {
        switch self {
        case .created, .updated, .deleted:
            true
        case .cancelled, .error:
            false
        }
    }
}

enum TestError: Error {
    case testFailure
}
