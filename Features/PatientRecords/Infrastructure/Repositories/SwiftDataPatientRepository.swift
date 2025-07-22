import Foundation
import SwiftData

/// SwiftData implementation of PatientRepository
@MainActor
public final class SwiftDataPatientRepository: PatientRepository {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func create(_ patient: PatientDomain) async throws -> PatientDomain {
        // Create SwiftData entity from domain model
        let entity = Patient(
            name: patient.name,
            species: patient.species,
            breed: patient.breed,
            dateOfBirth: patient.dateOfBirth,
            gender: patient.gender,
            weight: patient.weight,
            microchipNumber: patient.microchipNumber,
            notes: patient.notes,
            owner: nil // Will be set via ownerID lookup if needed
        )
        
        // Preserve IDs
        entity.patientID = patient.id
        entity.medicalID = patient.medicalID
        
        // If owner ID is provided, fetch and link the owner
        if let ownerID = patient.ownerID {
            let ownerDescriptor = FetchDescriptor<Owner>(
                predicate: #Predicate { $0.ownerID == ownerID }
            )
            if let owner = try modelContext.fetch(ownerDescriptor).first {
                entity.owner = owner
            }
        }
        
        modelContext.insert(entity)
        try modelContext.save()
        
        return entity.toDomain()
    }
    
    public func update(_ patient: PatientDomain) async throws -> PatientDomain {
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { $0.patientID == patient.id }
        )
        
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw ServiceError.notFound("Patient with ID \(patient.id)")
        }
        
        // Update entity fields
        entity.name = patient.name
        entity.species = patient.species
        entity.breed = patient.breed
        entity.dateOfBirth = patient.dateOfBirth
        entity.gender = patient.gender
        entity.weight = patient.weight
        entity.microchipNumber = patient.microchipNumber
        entity.notes = patient.notes
        entity.updatedAt = Date()
        
        // Update owner if changed
        if let ownerID = patient.ownerID {
            let ownerDescriptor = FetchDescriptor<Owner>(
                predicate: #Predicate { $0.ownerID == ownerID }
            )
            entity.owner = try modelContext.fetch(ownerDescriptor).first
        } else {
            entity.owner = nil
        }
        
        try modelContext.save()
        return entity.toDomain()
    }
    
    public func delete(id: UUID) async throws {
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { $0.patientID == id }
        )
        
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw ServiceError.notFound("Patient with ID \(id)")
        }
        
        // Soft delete
        entity.isActive = false
        entity.updatedAt = Date()
        try modelContext.save()
    }
    
    public func findById(_ id: UUID) async throws -> PatientDomain? {
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { $0.patientID == id && $0.isActive }
        )
        
        return try modelContext.fetch(descriptor).first?.toDomain()
    }
    
    public func findByOwnerId(_ ownerId: UUID) async throws -> [PatientDomain] {
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { patient in
                patient.owner?.ownerID == ownerId && patient.isActive
            }
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    public func search(query: String) async throws -> [PatientDomain] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { patient in
                patient.isActive &&
                (patient.name.localizedStandardContains(query) ||
                 patient.medicalID.localizedStandardContains(query) ||
                 (patient.owner?.firstName.localizedStandardContains(query) ?? false) ||
                 (patient.owner?.lastName.localizedStandardContains(query) ?? false))
            }
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    public func fetchAll() async throws -> [PatientDomain] {
        let descriptor = FetchDescriptor<Patient>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.name)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    public func fetch(limit: Int, offset: Int) async throws -> [PatientDomain] {
        var descriptor = FetchDescriptor<Patient>(
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

extension Patient {
    /// Convert SwiftData entity to domain model
    func toDomain() -> PatientDomain {
        PatientDomain(
            id: patientID,
            medicalID: medicalID,
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            gender: gender,
            weight: weight,
            microchipNumber: microchipNumber,
            notes: notes,
            ownerID: owner?.ownerID,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}