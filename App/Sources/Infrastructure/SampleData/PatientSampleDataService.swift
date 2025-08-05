// PatientSampleDataService.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-05 03:57 GMT.

import Foundation

// MARK: - Sample Data Service

final class PatientSampleDataService: Sendable {
    // MARK: - Sample Data Generation

    /// Generate a comprehensive dataset of 20+ patients with realistic data
    static func generateSamplePatients() -> [Patient] {
        var patients: [Patient] = []

        // Dogs - 10 patients
        patients.append(contentsOf: generateDogPatients())

        // Cats - 8 patients
        patients.append(contentsOf: generateCatPatients())

        // Exotic pets - 4 patients
        patients.append(contentsOf: generateExoticPatients())

        return patients
    }

    // MARK: - Dog Patients

    private static func generateDogPatients() -> [Patient] {
        [
            Patient(
                name: "Max",
                species: .dog,
                breed: .dogLabrador,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
                weight: Measurement(value: 32, unit: .kilograms),
                ownerName: "Sarah Johnson",
                ownerPhoneNumber: "(555) 123-4567",
                ownerEmail: "sarah.johnson@email.com",
                microchipNumber: "982000123456789",
                notes: "Very friendly, loves treats. Allergic to chicken.",
                createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
                updatedAt: Date().addingTimeInterval(-5 * 24 * 60 * 60) // 5 days ago
            ),

            Patient(
                name: "Bella",
                species: .dog,
                breed: .dogLabrador,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years old
                weight: Measurement(value: 28, unit: .kilograms),
                ownerName: "Michael Chen",
                ownerPhoneNumber: "(555) 234-5678",
                ownerEmail: "m.chen@email.com",
                microchipNumber: "982000234567890",
                notes: "High energy, needs regular exercise. Up to date on vaccinations.",
                createdAt: Date().addingTimeInterval(-45 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-10 * 24 * 60 * 60)
            ),

            Patient(
                name: "Rex",
                species: .dog,
                breed: .dogGermanShepherd,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 5), // 5 years old
                weight: Measurement(value: 38, unit: .kilograms),
                ownerName: "David Rodriguez",
                ownerPhoneNumber: "(555) 345-6789",
                ownerEmail: "david.r@email.com",
                microchipNumber: "982000345678901",
                notes: "Well-trained police dog. Sensitive to loud noises.",
                createdAt: Date().addingTimeInterval(-60 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-15 * 24 * 60 * 60)
            ),

            Patient(
                name: "Luna",
                species: .dog,
                breed: .dogGermanShepherd,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4), // 4 years old
                weight: Measurement(value: 30, unit: .kilograms),
                ownerName: "Emily Thompson",
                ownerPhoneNumber: "(555) 456-7890",
                ownerEmail: "emily.thompson@email.com",
                microchipNumber: "982000456789012",
                notes: "Rescue dog, still adjusting. Very gentle with children.",
                createdAt: Date().addingTimeInterval(-75 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-20 * 24 * 60 * 60)
            ),

