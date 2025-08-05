// PatientFormResult.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

import SwiftUIRouting

/// Result type for patient form operations
/// Provides type-safe results with detailed feedback for form operations
enum PatientFormResult: RouteResult {
    case created(Patient, message: String = "Patient created successfully")
    case updated(Patient, message: String = "Patient updated successfully")
    case deleted(Patient, message: String = "Patient deleted successfully")
    case cancelled
    case error(Error)

    // Required by RouteResult protocol
    typealias SuccessType = Patient
    typealias ErrorType = Error

    var isSuccess: Bool {
        switch self {
        case .created, .updated, .deleted: true
        case .cancelled, .error: false
        }
    }

    var isCancelled: Bool {
        if case .cancelled = self { return true }
        return false
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }

    var error: Error? {
        if case let .error(error) = self { return error }
        return nil
    }

    var patient: Patient? {
        switch self {
        case let .created(patient, _), let .updated(patient, _), let .deleted(patient, _):
            patient
        case .cancelled, .error:
            nil
        }
    }

    var successMessage: String? {
        switch self {
        case let .created(_, message), let .updated(_, message), let .deleted(_, message):
            message
        case .cancelled, .error:
            nil
        }
    }
}
