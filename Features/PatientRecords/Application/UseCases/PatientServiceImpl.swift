import Foundation

/// Service implementation using repository pattern with pure domain models
public final class PatientServiceImpl: PatientService {
    private let repository: PatientRepository
    private let validator: PatientValidator = PatientValidator()

    public init(repository: PatientRepository) {
        self.repository = repository
    }
    
    public func create(_ patient: PatientDomain) async throws -> PatientDomain {

        // Validate domain model
        try validatePatient(patient)

        // Create through repository
        let createdDomain = try await repository.create(patient)

        // Convert back to SwiftData model (temporary during migration)
        return try await createdDomain
    }
    
    public func update(_ patient: PatientDomain) async throws -> PatientDomain {
        let domain = patient.toDomain()
        try validatePatient(domain)
        let updatedDomain = try await repository.update(domain)
        return try await convertToSwiftDataModel(updatedDomain)
    }
    
    public func delete(_ patient: PatientDomain) async throws {
        try await repository.delete(id: patient.patientID)
    }
    
    public func findById(_ id: UUID) async throws -> PatientDomain? {
        guard let domain = try await repository.findById(id) else { return nil }
        return try await convertToSwiftDataModel(domain)
    }
    
    public func search(query: String) async throws -> [PatientDomain] {
        let domains = try await repository.search(query: query)
        return try await convertToSwiftDataModels(domains)
    }
    
    public func fetch(limit: Int, offset: Int) async throws -> [PatientDomain] {
        let domains = try await repository.fetch(limit: limit, offset: offset)
        return try await convertToSwiftDataModels(domains)
    }
    
    public func fetchAll() async throws -> [PatientDomain] {
        let domains = try await repository.fetchAll()
        return try await convertToSwiftDataModels(domains)
    }
    
    // MARK: - Private Helpers
    
    private func validatePatient(_ patient: PatientDomain) throws {
        var errors: [String] = []
        
        if !validator.isValidName(patient.name) {
            errors.append("Invalid patient name")
        }
        
        if let birthDate = patient.dateOfBirth, !validator.isValidBirthDate(birthDate) {
            errors.append("Invalid birth date")
        }
        
        if let weight = patient.weight, !validator.isValidWeight(weight, for: patient.species) {
            errors.append("Invalid weight for species")
        }
        
        if let microchip = patient.microchipNumber, !validator.isValidMicrochip(microchip) {
            errors.append("Invalid microchip format")
        }
        
        if let notes = patient.notes, !validator.isValidNotes(notes) {
            errors.append("Notes too long")
        }
        
        if !errors.isEmpty {
            throw ServiceError.validationFailed(errors)
        }
    }
    
    // Temporary conversion methods during migration
    private func convertToSwiftDataModel(_ domain: PatientDomain) async throws -> Patient {
        // This is a temporary hack during migration
        // Eventually, the service interface should use domain models directly
        let patient = Patient(
            name: domain.name,
            species: domain.species,
            breed: domain.breed,
            dateOfBirth: domain.dateOfBirth,
            gender: domain.gender,
            weight: domain.weight,
            microchipNumber: domain.microchipNumber,
            notes: domain.notes,
            owner: nil
        )
        patient.patientID = domain.id
        patient.medicalID = domain.medicalID
        patient.isActive = domain.isActive
        patient.createdAt = domain.createdAt
        patient.updatedAt = domain.updatedAt
        return patient
    }
    
    private func convertToSwiftDataModels(_ domains: [PatientDomain]) async throws -> [Patient] {
        var results: [Patient] = []
        for domain in domains {
            results.append(try await convertToSwiftDataModel(domain))
        }
        return results
    }
}
