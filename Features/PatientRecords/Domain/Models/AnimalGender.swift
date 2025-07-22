//
//  AnimalGender.swift
//  VetNet
//
//  Created by Daniel Moro on 22. 7. 2025..
//


public enum AnimalGender: String, CaseIterable, Codable, Sendable {
    case male = "Male"
    case female = "Female"
    case neutered = "Neutered"
    case spayed = "Spayed"
    case unknown = "Unknown"
}