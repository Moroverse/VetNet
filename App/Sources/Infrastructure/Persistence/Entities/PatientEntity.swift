// PatientEntity.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 20:24 GMT.

import Foundation
import SwiftData

// MARK: - Patient Entity

/// SwiftData persistence entity for Patient domain model
/// Located in Infrastructure layer to isolate persistence concerns from domain logic
///
/// ## CloudKit Integration Requirements
///
/// CloudKit synchronization imposes specific constraints on SwiftData models:
/// - All properties must be optional or have default values for CloudKit compatibility
/// - @Attribute(.unique) constraints are NOT supported with CloudKit enabled
/// - Uniqueness validation must be enforced at the repository layer instead
///
/// ## Uniqueness Enforcement Strategy
///
/// Although we cannot use @Attribute(.unique) with CloudKit, the following fields
/// require uniqueness and are validated in SwiftDataPatientRepository:
/// - `medicalID`: Must be unique across all patients in the practice
/// - Future: `(practiceID, medicalID)` compound key when multi-practice support is added
///
/// ## HIPAA Compliance
///
/// Patient data is synchronized to CloudKit private database with:
/// - Custom zone "VetNetSecure" for data isolation
/// - End-to-end encryption for PHI (Protected Health Information)
/// - Audit trail logging at repository level for all data access
///
/// ## Future Relationships
///
/// When related entities are implemented, the following relationships will be added:
/// - `owner`: Many-to-one relationship with OwnerEntity
/// - `appointments`: One-to-many relationship with AppointmentEntity
/// - `medicalRecords`: One-to-many relationship with MedicalRecordEntity
/// - `practice`: Many-to-one relationship with PracticeEntity (for multi-practice support)
@Model
final class PatientEntity {
    // MARK: - Identity

    /// UUID string representation of Patient.ID
    /// Stored as String for CloudKit compatibility
    var id: String = ""

    // MARK: - Basic Information

    /// Patient's name - required field
    var name: String = ""

    /// Raw value of Species enum - stored as String for CloudKit
    /// Maps to Species enum in domain model
    var speciesRawValue: String = "dog"

    /// Raw value of Breed enum - stored as String for CloudKit
    /// Maps to Breed enum in domain model, validated against species
    var breedRawValue: String = "mixed"

    /// Date of birth - used for age calculations
    var birthDate: Date = Date()

    /// Weight value component - combined with weightUnitSymbol
    /// Forms Measurement<UnitMass> in domain model
    var weightValue: Double = 0.0

    /// Weight unit symbol (kg, g, lb, oz) - combined with weightValue
    var weightUnitSymbol: String = "kg"

    // MARK: - Owner Information

    var ownerName: String = ""
    var ownerPhoneNumber: String = ""
    var ownerEmail: String?

    // MARK: - Medical Information

    var medicalID: String = ""
    var microchipNumber: String?
    var notes: String?

    // MARK: - Metadata

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // MARK: - CloudKit Specific

    /// CloudKit record zone for HIPAA compliance
    /// Custom zone enables proper access control and data isolation
    var cloudKitZone: String?

    // MARK: - Future Relationships (To Be Implemented)

    // When OwnerEntity is created:
    // @Relationship(inverse: \OwnerEntity.patients) var owner: OwnerEntity?

    // When AppointmentEntity is created:
    // @Relationship(deleteRule: .nullify) var appointments: [AppointmentEntity] = []

    // When MedicalRecordEntity is created:
    // @Relationship(deleteRule: .cascade) var medicalRecords: [MedicalRecordEntity] = []

    // When PracticeEntity is created (for multi-practice support):
    // @Relationship(inverse: \PracticeEntity.patients) var practice: PracticeEntity?

    // MARK: - Initialization

    init(
        id: String = "",
        name: String = "",
        speciesRawValue: String = "dog",
        breedRawValue: String = "mixed",
        birthDate: Date = Date(),
        weightValue: Double = 0.0,
        weightUnitSymbol: String = "kg",
        ownerName: String = "",
        ownerPhoneNumber: String = "",
        ownerEmail: String? = nil,
        medicalID: String = "",
        microchipNumber: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
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

    /// Required initializer for SwiftData
    init() {
        // All properties have default values
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
        var weight: Measurement<UnitMass>
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

        weightValue = patient.weight.value
        weightUnitSymbol = patient.weight.unit.symbol

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
            weightValue: patient.weight.value,
            weightUnitSymbol: patient.weight.unit.symbol,
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

        return entity
    }
}
