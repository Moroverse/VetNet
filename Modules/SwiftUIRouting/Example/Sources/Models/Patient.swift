import Foundation

struct Patient: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var age: Int
    var medicalRecordNumber: String
    var condition: String
    var lastVisit: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        medicalRecordNumber: String,
        condition: String,
        lastVisit: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.medicalRecordNumber = medicalRecordNumber
        self.condition = condition
        self.lastVisit = lastVisit
    }
}

extension Patient {
    static var preview: Patient {
        Patient(
            name: "John Doe",
            age: 35,
            medicalRecordNumber: "MRN-12345",
            condition: "Hypertension",
            lastVisit: Date().addingTimeInterval(-86400 * 7)
        )
    }
    
    static var previews: [Patient] {
        [
            Patient(name: "John Doe", age: 35, medicalRecordNumber: "MRN-12345", condition: "Hypertension"),
            Patient(name: "Jane Smith", age: 28, medicalRecordNumber: "MRN-12346", condition: "Diabetes Type 2"),
            Patient(name: "Robert Johnson", age: 52, medicalRecordNumber: "MRN-12347", condition: "Asthma"),
            Patient(name: "Maria Garcia", age: 41, medicalRecordNumber: "MRN-12348", condition: "Arthritis"),
            Patient(name: "David Lee", age: 67, medicalRecordNumber: "MRN-12349", condition: "Heart Disease")
        ]
    }
}