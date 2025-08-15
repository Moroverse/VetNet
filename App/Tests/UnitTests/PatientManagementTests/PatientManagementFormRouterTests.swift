// PatientManagementFormRouterTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import FactoryKit
import Foundation
import StateKit
import SwiftUIRouting
import Testing
@testable import VetNet

@Suite("Patient Management Form Router Tests")
@MainActor
struct PatientManagementFormRouterTests {
    // MARK: - Test Setup

    private func createTestPatient(name: String = "Test Patient") -> Patient {
        Patient(
            name: name,
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date(),
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-1234",
            ownerEmail: "test@example.com"
        )
    }

    // MARK: - Form Presentation Tests

    private func makeSUT() -> (sut: PatientManagementFormRouter, eventBroker: MockEventBroker, eventFactory: RouterEventFactory) {
        let mockBroker = MockEventBroker()
        let eventFactory = RouterEventFactory()
        Container.shared.routerEventBroker.register {
            mockBroker
        }
        Container.shared.routerEventFactory.register {
            eventFactory
        }
        let router = PatientManagementFormRouter()
        return (router, mockBroker, eventFactory)
    }

    @Test("Router presents create patient form")
    func createPatientFormPresentation() async {
        let (sut, _, _) = makeSUT()

        // Start form presentation
        Task {
            let result = await sut.createPatient()
            // This will wait for handleResult to be called
            if case let .created(patient, _) = result {
                #expect(patient.name == "New Test Patient")
            } else {
                #expect(Bool(false), "Expected created result")
            }
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify form is presented
        #expect(sut.presentedForm != nil)
        if let presentedForm = sut.presentedForm {
            #expect(presentedForm.id == "create")
            #expect(presentedForm.title == "New Patient")
            #expect(presentedForm.patient == nil)
        }

        // Simulate form completion
        let newPatient = createTestPatient(name: "New Test Patient")
        sut.handleResult(.created(newPatient))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(sut.presentedForm == nil)
    }

    @Test("Router presents edit patient form")
    func editPatientFormPresentation() async {
        let (sut, _, _) = makeSUT()
        let existingPatient = createTestPatient(name: "Existing Patient")

        // Start form presentation
        Task {
            let result = await sut.editPatient(existingPatient)
            // This will wait for handleResult to be called
            if case let .updated(patient, _) = result {
                #expect(patient.name == "Updated Patient")
            } else {
                #expect(Bool(false), "Expected updated result")
            }
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify form is presented
        #expect(sut.presentedForm != nil)
        if let presentedForm = sut.presentedForm {
            #expect(presentedForm.id == "edit-\(existingPatient.id.value.uuidString)")
            #expect(presentedForm.title == "Edit Patient")
            #expect(presentedForm.patient == existingPatient)
        }

        // Simulate form completion with updated patient
        var updatedPatient = existingPatient
        updatedPatient.name = "Updated Patient"
        sut.handleResult(.updated(updatedPatient))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(sut.presentedForm == nil)
    }

    @Test("Router handles form cancellation")
    func formCancellation() async {
        let (sut, mockBroker, eventFactory) = makeSUT()

        // Start form presentation
        Task {
            let result = await sut.createPatient()
            #expect(result.isCancelled)
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify form is presented
        #expect(sut.presentedForm != nil)

        // Cancel the form
        sut.handleResult(.cancelled)

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(sut.presentedForm == nil)
    }

    @Test("Router handles form error")
    func formError() async {
        let (sut, _, _) = makeSUT()

        struct TestFormError: LocalizedError {
            let errorDescription: String? = "Form validation failed"
        }

        // Start form presentation
        Task {
            let result = await sut.createPatient()
            #expect(result.isError)
            #expect(result.error?.localizedDescription == "Form validation failed")
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Simulate form error
        sut.handleResult(.error(TestFormError()))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(sut.presentedForm == nil)
    }

    // MARK: - Navigation Tests

    @Test("Router navigates to patient detail")
    func testNavigateToPatientDetail() {
        let (sut, _, _) = makeSUT()
        let patient = createTestPatient()

        // Initial state
        #expect(sut.navigationPath.isEmpty)

        // Navigate to patient detail
        sut.navigateToPatientDetail(patient)

        // Verify navigation
        #expect(sut.navigationPath.count == 1)
    }

    @Test("Router navigates to medical history")
    func testNavigateToMedicalHistory() {
        let (sut, _, _) = makeSUT()
        let patient = createTestPatient()

        // Initial state
        #expect(sut.navigationPath.isEmpty)

        // Navigate to medical history
        sut.navigateToMedicalHistory(patient)

        // Verify navigation
        #expect(sut.navigationPath.count == 1)
    }

    @Test("Router navigates to appointment history")
    func testNavigateToAppointmentHistory() {
        let (sut, _, _) = makeSUT()
        let patient = createTestPatient()

        // Initial state
        #expect(sut.navigationPath.isEmpty)

        // Navigate to appointment history
        sut.navigateToAppointmentHistory(patient)

        // Verify navigation
        #expect(sut.navigationPath.count == 1)
    }

    @Test("Router supports multiple navigation steps")
    func multipleNavigationSteps() {
        let (sut, _, _) = makeSUT()
        let patient1 = createTestPatient(name: "Patient 1")
        let patient2 = createTestPatient(name: "Patient 2")

        // Initial state
        #expect(sut.navigationPath.isEmpty)

        // Navigate through multiple screens
        sut.navigateToPatientDetail(patient1)
        #expect(sut.navigationPath.count == 1)

        sut.navigateToMedicalHistory(patient1)
        #expect(sut.navigationPath.count == 2)

        sut.navigateToPatientDetail(patient2)
        #expect(sut.navigationPath.count == 3)

        sut.navigateToAppointmentHistory(patient2)
        #expect(sut.navigationPath.count == 4)
    }

    // MARK: - Concurrent Operations Tests

    @Test("Router handles concurrent form presentations correctly")
    func concurrentFormPresentations() async {
        let (sut, _, _) = makeSUT()
        let patient = createTestPatient()

        // Start first form presentation
        Task {
            _ = await sut.createPatient()
        }

        // Give the first task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Try to present another form (should replace the first)
        Task {
            _ = await sut.editPatient(patient)
        }

        // Give the second task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify only the latest form is presented
        #expect(sut.presentedForm != nil)
        if let presentedForm = sut.presentedForm {
            // Should be the edit form, not create
            #expect(presentedForm.id == "edit-\(patient.id.value.uuidString)")
        }

        // Complete the form
        sut.handleResult(.updated(patient))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(sut.presentedForm == nil)
    }

    // MARK: - EventBroker Integration Tests

    @Test("Router publishes correct events during patient creation")
    func patientCreationEventFlow() async {
        let (sut, mockBroker, _) = makeSUT()

        // Start form presentation
        Task {
            let result = await sut.createPatient()
            if case .created = result {
                // Success
            }
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify initial event published
        #expect(mockBroker.publishedEvents.count == 1)
        #expect(mockBroker.verifyEventPublished(FormPresentationRequested.self))

        let presentationEvent = mockBroker.events(of: FormPresentationRequested.self).first
        #expect(presentationEvent?.mode == .create)

        // Simulate form completion
        let newPatient = createTestPatient(name: "New Test Patient")
        sut.handleResult(.created(newPatient))

        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify completion event published
        #expect(mockBroker.publishedEvents.count == 2)
        #expect(mockBroker.verifyEventPublished(FormPresentationCompleted.self))

        let completionEvent = mockBroker.events(of: FormPresentationCompleted.self).first
        #expect(completionEvent?.mode == .create)
        if case .created = completionEvent?.result {
            // Success
        } else {
            #expect(Bool(false), "Expected created result")
        }
    }

    @Test("Router publishes correct events during patient editing")
    func patientEditEventFlow() async {
        let (sut, mockBroker, _) = makeSUT()
        let existingPatient = createTestPatient(name: "Existing Patient")

        // Start form presentation
        Task {
            let result = await sut.editPatient(existingPatient)
            if case .updated = result {
                // Success
            }
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify initial event published
        #expect(mockBroker.publishedEvents.count == 1)
        #expect(mockBroker.verifyEventPublished(FormPresentationRequested.self))

        let presentationEvent = mockBroker.events(of: FormPresentationRequested.self).first
        if case .edit = presentationEvent?.mode {
            // Success
        } else {
            #expect(Bool(false), "Expected edit mode")
        }

        // Simulate form completion
        var updatedPatient = existingPatient
        updatedPatient.name = "Updated Patient"
        sut.handleResult(.updated(updatedPatient))

        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify completion event published
        #expect(mockBroker.publishedEvents.count == 2)
        #expect(mockBroker.verifyEventPublished(FormPresentationCompleted.self))

        let completionEvent = mockBroker.events(of: FormPresentationCompleted.self).first
        if case .edit = completionEvent?.mode {
            // Success
        } else {
            #expect(Bool(false), "Expected edit mode")
        }
        if case .updated = completionEvent?.result {
            // Success
        } else {
            #expect(Bool(false), "Expected updated result")
        }
    }

    @Test("Router publishes navigation events")
    func navigationEventFlow() {
        let (sut, mockBroker, _) = makeSUT()
        let patient = createTestPatient()

        // Navigate to patient detail
        sut.navigateToPatientDetail(patient)

        // Verify navigation events published
        #expect(mockBroker.publishedEvents.count == 2)
        #expect(mockBroker.verifyEventPublished(NavigationRequested.self))
        #expect(mockBroker.verifyEventPublished(NavigationCompleted.self))

        let requestedEvent = mockBroker.events(of: NavigationRequested.self).first
        if case .patientDetail = requestedEvent?.route {
            // Success
        } else {
            #expect(Bool(false), "Expected patientDetail route")
        }

        let completedEvent = mockBroker.events(of: NavigationCompleted.self).first
        if case .patientDetail = completedEvent?.route {
            // Success
        } else {
            #expect(Bool(false), "Expected patientDetail route")
        }

        // Reset and test medical history navigation
        mockBroker.reset()
        sut.navigateToMedicalHistory(patient)

        #expect(mockBroker.publishedEvents.count == 2)
        let medicalRequestedEvent = mockBroker.events(of: NavigationRequested.self).first
        if case .medicalHistory = medicalRequestedEvent?.route {
            // Success
        } else {
            #expect(Bool(false), "Expected medicalHistory route")
        }

        // Reset and test appointment history navigation
        mockBroker.reset()
        sut.navigateToAppointmentHistory(patient)

        #expect(mockBroker.publishedEvents.count == 2)
        let appointmentRequestedEvent = mockBroker.events(of: NavigationRequested.self).first
        if case .appointmentHistory = appointmentRequestedEvent?.route {
            // Success
        } else {
            #expect(Bool(false), "Expected appointmentHistory route")
        }
    }

    // MARK: - Factory Integration Tests

    @Test("Router is properly registered in Container")
    func routerFactoryRegistration() {
        let container = Container()
        let router1 = container.patientManagementRouter()
        let router2 = container.patientManagementRouter()

        // Should be the same instance (shared)
        #expect(router1 === router2)
    }

    // MARK: - Memory Management Tests

    @Test("Router properly cleans up after operations")
    func routerCleanup() async {
        let (sut, _, _) = makeSUT()

        // Start form presentation
        Task {
            _ = await sut.createPatient()
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify form is presented
        #expect(sut.presentedForm != nil)
        #expect(sut.hasActiveOperations)

        // Cancel active operations
        sut.cancelActiveOperations()

        // Verify cleanup
        #expect(sut.presentedForm == nil)
        #expect(!sut.hasActiveOperations)
    }
}
