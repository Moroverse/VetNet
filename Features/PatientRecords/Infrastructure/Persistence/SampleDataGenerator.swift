import Foundation

@MainActor
struct SampleDataGenerator: Sendable {
    
    static func generateSampleData() -> (owners: [Owner], patients: [Patient]) {
        let owners = generateSampleOwners()
        let patients = generateSamplePatients(with: owners)
        return (owners: owners, patients: patients)
    }
    
    private static func generateSampleOwners() -> [Owner] {
        let sampleOwners = [
            ("Emily", "Johnson", "emily.johnson@email.com", "+1-555-0101"),
            ("Michael", "Chen", "michael.chen@email.com", "+1-555-0102"),
            ("Sarah", "Williams", "sarah.williams@email.com", "+1-555-0103"),
            ("David", "Brown", "david.brown@email.com", "+1-555-0104"),
            ("Jessica", "Davis", "jessica.davis@email.com", "+1-555-0105"),
            ("Robert", "Miller", "robert.miller@email.com", "+1-555-0106"),
            ("Amanda", "Wilson", "amanda.wilson@email.com", "+1-555-0107"),
            ("Christopher", "Moore", "christopher.moore@email.com", "+1-555-0108"),
            ("Lisa", "Taylor", "lisa.taylor@email.com", "+1-555-0109"),
            ("James", "Anderson", "james.anderson@email.com", "+1-555-0110"),
            ("Maria", "Garcia", "maria.garcia@email.com", "+1-555-0111"),
            ("John", "Martinez", "john.martinez@email.com", "+1-555-0112")
        ]
        
        return sampleOwners.map { firstName, lastName, email, phone in
            Owner(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phone,
                address: generateRandomAddress(),
                emergencyContact: generateRandomEmergencyContact(),
                preferredCommunication: CommunicationPreference.allCases.randomElement() ?? .email
            )
        }
    }
    
    private static func generateSamplePatients(with owners: [Owner]) -> [Patient] {
        let dogPatients = [
            ("Max", AnimalSpecies.dog, "Labrador Retriever", 3, 28.5),
            ("Bella", AnimalSpecies.dog, "German Shepherd", 5, 32.1),
            ("Charlie", AnimalSpecies.dog, "Golden Retriever", 2, 25.8),
            ("Luna", AnimalSpecies.dog, "French Bulldog", 4, 12.3),
            ("Cooper", AnimalSpecies.dog, "Beagle", 6, 15.7),
            ("Lucy", AnimalSpecies.dog, "Poodle", 1, 8.9),
            ("Rocky", AnimalSpecies.dog, "Rottweiler", 7, 45.2)
        ]
        
        let catPatients = [
            ("Whiskers", AnimalSpecies.cat, "Persian", 4, 4.8),
            ("Mittens", AnimalSpecies.cat, "Maine Coon", 2, 7.2),
            ("Oliver", AnimalSpecies.cat, "Siamese", 3, 4.1),
            ("Sophie", AnimalSpecies.cat, "British Shorthair", 5, 5.3),
            ("Leo", AnimalSpecies.cat, "American Shorthair", 1, 3.9),
            ("Cleo", AnimalSpecies.cat, "Scottish Fold", 6, 4.6)
        ]
        
        let exoticPatients = [
            ("Bunny", AnimalSpecies.rabbit, "Holland Lop", 2, 1.8),
            ("Polly", AnimalSpecies.bird, "African Grey", 8, 0.45),
            ("Spike", AnimalSpecies.reptile, "Bearded Dragon", 3, 0.35),
            ("Patches", AnimalSpecies.exotic, "Guinea Pig", 1, 0.95),
            ("Nibbles", AnimalSpecies.rabbit, "Netherland Dwarf", 4, 1.1),
            ("Echo", AnimalSpecies.bird, "Cockatiel", 2, 0.09),
            ("Scales", AnimalSpecies.reptile, "Ball Python", 5, 1.2),
            ("Squeaky", AnimalSpecies.exotic, "Hamster", 1, 0.12)
        ]
        
        let allPatientData = dogPatients + catPatients + exoticPatients
        
        return allPatientData.enumerated().map { index, patientData in
            let (name, species, breed, ageYears, weightKg) = patientData
            let owner = owners[index % owners.count]
            let birthDate = Calendar.current.date(byAdding: .year, value: -ageYears, to: Date()) ?? Date()
            let weight = Measurement(value: weightKg, unit: UnitMass.kilograms)
            let gender = AnimalGender.allCases.randomElement() ?? .unknown
            
            let patient = Patient(
                name: name,
                species: species,
                breed: breed,
                dateOfBirth: birthDate,
                gender: gender,
                weight: weight,
                microchipNumber: generateMicrochipNumber(),
                notes: generatePatientNotes(name: name, species: species),
                owner: owner
            )
            
            return patient
        }
    }
    
