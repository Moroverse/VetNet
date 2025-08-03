// PatientRepository.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:58 GMT.

import Foundation
import StateKit

// MARK: - Core CRUD Repository

/// Basic CRUD operations for single patient entities
protocol PatientCRUDRepository: Sendable {
    /// Create a new patient
    func create(_ patient: Patient) async throws -> Patient

    /// Read a patient by ID (core CRUD read operation)
    func findById(_ id: Patient.ID) async throws -> Patient?

    /// Update an existing patient
    func update(_ patient: Patient) async throws -> Patient

    /// Delete a patient by ID
    func delete(_ id: Patient.ID) async throws
}

// MARK: - Search Repository

/// Search, filtering, and bulk query operations for patients
protocol PatientSearchRepository: Sendable {
    /// Find all patients (bulk query operation)
    func findAll() async throws -> [Patient]

    /// Find a patient by medical ID
    func findByMedicalID(_ medicalID: String) async throws -> Patient?

    /// Search patients by name (case-insensitive)
    func searchByName(_ nameQuery: String) async throws -> [Patient]

    /// Find patients by species
    func findBySpecies(_ species: Species) async throws -> [Patient]

    /// Find patients by owner name (case-insensitive)
    func findByOwnerName(_ ownerName: String) async throws -> [Patient]

    /// Find patients created within date range
    func findCreatedBetween(startDate: Date, endDate: Date) async throws -> [Patient]
}

// MARK: - Utility Repository

/// Utility operations for patient data
protocol PatientUtilityRepository: Sendable {
    /// Count total number of patients
    func count() async throws -> Int

    /// Check if a medical ID already exists
    func medicalIDExists(_ medicalID: String) async throws -> Bool
}

// MARK: - Pagination Repository

/// Pagination support for patient queries using StateKit
protocol PatientPaginationRepository: Sendable {
    /// Find patients with pagination
    func findWithPagination(limit: Int) async throws -> Paginated<Patient>

    /// Search patients by name with pagination
    func searchByNameWithPagination(_ nameQuery: String, limit: Int) async throws -> Paginated<Patient>
}

// MARK: - Composed Repository Protocol

/// Complete patient repository interface composed from focused protocols
/// Uses protocol composition to provide full functionality while maintaining ISP

typealias PatientRepositoryProtocol = PatientCRUDRepository &
    PatientPaginationRepository &
    PatientSearchRepository &
    PatientUtilityRepository

// MARK: - Repository Error

/// Errors that can occur during repository operations
nonisolated enum RepositoryError: Error, Sendable {
    case notFound
    case duplicateKey(String)
    case validationFailed([String])
    case databaseError(String)
    case unknownError(String)
}

// MARK: - Repository Error Extensions

extension RepositoryError: LocalizedError, Equatable {
    nonisolated var errorDescription: String? {
        switch self {
        case .notFound:
            "The requested resource was not found"
        case let .duplicateKey(key):
            "A record with key '\(key)' already exists"
        case let .validationFailed(errors):
            "Validation failed: \(errors.joined(separator: ", "))"
        case let .databaseError(message):
            "Database error: \(message)"
        case let .unknownError(message):
            "Unknown error: \(message)"
        }
    }
}
