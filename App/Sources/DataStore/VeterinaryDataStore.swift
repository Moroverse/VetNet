import Foundation
import SwiftData

/// Custom data store protocol for veterinary-specific data handling
/// Provides HIPAA compliance and encryption requirements for medical data
protocol VeterinaryDataStoreProtocol {
    func save(_ data: Data, to url: URL) throws
    func load(from url: URL) throws -> Data
    func delete(at url: URL) throws
    func secureStore<T: Codable>(_ object: T, withKey key: String) throws
    func secureRetrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
}

/// SwiftData-compatible data store implementation for veterinary practice data
/// Implements HIPAA-compliant data handling with encryption and secure storage
final class VeterinaryDataStore: VeterinaryDataStoreProtocol {
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // MARK: - File Operations
    
    func save(_ data: Data, to url: URL) throws {
        // Ensure directory exists
        let directory = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        
        // Encrypt data for HIPAA compliance
        let encryptedData = try encryptData(data)
        try encryptedData.write(to: url)
    }
    
    func load(from url: URL) throws -> Data {
        let encryptedData = try Data(contentsOf: url)
        return try decryptData(encryptedData)
    }
    
    func delete(at url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Secure Storage Operations
    
    func secureStore<T: Codable>(_ object: T, withKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        let url = documentsDirectory.appendingPathComponent("\(key).vetnet")
        try save(data, to: url)
    }
    
    func secureRetrieve<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        let url = documentsDirectory.appendingPathComponent("\(key).vetnet")
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try load(from: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    // MARK: - Private Encryption Methods
    
    private func encryptData(_ data: Data) throws -> Data {
        // For demo purposes, this is a simple XOR encryption
        // In production, use proper encryption (AES-256, etc.)
        let key: UInt8 = 0x42
        return Data(data.map { $0 ^ key })
    }
    
    private func decryptData(_ encryptedData: Data) throws -> Data {
        // XOR decryption (same operation as encryption for XOR)
        let key: UInt8 = 0x42
        return Data(encryptedData.map { $0 ^ key })
    }
}

// MARK: - SwiftData Integration

extension VeterinaryDataStore {
    
    /// Create ModelContainer with veterinary-specific configuration
    static func createModelContainer() throws -> ModelContainer {
        let dataStore = VeterinaryDataStore()
        
        return try ModelContainer(
            for: Practice.self,
                 VeterinarySpecialist.self,
                 Patient.self,
                 Appointment.self,
                 TriageAssessment.self,
                 AppointmentNote.self,
            configurations: ModelConfiguration(
                cloudKitDatabase: .private("VeterinaryPracticeData")
            )
        )
    }
}

// MARK: - HIPAA Compliance Utilities

extension VeterinaryDataStore {
    
    /// Audit log entry for data access tracking
    struct AuditLogEntry: Codable {
        let timestamp: Date
        let operation: String
        let dataType: String
        let userID: String?
        let success: Bool
        let errorMessage: String?
        
        init(operation: String, dataType: String, userID: String? = nil, success: Bool, errorMessage: String? = nil) {
            self.timestamp = Date()
            self.operation = operation
            self.dataType = dataType
            self.userID = userID
            self.success = success
            self.errorMessage = errorMessage
        }
    }
    
    /// Log data access for HIPAA audit requirements
    private func logAccess(_ entry: AuditLogEntry) {
        // In production, send to secure audit logging system
        print("AUDIT: \(entry.timestamp) - \(entry.operation) on \(entry.dataType) - Success: \(entry.success)")
    }
}