import Foundation

final class SamplePatientService: PatientService {
    private var patients: [UUID: Patient] = [:]
    private let validator = PatientValidator()
    private let shouldSimulateErrors: Bool
    
    init(shouldSimulateErrors: Bool = false) {
        self.shouldSimulateErrors = shouldSimulateErrors
        self.patients = [:]
    }
    
    func create(_ patient: Patient) async throws -> Patient {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 2 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        // Validate patient data
        if !validator.isValidName(patient.name) {
            throw ServiceError.validationFailed(["Invalid patient name"])
        }
        
        if let birthDate = patient.dateOfBirth, !validator.isValidBirthDate(birthDate) {
            throw ServiceError.validationFailed(["Invalid birth date"])
        }
        
        if let weight = patient.weight, !validator.isValidWeight(weight, for: patient.species) {
            throw ServiceError.validationFailed(["Invalid weight for species"])
        }
        
        if let microchip = patient.microchipNumber, !validator.isValidMicrochip(microchip) {
            throw ServiceError.validationFailed(["Invalid microchip format"])
        }
        
        if let notes = patient.notes, !validator.isValidNotes(notes) {
            throw ServiceError.validationFailed(["Notes too long"])
        }
        
        // Simulate creation delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        patients[patient.patientID] = patient
        return patient
    }
    
    func update(_ patient: Patient) async throws -> Patient {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 2 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        guard patients[patient.patientID] != nil else {
            throw ServiceError.notFound("Patient")
        }
        
        // Validate updated patient data
        if !validator.isValidName(patient.name) {
            throw ServiceError.validationFailed(["Invalid patient name"])
        }
        
        // Simulate update delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        var updatedPatient = patient
        updatedPatient.updatedAt = Date()
        patients[patient.patientID] = updatedPatient
        return updatedPatient
    }
    
    func delete(_ patient: Patient) async throws {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 2 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        guard patients[patient.patientID] != nil else {
            throw ServiceError.notFound("Patient")
        }
        
        // Simulate soft delete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        var deletedPatient = patient
        deletedPatient.isActive = false
        deletedPatient.updatedAt = Date()
        patients[patient.patientID] = deletedPatient
    }
    
    func findById(_ id: UUID) async throws -> Patient? {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        return patients[id]?.isActive == true ? patients[id] : nil
    }
    
    func search(query: String) async throws -> [Patient] {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let lowercaseQuery = query.lowercased()
        return patients.values.filter { patient in
            patient.isActive && (
                patient.name.lowercased().contains(lowercaseQuery) ||
                patient.medicalID.lowercased().contains(lowercaseQuery) ||
                patient.species.rawValue.lowercased().contains(lowercaseQuery) ||
                patient.breed?.lowercased().contains(lowercaseQuery) == true ||
                patient.owner?.fullName.lowercased().contains(lowercaseQuery) == true
            )
        }.sorted { $0.name < $1.name }
    }
    
    func fetch(limit: Int, offset: Int) async throws -> [Patient] {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        let activePatients = patients.values
            .filter { $0.isActive }
            .sorted { $0.createdAt > $1.createdAt }
        
        let startIndex = min(offset, activePatients.count)
        let endIndex = min(offset + limit, activePatients.count)
        
        guard startIndex < endIndex else { return [] }
        
        return Array(activePatients[startIndex..<endIndex])
    }
    
    func fetchAll() async throws -> [Patient] {
        if shouldSimulateErrors && Int.random(in: 1...10) <= 1 {
            throw ServiceError.networkError(NSError(domain: "Mock", code: 500, userInfo: nil))
        }
        
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        return patients.values
            .filter { $0.isActive }
            .sorted { $0.name < $1.name }
    }
    
    // Helper methods for testing
    func addPatient(_ patient: Patient) {
        patients[patient.patientID] = patient
    }
    
    func removeAllPatients() {
        patients.removeAll()
    }
    
    func patientCount() -> Int {
        patients.values.filter { $0.isActive }.count
    }
}
