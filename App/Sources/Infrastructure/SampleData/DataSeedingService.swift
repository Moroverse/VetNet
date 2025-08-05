// DataSeedingService.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-05 03:57 GMT.

import FactoryKit
import Foundation

// MARK: - Data Seeding Service

final class DataSeedingService: Sendable {
    @Injected(\.patientRepository) private var patientRepository

    // MARK: - Public Interface

    /// Seed the database with sample patient data
    /// - Parameter force: If true, will clear existing data before seeding
    /// - Note: Only works with production database, not mock repository
    func seedPatientData(force: Bool = false) async throws {
        // Prevent seeding if using mock repository
        let featureFlagService = Container.shared.featureFlagService()
        if featureFlagService.isEnabled(.useMockData) {
            print("⚠️ Cannot seed sample data when using mock repository. Switch to production database first.")
            return
        }

        // Check if data already exists
        let existingCount = try await patientRepository.count()

        if existingCount > 0, !force {
            print("📊 Sample data already exists (\(existingCount) patients). Use force: true to reseed.")
            return
        }

        if force, existingCount > 0 {
            print("🗑️ Clearing existing patient data...")
            try await clearExistingPatients()
        }

        print("🌱 Seeding sample patient data...")

        let samplePatients = PatientSampleDataService.generateSamplePatients()
        var successCount = 0
        var failureCount = 0

        // Insert patients one by one to handle potential conflicts gracefully
        for patient in samplePatients {
            do {
                _ = try await patientRepository.create(patient)
                successCount += 1
                print("✅ Created patient: \(patient.name) (\(patient.species.displayName))")
            } catch {
                failureCount += 1
                print("❌ Failed to create patient \(patient.name): \(error.localizedDescription)")
            }
        }

        print("🎉 Data seeding completed: \(successCount) patients created, \(failureCount) failures")
    }

    /// Clear all patient data from the repository
    func clearAllPatientData() async throws {
        print("🗑️ Clearing all patient data...")
        try await clearExistingPatients()
        print("✅ All patient data cleared")
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
                print("⚠️ Failed to delete patient \(patient.name): \(error.localizedDescription)")
            }
        }
    }
}
