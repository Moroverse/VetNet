// PatientManagementFormRouterTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import FactoryKit
import Foundation
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

    @Test("Router presents create patient form")
    func createPatientFormPresentation() async {
        let router = PatientManagementFormRouter()

        // Start form presentation
        Task {
            let result = await router.createPatient()
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
        #expect(router.presentedForm != nil)
        if let presentedForm = router.presentedForm {
            #expect(presentedForm.id == "create")
            #expect(presentedForm.title == "New Patient")
            #expect(presentedForm.patient == nil)
        }

        // Simulate form completion
        let newPatient = createTestPatient(name: "New Test Patient")
        router.handleResult(.created(newPatient))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(router.presentedForm == nil)
    }

    @Test("Router presents edit patient form")
    func editPatientFormPresentation() async {
        let router = PatientManagementFormRouter()
        let existingPatient = createTestPatient(name: "Existing Patient")

        // Start form presentation
        Task {
            let result = await router.editPatient(existingPatient)
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
        #expect(router.presentedForm != nil)
        if let presentedForm = router.presentedForm {
            #expect(presentedForm.id == "edit-\(existingPatient.id.value.uuidString)")
            #expect(presentedForm.title == "Edit Patient")
            #expect(presentedForm.patient == existingPatient)
        }

        // Simulate form completion with updated patient
        var updatedPatient = existingPatient
        updatedPatient.name = "Updated Patient"
        router.handleResult(.updated(updatedPatient))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(router.presentedForm == nil)
    }

    @Test("Router handles form cancellation")
    func formCancellation() async {
        let router = PatientManagementFormRouter()

        // Start form presentation
        Task {
            let result = await router.createPatient()
            #expect(result.isCancelled)
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify form is presented
        #expect(router.presentedForm != nil)

        // Cancel the form
        router.handleResult(.cancelled)

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(router.presentedForm == nil)
    }

    @Test("Router handles form error")
    func formError() async {
        let router = PatientManagementFormRouter()

        struct TestFormError: LocalizedError {
            let errorDescription: String? = "Form validation failed"
        }

        // Start form presentation
        Task {
            let result = await router.createPatient()
            #expect(result.isError)
            #expect(result.error?.localizedDescription == "Form validation failed")
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Simulate form error
        router.handleResult(.error(TestFormError()))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(router.presentedForm == nil)
    }

    // MARK: - Navigation Tests

    @Test("Router navigates to patient detail")
    func testNavigateToPatientDetail() {
        let router = PatientManagementFormRouter()
        let patient = createTestPatient()

        // Initial state
        #expect(router.navigationPath.isEmpty)

        // Navigate to patient detail
        router.navigateToPatientDetail(patient)

        // Verify navigation
        #expect(router.navigationPath.count == 1)
    }

    @Test("Router navigates to medical history")
    func testNavigateToMedicalHistory() {
        let router = PatientManagementFormRouter()
        let patient = createTestPatient()

        // Initial state
        #expect(router.navigationPath.isEmpty)

        // Navigate to medical history
        router.navigateToMedicalHistory(patient)

        // Verify navigation
        #expect(router.navigationPath.count == 1)
    }

    @Test("Router navigates to appointment history")
    func testNavigateToAppointmentHistory() {
        let router = PatientManagementFormRouter()
        let patient = createTestPatient()

        // Initial state
        #expect(router.navigationPath.isEmpty)

        // Navigate to appointment history
        router.navigateToAppointmentHistory(patient)

        // Verify navigation
        #expect(router.navigationPath.count == 1)
    }

    @Test("Router supports multiple navigation steps")
    func multipleNavigationSteps() {
        let router = PatientManagementFormRouter()
        let patient1 = createTestPatient(name: "Patient 1")
        let patient2 = createTestPatient(name: "Patient 2")

        // Initial state
        #expect(router.navigationPath.isEmpty)

        // Navigate through multiple screens
        router.navigateToPatientDetail(patient1)
        #expect(router.navigationPath.count == 1)

        router.navigateToMedicalHistory(patient1)
        #expect(router.navigationPath.count == 2)

        router.navigateToPatientDetail(patient2)
        #expect(router.navigationPath.count == 3)

        router.navigateToAppointmentHistory(patient2)
        #expect(router.navigationPath.count == 4)
    }

    // MARK: - Concurrent Operations Tests

    @Test("Router handles concurrent form presentations correctly")
    func concurrentFormPresentations() async {
        let router = PatientManagementFormRouter()
        let patient = createTestPatient()

        // Start first form presentation
        Task {
            _ = await router.createPatient()
        }

        // Give the first task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Try to present another form (should replace the first)
        Task {
            _ = await router.editPatient(patient)
        }

        // Give the second task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify only the latest form is presented
        #expect(router.presentedForm != nil)
        if let presentedForm = router.presentedForm {
            // Should be the edit form, not create
            #expect(presentedForm.id == "edit-\(patient.id.value.uuidString)")
        }

        // Complete the form
        router.handleResult(.updated(patient))

        // Verify form is dismissed
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        #expect(router.presentedForm == nil)
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
        let router = PatientManagementFormRouter()

        // Start form presentation
        Task {
            _ = await router.createPatient()
        }

        // Give the task time to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Verify form is presented
        #expect(router.presentedForm != nil)
        #expect(router.hasActiveOperations)

        // Cancel active operations
        router.cancelActiveOperations()

        // Verify cleanup
        #expect(router.presentedForm == nil)
        #expect(!router.hasActiveOperations)
    }
}
