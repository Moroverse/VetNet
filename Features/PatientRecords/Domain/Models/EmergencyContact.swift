//
//  EmergencyContact.swift
//  VetNet
//
//  Created by Daniel Moro on 22. 7. 2025..
//


public struct EmergencyContact: Codable, Sendable, Equatable {
    public let name: String
    public let phoneNumber: String
    public let relationship: String
}
