import Foundation
import SwiftUIRouting

/// SwiftUIRouting-based navigation service for veterinary workflows
/// Implements type-safe routing patterns optimized for veterinary practice operations
@Observable
final class NavigationService: NavigationServiceProtocol {
    
    // MARK: - Navigation State
    
    var navigationPath: [VetNetRoute] = []
    var currentAlert: AppAlert?
    var isShowingAlert = false
    
    // MARK: - Navigation Methods
    
    func navigateToSchedule() {
        navigationPath.append(.schedule)
    }
    
    func navigateToPatients() {
        navigationPath.append(.patients)
    }
    
    func navigateToSpecialists() {
        navigationPath.append(.specialists)
    }
    
    func navigateToAppointment(_ appointmentID: UUID) {
        navigationPath.append(.appointmentDetail(appointmentID))
    }
    
    func navigateToPatient(_ patientID: UUID) {
        navigationPath.append(.patientDetail(patientID))
    }
    
    func navigateToSpecialist(_ specialistID: UUID) {
        navigationPath.append(.specialistDetail(specialistID))
    }
    
    func showAlert(_ alert: AppAlert) {
        currentAlert = alert
        isShowingAlert = true
    }
    
    func dismissCurrentView() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    // MARK: - Utility Methods
    
    func popToRoot() {
        navigationPath.removeAll()
    }
    
    func popToSpecific(_ route: VetNetRoute) {
        guard let index = navigationPath.firstIndex(of: route) else { return }
        navigationPath = Array(navigationPath.prefix(through: index))
    }
    
    func dismissAlert() {
        isShowingAlert = false
        currentAlert = nil
    }
}

// MARK: - VetNet Route Definitions

enum VetNetRoute: Hashable, CaseIterable {
    case schedule
    case patients  
    case specialists
    case appointmentDetail(UUID)
    case patientDetail(UUID)
    case specialistDetail(UUID)
    case createAppointment
    case createPatient
    case createSpecialist
    case triageAssessment(UUID) // Patient ID
    case settings
    
    // MARK: - CaseIterable Support
    
    static var allCases: [VetNetRoute] {
        [
            .schedule,
            .patients,
            .specialists,
            .createAppointment,
            .createPatient,
            .createSpecialist,
            .settings
        ]
    }
    
    // MARK: - Route Metadata
    
    var title: String {
        switch self {
        case .schedule:
            return "Schedule"
        case .patients:
            return "Patients"
        case .specialists:
            return "Specialists"
        case .appointmentDetail:
            return "Appointment Details"
        case .patientDetail:
            return "Patient Details"
        case .specialistDetail:
            return "Specialist Details"
        case .createAppointment:
            return "New Appointment"
        case .createPatient:
            return "New Patient"
        case .createSpecialist:
            return "New Specialist"
        case .triageAssessment:
            return "Triage Assessment"
        case .settings:
            return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .schedule:
            return "calendar"
        case .patients:
            return "heart.circle"
        case .specialists:
            return "stethoscope"
        case .appointmentDetail, .createAppointment:
            return "calendar.badge.clock"
        case .patientDetail, .createPatient:
            return "heart.circle.fill"
        case .specialistDetail, .createSpecialist:
            return "person.crop.circle.fill"
        case .triageAssessment:
            return "cross.circle.fill"
        case .settings:
            return "gear"
        }
    }
}

// MARK: - Alert Extensions

extension AppAlert {
    
    /// Alert for appointment conflicts
    static func appointmentConflict() -> AppAlert {
        AppAlert(
            title: "Scheduling Conflict",
            message: "The selected time slot conflicts with an existing appointment. Please choose a different time.",
            primaryAction: AppAlertAction(title: "OK", style: .default, action: {})
        )
    }
    
    /// Alert for successful appointment creation
    static func appointmentCreated() -> AppAlert {
        AppAlert(
            title: "Appointment Created",
            message: "The appointment has been successfully scheduled.",
            primaryAction: AppAlertAction(title: "OK", style: .default, action: {})
        )
    }
    
    /// Alert for deletion confirmation
    static func confirmDeletion(itemType: String, action: @escaping () -> Void) -> AppAlert {
        AppAlert(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this \(itemType)? This action cannot be undone.",
            primaryAction: AppAlertAction(title: "Cancel", style: .cancel, action: {}),
            secondaryAction: AppAlertAction(title: "Delete", style: .destructive, action: action)
        )
    }
    
    /// Alert for network errors
    static func networkError() -> AppAlert {
        AppAlert(
            title: "Network Error",
            message: "Unable to connect to the server. Please check your internet connection and try again.",
            primaryAction: AppAlertAction(title: "OK", style: .default, action: {})
        )
    }
}
