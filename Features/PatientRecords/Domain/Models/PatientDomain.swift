import Foundation

/// Pure domain model for Patient without any persistence concerns
public struct PatientDomain: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let medicalID: String
    public let name: String
    public let species: AnimalSpecies
    public let breed: String?
    public let dateOfBirth: Date?
    public let gender: AnimalGender?
    public let weight: Measurement<UnitMass>?
    public let microchipNumber: String?
    public let notes: String?
    public let ownerID: UUID?
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        medicalID: String? = nil,
        name: String,
        species: AnimalSpecies,
        breed: String? = nil,
        dateOfBirth: Date? = nil,
        gender: AnimalGender? = nil,
        weight: Measurement<UnitMass>? = nil,
        microchipNumber: String? = nil,
        notes: String? = nil,
        ownerID: UUID? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.medicalID = medicalID ?? Self.generateMedicalID()
        self.name = name
        self.species = species
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.weight = weight
        self.microchipNumber = microchipNumber
        self.notes = notes
        self.ownerID = ownerID
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Business Logic
    
    /// Calculate age based on birth date
    public var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }
    
    /// Age in human-readable format
    public var ageDescription: String {
        guard let age = age else { return "Unknown age" }
        return age == 1 ? "1 year old" : "\(age) years old"
    }
    
    /// Check if patient is considered senior based on species
    public var isSenior: Bool {
        guard let age = age else { return false }
        
        switch species {
        case .dog:
            return age >= 7
        case .cat:
            return age >= 10
        case .rabbit:
            return age >= 5
        case .bird:
            return age >= 15
        case .reptile:
            return age >= 10
        case .exotic:
            return age >= 3
        }
    }
    
    /// Generate unique medical ID
    public static func generateMedicalID() -> String {
        let prefix = "VN"
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let random = String(Int.random(in: 1000...9999))
        return "\(prefix)\(timestamp)\(random)"
    }
    
    // MARK: - Mutations (return new instances)
    
    public func updating(
        name: String? = nil,
        species: AnimalSpecies? = nil,
        breed: String?? = nil,
        dateOfBirth: Date?? = nil,
        gender: AnimalGender?? = nil,
        weight: Measurement<UnitMass>?? = nil,
        microchipNumber: String?? = nil,
        notes: String?? = nil,
        ownerID: UUID?? = nil
    ) -> PatientDomain {
        PatientDomain(
            id: self.id,
            medicalID: self.medicalID,
            name: name ?? self.name,
            species: species ?? self.species,
            breed: breed ?? self.breed,
            dateOfBirth: dateOfBirth ?? self.dateOfBirth,
            gender: gender ?? self.gender,
            weight: weight ?? self.weight,
            microchipNumber: microchipNumber ?? self.microchipNumber,
            notes: notes ?? self.notes,
            ownerID: ownerID ?? self.ownerID,
            isActive: self.isActive,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
    
    public func deactivated() -> PatientDomain {
        PatientDomain(
            id: self.id,
            medicalID: self.medicalID,
            name: self.name,
            species: self.species,
            breed: self.breed,
            dateOfBirth: self.dateOfBirth,
            gender: self.gender,
            weight: self.weight,
            microchipNumber: self.microchipNumber,
            notes: self.notes,
            ownerID: self.ownerID,
            isActive: false,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
}