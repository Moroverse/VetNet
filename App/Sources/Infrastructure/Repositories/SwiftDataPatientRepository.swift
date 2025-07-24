// SwiftDataPatientRepository.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 20:23 GMT.

import Foundation
import StateKit
import SwiftData

// MARK: - SwiftData Patient Repository

/// SwiftData implementation of PatientRepositoryProtocol
/// Handles persistence operations and entity-domain mapping

final class SwiftDataPatientRepository: PatientRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - CRUD Repository Implementation

extension SwiftDataPatientRepository {
    func create(_ patient: Patient) async throws -> Patient {
        // Check if medical ID already exists
        if try await medicalIDExists(patient.medicalID) {
            throw RepositoryError.duplicateKey("medicalID: \(patient.medicalID)")
        }

        // Create entity from domain model
        let entity = PatientEntity.fromDomainModel(patient)

        // Insert into context
        modelContext.insert(entity)

        // Save changes
        do {
            try modelContext.save()
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }

        // Return domain model
        guard let domainModel = entity.toDomainModel() else {
            throw RepositoryError.unknownError("Failed to convert entity to domain model")
        }

        return domainModel
    }

    func findById(_ id: Patient.ID) async throws -> Patient? {
        let idString = id.value.uuidString

        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.first { $0.id == idString }?.toDomainModel()
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func update(_ patient: Patient) async throws -> Patient {
        // Find existing entity
        guard let entity = try await findEntityById(patient.id) else {
            throw RepositoryError.notFound
        }

        // Update entity from domain model
        entity.updateFromDomainModel(patient)

        // Save changes
        do {
            try modelContext.save()
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }

        // Return updated domain model
        guard let updatedModel = entity.toDomainModel() else {
            throw RepositoryError.unknownError("Failed to convert updated entity to domain model")
        }

        return updatedModel
    }

    func delete(_ id: Patient.ID) async throws {
        // Find existing entity
        guard let entity = try await findEntityById(id) else {
            throw RepositoryError.notFound
        }

        // Delete entity
        modelContext.delete(entity)

        // Save changes
        do {
            try modelContext.save()
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }
}

// MARK: - Search Repository Implementation

extension SwiftDataPatientRepository {
    func findAll() async throws -> [Patient] {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let patients = entities.compactMap { $0.toDomainModel() }
                .sorted { $0.name < $1.name }
            return patients
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func findByMedicalID(_ medicalID: String) async throws -> Patient? {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.first { $0.medicalID == medicalID }?.toDomainModel()
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func searchByName(_ nameQuery: String) async throws -> [Patient] {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let filteredEntities = entities.filter { $0.name.localizedCaseInsensitiveContains(nameQuery) }
            return filteredEntities.compactMap { $0.toDomainModel() }
                .sorted { $0.name < $1.name }
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func findBySpecies(_ species: Species) async throws -> [Patient] {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let filteredEntities = entities.filter { $0.speciesRawValue == species.rawValue }
            return filteredEntities.compactMap { $0.toDomainModel() }
                .sorted { $0.name < $1.name }
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func findByOwnerName(_ ownerName: String) async throws -> [Patient] {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let filteredEntities = entities.filter { $0.ownerName.localizedCaseInsensitiveContains(ownerName) }
            return filteredEntities.compactMap { $0.toDomainModel() }
                .sorted { $0.ownerName < $1.ownerName || ($0.ownerName == $1.ownerName && $0.name < $1.name) }
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func findCreatedBetween(startDate: Date, endDate: Date) async throws -> [Patient] {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let filteredEntities = entities.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
            return filteredEntities.compactMap { $0.toDomainModel() }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }
}

// MARK: - Pagination Repository Implementation

extension SwiftDataPatientRepository {
    func findWithPagination(limit: Int) async throws -> Paginated<Patient> {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let patients = entities.compactMap { $0.toDomainModel() }
                .sorted { $0.name < $1.name }

            return Paginated(items: patients)
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func searchByNameWithPagination(_ nameQuery: String, limit: Int) async throws -> Paginated<Patient> {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            let filteredEntities = entities.filter { $0.name.localizedCaseInsensitiveContains(nameQuery) }
            let patients = filteredEntities.compactMap { $0.toDomainModel() }
                .sorted { $0.name < $1.name }

            return Paginated(items: patients)
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }
}

// MARK: - Utility Repository Implementation

extension SwiftDataPatientRepository {
    func count() async throws -> Int {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }

    func medicalIDExists(_ medicalID: String) async throws -> Bool {
        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.contains { $0.medicalID == medicalID }
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }
}

// MARK: - Private Helper Methods

private extension SwiftDataPatientRepository {
    /// Find entity by patient ID
    /// - Parameter id: Patient domain ID
    /// - Returns: PatientEntity if found, nil otherwise
    func findEntityById(_ id: Patient.ID) async throws -> PatientEntity? {
        let idString = id.value.uuidString

        let descriptor = FetchDescriptor<PatientEntity>()

        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.first { $0.id == idString }
        } catch {
            throw RepositoryError.databaseError(error.localizedDescription)
        }
    }
}
