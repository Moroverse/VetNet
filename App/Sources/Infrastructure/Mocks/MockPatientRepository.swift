// MockPatientRepository.swift
// Copyright (c) 2025 Moroverse
// Mock Patient Repository for Previews and Testing

#if DEBUG
    import Foundation
    import StateKit

    // MARK: - Mock Behavior

    enum MockRepositoryBehavior {
        case success
        case duplicateKeyError
        case generalError
        case slowResponse
    }

    // MARK: - Mock Patient Repository

    final class MockPatientRepository: PatientRepositoryProtocol {
        let behavior: MockRepositoryBehavior
        private var patients: [Patient.ID: Patient] = [:]

        init(behavior: MockRepositoryBehavior = .success) {
            self.behavior = behavior
        }

        // MARK: - PatientCRUDRepository

        func create(_ patient: Patient) async throws -> Patient {
            // Simulate delay for slow response
            if behavior == .slowResponse {
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            }

            switch behavior {
            case .duplicateKeyError:
                throw RepositoryError.duplicateKey("medicalID: \(patient.medicalID)")
            case .generalError:
                throw RepositoryError.databaseError("Connection failed")
            case .success, .slowResponse:
                patients[patient.id] = patient
                return patient
            }
        }

        func findById(_ id: Patient.ID) async throws -> Patient? {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }
            return patients[id]
        }

        func update(_ patient: Patient) async throws -> Patient {
            // Simulate delay for slow response
            if behavior == .slowResponse {
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            }

            switch behavior {
            case .duplicateKeyError:
                throw RepositoryError.duplicateKey("medicalID: \(patient.medicalID)")
            case .generalError:
                throw RepositoryError.databaseError("Connection failed")
            case .success, .slowResponse:
                guard patients[patient.id] != nil else {
                    throw RepositoryError.notFound
                }
                patients[patient.id] = patient
                return patient
            }
        }

        func delete(_ id: Patient.ID) async throws {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }
            guard patients[id] != nil else {
                throw RepositoryError.notFound
            }
            patients.removeValue(forKey: id)
        }

        // MARK: - PatientSearchRepository

        func findAll() async throws -> [Patient] {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }
            return Array(patients.values)
        }

        func findByMedicalID(_ medicalID: String) async throws -> Patient? {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }
            return patients.values.first { $0.medicalID == medicalID }
        }

        func searchByName(_ nameQuery: String) async throws -> [Patient] {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            return patients.values.filter { patient in
                patient.name.localizedCaseInsensitiveContains(nameQuery)
            }
        }

        func findBySpecies(_ species: Species) async throws -> [Patient] {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            return patients.values.filter { $0.species == species }
        }

        func findByOwnerName(_ ownerName: String) async throws -> [Patient] {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            return patients.values.filter { patient in
                patient.ownerName.localizedCaseInsensitiveContains(ownerName)
            }
        }

        func findCreatedBetween(startDate: Date, endDate: Date) async throws -> [Patient] {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            return patients.values.filter { patient in
                patient.createdAt >= startDate && patient.createdAt <= endDate
            }
        }

        // MARK: - PatientUtilityRepository

        func count() async throws -> Int {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            return patients.count
        }

        func medicalIDExists(_ medicalID: String) async throws -> Bool {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            return patients.values.contains { $0.medicalID == medicalID }
        }

        // MARK: - PatientPaginationRepository

        func findWithPagination(limit: Int) async throws -> Paginated<Patient> {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            let allPatients = Array(patients.values).sorted { $0.createdAt > $1.createdAt }
            
            // For mock, we'll return all patients up to limit, with no loadMore
            let itemsToReturn = Array(allPatients.prefix(limit))
            
            return Paginated(items: itemsToReturn, loadMore: nil)
        }

        func searchByNameWithPagination(_ nameQuery: String, limit: Int) async throws -> Paginated<Patient> {
            if behavior == .generalError {
                throw RepositoryError.databaseError("Connection failed")
            }

            let filteredPatients = patients.values
                .filter { $0.name.localizedCaseInsensitiveContains(nameQuery) }
                .sorted { $0.name < $1.name }
            
            // For mock, we'll return filtered patients up to limit, with no loadMore
            let itemsToReturn = Array(filteredPatients.prefix(limit))
            
            return Paginated(items: itemsToReturn, loadMore: nil)
        }
    }
#endif
