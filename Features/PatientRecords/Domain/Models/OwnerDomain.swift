import Foundation

/// Pure domain model for Owner without any persistence concerns
public struct OwnerDomain: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phoneNumber: String
    public let address: Address?
    public let emergencyContact: EmergencyContact?
    public let preferredCommunication: CommunicationPreference
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        address: Address? = nil,
        emergencyContact: EmergencyContact? = nil,
        preferredCommunication: CommunicationPreference = .email,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
        self.emergencyContact = emergencyContact
        self.preferredCommunication = preferredCommunication
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Business Logic
    
    /// Full name of the owner
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Formal name for correspondence
    public var formalName: String {
        "Mr./Ms. \(lastName)"
    }
    
    /// Check if owner has complete contact information
    public var hasCompleteContactInfo: Bool {
        !email.isEmpty && !phoneNumber.isEmpty && address != nil
    }
    
    /// Preferred contact method based on preferences and available info
    public var bestContactMethod: String {
        switch preferredCommunication {
        case .email where !email.isEmpty:
            return email
        case .phone, .text where !phoneNumber.isEmpty:
            return phoneNumber
        case .mail where address != nil:
            return address?.formattedAddress ?? email
        default:
            // Fallback to any available contact
            return !email.isEmpty ? email : phoneNumber
        }
    }
    
    // MARK: - Mutations (return new instances)
    
    public func updating(
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        address: Address?? = nil,
        emergencyContact: EmergencyContact?? = nil,
        preferredCommunication: CommunicationPreference? = nil
    ) -> OwnerDomain {
        OwnerDomain(
            id: self.id,
            firstName: firstName ?? self.firstName,
            lastName: lastName ?? self.lastName,
            email: email ?? self.email,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            address: address ?? self.address,
            emergencyContact: emergencyContact ?? self.emergencyContact,
            preferredCommunication: preferredCommunication ?? self.preferredCommunication,
            isActive: self.isActive,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
    
    public func deactivated() -> OwnerDomain {
        OwnerDomain(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            email: self.email,
            phoneNumber: self.phoneNumber,
            address: self.address,
            emergencyContact: self.emergencyContact,
            preferredCommunication: self.preferredCommunication,
            isActive: false,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
}