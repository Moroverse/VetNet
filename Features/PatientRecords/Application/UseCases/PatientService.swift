import Foundation
import Mockable

@Mockable
protocol PatientService: Sendable {
    func create(_ patient: PatientDomain) async throws -> PatientDomain
    func update(_ patient: PatientDomain) async throws -> PatientDomain
    func delete(_ patient: PatientDomain) async throws
    func findById(_ id: UUID) async throws -> PatientDomain?
    func search(query: String) async throws -> [PatientDomain]
    func fetch(limit: Int, offset: Int) async throws -> [PatientDomain]
    func fetchAll() async throws -> [PatientDomain]
}

@Mockable 
protocol OwnerService: Sendable {
    func create(_ owner: Owner) async throws -> Owner
    func update(_ owner: Owner) async throws -> Owner
    func delete(_ owner: Owner) async throws
    func findById(_ id: UUID) async throws -> Owner?
    func findByEmail(_ email: String) async throws -> Owner?
    func search(query: String) async throws -> [Owner]
    func fetch(limit: Int, offset: Int) async throws -> [Owner]
}

// Service errors
nonisolated
enum ServiceError: Error {
    case notFound(String)
    case validationFailed([String])
    case duplicateEmail(String)
    case networkError(Error)
    case persistenceError(Error)
    case unknownError
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFound(let resource):
            return "\(resource) not found"
        case .validationFailed(let errors):
            return "Validation failed: \(errors.joined(separator: ", "))"
        case .duplicateEmail(let email):
            return "An account with email \(email) already exists"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .persistenceError(let error):
            return "Data persistence error: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}
