// PatientFormMode.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import Foundation
import SwiftUIRouting

enum PatientFormMode: Identifiable, Hashable {
    case create
    case edit(Patient)

    var id: String {
        switch self {
        case .create:
            "create"
        case let .edit(patient):
            "edit-\(patient.id.uuidString)"
        }
    }

    var title: String {
        switch self {
        case .create:
            "New Patient"
        case .edit:
            "Edit Patient"
        }
    }

    var patient: Patient? {
        switch self {
        case .create:
            nil
        case let .edit(patient):
            patient
        }
    }
}

typealias PatientFormResult = FormOperationResult<Patient>

enum PatientRoute: Hashable {
    case patientDetail(Patient)
}
