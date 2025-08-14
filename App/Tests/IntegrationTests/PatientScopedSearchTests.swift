// PatientScopedSearchTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-14 04:01 GMT.

import Foundation
import SwiftData
import Testing
@testable import VetNet

// MARK: - Patient Scoped Search Integration Tests

@Suite("Patient Scoped Search", .serialized)
@MainActor
struct PatientScopedSearchTests {
    @Test("Search with name scope should only return patients matching by name")
    func searchByNameScopeOnlyMatchesPatientNames() async throws {
        // Given - Repository with test data where "Bella" appears in both name and owner fields
        let container = try ModelContainer(
            for: PatientEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let repository = SwiftDataPatientRepository(modelContext: context)

        // Insert patient named Bella
        let bellaDog = Patient(
            id: Patient.ID(),
            name: "Bella",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "John Smith",
            ownerPhoneNumber: "555-0001"
        )
        _ = try await repository.create(bellaDog)

        // Insert patient owned by Bella Johnson
        let maxCat = Patient(
            id: Patient.ID(),
            name: "Max",
            species: .cat,
            breed: .catPersian,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years old
            weight: Measurement(value: 4.5, unit: .kilograms),
            ownerName: "Bella Johnson",
            ownerPhoneNumber: "555-0002"
        )
        _ = try await repository.create(maxCat)

        // When - Search for "Bella" with name scope
        let results = try await repository.searchWithPagination(
            "Bella",
            scope: .name,
            limit: 10
        )

        // Then - Should only find the patient named Bella, not the one owned by Bella
        #expect(results.items.count == 1)
        #expect(results.items.first?.name == "Bella")
        #expect(results.items.first?.ownerName == "John Smith")
    }

    @Test("Search with owner scope should only return patients matching by owner name")
    func searchByOwnerScopeOnlyMatchesOwnerNames() async throws {
        // Given - Repository with test data
        let container = try ModelContainer(
            for: PatientEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let repository = SwiftDataPatientRepository(modelContext: context)

        // Insert patients with similar names in different fields
        let bellaDog = Patient(
            id: Patient.ID(),
            name: "Bella",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3),
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "John Smith",
            ownerPhoneNumber: "555-0001"
        )
        _ = try await repository.create(bellaDog)

        let maxCat = Patient(
            id: Patient.ID(),
            name: "Max",
            species: .cat,
            breed: .catPersian,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2),
            weight: Measurement(value: 4.5, unit: .kilograms),
            ownerName: "Bella Johnson",
            ownerPhoneNumber: "555-0002"
        )
        _ = try await repository.create(maxCat)

        // When - Search for "Bella" with owner scope
        let results = try await repository.searchWithPagination(
            "Bella",
            scope: .owner,
            limit: 10
        )

        // Then - Should only find the patient owned by Bella Johnson
        #expect(results.items.count == 1)
        #expect(results.items.first?.name == "Max")
        #expect(results.items.first?.ownerName == "Bella Johnson")
    }

    @Test("Search with species scope should return exact matches for species")
    func searchBySpeciesScopeExactMatch() async throws {
        // Given - Repository with various species
        let container = try ModelContainer(
            for: PatientEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let repository = SwiftDataPatientRepository(modelContext: context)

        // Insert various animals
        let dog1 = Patient(
            id: Patient.ID(),
            name: "Buddy",
            species: .dog,
            breed: .dogGoldenRetriever,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 5),
            weight: Measurement(value: 30, unit: .kilograms),
            ownerName: "Alice Brown",
            ownerPhoneNumber: "555-0003"
        )
        _ = try await repository.create(dog1)

        let cat1 = Patient(
            id: Patient.ID(),
            name: "Whiskers",
            species: .cat,
            breed: .catSiamese,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4),
            weight: Measurement(value: 3.8, unit: .kilograms),
            ownerName: "Bob Wilson",
            ownerPhoneNumber: "555-0004"
        )
        _ = try await repository.create(cat1)

