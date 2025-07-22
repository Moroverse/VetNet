import Foundation

final class SampleOwnerService: OwnerService {
    private var owners: [UUID: Owner] = [:]
    private var emailIndex: [String: UUID] = [:]
    private let validator = OwnerValidator()
    private let shouldSimulateErrors: Bool
    
    init(shouldSimulateErrors: Bool = false) {
        self.shouldSimulateErrors = shouldSimulateErrors
        self.owners = [:]
        self.emailIndex = [:]
    }
    
    func create(_ owner: Owner) async throws -> Owner {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 2 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        // Check for duplicate email
        if emailIndex[owner.email.lowercased()] != nil {
            throw ServiceError.duplicateEmail(owner.email)
        }
        
        // Validate owner data
        if !validator.isValidFirstName(owner.firstName) {
            throw ServiceError.validationFailed(["Invalid first name"])
        }
        
        if !validator.isValidLastName(owner.lastName) {
            throw ServiceError.validationFailed(["Invalid last name"])
        }
        
        if !validator.isValidEmail(owner.email) {
            throw ServiceError.validationFailed(["Invalid email format"])
        }
        
        if !validator.isValidPhoneNumber(owner.phoneNumber) {
            throw ServiceError.validationFailed(["Invalid phone number"])
        }
        
        // Simulate creation delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        owners[owner.ownerID] = owner
        emailIndex[owner.email.lowercased()] = owner.ownerID
        return owner
    }
    
    func update(_ owner: Owner) async throws -> Owner {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 2 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        guard let existingOwner = owners[owner.ownerID] else {
            throw ServiceError.notFound("Owner")
        }
        
        // Check for duplicate email (excluding current owner)
        if let existingEmailOwnerID = emailIndex[owner.email.lowercased()],
           existingEmailOwnerID != owner.ownerID {
            throw ServiceError.duplicateEmail(owner.email)
        }
        
        // Validate updated owner data
        if !validator.isValidFirstName(owner.firstName) {
            throw ServiceError.validationFailed(["Invalid first name"])
        }
        
        if !validator.isValidLastName(owner.lastName) {
            throw ServiceError.validationFailed(["Invalid last name"])
        }
        
        if !validator.isValidEmail(owner.email) {
            throw ServiceError.validationFailed(["Invalid email format"])
        }
        
        if !validator.isValidPhoneNumber(owner.phoneNumber) {
            throw ServiceError.validationFailed(["Invalid phone number"])
        }
        
        // Simulate update delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Update email index if email changed
        if existingOwner.email.lowercased() != owner.email.lowercased() {
            emailIndex.removeValue(forKey: existingOwner.email.lowercased())
            emailIndex[owner.email.lowercased()] = owner.ownerID
        }
        
        var updatedOwner = owner
        updatedOwner.updatedAt = Date()
        owners[owner.ownerID] = updatedOwner
        return updatedOwner
    }
    
    func delete(_ owner: Owner) async throws {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 2 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        guard owners[owner.ownerID] != nil else {
            throw ServiceError.notFound("Owner")
        }
        
        // Simulate soft delete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        var deletedOwner = owner
        deletedOwner.isActive = false
        deletedOwner.updatedAt = Date()
        owners[owner.ownerID] = deletedOwner
        
        // Remove from email index
        emailIndex.removeValue(forKey: owner.email.lowercased())
    }
    
    func findById(_ id: UUID) async throws -> Owner? {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        return owners[id]?.isActive == true ? owners[id] : nil
    }
    
    func findByEmail(_ email: String) async throws -> Owner? {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 150_000_000) // 0.15 seconds
        
        guard let ownerID = emailIndex[email.lowercased()],
              let owner = owners[ownerID],
              owner.isActive else {
            return nil
        }
        
        return owner
    }
    
    func search(query: String) async throws -> [Owner] {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let lowercaseQuery = query.lowercased()
        return owners.values.filter { owner in
            owner.isActive && (
                owner.firstName.lowercased().contains(lowercaseQuery) ||
                owner.lastName.lowercased().contains(lowercaseQuery) ||
                owner.email.lowercased().contains(lowercaseQuery) ||
                owner.phoneNumber.contains(query)
            )
        }.sorted { $0.fullName < $1.fullName }
    }
    
    func fetch(limit: Int, offset: Int) async throws -> [Owner] {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        let activeOwners = owners.values
            .filter { $0.isActive }
            .sorted { $0.fullName < $1.fullName }
        
        let startIndex = min(offset, activeOwners.count)
        let endIndex = min(offset + limit, activeOwners.count)
        
        guard startIndex < endIndex else { return [] }
        
        return Array(activeOwners[startIndex..<endIndex])
    }
    
    // Helper methods for testing
    func addOwner(_ owner: Owner) {
        owners[owner.ownerID] = owner
        emailIndex[owner.email.lowercased()] = owner.ownerID
    }
    
    func removeAllOwners() {
        owners.removeAll()
        emailIndex.removeAll()
    }
    
    func ownerCount() -> Int {
        owners.values.filter { $0.isActive }.count
    }
}
