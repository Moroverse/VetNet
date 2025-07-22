import Foundation
import SwiftData

/// SwiftData implementation of OwnerRepository
@MainActor
public final class SwiftDataOwnerRepository: OwnerRepository {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func create(_ owner: OwnerDomain) async throws -> OwnerDomain {
        // Check for duplicate email
        let emailDescriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.emailKey == owner.email }
        )
        if try modelContext.fetch(emailDescriptor).first != nil {
            throw ServiceError.duplicateEmail(owner.email)
        }
        
        // Create SwiftData entity from domain model
        let entity = Owner(
            firstName: owner.firstName,
            lastName: owner.lastName,
            email: owner.email,
            phoneNumber: owner.phoneNumber,
            address: owner.address,
            emergencyContact: owner.emergencyContact,
            preferredCommunication: owner.preferredCommunication
        )
        
        // Preserve ID
        entity.ownerID = owner.id
        
        modelContext.insert(entity)
        try modelContext.save()
        
        return entity.toDomain()
    }
    
    public func update(_ owner: OwnerDomain) async throws -> OwnerDomain {
        let descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.ownerID == owner.id }
        )
        
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw ServiceError.notFound("Owner with ID \(owner.id)")
        }
        
        // Check for duplicate email if email changed
        if entity.email != owner.email {
            let emailDescriptor = FetchDescriptor<Owner>(
                predicate: #Predicate { owner in
                    owner.emailKey == owner.email &&
                    owner.ownerID != owner.ownerID
                }
            )
            if try modelContext.fetch(emailDescriptor).first != nil {
                throw ServiceError.duplicateEmail(owner.email)
            }
        }
        
        // Update entity fields
        entity.firstName = owner.firstName
        entity.lastName = owner.lastName
        entity.email = owner.email
        entity.emailKey = owner.email.lowercased()
        entity.phoneNumber = owner.phoneNumber
        entity.address = owner.address
        entity.emergencyContact = owner.emergencyContact
        entity.preferredCommunication = owner.preferredCommunication
        entity.updatedAt = Date()
        
        try modelContext.save()
        return entity.toDomain()
    }
    
    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.ownerID == id }
        )
        
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw ServiceError.notFound("Owner with ID \(id)")
        }
        
        // Soft delete
        entity.isActive = false
        entity.updatedAt = Date()
        try modelContext.save()
    }
    
    public func findById(_ id: UUID) async throws -> OwnerDomain? {
        let descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.ownerID == id && $0.isActive }
        )
        
        return try modelContext.fetch(descriptor).first?.toDomain()
    }
    
    public func findByEmail(_ email: String) async throws -> OwnerDomain? {
        let descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.emailKey == email && $0.isActive }
        )
        
        return try modelContext.fetch(descriptor).first?.toDomain()
    }
    
    public func search(query: String) async throws -> [OwnerDomain] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { owner in
                owner.isActive &&
                (owner.firstName.localizedStandardContains(query) ||
                 owner.lastName.localizedStandardContains(query) ||
                 owner.email.localizedStandardContains(query) ||
                 owner.phoneNumber.contains(query))
            }
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    public func fetchAll() async throws -> [OwnerDomain] {
        let descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    public func fetch(limit: Int, offset: Int) async throws -> [OwnerDomain] {
        var descriptor = FetchDescriptor<Owner>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
}

// MARK: - Mapping Extensions

extension Owner {
    /// Convert SwiftData entity to domain model
    func toDomain() -> OwnerDomain {
        OwnerDomain(
            id: ownerID,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            address: address,
            emergencyContact: emergencyContact,
            preferredCommunication: preferredCommunication,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
