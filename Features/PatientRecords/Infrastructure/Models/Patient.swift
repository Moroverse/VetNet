import Foundation
import SwiftData

@Model
public final class Patient: Sendable {
    @Attribute(.unique) var patientID: UUID
    var medicalID: String
    var name: String
    var species: AnimalSpecies
    var breed: String?
    var dateOfBirth: Date?
    var gender: AnimalGender?
    var weight: Measurement<UnitMass>?
    var microchipNumber: String?
    var notes: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \Owner.patients) var owner: Owner?
    @Relationship(deleteRule: .cascade) var appointments: [Appointment] = []
    @Relationship(deleteRule: .cascade) var medicalDocuments: [MedicalDocument] = []
    
    init(
        name: String,
        species: AnimalSpecies,
        breed: String? = nil,
        dateOfBirth: Date? = nil,
        gender: AnimalGender? = nil,
        weight: Measurement<UnitMass>? = nil,
        microchipNumber: String? = nil,
        notes: String? = nil,
        owner: Owner? = nil
    ) {
        self.patientID = UUID()
        self.medicalID = Self.generateMedicalID()
        self.name = name
        self.species = species
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.weight = weight
        self.microchipNumber = microchipNumber
        self.notes = notes
        self.owner = owner
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }
    
    private static func generateMedicalID() -> String {
        let prefix = "VN"
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let random = String(Int.random(in: 1000...9999))
        return "\(prefix)\(timestamp)\(random)"
    }
}

public enum AnimalSpecies: String, CaseIterable, Codable, CustomStringConvertible, Sendable {


    case dog = "Dog"
    case cat = "Cat"
    case rabbit = "Rabbit"
    case bird = "Bird"
    case reptile = "Reptile"
    case exotic = "Exotic"

    public var description: String {
        self.rawValue
    }

    var breedOptions: [String] {
        switch self {
        case .dog:
            return ["Labrador Retriever", "German Shepherd", "Golden Retriever", "French Bulldog", "Bulldog", "Poodle", "Beagle", "Rottweiler", "German Shorthaired Pointer", "Yorkshire Terrier", "Mixed Breed"]
        case .cat:
            return ["Persian", "Maine Coon", "Siamese", "Ragdoll", "British Shorthair", "American Shorthair", "Scottish Fold", "Sphynx", "Russian Blue", "Mixed Breed"]
        case .rabbit:
            return ["Holland Lop", "Netherland Dwarf", "Flemish Giant", "Angora", "Lionhead", "Rex", "Mini Lop", "Mixed Breed"]
        case .bird:
            return ["Budgerigar", "Cockatiel", "Canary", "Lovebird", "Conure", "Macaw", "Amazon", "African Grey", "Mixed Breed"]
        case .reptile:
            return ["Bearded Dragon", "Leopard Gecko", "Ball Python", "Corn Snake", "Red-eared Slider", "Russian Tortoise", "Blue-tongued Skink", "Mixed Breed"]
        case .exotic:
            return ["Guinea Pig", "Hamster", "Ferret", "Chinchilla", "Hedgehog", "Sugar Glider", "Rat", "Mixed Breed"]
        }
    }
}


