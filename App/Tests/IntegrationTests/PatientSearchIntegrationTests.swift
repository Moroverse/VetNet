// PatientSearchIntegrationTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-13 09:22 GMT.

import Foundation
import StateKit
import SwiftData
import Testing
@testable import VetNet

// MARK: - Patient Search Integration Tests

/// Integration tests for comprehensive patient search functionality
/// Following TDD principles: Red → Green → Refactor
@Suite("Patient Search Integration Tests", .serialized)
@MainActor
struct PatientSearchIntegrationTests {
    // MARK: - Test Container Setup

    /// Creates an in-memory ModelContainer for testing
    private func createTestContainer() throws -> ModelContainer {
        let schema = Schema([PatientEntity.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Creates a test repository with in-memory storage
    @MainActor
    private func createTestRepository() throws -> SwiftDataPatientRepository {
        let container = try createTestContainer()
        let context = ModelContext(container)
        return SwiftDataPatientRepository(modelContext: context)
    }

    // MARK: - Test: Search by partial name

    @Test("Search by partial name returns matching patients")
    @MainActor
    func searchByPartialName() async throws {
        // Given
        let repository = try createTestRepository()
        let patient = Patient(
            name: "Bella",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years
            weight: Measurement(value: 25.5, unit: .kilograms),
            ownerName: "John Smith",
            ownerPhoneNumber: "+1-555-0123",
            ownerEmail: "john.smith@example.com",
            medicalID: "DOG-001"
        )
        _ = try await repository.create(patient)

        // When - Search for "Bel"
        let results = try await repository.searchByName("Bel")

        // Then
        #expect(results.count == 1)
        #expect(results.first?.name == "Bella")
    }
}
