// PatientLoaderAdapterTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 04:07 GMT.

import FactoryKit
import Foundation
import StateKit
import Testing
import TestKit
@testable import VetNet

@Suite("Patient Loader Adapter Tests")
struct PatientLoaderAdapterTests {
    // MARK: - Test Helpers
    @MainActor
    private func makeSUT() -> (sut: PatientLoaderAdapter, spy: AsyncSpy<Paginated<Patient>>) {
        let spy = AsyncSpy<Paginated<Patient>>()
        Container.shared.patientPaginationRepository.register {
            spy
        }
        let sut = PatientLoaderAdapter()
        return (sut, spy)
    }

    private let allPatients: Paginated<Patient> = Paginated(items: [
        Patient(
            name: "Test Dog Alpha",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "Mock Owner 1",
            ownerPhoneNumber: "(555) 111-1111",
            ownerEmail: "mock1@test.com",
            medicalID: "MOCK-DOG-001"
        ),
        Patient(
            name: "Test Cat Beta",
            species: .cat,
            breed: .catPersian,
            birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years
            weight: Measurement(value: 4.5, unit: .kilograms),
            ownerName: "Mock Owner 2",
            ownerPhoneNumber: "(555) 222-2222",
            ownerEmail: "mock2@test.com",
            medicalID: "MOCK-CAT-001"
        )
    ], loadMore: {
        Paginated(items: [
            Patient(
                name: "Test Dog Alpha",
                species: .dog,
                breed: .dogLabrador,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years
                weight: Measurement(value: 25, unit: .kilograms),
                ownerName: "Mock Owner 1",
                ownerPhoneNumber: "(555) 111-1111",
                ownerEmail: "mock1@test.com",
                medicalID: "MOCK-DOG-001"
            ),
            Patient(
                name: "Test Cat Beta",
                species: .cat,
                breed: .catPersian,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years
                weight: Measurement(value: 4.5, unit: .kilograms),
                ownerName: "Mock Owner 2",
                ownerPhoneNumber: "(555) 222-2222",
                ownerEmail: "mock2@test.com",
                medicalID: "MOCK-CAT-001"
            ),
            Patient(
                name: "Test Dog Gamma",
                species: .dog,
                breed: .dogGermanShepherd,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 5), // 5 years
                weight: Measurement(value: 35, unit: .kilograms),
                ownerName: "Mock Owner 3",
                ownerPhoneNumber: "(555) 333-3333",
                ownerEmail: "mock3@test.com",
                medicalID: "MOCK-DOG-002"
            ),
            Patient(
                name: "Test Rabbit Delta",
                species: .rabbit,
                breed: .rabbitAngora,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 1), // 1 year
                weight: Measurement(value: 2, unit: .kilograms),
                ownerName: "Mock Owner 4",
                ownerPhoneNumber: "(555) 444-4444",
                ownerEmail: "mock4@test.com",
                medicalID: "MOCK-RABBIT-001"
            ),
            Patient(
                name: "Test Cat Epsilon",
                species: .cat,
                breed: .catSiamese,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4), // 4 years
                weight: Measurement(value: 3.8, unit: .kilograms),
                ownerName: "Mock Owner 5",
                ownerPhoneNumber: "(555) 555-5555",
                ownerEmail: "mock5@test.com",
                medicalID: "MOCK-CAT-002"
            )
        ])
    })

    // MARK: - Tests

    @Test("Load without search query returns all patients")
    @MainActor
    func loadWithoutSearchQuery() async throws {
        // Given
        let (sut, spy) = makeSUT()
        var result: Paginated<Patient>?

        //when
        try await spy.async {
            let query = PatientQuery(searchText: "")
            return try await sut.load(query: query)
        } completeWith: {
            .success(allPatients)
        } expectationAfterCompletion: {
            result = $0
        }

        // Then
        #expect(result?.items == allPatients.items)
        #expect(result?.loadMore != nil)
    }

    @Test("Load with search query call specific repository method")
    @MainActor
    func loadWithSearchQuery() async throws {
        // Given
        let (sut, spy) = makeSUT()

        //when
        try await spy.async {
            let query = PatientQuery(searchText: "Test Dog")
            return try await sut.load(query: query)
        } completeWith: {
            .success(.init(items: []))
        }

        // Then
        #expect(spy.callCount == 1)
        let (params, tag) = spy.params(at: 0)
        #expect(params[0] as? String == "Test Dog")
        #expect(tag == "searchByNameWithPagination")
    }

    @Test("Adapter propagates repository errors")
    @MainActor
    func errorPropagation() async throws {
        // Given
        let (sut, spy) = makeSUT()
        let anyNSError = NSError(domain: "error", code: 0, userInfo: nil)

        // When/Then
        await #expect(throws: Error.self) {
            try await spy.async {
                let query = PatientQuery(searchText: "")
                return try await sut.load(query: query)
            } completeWith: {
                .failure(anyNSError)
            }
        }
    }
}

// MARK: - Test Extensions


extension AsyncSpy: @retroactive PatientPaginationRepository where Result == Paginated<Patient> {
    public func findWithPagination(limit: Int) async throws -> Paginated<Patient> {
        try await perform(limit, tag: "findWithPagination")
    }
    
    public func searchByNameWithPagination(_ nameQuery: String, limit: Int) async throws -> Paginated<Patient> {
        try await perform(nameQuery, limit, tag: "searchByNameWithPagination")
    }
}
