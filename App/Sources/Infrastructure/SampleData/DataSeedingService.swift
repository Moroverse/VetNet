// DataSeedingService.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-05 03:57 GMT.

import FactoryKit
import Foundation

// MARK: - Data Seeding Service

final class DataSeedingService: Sendable {
    @Injected(\.patientRepository) private var patientRepository
    @Injected(\.loggingService) private var logger

    // MARK: - Public Interface

    /// Seed the database with sample patient data
    /// - Parameter force: If true, will clear existing data before seeding
    /// - Note: Only works with production database, not mock repository
    func seedPatientData(force: Bool = false) async throws {
        // Prevent seeding if using mock repository
        let featureFlagService = Container.shared.featureFlagService()
        if featureFlagService.isEnabled(.useMockData) {
            logger.warning("Cannot seed sample data when using mock repository. Switch to production database first.", category: .development)
            return
        }

        // Check if data already exists
        let existingCount = try await patientRepository.count()

        if existingCount > 0, !force {
            logger.info("Sample data already exists (\(existingCount) patients). Use force: true to reseed.", category: .data)
            return
        }

        if force, existingCount > 0 {
            logger.info("Clearing existing patient data...", category: .data)
            try await clearExistingPatients()
        }

        logger.info("Seeding sample patient data...", category: .development)

        let samplePatients = PatientSampleDataService.generateSamplePatients()
        var successCount = 0
        var failureCount = 0

        // Insert patients one by one to handle potential conflicts gracefully
        for patient in samplePatients {
            do {
                _ = try await patientRepository.create(patient)
                successCount += 1
                logger.debug("Created patient: \(patient.name) (\(patient.species.displayName))", category: .data)
            } catch {
                failureCount += 1
                logger.error("Failed to create patient \(patient.name): \(error.localizedDescription)", category: .data)
            }
        }

        logger.info("Data seeding completed: \(successCount) patients created, \(failureCount) failures", category: .development)
    }

    /// Clear all patient data from the repository
    func clearAllPatientData() async throws {
        logger.info("Clearing all patient data...", category: .data)
        try await clearExistingPatients()
        logger.info("All patient data cleared", category: .data)
    }

    /// Check if sample data has been seeded
    func isSampleDataSeeded() async throws -> Bool {
        let count = try await patientRepository.count()
        return count >= 20 // We generate 22 patients, so 20+ indicates seeded data
    }

    // MARK: - Private Methods

    private func clearExistingPatients() async throws {
        let existingPatients = try await patientRepository.findAll()

        for patient in existingPatients {
            do {
                try await patientRepository.delete(patient.id)
            } catch {
                logger.warning("Failed to delete patient \(patient.name): \(error.localizedDescription)", category: .data)
            }
        }
    }
}