    private static func generateRandomAddress() -> Address {
        let streets = [
            "123 Main Street", "456 Oak Avenue", "789 Pine Road", "321 Elm Drive",
            "654 Maple Lane", "987 Cedar Boulevard", "147 Birch Way", "258 Willow Court"
        ]
        let cities = [
            "San Francisco", "Los Angeles", "New York", "Chicago",
            "Houston", "Phoenix", "Philadelphia", "San Antonio"
        ]
        let states = [
            "CA", "NY", "TX", "FL", "IL", "PA", "OH", "GA"
        ]
        let zipCodes = [
            "90210", "10001", "77001", "33101", "60601", "19101", "43201", "30301"
        ]
        
        return Address(
            street: streets.randomElement() ?? "123 Main Street",
            city: cities.randomElement() ?? "San Francisco",
            state: states.randomElement() ?? "CA",
            zipCode: zipCodes.randomElement() ?? "90210",
            country: "USA"
        )
    }
    
    private static func generateRandomEmergencyContact() -> EmergencyContact? {
        // 70% chance of having an emergency contact
        guard Bool.random(probability: 0.7) else { return nil }
        
        let names = [
            "John Smith", "Mary Johnson", "Robert Brown", "Linda Davis",
            "William Wilson", "Patricia Miller", "Richard Moore", "Barbara Taylor"
        ]
        let relationships = [
            "Spouse", "Parent", "Sibling", "Friend", "Neighbor", "Relative"
        ]
        let phoneNumbers = [
            "+1-555-9001", "+1-555-9002", "+1-555-9003", "+1-555-9004",
            "+1-555-9005", "+1-555-9006", "+1-555-9007", "+1-555-9008"
        ]
        
        return EmergencyContact(
            name: names.randomElement() ?? "Emergency Contact",
            phoneNumber: phoneNumbers.randomElement() ?? "+1-555-9999",
            relationship: relationships.randomElement() ?? "Friend"
        )
    }
    
    private static func generateMicrochipNumber() -> String? {
        // 60% chance of having a microchip
        guard Bool.random(probability: 0.6) else { return nil }
        
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let random = String(format: "%06d", Int.random(in: 100000...999999))
        let prefix = String(Int.random(in: 100...999))
        
        return "\(prefix)\(timestamp.suffix(6))\(random)"
    }
    
    private static func generatePatientNotes(name: String, species: AnimalSpecies) -> String? {
        // 80% chance of having notes
        guard Bool.random(probability: 0.8) else { return nil }
        
        let generalNotes = [
            "Very friendly and well-behaved during visits.",
            "Gets anxious around other animals, please schedule separately.",
            "Loves treats and responds well to positive reinforcement.",
            "Has a history of allergies, monitor for reactions.",
            "Very energetic, may need extra exercise recommendations.",
            "Older pet, may need gentle handling and extra time.",
            "Recent rescue, still adjusting to new environment.",
            "Previous medical history available from former vet."
        ]
        
        let speciesSpecificNotes: [AnimalSpecies: [String]] = [
            .dog: [
                "Excellent recall and obedience training.",
                "Enjoys car rides to the vet.",
                "Good with children and other dogs.",
                "Needs regular dental cleanings.",
                "Sensitive stomach, special diet recommended."
            ],
            .cat: [
                "Indoor cat, up to date on vaccinations.",
                "Prefers quiet examination rooms.",
                "Very clean, excellent litter box habits.",
                "May hide when stressed, give time to adjust.",
                "Responds well to feliway calming pheromones."
            ],
            .bird: [
                "Talks frequently, very intelligent.",
                "Requires specialized avian vet care.",
                "Sensitive to temperature changes.",
                "Well-socialized with humans.",
                "Needs regular wing and nail trims."
            ],
            .rabbit: [
                "House-trained and very social.",
                "Requires high-fiber diet monitoring.",
                "Regular grooming needed.",
                "Sensitive to loud noises.",
                "Enjoys supervised playtime."
            ],
            .reptile: [
                "Requires specific temperature and humidity.",
                "Fed appropriate diet for species.",
                "Regular shedding cycles monitored.",
                "Docile temperament, easy to handle.",
                "UV lighting requirements maintained."
            ],
            .exotic: [
                "Requires specialized exotic pet care.",
                "Diet and habitat carefully managed.",
                "Regular weight monitoring important.",
                "Social animal, enjoys interaction.",
                "Sensitive to environmental changes."
            ]
        ]
        
        let allNotes = generalNotes + (speciesSpecificNotes[species] ?? [])
        return allNotes.randomElement()
    }
}

// MARK: - Helper Extensions

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}

// MARK: - Sample Data Seeder

final class SampleDataSeeder {
    private let patientService: PatientService
    private let ownerService: OwnerService
    
    init(patientService: PatientService, ownerService: OwnerService) {
        self.patientService = patientService
        self.ownerService = ownerService
    }
    
    func seedSampleData() async throws {
        let (owners, patients) = SampleDataGenerator.generateSampleData()
        
        // First create all owners
        for owner in owners {
            do {
                _ = try await ownerService.create(owner)
            } catch {
                await MainActor.run {
                    print("Failed to create owner \(owner.fullName): \(error)")
                }
            }
        }
        
        // Then create all patients
        for patient in patients {
            do {
                _ = try await patientService.create(patient)
            } catch {
                await MainActor.run {
                    print("Failed to create patient \(patient.name): \(error)")
                }
            }
        }
        
        print("Successfully seeded sample data: \(owners.count) owners, \(patients.count) patients")
    }
}
