import Foundation
import SwiftData

@Model
final class MedicalDocument: Sendable {
    @Attribute(.unique) var documentID: UUID
    var title: String
    var documentType: MedicalDocumentType
    var content: String?
    var fileURL: URL?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(inverse: \Patient.medicalDocuments) var patient: Patient?
    
    init(
        title: String,
        documentType: MedicalDocumentType,
        content: String? = nil,
        fileURL: URL? = nil,
        patient: Patient? = nil
    ) {
        self.documentID = UUID()
        self.title = title
        self.documentType = documentType
        self.content = content
        self.fileURL = fileURL
        self.patient = patient
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum MedicalDocumentType: String, CaseIterable, Codable, Sendable {
    case vaccinationRecord = "Vaccination Record"
    case medicalHistory = "Medical History"
    case labResults = "Lab Results"
    case xray = "X-Ray"
    case prescription = "Prescription"
    case treatmentPlan = "Treatment Plan"
    case notes = "Notes"
}