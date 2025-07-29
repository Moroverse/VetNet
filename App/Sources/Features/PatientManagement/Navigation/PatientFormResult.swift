//
//  PatientFormResult.swift
//  VetNet
//
//  Created by Daniel Moro on 24. 7. 2025..
//

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
        if case .error(let error) = self { return error }
        return nil
    }
    
    var patient: Patient? {
        switch self {
        case .created(let patient, _), .updated(let patient, _), .deleted(let patient, _):
            return patient
        case .cancelled, .error:
            return nil
        }
    }
    
    var successMessage: String? {
        switch self {
        case .created(_, let message), .updated(_, let message), .deleted(_, let message):
            return message
        case .cancelled, .error:
            return nil
        }
    }
}
