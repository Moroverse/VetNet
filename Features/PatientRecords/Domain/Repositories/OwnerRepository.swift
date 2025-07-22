import Foundation

/// Repository protocol for Owner persistence operations
public protocol OwnerRepository: Sendable {
    /// Create a new owner
    func create(_ owner: OwnerDomain) async throws -> OwnerDomain
    
    /// Update an existing owner
    func update(_ owner: OwnerDomain) async throws -> OwnerDomain
    
    /// Delete an owner by ID (soft delete)
    func delete(id: UUID) async throws
    
    /// Find an owner by ID
    func findById(_ id: UUID) async throws -> OwnerDomain?
    
    /// Find an owner by email
    func findByEmail(_ email: String) async throws -> OwnerDomain?
    
    /// Search owners by name, email, or phone
    func search(query: String) async throws -> [OwnerDomain]
    
    /// Fetch all active owners
    func fetchAll() async throws -> [OwnerDomain]
    
    /// Fetch owners with pagination
    func fetch(limit: Int, offset: Int) async throws -> [OwnerDomain]
}