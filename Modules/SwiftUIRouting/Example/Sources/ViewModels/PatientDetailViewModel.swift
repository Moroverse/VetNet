// PatientDetailViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import SwiftUI
import SwiftUIRouting

@Observable
class PatientDetailViewModel {
    private let repository: PatientRepository
    private let router: PatientRouter
    private let patientId: UUID

    var patient: Patient {
        repository.patient(withId: patientId) ?? Patient.preview
    }

    var isLoading: Bool = false
    var errorMessage: String?

    var formattedLastVisit: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: patient.lastVisit)
    }

    var ageDescription: String {
        "\(patient.age) years old"
    }

    init(patientId: UUID, repository: PatientRepository, router: PatientRouter) {
        self.patientId = patientId
        self.repository = repository
        self.router = router
    }

    func scheduleAppointment() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        print("Appointment scheduled for patient: \(patient.name)")
    }

    func exportMedicalRecord() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 500_000_000)

        print("Medical record exported for patient: \(patient.name)")
    }

    func editPatient() async {
        let result = await router.editPatient(patient)

        switch result {
        case let .updated(updatedPatient):
            repository.updatePatient(updatedPatient)
        case .cancelled:
            break
        case .created, .error:
            break
        }
    }
}
