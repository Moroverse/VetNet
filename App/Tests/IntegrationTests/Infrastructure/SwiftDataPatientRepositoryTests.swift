// SwiftDataPatientRepositoryTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-02.

import Foundation
import SwiftData
import Testing
@testable import VetNet

// MARK: - SwiftData Patient Repository Integration Tests

/// Integration tests for SwiftDataPatientRepository
/// Validates entity-domain mapping, persistence operations, and business rule enforcement
@Suite("SwiftData Patient Repository Integration Tests", .serialized)
struct SwiftDataPatientRepositoryTests {
    
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
    
    // MARK: - Test Helpers
    
    /// Creates a valid test patient with all required fields
    private func createTestPatient(
        id: Patient.ID = .init(),
        name: String = "Max",
        species: Species = .dog,
        breed: Breed = .dogLabrador,
        medicalID: String? = nil
    ) -> Patient {
        Patient(
            id: id,
            name: name,
            species: species,
            breed: breed,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60), // 1 year old
            weight: Measurement(value: 25.5, unit: .kilograms),
            ownerName: "John Doe",
            ownerPhoneNumber: "+1-555-0123",
            ownerEmail: "john.doe@example.com",
            medicalID: medicalID,
            microchipNumber: "123456789",
            notes: "Friendly dog, loves treats"
        )
    }
    
    // MARK: - Entity-Domain Mapping Tests
    
    @Test("Entity to domain model mapping preserves all fields")
    @MainActor
    func testEntityToDomainMapping() throws {
        // Given
        let patient = createTestPatient()
        let entity = PatientEntity.fromDomainModel(patient)
        
        // When
        let mappedPatient = entity.toDomainModel()
        
        // Then
        #expect(mappedPatient != nil, "Mapping should succeed")
        guard let result = mappedPatient else { return }
        
        // Verify all fields are preserved
        #expect(result.id.value == patient.id.value)
        #expect(result.name == patient.name)
        #expect(result.species == patient.species)
        #expect(result.breed == patient.breed)
        #expect(result.birthDate == patient.birthDate)
        #expect(result.weight.value == patient.weight.value)
        #expect(result.weight.unit == patient.weight.unit)
        #expect(result.ownerName == patient.ownerName)
        #expect(result.ownerPhoneNumber == patient.ownerPhoneNumber)
        #expect(result.ownerEmail == patient.ownerEmail)
        #expect(result.medicalID == patient.medicalID)
        #expect(result.microchipNumber == patient.microchipNumber)
        #expect(result.notes == patient.notes)
    }
    
    @Test("Domain to entity mapping handles different weight units correctly")
    @MainActor
    func testWeightUnitMapping() throws {
        // Test various weight units
        let units: [(UnitMass, String)] = [
            (.kilograms, "kg"),
            (.grams, "g"),
            (.pounds, "lb"),
            (.ounces, "oz")
        ]
        
        for (unit, expectedSymbol) in units {
            // Given
            var patient = createTestPatient()
            patient.weight = Measurement(value: 10.0, unit: unit)
            
            // When
            let entity = PatientEntity.fromDomainModel(patient)
            
            // Then
            #expect(entity.weightValue == 10.0)
            #expect(entity.weightUnitSymbol == expectedSymbol)
            
            // Verify round-trip mapping
            let mapped = entity.toDomainModel()
            #expect(mapped?.weight.value == 10.0)
            #expect(mapped?.weight.unit == unit)
        }
    }
    
    @Test("Entity mapping handles invalid data gracefully")
    @MainActor
    func testInvalidDataMapping() throws {
        // Given - Entity with invalid species
        let entity = PatientEntity()
        entity.id = UUID().uuidString
        entity.speciesRawValue = "invalid_species"
        entity.breedRawValue = "labrador"
        
        // When
        let mapped = entity.toDomainModel()
        
        // Then
        #expect(mapped == nil, "Mapping should fail for invalid species")
    }
    
    // MARK: - CRUD Operation Tests
    
    @Test("Create patient successfully persists data")
    @MainActor
    func testCreatePatient() async throws {
        // Given
        let repository = try createTestRepository()
        let patient = createTestPatient()
        
        // When
        let savedPatient = try await repository.create(patient)
        
        // Then
        #expect(savedPatient.id == patient.id)
        #expect(savedPatient.name == patient.name)
        
        // Verify it can be retrieved
        let retrieved = try await repository.findById(patient.id)
        #expect(retrieved != nil)
        #expect(retrieved?.medicalID == patient.medicalID)
    }
    
    @Test("Update patient modifies existing data")
    @MainActor
    func testUpdatePatient() async throws {
        // Given
        let repository = try createTestRepository()
        let patient = createTestPatient()
        let created = try await repository.create(patient)
        
        // When - Update the patient
        var updated = created
        updated.name = "Max Updated"
        updated.weight = Measurement(value: 30.0, unit: .kilograms)
        updated.notes = "Updated notes"
        
        let result = try await repository.update(updated)
        
        // Then
        #expect(result.name == "Max Updated")
        #expect(result.weight.value == 30.0)
        #expect(result.notes == "Updated notes")
        
        // Verify persistence
        let retrieved = try await repository.findById(patient.id)
        #expect(retrieved?.name == "Max Updated")
    }
    
    @Test("Delete patient removes from storage")
    @MainActor
    func testDeletePatient() async throws {
        // Given
        let repository = try createTestRepository()
        let patient = createTestPatient()
        _ = try await repository.create(patient)
        
        // When
        try await repository.delete(patient.id)
        
        // Then
        let retrieved = try await repository.findById(patient.id)
        #expect(retrieved == nil, "Patient should be deleted")
    }
    
    // MARK: - Uniqueness Constraint Tests
    
    @Test("Medical ID uniqueness is enforced at repository level")
    @MainActor
    func testMedicalIDUniqueness() async throws {
        // Given
        let repository = try createTestRepository()
        let patient1 = createTestPatient(name: "Max", medicalID: "VET-001")
        let patient2 = createTestPatient(name: "Bella", medicalID: "VET-001") // Same medical ID
        
        // When - Create first patient
        _ = try await repository.create(patient1)
        
        // Then - Second patient with same medical ID should fail
        await #expect(throws: RepositoryError.self) {
            try await repository.create(patient2)
        }
    }
    
    @Test("medicalIDExists correctly identifies existing IDs")
    @MainActor
    func testMedicalIDExists() async throws {
        // Given
        let repository = try createTestRepository()
        let patient = createTestPatient(medicalID: "VET-123")
        
        // When - Before creation
        let existsBefore = try await repository.medicalIDExists("VET-123")
        #expect(!existsBefore, "Medical ID should not exist before creation")
        
        // Create patient
        _ = try await repository.create(patient)
        
        // Then - After creation
        let existsAfter = try await repository.medicalIDExists("VET-123")
        #expect(existsAfter, "Medical ID should exist after creation")
    }
    
    // MARK: - Search Operation Tests
    
    @Test("Search by name is case-insensitive")
    @MainActor
    func testSearchByName() async throws {
        // Given
        let repository = try createTestRepository()
        let patients = [
            createTestPatient(name: "Max"),
            createTestPatient(name: "Maximus"),
            createTestPatient(name: "Bella")
        ]
        
        for patient in patients {
            _ = try await repository.create(patient)
        }
        
        // When - Search with different cases
        let results1 = try await repository.searchByName("max")
        let results2 = try await repository.searchByName("MAX")
        let results3 = try await repository.searchByName("MaX")
        
        // Then
        #expect(results1.count == 2, "Should find Max and Maximus")
        #expect(results2.count == 2, "Case-insensitive search")
        #expect(results3.count == 2, "Mixed case search")
    }
    
    @Test("Find by species returns correct patients")
    @MainActor
    func testFindBySpecies() async throws {
        // Given
        let repository = try createTestRepository()
        let dog1 = createTestPatient(name: "Max", species: .dog)
        let dog2 = createTestPatient(name: "Bella", species: .dog)
        let cat = createTestPatient(name: "Whiskers", species: .cat, breed: .catPersian)
        
        _ = try await repository.create(dog1)
        _ = try await repository.create(dog2)
        _ = try await repository.create(cat)
        
        // When
        let dogs = try await repository.findBySpecies(.dog)
        let cats = try await repository.findBySpecies(.cat)
        
        // Then
        #expect(dogs.count == 2)
        #expect(cats.count == 1)
        #expect(cats.first?.name == "Whiskers")
    }
    
    // MARK: - Pagination Tests
    
    @Test("Pagination returns all items when no limit applied")
    @MainActor
    func testPaginationWithoutLimit() async throws {
        // Given
        let repository = try createTestRepository()
        for i in 1...5 {
            let patient = createTestPatient(name: "Patient \(i)")
            _ = try await repository.create(patient)
        }
        
        // When
        let paginated = try await repository.findWithPagination(limit: 10)
        
        // Then
        #expect(paginated.items.count == 5)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Repository throws notFound error for non-existent patient")
    @MainActor
    func testNotFoundError() async throws {
        // Given
        let repository = try createTestRepository()
        let nonExistentId = Patient.ID()
        
        // When/Then - Update non-existent patient
        await #expect(throws: RepositoryError.notFound) {
            let patient = createTestPatient(id: nonExistentId)
            _ = try await repository.update(patient)
        }
        
        // When/Then - Delete non-existent patient
        await #expect(throws: RepositoryError.notFound) {
            try await repository.delete(nonExistentId)
        }
    }
    
    // MARK: - CloudKit Preparation Tests
    
    @Test("Entity includes CloudKit zone configuration")
    @MainActor
    func testCloudKitZoneConfiguration() throws {
        // Given
        let patient = createTestPatient()
        
        // When
        let entity = PatientEntity.fromDomainModel(patient, cloudKitZone: "VetNetSecure")
        
        // Then
        #expect(entity.cloudKitZone == "VetNetSecure")
    }
    
    @Test("Entity creation uses default CloudKit zone")
    @MainActor
    func testDefaultCloudKitZone() throws {
        // Given
        let patient = createTestPatient()
        
        // When - Create without specifying zone
        let entity = PatientEntity.fromDomainModel(patient)
        
        // Then
        #expect(entity.cloudKitZone == "VetNetSecure", "Should use default secure zone")
    }
}
