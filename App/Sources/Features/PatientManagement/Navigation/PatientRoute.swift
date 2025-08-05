// PatientRoute.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-29 14:43 GMT.

/// Navigation routes for patient management module
/// Defines the different destinations within the patient management flow
enum PatientRoute: Hashable {
    case patientDetail(Patient)
    case medicalHistory(Patient)
    case appointmentHistory(Patient)
}
