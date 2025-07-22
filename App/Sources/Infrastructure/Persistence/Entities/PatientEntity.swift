// PatientEntity.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 20:18 GMT.

import Foundation
import SwiftData

// MARK: - Patient Entity

/// SwiftData persistence entity for Patient domain model
/// Located in Infrastructure layer to isolate persistence concerns from domain logic
@Model
final class PatientEntity {
    // MARK: - Identity

    @Attribute(.unique)
    var id: String

    // MARK: - Basic Information

    var name: String
    var speciesRawValue: String
    var breedRawValue: String
    var birthDate: Date
    var weightValue: Double?
    var weightUnitSymbol: String?

    // MARK: - Owner Information

    var ownerName: String
    var ownerPhoneNumber: String
    var ownerEmail: String?

    // MARK: - Medical Information

    @Attribute(.unique)
    var medicalID: String
    var microchipNumber: String?
    var notes: String?

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date

    // MARK: - CloudKit Specific

    /// CloudKit record zone for HIPAA compliance
    /// Custom zone enables proper access control and data isolation
    var cloudKitZone: String?

    // MARK: - Initialization

    init(
        id: String,
        name: String,
        speciesRawValue: String,
        breedRawValue: String,
        birthDate: Date,
        weightValue: Double? = nil,
        weightUnitSymbol: String? = nil,
        ownerName: String,
        ownerPhoneNumber: String,
        ownerEmail: String? = nil,
        medicalID: String,
        microchipNumber: String? = nil,
        notes: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        cloudKitZone: String? = nil
    ) {
        self.id = id
        self.name = name
        self.speciesRawValue = speciesRawValue
        self.breedRawValue = breedRawValue
        self.birthDate = birthDate
        self.weightValue = weightValue
        self.weightUnitSymbol = weightUnitSymbol
        self.ownerName = ownerName
        self.ownerPhoneNumber = ownerPhoneNumber
        self.ownerEmail = ownerEmail
        self.medicalID = medicalID
        self.microchipNumber = microchipNumber
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cloudKitZone = cloudKitZone
    }
}

// MARK: - Domain Model Mapping

extension PatientEntity {
    /// Convert SwiftData entity to domain model
    /// - Returns: Patient domain model, or nil if conversion fails
    func toDomainModel() -> Patient? {
        // Parse species
        guard let species = Species(rawValue: speciesRawValue) else {
            return nil
        }

        // Parse breed
        guard let breed = Breed(rawValue: breedRawValue) else {
            return nil
        }

        // Parse UUID
        guard let uuid = UUID(uuidString: id) else {
            return nil
        }

        // Parse weight if present
        var weight: Measurement<UnitMass>?
        if let weightValue,
           let weightUnitSymbol {
            let unit: UnitMass = switch weightUnitSymbol {
            case "kg":
                .kilograms
            case "g":
                .grams
            case "lb":
                .pounds
            case "oz":
                .ounces
            default:
                .kilograms // Default fallback
            }
            weight = Measurement(value: weightValue, unit: unit)
        }

        return Patient(
            id: Patient.ID(uuid),
            name: name,
            species: species,
            breed: breed,
            birthDate: birthDate,
            weight: weight,
            ownerName: ownerName,
            ownerPhoneNumber: ownerPhoneNumber,
            ownerEmail: ownerEmail,
            medicalID: medicalID,
            microchipNumber: microchipNumber,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Update entity from domain model
    /// - Parameter patient: Domain model to update from
    func updateFromDomainModel(_ patient: Patient) {
        id = patient.id.value.uuidString
        name = patient.name
        speciesRawValue = patient.species.rawValue
        breedRawValue = patient.breed.rawValue
        birthDate = patient.birthDate

        // Handle weight conversion
        if let weight = patient.weight {
            weightValue = weight.value
            weightUnitSymbol = weight.unit.symbol
        } else {
            weightValue = nil
            weightUnitSymbol = nil
        }

        ownerName = patient.ownerName
        ownerPhoneNumber = patient.ownerPhoneNumber
        ownerEmail = patient.ownerEmail
        medicalID = patient.medicalID
        microchipNumber = patient.microchipNumber
        notes = patient.notes
        updatedAt = patient.updatedAt

        // Note: createdAt is not updated to preserve original creation time
    }

    /// Create entity from domain model
    /// - Parameters:
    ///   - patient: Domain model to convert
    ///   - cloudKitZone: Optional CloudKit zone for HIPAA compliance
    /// - Returns: New PatientEntity
    static func fromDomainModel(_ patient: Patient, cloudKitZone: String? = "VetNetSecure") -> PatientEntity {
        let entity = PatientEntity(
            id: patient.id.value.uuidString,
            name: patient.name,
            speciesRawValue: patient.species.rawValue,
            breedRawValue: patient.breed.rawValue,
            birthDate: patient.birthDate,
            ownerName: patient.ownerName,
            ownerPhoneNumber: patient.ownerPhoneNumber,
            ownerEmail: patient.ownerEmail,
            medicalID: patient.medicalID,
            microchipNumber: patient.microchipNumber,
            notes: patient.notes,
            createdAt: patient.createdAt,
            updatedAt: patient.updatedAt,
            cloudKitZone: cloudKitZone
        )

        // Handle weight conversion
        if let weight = patient.weight {
            entity.weightValue = weight.value
            entity.weightUnitSymbol = weight.unit.symbol
        }

        return entity
    }
}
