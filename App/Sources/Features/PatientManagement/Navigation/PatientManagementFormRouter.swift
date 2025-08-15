// PatientManagementFormRouter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import FactoryKit
import Observation
import StateKit
import SwiftUIRouting

// MARK: - Patient Form Router

final class PatientManagementFormRouter: BaseFormRouter<PatientFormMode, PatientFormResult> {
    // MARK: - Properties

    /// Callback to refresh the patient list when a patient is created or updated
    var onPatientListNeedsRefresh: (() async -> Void)?

    @Injected(\.routerEventBroker)
    private var eventBroker: EventBroker
    @Injected(\.routerEventFactory)
    private var eventFactory: RouterEventFactory

    // MARK: - Form Routing Methods

    func createPatient() async -> PatientFormResult {
        // Publish form presentation requested event
        eventBroker.publish(eventFactory.formPresentationRequested(mode: .create))

        let result = await presentForm(.create)

        // Publish form presentation completed event
        eventBroker.publish(eventFactory.formPresentationCompleted(mode: .create, result: result))

        // Trigger list refresh if patient was created successfully (keeping callback during transition)
        if case .created = result {
            await onPatientListNeedsRefresh?()
        }

        return result
    }

    func editPatient(_ patient: Patient) async -> PatientFormResult {
        let mode = PatientFormMode.edit(patient)

        // Publish form presentation requested event
        eventBroker.publish(eventFactory.formPresentationRequested(mode: mode))

        let result = await presentForm(mode)

        // Publish form presentation completed event
        eventBroker.publish(eventFactory.formPresentationCompleted(mode: mode, result: result))

        // Trigger list refresh if patient was updated successfully (keeping callback during transition)
        if case .updated = result {
            await onPatientListNeedsRefresh?()
        }

        return result
    }

    // MARK: - Navigation Methods

    func navigateToPatientDetail(_ patient: Patient) {
        let route = PatientRoute.patientDetail(patient)

        // Publish navigation requested event
        eventBroker.publish(eventFactory.navigationRequested(route: route))

        navigate(to: route)

        // Publish navigation completed event
        eventBroker.publish(eventFactory.navigationCompleted(route: route))
    }

    func navigateToMedicalHistory(_ patient: Patient) {
        let route = PatientRoute.medicalHistory(patient)

        // Publish navigation requested event
        eventBroker.publish(eventFactory.navigationRequested(route: route))

        navigate(to: route)

        // Publish navigation completed event
        eventBroker.publish(eventFactory.navigationCompleted(route: route))
    }

    func navigateToAppointmentHistory(_ patient: Patient) {
        let route = PatientRoute.appointmentHistory(patient)

        // Publish navigation requested event
        eventBroker.publish(eventFactory.navigationRequested(route: route))

        navigate(to: route)

        // Publish navigation completed event
        eventBroker.publish(eventFactory.navigationCompleted(route: route))
    }
}

extension Container {
    @MainActor
    var patientManagementRouter: Factory<PatientManagementFormRouter> {
        self {
            PatientManagementFormRouter()
        }
        .shared
    }
}
