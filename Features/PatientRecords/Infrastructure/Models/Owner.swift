import Foundation
import SwiftData

@Model
public final class Owner: Sendable {
    @Attribute(.unique) var ownerID: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var address: Address?
    var emergencyContact: EmergencyContact?
    var preferredCommunication: CommunicationPreference
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var patients: [Patient] = []
    
    @Attribute(.unique) var emailKey: String
    
    init(
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String,
        address: Address? = nil,
        emergencyContact: EmergencyContact? = nil,
        preferredCommunication: CommunicationPreference = .email
    ) {
        self.ownerID = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.emailKey = email.lowercased()
        self.phoneNumber = phoneNumber
        self.address = address
        self.emergencyContact = emergencyContact
        self.preferredCommunication = preferredCommunication
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}





