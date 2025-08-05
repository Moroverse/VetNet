// CreatePatientViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import SwiftUI

@Observable
class CreatePatientViewModel {
    var name: String = ""
    var age: String = ""
    var medicalRecordNumber: String = ""
    var condition: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let existingPatient: Patient?

    init(patient: Patient? = nil) {
        existingPatient = patient
        if let patient {
            name = patient.name
            age = "\(patient.age)"
            medicalRecordNumber = patient.medicalRecordNumber
            condition = patient.condition
        }
    }

    var isEditing: Bool {
        existingPatient != nil
    }

    var title: String {
        isEditing ? "Edit Patient" : "New Patient"
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            Int(age) != nil &&
            !medicalRecordNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !condition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() async throws -> Patient {
        guard isValid else {
            throw ValidationError.invalidInput
        }

        guard let ageInt = Int(age) else {
            throw ValidationError.invalidAge
        }

        isLoading = true
        defer { isLoading = false }

        try await Task.sleep(nanoseconds: 500_000_000)

        if isEditing, let existingPatient {
            return Patient(
                id: existingPatient.id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                age: ageInt,
                medicalRecordNumber: medicalRecordNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                condition: condition.trimmingCharacters(in: .whitespacesAndNewlines),
                lastVisit: existingPatient.lastVisit
            )
        } else {
            return Patient(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                age: ageInt,
                medicalRecordNumber: medicalRecordNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                condition: condition.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
}

nonisolated enum ValidationError: LocalizedError {
    case invalidInput
    case invalidAge

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            "Please fill in all fields"
        case .invalidAge:
            "Please enter a valid age"
        }
    }
}