        let bird1 = Patient(
            id: Patient.ID(),
            name: "Tweety",
            species: .bird,
            breed: .birdParrot,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2),
            weight: Measurement(value: 0.5, unit: .kilograms),
            ownerName: "Carol Davis",
            ownerPhoneNumber: "555-0005"
        )
        _ = try await repository.create(bird1)

        // When - Search for "Cat" with species scope
        let results = try await repository.searchWithPagination(
            "Cat",
            scope: .species,
            limit: 10
        )

        // Then - Should only find cats
        #expect(results.items.count == 1)
        #expect(results.items.first?.species == .cat)
        #expect(results.items.first?.name == "Whiskers")
    }

    @Test("Search with breed scope should match breed names")
    func searchByBreedScopeMatchesBreedNames() async throws {
        // Given - Repository with various breeds
        let container = try ModelContainer(
            for: PatientEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let repository = SwiftDataPatientRepository(modelContext: context)

        // Insert dogs with different breeds
        let labrador = Patient(
            id: Patient.ID(),
            name: "Charlie",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3),
            weight: Measurement(value: 28, unit: .kilograms),
            ownerName: "David Miller",
            ownerPhoneNumber: "555-0006"
        )
        _ = try await repository.create(labrador)

        let goldenRetriever = Patient(
            id: Patient.ID(),
            name: "Sandy",
            species: .dog,
            breed: .dogGoldenRetriever,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4),
            weight: Measurement(value: 32, unit: .kilograms),
            ownerName: "Eve Thompson",
            ownerPhoneNumber: "555-0007"
        )
        _ = try await repository.create(goldenRetriever)

        let persian = Patient(
            id: Patient.ID(),
            name: "Fluffy",
            species: .cat,
            breed: .catPersian,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2),
            weight: Measurement(value: 4.2, unit: .kilograms),
            ownerName: "Frank Garcia",
            ownerPhoneNumber: "555-0008"
        )
        _ = try await repository.create(persian)

        // When - Search for "Labrador" with breed scope
        let results = try await repository.searchWithPagination(
            "Labrador",
            scope: .breed,
            limit: 10
        )

        // Then - Should only find Labrador breed
        #expect(results.items.count == 1)
        #expect(results.items.first?.breed == .dogLabrador)
        #expect(results.items.first?.name == "Charlie")
    }

    @Test("Search with all scope should match across all fields")
    func searchByAllScopeMatchesAllFields() async throws {
        // Given - Repository with test data
        let container = try ModelContainer(
            for: PatientEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let repository = SwiftDataPatientRepository(modelContext: context)

        // Insert patients with "Golden" in different fields
        let goldenRetriever = Patient(
            id: Patient.ID(),
            name: "Max",
            species: .dog,
            breed: .dogGoldenRetriever, // "Golden" in breed
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4),
            weight: Measurement(value: 32, unit: .kilograms),
            ownerName: "Sarah White",
            ownerPhoneNumber: "555-0009"
        )
        _ = try await repository.create(goldenRetriever)

        let goldenNamed = Patient(
            id: Patient.ID(),
            name: "Golden", // "Golden" in name
            species: .cat,
            breed: .catSiamese,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3),
            weight: Measurement(value: 3.5, unit: .kilograms),
            ownerName: "Tom Brown",
            ownerPhoneNumber: "555-0010"
        )
        _ = try await repository.create(goldenNamed)

        let ownedByGolden = Patient(
            id: Patient.ID(),
            name: "Spike",
            species: .dog,
            breed: .dogBeagle,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2),
            weight: Measurement(value: 15, unit: .kilograms),
            ownerName: "Golden Smith",
            ownerPhoneNumber: "555-0011" // "Golden" in owner name
        )
        _ = try await repository.create(ownedByGolden)

        // When - Search for "Golden" with all scope
        let results = try await repository.searchWithPagination(
            "Golden",
            scope: .all,
            limit: 10
        )

        // Then - Should find all patients with "Golden" in any field
        #expect(results.items.count == 3)
        let names = Set(results.items.map(\.name))
        #expect(names.contains("Max")) // Golden Retriever breed
        #expect(names.contains("Golden")) // Named Golden
        #expect(names.contains("Spike")) // Owned by Golden Smith
    }
}
