// PatientNavigationIntegrationTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import ConcurrencyExtras
import FactoryKit
import Foundation
import SwiftUI
import SwiftUIRouting
import Testing
@testable import VetNet

@Suite("Patient Navigation Integration Tests")
@MainActor
struct PatientNavigationIntegrationTests {
    // MARK: - Test Setup

    private func createTestPatient(name: String = "Test Patient") -> Patient {
        Patient(
            name: name,
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-1234",
            ownerEmail: "test@example.com",
            microchipNumber: "123456789"
        )
    }

    // MARK: - End-to-End Navigation Flow Tests

    @Test("Complete patient creation and navigation flow")
    func completePatientCreationFlow() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()
            var createdPatient: Patient?

            // Step 1: Create a new patient
            Task {
                let result = await router.createPatient()
                if case let .created(patient, _) = result {
                    createdPatient = patient
                }
            }

            // Wait for form presentation
            await Task.yield()
            #expect(router.presentedForm?.id == "create")

            // Simulate successful patient creation
            let newPatient = createTestPatient(name: "Integration Test Patient")
            router.handleResult(.created(newPatient))

            // Wait for form dismissal
            await Task.yield()
            #expect(router.presentedForm == nil)
            #expect(createdPatient != nil)

            // Step 2: Navigate to patient detail
            if let patient = createdPatient {
                router.navigateToPatientDetail(patient)
                #expect(router.navigationPath.count == 1)

                // Step 3: Navigate to medical history from detail
                router.navigateToMedicalHistory(patient)
                #expect(router.navigationPath.count == 2)

                // Step 4: Navigate to appointment history
                router.navigateToAppointmentHistory(patient)
                #expect(router.navigationPath.count == 3)
            }
        }
    }

    @Test("Edit patient flow with navigation")
    func editPatientFlow() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()
            let existingPatient = createTestPatient(name: "Existing Patient")
            var updatedPatient: Patient?

            // Navigate to patient detail first
            router.navigateToPatientDetail(existingPatient)
            #expect(router.navigationPath.count == 1)

            // Start edit flow
            Task {
                let result = await router.editPatient(existingPatient)
                if case let .updated(patient, _) = result {
                    updatedPatient = patient
                }
            }

            // Wait for form presentation
            await Task.yield()
            #expect(router.presentedForm?.id == "edit-\(existingPatient.id.value.uuidString)")

            // Simulate patient update
            var modifiedPatient = existingPatient
            modifiedPatient.name = "Updated Integration Patient"
            modifiedPatient.weight = Measurement(value: 27, unit: .kilograms)
            router.handleResult(.updated(modifiedPatient))

            // Wait for form dismissal
            await Task.yield()
            #expect(router.presentedForm == nil)
            #expect(updatedPatient?.name == "Updated Integration Patient")

            // Navigation path should still be at patient detail
            #expect(router.navigationPath.count == 1)
        }
    }

    @Test("Error handling in navigation flow")
    func errorHandlingFlow() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()
            var errorReceived: Error?

            struct ValidationError: LocalizedError {
                let errorDescription: String? = "Invalid patient data"
            }

            // Start create flow
            Task {
                let result = await router.createPatient()
                if case let .error(error) = result {
                    errorReceived = error
                }
            }

            // Wait for form presentation
            await Task.yield()
            #expect(router.presentedForm != nil)

            // Simulate validation error
            router.handleResult(.error(ValidationError()))

            // Wait for form dismissal
            await Task.yield()
            #expect(router.presentedForm == nil)
            #expect(errorReceived?.localizedDescription == "Invalid patient data")

            // Navigation path should remain empty
            #expect(router.navigationPath.isEmpty)
        }
    }

    @Test("Cancellation in navigation flow")
    func cancellationFlow() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()
            let patient = createTestPatient()
            var wasCancelled = false

            // Navigate to patient detail
            router.navigateToPatientDetail(patient)
            #expect(router.navigationPath.count == 1)

            // Start edit flow
            Task {
                let result = await router.editPatient(patient)
                wasCancelled = result.isCancelled
            }

            // Wait for form presentation
            await Task.yield()
            #expect(router.presentedForm != nil)

            // Cancel the form
            router.handleResult(.cancelled)

            // Wait for form dismissal
            await Task.yield()
            #expect(router.presentedForm == nil)
            #expect(wasCancelled == true)

            // Navigation should remain at patient detail
            #expect(router.navigationPath.count == 1)
        }
    }

    // MARK: - Complex Navigation Scenarios

    @Test("Deep navigation with form interactions")
    func deepNavigationWithForms() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()
            let patient1 = createTestPatient(name: "Patient 1")
            let patient2 = createTestPatient(name: "Patient 2")

            // Build navigation stack
            router.navigateToPatientDetail(patient1)
            router.navigateToMedicalHistory(patient1)
            router.navigateToPatientDetail(patient2)
            router.navigateToAppointmentHistory(patient2)

            #expect(router.navigationPath.count == 4)

            // Start edit flow from deep in navigation
            Task {
                let result = await router.editPatient(patient2)
                if case let .updated(updatedPatient, _) = result {
                    #expect(updatedPatient.name == "Updated Patient 2")
                }
            }

            // Wait for form presentation
            await Task.yield()
            #expect(router.presentedForm != nil)

            // Complete the edit
            var updatedPatient2 = patient2
            updatedPatient2.name = "Updated Patient 2"
            router.handleResult(.updated(updatedPatient2))

            // Wait for form dismissal
            await Task.yield()
            #expect(router.presentedForm == nil)

            // Navigation stack should be preserved
            #expect(router.navigationPath.count == 4)
        }
    }

    @Test("Multiple form presentations in sequence")
    func multipleFormPresentationsInSequence() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()

            // Create first patient
            Task {
                let result1 = await router.createPatient()
                #expect(result1.isSuccess)

                // Immediately create second patient
                let result2 = await router.createPatient()
                #expect(result2.isSuccess)

                // Edit the second patient
                if case let .created(patient, _) = result2 {
                    let result3 = await router.editPatient(patient)
                    #expect(result3.isSuccess)
                }
            }

            // First form
            await Task.yield()
            #expect(router.presentedForm?.id == "create")
            let patient1 = createTestPatient(name: "Sequential Patient 1")
            router.handleResult(.created(patient1))

            // Second form
            await Task.yield()
            #expect(router.presentedForm?.id == "create")
            let patient2 = createTestPatient(name: "Sequential Patient 2")
            router.handleResult(.created(patient2))

            // Third form (edit)
            await Task.yield()
            #expect(router.presentedForm?.id == "edit-\(patient2.id.value.uuidString)")
            var updatedPatient2 = patient2
            updatedPatient2.name = "Updated Sequential Patient 2"
            router.handleResult(.updated(updatedPatient2))

            // All forms should be completed
            await Task.yield()
            #expect(router.presentedForm == nil)
        }
    }

    // MARK: - State Preservation Tests

    @Test("Navigation state preserved across form operations")
    func navigationStatePreservation() async {
        await withMainSerialExecutor {
            let router = PatientManagementFormRouter()
            let patient = createTestPatient()

            // Build navigation state
            router.navigateToPatientDetail(patient)
            router.navigateToMedicalHistory(patient)
            let initialPathCount = router.navigationPath.count
            #expect(initialPathCount == 2)

            // Perform form operation
            Task {
                let _ = await router.createPatient()
            }

            await Task.yield()
            #expect(router.presentedForm != nil)

            // Navigation path should remain unchanged during form presentation
            #expect(router.navigationPath.count == initialPathCount)

            // Complete form
            let newPatient = createTestPatient(name: "New Patient")
            router.handleResult(.created(newPatient))

            await Task.yield()

            // Navigation path should still be preserved
            #expect(router.navigationPath.count == initialPathCount)
        }
    }
}
