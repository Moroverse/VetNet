// MedicalIDGenerator.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:58 GMT.

import Foundation

// MARK: - Medical ID Generator

/// Generates unique medical IDs for veterinary patients
/// Format: [Species Code][YYYYMM][Sequential Number][Check Digit]
/// Example: DOG2025011234A
enum MedicalIDGenerator {
    /// Generate a unique medical ID for a patient
    /// - Parameters:
    ///   - species: Patient species
    ///   - name: Patient name (used for deterministic component)
    /// - Returns: Unique medical ID string
    static func generateID(for species: Species, name: String) -> String {
        let speciesCode = species.medicalCode
        let dateComponent = dateComponent()
        let sequentialNumber = generateSequentialNumber(from: name)
        let checkDigit = generateCheckDigit(species: speciesCode, date: dateComponent, sequence: sequentialNumber)

        return "\(speciesCode)\(dateComponent)\(sequentialNumber)\(checkDigit)"
    }

    /// Validate a medical ID format
    /// - Parameter medicalID: The medical ID to validate
    /// - Returns: True if the format is valid
    static func isValidFormat(_ medicalID: String) -> Bool {
        // Expected format: [3 letters][6 digits][4 digits][1 letter] = 14 chars total
        let pattern = #"^[A-Z]{3}\d{6}\d{4}[A-Z]$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: medicalID.count)
        return regex?.firstMatch(in: medicalID, options: [], range: range) != nil
    }

    /// Extract species from medical ID
    /// - Parameter medicalID: The medical ID
    /// - Returns: Species if extractable, nil otherwise
    static func extractSpecies(from medicalID: String) -> Species? {
        guard medicalID.count >= 3 else { return nil }
        let speciesCode = String(medicalID.prefix(3))
        return Species.allCases.first { $0.medicalCode == speciesCode }
    }
}

// MARK: - Private Implementation

private extension MedicalIDGenerator {
    /// Generate date component (YYYYMM format)
    static func dateComponent() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter.string(from: Date())
    }

    /// Generate sequential number from patient name
    /// Uses hash of name combined with timestamp to create unique 4-digit number
    static func generateSequentialNumber(from name: String) -> String {
        let nameHash = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).hash
        let timestampHash = Int(Date().timeIntervalSince1970 * 1_000_000) // Convert to microseconds for more uniqueness
        let combinedHash = nameHash ^ timestampHash // XOR for uniqueness
        let positiveHash = abs(combinedHash)
        let fourDigitNumber = positiveHash % 10000
        return String(format: "%04d", fourDigitNumber)
    }

    /// Generate check digit using simple algorithm
    static func generateCheckDigit(species: String, date: String, sequence: String) -> String {
        let combined = species + date + sequence
        let hash = combined.hash
        let positiveHash = abs(hash)
        let letterIndex = positiveHash % 26
        let letter = Character(UnicodeScalar(65 + letterIndex)!) // A-Z
        return String(letter)
    }
}

// MARK: - Species Extension

private extension Species {
    /// Three-letter medical code for this species
    var medicalCode: String {
        switch self {
        case .dog: "DOG"
        case .cat: "CAT"
        case .bird: "BRD"
        case .rabbit: "RBT"
        case .other: "OTH"
        }
    }
}
