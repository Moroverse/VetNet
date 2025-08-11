// MockPatientRepository.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-03 04:36 GMT.

#if DEBUG
    import Foundation
    import StateKit

    // MARK: - Mock Patient Repository

    final class MockPatientRepository: PatientRepositoryProtocol, TestControllable {
        var behavior: BehaviorTrait = .success
        private var patients: [Patient.ID: Patient] = [:]

        init(behavior: BehaviorTrait = .success) {
            self.behavior = behavior

            // Pre-populate with built-in test data if success or delayed
            if case .success = behavior {
                populateBuiltInTestData()
            } else if case .delayed = behavior {
                populateBuiltInTestData()
            }
        }

        // MARK: - TestControllable

        func applyBehavior(_ behavior: BehaviorTrait) {
            self.behavior = behavior

            // Re-populate data if switching to success or delayed mode
            if case .success = behavior {
                populateBuiltInTestData()
            } else if case .delayed = behavior {
                populateBuiltInTestData()
            } else {
                patients.removeAll()
            }
        }

        func resetBehavior() {
            behavior = .success
            populateBuiltInTestData()
        }

        // MARK: - Helper Methods

        private func checkForFailure() throws {
            switch behavior {
            case let .failure(error):
                throw error

            case let .intermittent(successRate):
                if Double.random(in: 0 ... 1) >= successRate {
                    throw RepositoryError.databaseError("Intermittent failure")
                }

            default:
                break
            }
        }

        // MARK: - Built-in Test Data

        private func populateBuiltInTestData() {
            // Add 5 simple test patients for mock repository
            let testPatients = [
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
            ]

            for patient in testPatients {
                patients[patient.id] = patient
            }
        }

        // MARK: - PatientCRUDRepository

        func create(_ patient: Patient) async throws -> Patient {
            // Handle behavior trait
            switch behavior {
            case .success:
                patients[patient.id] = patient
                return patient

            case let .delayed(seconds):
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                patients[patient.id] = patient
                return patient

            case let .failure(error):
                throw error

            case let .intermittent(successRate):
                if Double.random(in: 0 ... 1) < successRate {
                    patients[patient.id] = patient
                    return patient
                } else {
                    throw RepositoryError.databaseError("Intermittent failure")
                }

            case let .sequential(behaviors):
                // For simplicity, just use the first behavior
                if let firstBehavior = behaviors.first {
                    let originalBehavior = behavior
                    behavior = firstBehavior
                    let result = try await create(patient)
                    behavior = originalBehavior
                    return result
                } else {
                    patients[patient.id] = patient
                    return patient
                }

            case let .custom(customBehavior):
                // Handle custom behaviors
                if customBehavior is EmptyDatasetBehavior {
                    patients.removeAll()
                    patients[patient.id] = patient
                    return patient
                } else {
                    patients[patient.id] = patient
                    return patient
                }
            }
        }

        func findById(_ id: Patient.ID) async throws -> Patient? {
            try checkForFailure()
            return patients[id]
        }

        func update(_ patient: Patient) async throws -> Patient {
            // Handle delays
            if case let .delayed(seconds) = behavior {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            }

            try checkForFailure()

            guard patients[patient.id] != nil else {
                throw RepositoryError.notFound
            }
            patients[patient.id] = patient
            return patient
        }

        func delete(_ id: Patient.ID) async throws {
            try checkForFailure()
            guard patients[id] != nil else {
                throw RepositoryError.notFound
            }
            patients.removeValue(forKey: id)
        }

        // MARK: - PatientSearchRepository

        func findAll() async throws -> [Patient] {
            try checkForFailure()
            return Array(patients.values)
        }

        func findByMedicalID(_ medicalID: String) async throws -> Patient? {
            try checkForFailure()
            return patients.values.first { $0.medicalID == medicalID }
        }

        func searchByName(_ nameQuery: String) async throws -> [Patient] {
            try checkForFailure()
            return patients.values.filter { patient in
                patient.name.localizedCaseInsensitiveContains(nameQuery)
            }
        }

        func findBySpecies(_ species: Species) async throws -> [Patient] {
            try checkForFailure()
            return patients.values.filter { $0.species == species }
        }

        func findByOwnerName(_ ownerName: String) async throws -> [Patient] {
            try checkForFailure()
            return patients.values.filter { patient in
                patient.ownerName.localizedCaseInsensitiveContains(ownerName)
            }
        }

        func findCreatedBetween(startDate: Date, endDate: Date) async throws -> [Patient] {
            try checkForFailure()
            return patients.values.filter { patient in
                patient.createdAt >= startDate && patient.createdAt <= endDate
            }
        }

        // MARK: - PatientUtilityRepository

        func count() async throws -> Int {
            try checkForFailure()
            return patients.count
        }

        func medicalIDExists(_ medicalID: String) async throws -> Bool {
            try checkForFailure()
            return patients.values.contains { $0.medicalID == medicalID }
        }

        // MARK: - PatientPaginationRepository

        func findWithPagination(limit: Int) async throws -> Paginated<Patient> {
            try checkForFailure()
            let allPatients = Array(patients.values).sorted { $0.createdAt > $1.createdAt }
            let itemsToReturn = Array(allPatients.prefix(limit))
            return Paginated(items: itemsToReturn, loadMore: nil)
        }

        func searchByNameWithPagination(_ nameQuery: String, limit: Int) async throws -> Paginated<Patient> {
            try checkForFailure()

            let filteredPatients = patients.values
                .filter { $0.name.localizedCaseInsensitiveContains(nameQuery) }
                .sorted { $0.name < $1.name }

            // For mock, we'll return filtered patients up to limit, with no loadMore
            let itemsToReturn = Array(filteredPatients.prefix(limit))

            return Paginated(items: itemsToReturn, loadMore: nil)
        }
    }
#endif