            Patient(
                name: "Charlie",
                species: .dog,
                breed: .dogGoldenRetriever,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 6), // 6 years old
                weight: Measurement(value: 35, unit: .kilograms),
                ownerName: "James Wilson",
                ownerPhoneNumber: "(555) 567-8901",
                ownerEmail: "james.wilson@email.com",
                microchipNumber: "982000567890123",
                notes: "Senior dog, arthritis in back legs. Special diet required.",
                createdAt: Date().addingTimeInterval(-90 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-25 * 24 * 60 * 60)
            ),

            Patient(
                name: "Daisy",
                species: .dog,
                breed: .dogGoldenRetriever,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 1), // 1 year old
                weight: Measurement(value: 25, unit: .kilograms),
                ownerName: "Lisa Anderson",
                ownerPhoneNumber: "(555) 678-9012",
                ownerEmail: "lisa.anderson@email.com",
                microchipNumber: "982000678901234",
                notes: "Puppy, very energetic. Still in training phase.",
                createdAt: Date().addingTimeInterval(-15 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-2 * 24 * 60 * 60)
            ),

            Patient(
                name: "Rocky",
                species: .dog,
                breed: .dogBulldog,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4), // 4 years old
                weight: Measurement(value: 25, unit: .kilograms),
                ownerName: "Robert Martinez",
                ownerPhoneNumber: "(555) 789-0123",
                ownerEmail: "robert.martinez@email.com",
                microchipNumber: "982000789012345",
                notes: "Breathing issues common to breed. Monitor during hot weather.",
                createdAt: Date().addingTimeInterval(-120 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-30 * 24 * 60 * 60)
            ),

            Patient(
                name: "Sophie",
                species: .dog,
                breed: .dogPoodle,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 7), // 7 years old
                weight: Measurement(value: 15, unit: .kilograms),
                ownerName: "Amanda Davis",
                ownerPhoneNumber: "(555) 890-1234",
                ownerEmail: "amanda.davis@email.com",
                microchipNumber: "982000890123456",
                notes: "Regular grooming required. Very intelligent and trainable.",
                createdAt: Date().addingTimeInterval(-105 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-35 * 24 * 60 * 60)
            ),

            Patient(
                name: "Buddy",
                species: .dog,
                breed: .dogBeagle,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 5), // 5 years old
                weight: Measurement(value: 22, unit: .kilograms),
                ownerName: "Christopher Lee",
                ownerPhoneNumber: "(555) 901-2345",
                ownerEmail: "chris.lee@email.com",
                microchipNumber: "982000901234567",
                notes: "Excellent hunting dog. Prone to weight gain, monitor diet.",
                createdAt: Date().addingTimeInterval(-135 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-40 * 24 * 60 * 60)
            ),

            Patient(
                name: "Zoe",
                species: .dog,
                breed: .dogPoodle,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
                weight: Measurement(value: 27, unit: .kilograms),
                ownerName: "Jessica Brown",
                ownerPhoneNumber: "(555) 012-3456",
                ownerEmail: "jessica.brown@email.com",
                microchipNumber: "982000012345678",
                notes: "High energy working dog. Requires lots of exercise and mental stimulation.",
                createdAt: Date().addingTimeInterval(-80 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-12 * 24 * 60 * 60)
            )
        ]
    }

    // MARK: - Cat Patients

    private static func generateCatPatients() -> [Patient] {
        [
            Patient(
                name: "Whiskers",
                species: .cat,
                breed: .catPersian,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4), // 4 years old
                weight: Measurement(value: 5.5, unit: .kilograms),
                ownerName: "Maria Garcia",
                ownerPhoneNumber: "(555) 111-2222",
                ownerEmail: "maria.garcia@email.com",
                microchipNumber: "982000111222333",
                notes: "Long-haired breed, requires daily brushing. Indoor cat only.",
                createdAt: Date().addingTimeInterval(-50 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-8 * 24 * 60 * 60)
            ),

            Patient(
                name: "Mittens",
                species: .cat,
                breed: .catPersian,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 6), // 6 years old
                weight: Measurement(value: 4.8, unit: .kilograms),
                ownerName: "Thomas White",
                ownerPhoneNumber: "(555) 222-3333",
                ownerEmail: "thomas.white@email.com",
                microchipNumber: "982000222333444",
                notes: "Senior cat, early signs of kidney disease. Special diet.",
                createdAt: Date().addingTimeInterval(-95 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-18 * 24 * 60 * 60)
            ),

            Patient(
                name: "Oliver",
                species: .cat,
                breed: .catMaineCoon,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years old
                weight: Measurement(value: 7.2, unit: .kilograms),
                ownerName: "Karen Miller",
                ownerPhoneNumber: "(555) 333-4444",
                ownerEmail: "karen.miller@email.com",
                microchipNumber: "982000333444555",
                notes: "Large breed cat, very social. Gets along well with dogs.",
                createdAt: Date().addingTimeInterval(-70 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-14 * 24 * 60 * 60)
            ),

            Patient(
                name: "Sophie",
                species: .cat,
                breed: .catMaineCoon,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 5), // 5 years old
                weight: Measurement(value: 6.8, unit: .kilograms),
                ownerName: "Daniel Taylor",
                ownerPhoneNumber: "(555) 444-5555",
                ownerEmail: "daniel.taylor@email.com",
                microchipNumber: "982000444555666",
                notes: "Spayed female, very calm temperament. Good with children.",
                createdAt: Date().addingTimeInterval(-110 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-22 * 24 * 60 * 60)
            ),

            Patient(
                name: "Leo",
                species: .cat,
                breed: .catSiamese,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
                weight: Measurement(value: 4.5, unit: .kilograms),
                ownerName: "Rachel Green",
                ownerPhoneNumber: "(555) 555-6666",
                ownerEmail: "rachel.green@email.com",
                microchipNumber: "982000555666777",
                notes: "Very vocal cat, typical of breed. Prefers warm environments.",
                createdAt: Date().addingTimeInterval(-85 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-16 * 24 * 60 * 60)
            ),

            Patient(
                name: "Cleo",
                species: .cat,
                breed: .catSiamese,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 1), // 1 year old
                weight: Measurement(value: 3.8, unit: .kilograms),
                ownerName: "Steven Clark",
                ownerPhoneNumber: "(555) 666-7777",
                ownerEmail: "steven.clark@email.com",
                microchipNumber: "982000666777888",
                notes: "Young cat, still very playful. Recently spayed.",
                createdAt: Date().addingTimeInterval(-25 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-3 * 24 * 60 * 60)
            ),

            Patient(
                name: "Shadow",
                species: .cat,
                breed: .catRussianBlue,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 7), // 7 years old
                weight: Measurement(value: 5.2, unit: .kilograms),
                ownerName: "Jennifer Lewis",
                ownerPhoneNumber: "(555) 777-8888",
                ownerEmail: "jennifer.lewis@email.com",
                microchipNumber: "982000777888999",
                notes: "Shy cat, takes time to warm up to new people. Indoor only.",
                createdAt: Date().addingTimeInterval(-140 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-28 * 24 * 60 * 60)
            ),

            Patient(
                name: "Luna",
                species: .cat,
                breed: .catBritishShorthair,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 4), // 4 years old
                weight: Measurement(value: 5.8, unit: .kilograms),
                ownerName: "Matthew Turner",
                ownerPhoneNumber: "(555) 888-9999",
                ownerEmail: "matthew.turner@email.com",
                microchipNumber: "982000888999000",
                notes: "Calm and gentle personality. Good for apartment living.",
                createdAt: Date().addingTimeInterval(-65 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-11 * 24 * 60 * 60)
            )
        ]
    }

    // MARK: - Exotic Patients

    private static func generateExoticPatients() -> [Patient] {
        [
            Patient(
                name: "Bunny",
                species: .rabbit,
                breed: .rabbitAngora,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 2), // 2 years old
                weight: Measurement(value: 2.1, unit: .kilograms),
                ownerName: "Ashley Moore",
                ownerPhoneNumber: "(555) 999-0000",
                ownerEmail: "ashley.moore@email.com",
                notes: "Holland Lop rabbit. Requires high-fiber diet and regular nail trims.",
                createdAt: Date().addingTimeInterval(-40 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-6 * 24 * 60 * 60)
            ),

            Patient(
                name: "Polly",
                species: .bird,
                breed: .birdLovebird,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 8), // 8 years old
                weight: Measurement(value: 0.4, unit: .kilograms),
                ownerName: "Brian Hall",
                ownerPhoneNumber: "(555) 000-1111",
                ownerEmail: "brian.hall@email.com",
                notes: "African Grey Parrot. Very intelligent, requires mental stimulation.",
                createdAt: Date().addingTimeInterval(-100 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-20 * 24 * 60 * 60)
            ),

            Patient(
                name: "Spike",
                species: .other,
                breed: .otherUnknown,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 3), // 3 years old
                weight: Measurement(value: 0.3, unit: .kilograms),
                ownerName: "Kevin Adams",
                ownerPhoneNumber: "(555) 111-0000",
                ownerEmail: "kevin.adams@email.com",
                notes: "Bearded Dragon. Requires UVB lighting and specific temperature range.",
                createdAt: Date().addingTimeInterval(-55 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-9 * 24 * 60 * 60)
            ),

            Patient(
                name: "Patches",
                species: .other,
                breed: .otherUnknown,
                birthDate: Date().addingTimeInterval(-365 * 24 * 60 * 60 * 1), // 1 year old
                weight: Measurement(value: 0.8, unit: .kilograms),
                ownerName: "Michelle Scott",
                ownerPhoneNumber: "(555) 222-1111",
                ownerEmail: "michelle.scott@email.com",
                notes: "Guinea Pig. Social animal, lives with companion. Vitamin C supplementation needed.",
                createdAt: Date().addingTimeInterval(-35 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-4 * 24 * 60 * 60)
            )
        ]
    }
}
