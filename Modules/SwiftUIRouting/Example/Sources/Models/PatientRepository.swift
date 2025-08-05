// PatientRepository.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import Foundation
import Observation

@Observable
class PatientRepository {
    var patients: [Patient] = []
    var isLoading: Bool = false
    var errorMessage: String?

    init() {
        loadPatients()
    }

    func loadPatients() {
        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)

            self.patients = Patient.previews
            self.isLoading = false
        }
    }

    func addPatient(_ patient: Patient) {
        patients.append(patient)
    }

    func updatePatient(_ patient: Patient) {
        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[index] = patient
        }
    }

    func deletePatient(_ patient: Patient) {
        patients.removeAll { $0.id == patient.id }
    }

    func deletePatients(at offsets: IndexSet) {
        patients.remove(atOffsets: offsets)
    }

    func patient(withId id: UUID) -> Patient? {
        patients.first { $0.id == id }
    }
}
