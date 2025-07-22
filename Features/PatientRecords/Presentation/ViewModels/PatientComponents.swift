import Foundation

struct PatientComponents {
    var name: String = ""
    var species: AnimalSpecies = .dog
    var breed: String = ""
    var birthDate: Date = Date()
    var weight: Measurement<UnitMass> = Measurement(value: 0, unit: .kilograms)
    var microchipNumber: String = ""
    var notes: String = ""
    var ownerFirstName: String = ""
    var ownerLastName: String = ""
    var ownerEmail: String = ""
    var ownerPhoneNumber: String = ""
}