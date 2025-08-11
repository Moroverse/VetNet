// ServiceIdentifier.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-11 05:36 GMT.

import Foundation

// MARK: - Service Identifier

/// Identifies a service within the test control plane
/// Services can be identified by type and optional instance name
public struct ServiceIdentifier: Hashable, Sendable {
    /// The type of service (e.g., "UUIDProvider", "PatientRepository")
    public let type: String

    /// Optional instance identifier for multiple instances of the same type
    public let instance: String?

    /// Create a service identifier
    /// - Parameters:
    ///   - type: The service type
    ///   - instance: Optional instance identifier
    public init(type: String, instance: String? = nil) {
        self.type = type
        self.instance = instance
    }

    /// Create an identifier for any instance of a service type
    /// - Parameter type: The service type
    /// - Returns: A service identifier that matches any instance
    public static func any(_ type: String) -> ServiceIdentifier {
        ServiceIdentifier(type: type, instance: nil)
    }
}

// MARK: - Common Service Identifiers

public extension ServiceIdentifier {
    /// Common service type identifiers
    enum ServiceType {
        public static let uuidProvider = "UUIDProvider"
        public static let dateProvider = "DateProvider"
        public static let patientRepository = "PatientRepository"
        public static let patientCRUDRepository = "PatientCRUDRepository"
        public static let patientPaginationRepository = "PatientPaginationRepository"
        public static let networkService = "NetworkService"
        public static let authService = "AuthService"
    }

    // Convenience constructors for common services
    static let uuidProvider = ServiceIdentifier(type: ServiceType.uuidProvider)
    static let dateProvider = ServiceIdentifier(type: ServiceType.dateProvider)
    static let patientRepository = ServiceIdentifier(type: ServiceType.patientRepository)
    static let patientCRUDRepository = ServiceIdentifier(type: ServiceType.patientCRUDRepository)
}

// MARK: - CustomStringConvertible

extension ServiceIdentifier: CustomStringConvertible {
    public var description: String {
        if let instance {
            "\(type)[\(instance)]"
        } else {
            type
        }
    }
}

// MARK: - Codable

extension ServiceIdentifier: Codable {
    nonisolated enum CodingKeys: String, CodingKey {
        case type
        case instance
    }
}
