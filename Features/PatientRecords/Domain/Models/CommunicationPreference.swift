//
//  CommunicationPreference.swift
//  VetNet
//
//  Created by Daniel Moro on 22. 7. 2025..
//


public enum CommunicationPreference: String, CaseIterable, Codable, Sendable {
    case email = "Email"
    case phone = "Phone"
    case text = "Text"
    case mail = "Mail"
}
