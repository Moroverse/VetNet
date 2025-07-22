//
//  Address.swift
//  VetNet
//
//  Created by Daniel Moro on 22. 7. 2025..
//


public struct Address: Codable, Sendable, Equatable {
    public let street: String
    public let city: String
    public let state: String
    public let zipCode: String
    public let country: String

    public var formattedAddress: String {
        "\(street), \(city), \(state) \(zipCode), \(country)"
    }
}
