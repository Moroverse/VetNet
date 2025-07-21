import Foundation
import Factory
import SwiftUIRouting

/// Main view model for VetNet application
/// Implements @Observable pattern for optimal SwiftUI integration with iOS 26
@Observable
final class MainViewModel {
    
    // MARK: - Dependencies
    
    @ObservationIgnored
    private let navigationService = Container.shared.navigationService()
    
    @ObservationIgnored  
    private let practiceService = Container.shared.practiceService()
    
    // MARK: - Published State
    
    var isLoading = false
    var errorMessage: String?
    var selectedTab: MainTab = .schedule
    
    // MARK: - Navigation State
    
    var navigationPath: [VetNetRoute] {
        navigationService.navigationPath
    }
    
    var currentAlert: AppAlert? {
        navigationService.currentAlert
    }
    
    var isShowingAlert: Bool {
        navigationService.isShowingAlert
    }
    
    // MARK: - Initialization
    
    init() {
        // Initialize view model
        setupInitialState()
    }
    
    // MARK: - Actions
    
    func selectTab(_ tab: MainTab) {
        selectedTab = tab
        
        switch tab {
        case .schedule:
            navigationService.navigateToSchedule()
        case .patients:
            navigationService.navigateToPatients()
        case .specialists:
            navigationService.navigateToSpecialists()
        case .settings:
            // Navigate to settings when implemented
            break
        }
    }
    
    func dismissAlert() {
        navigationService.dismissAlert()
    }
    
    func showError(_ message: String) {
        errorMessage = message
        let alert = AppAlert(
            title: "Error",
            message: message,
            primaryAction: AppAlertAction(title: "OK", style: .default, action: { [weak self] in
                self?.errorMessage = nil
            })
        )
        navigationService.showAlert(alert)
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        // Setup initial application state
        // This could include loading user preferences, checking authentication, etc.
    }
}

// MARK: - Supporting Types

enum MainTab: CaseIterable {
    case schedule
    case patients
    case specialists
    case settings
    
    var title: String {
        switch self {
        case .schedule:
            return "Schedule"
        case .patients:
            return "Patients"
        case .specialists:
            return "Specialists"
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
        case .settings:
            return "gear"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .schedule:
            return "calendar.fill"
        case .patients:
            return "heart.circle.fill"
        case .specialists:
            return "stethoscope"
        case .settings:
            return "gear.fill"
        }
    }
}