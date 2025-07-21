import SwiftUI
import SwiftUIRouting

struct ContentView: View {
    
    @State private var viewModel = MainViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            
            // Schedule Tab
            NavigationStack(path: .constant(viewModel.navigationPath)) {
                SchedulePlaceholderView()
                    .navigationTitle("Schedule")
            }
            .tabItem {
                Image(systemName: viewModel.selectedTab == .schedule ? "calendar.fill" : "calendar")
                Text("Schedule")
            }
            .tag(MainTab.schedule)
            
            // Patients Tab
            NavigationStack {
                PatientsPlaceholderView()
                    .navigationTitle("Patients")
            }
            .tabItem {
                Image(systemName: viewModel.selectedTab == .patients ? "heart.circle.fill" : "heart.circle")
                Text("Patients")
            }
            .tag(MainTab.patients)
            
            // Specialists Tab
            NavigationStack {
                SpecialistsPlaceholderView()
                    .navigationTitle("Specialists")
            }
            .tabItem {
                Image(systemName: "stethoscope")
                Text("Specialists")
            }
            .tag(MainTab.specialists)
            
            // Settings Tab
            NavigationStack {
                SettingsPlaceholderView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: viewModel.selectedTab == .settings ? "gear.fill" : "gear")
                Text("Settings")
            }
            .tag(MainTab.settings)
        }
        .alert(
            viewModel.currentAlert?.title ?? "Alert",
            isPresented: .constant(viewModel.isShowingAlert)
        ) {
            if let alert = viewModel.currentAlert {
                Button(alert.primaryAction.title, role: buttonRole(for: alert.primaryAction.style)) {
                    alert.primaryAction.action?()
                    viewModel.dismissAlert()
                }
                
                if let secondaryAction = alert.secondaryAction {
                    Button(secondaryAction.title, role: buttonRole(for: secondaryAction.style)) {
                        secondaryAction.action?()
                        viewModel.dismissAlert()
                    }
                }
            }
        } message: {
            if let message = viewModel.currentAlert?.message {
                Text(message)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func buttonRole(for style: AppAlertAction.Style) -> ButtonRole? {
        switch style {
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        case .default:
            return nil
        }
    }
}

// MARK: - Placeholder Views

struct SchedulePlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Schedule Management")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Intelligent appointment scheduling with VTL triage integration")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("schedule_placeholder_view")
    }
}

struct PatientsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Patient Records")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Comprehensive animal patient database with medical history")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("patients_placeholder_view")
    }
}

struct SpecialistsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "stethoscope")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Veterinary Specialists")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Expert matching algorithm with availability optimization")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("specialists_placeholder_view")
    }
}

struct SettingsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gear.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            Text("Settings & Configuration")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Practice configuration and system preferences")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("settings_placeholder_view")
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
