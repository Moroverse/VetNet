// MedicalIDGeneratorTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import Foundation
import Testing
@testable import VetNet

@Suite("Medical ID Generator Tests")
@MainActor
struct MedicalIDGeneratorTests {
    @Test("Medical ID format is correct for each species")
    func medicalIDFormat() {
        // Test dog IDs
        let dogID = MedicalIDGenerator.generateID(for: .dog, name: "Max")
        #expect(dogID.hasPrefix("DOG"))
        #expect(dogID.count == 14) // DOG + 6 date digits + 4 sequence digits + 1 check letter

        // Test cat IDs
        let catID = MedicalIDGenerator.generateID(for: .cat, name: "Luna")
        #expect(catID.hasPrefix("CAT"))
        #expect(catID.count == 14)

        // Test bird IDs
        let birdID = MedicalIDGenerator.generateID(for: .bird, name: "Polly")
        #expect(birdID.hasPrefix("BRD"))
        #expect(birdID.count == 14)

        // Test rabbit IDs
        let rabbitID = MedicalIDGenerator.generateID(for: .rabbit, name: "Bunny")
        #expect(rabbitID.hasPrefix("RBT"))
        #expect(rabbitID.count == 14)

        // Test other IDs
        let otherID = MedicalIDGenerator.generateID(for: .other, name: "Pet")
        #expect(otherID.hasPrefix("OTH"))
        #expect(otherID.count == 14)
    }

    @Test("Medical ID contains only valid characters")
    func medicalIDCharacters() {
        let id = MedicalIDGenerator.generateID(for: .dog, name: "Test")

        // Should only contain uppercase letters and digits
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let idCharacters = CharacterSet(charactersIn: id)

        #expect(idCharacters.isSubset(of: allowedCharacters))
    }

    @Test("Medical ID is unique for same inputs")
    func medicalIDUniqueness() {
        // Generate multiple IDs with same inputs
        let ids = (0 ..< 100).map { _ in
            MedicalIDGenerator.generateID(for: .dog, name: "Max")
        }

        // Check sufficient uniqueness (at least 95% unique due to potential hash collisions)
        let uniqueIDs = Set(ids)
        #expect(uniqueIDs.count >= 95, "Expected at least 95% uniqueness, got \(uniqueIDs.count)/100")
    }

    @Test("Medical ID handles empty names")
    func medicalIDEmptyName() {
        let id = MedicalIDGenerator.generateID(for: .cat, name: "")
        #expect(id.hasPrefix("CAT"))
        #expect(id.count == 14)
    }

    @Test("Medical ID handles long names")
    func medicalIDLongName() {
        let longName = String(repeating: "A", count: 100)
        let id = MedicalIDGenerator.generateID(for: .dog, name: longName)
        #expect(id.hasPrefix("DOG"))
        #expect(id.count == 14)
    }

    @Test("Medical ID handles special characters in names")
    func medicalIDSpecialCharacters() {
        let specialName = "Mr. Whiskers Jr. #1!"
        let id = MedicalIDGenerator.generateID(for: .cat, name: specialName)
        #expect(id.hasPrefix("CAT"))
        #expect(id.count == 14)
    }

    @Test("Species prefix mapping is complete")
    func speciesPrefixMapping() {
        // Ensure all species have a prefix
        for species in Species.allCases {
            let id = MedicalIDGenerator.generateID(for: species, name: "Test")
            #expect(id.count == 14, "Species \(species) should generate valid ID")

            // Verify prefix matches expected pattern
            switch species {
            case .dog:
                #expect(id.hasPrefix("DOG"))
            case .cat:
                #expect(id.hasPrefix("CAT"))
            case .bird:
                #expect(id.hasPrefix("BRD"))
            case .rabbit:
                #expect(id.hasPrefix("RBT"))
            case .other:
                #expect(id.hasPrefix("OTH"))
            }
        }
    }
}
