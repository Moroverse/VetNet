import Foundation

/// Repository protocol for Patient persistence operations
public protocol PatientRepository: Sendable {
    /// Create a new patient
    func create(_ patient: PatientDomain) async throws -> PatientDomain
    
    /// Update an existing patient
    func update(_ patient: PatientDomain) async throws -> PatientDomain
    
    /// Delete a patient by ID (soft delete)
    func delete(id: UUID) async throws
    
    /// Find a patient by ID
    func findById(_ id: UUID) async throws -> PatientDomain?
    
    /// Find patients by owner ID
    func findByOwnerId(_ ownerId: UUID) async throws -> [PatientDomain]
    
    /// Search patients by name, medical ID, or owner name
    func search(query: String) async throws -> [PatientDomain]
    
    /// Fetch all active patients
    func fetchAll() async throws -> [PatientDomain]
    
    /// Fetch patients with pagination
    func fetch(limit: Int, offset: Int) async throws -> [PatientDomain]
}