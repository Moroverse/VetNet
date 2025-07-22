import Foundation
import SwiftUI

// MARK: - Feature Flag Manager

@MainActor
@Observable
final class FeatureFlagManager {
    static let shared = FeatureFlagManager()
    
    private var flags: [String: Bool] = [:]
    
    private init() {
        loadFeatureFlags()
    }
    
    private func loadFeatureFlags() {
        // Load from UserDefaults for development
        // In production, this would come from a remote config service
        flags = [
            FeatureFlag.patientManagementV1.rawValue: UserDefaults.standard.bool(forKey: FeatureFlag.patientManagementV1.rawValue),
            FeatureFlag.mockDataToggle.rawValue: UserDefaults.standard.bool(forKey: FeatureFlag.mockDataToggle.rawValue),
            FeatureFlag.progressiveRollout.rawValue: UserDefaults.standard.bool(forKey: FeatureFlag.progressiveRollout.rawValue),
            FeatureFlag.abTestingCapability.rawValue: UserDefaults.standard.bool(forKey: FeatureFlag.abTestingCapability.rawValue)
        ]
        
        // Set default values for first run
        if !UserDefaults.standard.bool(forKey: "feature_flags_initialized") {
            setDefaultFlags()
            UserDefaults.standard.set(true, forKey: "feature_flags_initialized")
        }
    }
    
    private func setDefaultFlags() {
        #if DEBUG
        // Enable all features in debug mode
        updateFlag(.patientManagementV1, isEnabled: true)
        updateFlag(.mockDataToggle, isEnabled: true)
        updateFlag(.progressiveRollout, isEnabled: true)
        updateFlag(.abTestingCapability, isEnabled: true)
        #else
        // Conservative defaults for production
        updateFlag(.patientManagementV1, isEnabled: false)
        updateFlag(.mockDataToggle, isEnabled: false)
        updateFlag(.progressiveRollout, isEnabled: false)
        updateFlag(.abTestingCapability, isEnabled: false)
        #endif
    }
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        return flags[flag.rawValue] ?? false
    }
    
    func updateFlag(_ flag: FeatureFlag, isEnabled: Bool) {
        flags[flag.rawValue] = isEnabled
        UserDefaults.standard.set(isEnabled, forKey: flag.rawValue)
        
        // Notify about the change
        NotificationCenter.default.post(
            name: .featureFlagDidChange,
            object: nil,
            userInfo: [
                "flag": flag.rawValue,
                "enabled": isEnabled
            ]
        )
    }
    
    // MARK: - A/B Testing Support
    
    func getVariant(for experiment: String) -> String {
        // Simple A/B testing implementation
        // In production, this would integrate with a proper A/B testing platform
        let userIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let hash = userIdentifier.hash
        let variant = abs(hash) % 2 == 0 ? "A" : "B"
        
        return UserDefaults.standard.string(forKey: "experiment_\(experiment)") ?? variant
    }
    
    func setVariant(_ variant: String, for experiment: String) {
        UserDefaults.standard.set(variant, forKey: "experiment_\(experiment)")
    }
    
    // MARK: - Progressive Rollout
    
    func isInRolloutGroup(for flag: FeatureFlag, percentage: Double) -> Bool {
        guard isEnabled(.progressiveRollout) else { return isEnabled(flag) }
        
        let userIdentifier = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let hash = abs(userIdentifier.hash)
        let userPercentile = Double(hash % 100)
        
        return userPercentile < percentage && isEnabled(flag)
    }
}

// MARK: - Feature Flags Enum

enum FeatureFlag: String, CaseIterable {
    case patientManagementV1 = "patient_management_v1"
    case mockDataToggle = "mock_data_toggle"
    case progressiveRollout = "progressive_rollout"
    case abTestingCapability = "ab_testing_capability"
    
    var displayName: String {
        switch self {
        case .patientManagementV1:
            return "Patient Management V1"
        case .mockDataToggle:
            return "Mock Data Toggle"
        case .progressiveRollout:
            return "Progressive Rollout"
        case .abTestingCapability:
            return "A/B Testing"
        }
    }
    
    var description: String {
        switch self {
        case .patientManagementV1:
            return "Controls visibility of patient management features"
        case .mockDataToggle:
            return "Switch between mock and real data services"
        case .progressiveRollout:
            return "Enable gradual feature rollout capabilities"
        case .abTestingCapability:
            return "Enable A/B testing framework"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let featureFlagDidChange = Notification.Name("featureFlagDidChange")
}

// MARK: - SwiftUI Property Wrapper

@propertyWrapper
struct FeatureFlagged<Value> {
    private let flag: FeatureFlag
    private let enabled: Value
    private let disabled: Value
    
    init(_ flag: FeatureFlag, enabled: Value, disabled: Value) {
        self.flag = flag
        self.enabled = enabled
        self.disabled = disabled
    }
    
    var wrappedValue: Value {
        FeatureFlagManager.shared.isEnabled(flag) ? enabled : disabled
    }
}

// MARK: - View Modifier

struct FeatureGated: ViewModifier {
    let flag: FeatureFlag
    let fallback: AnyView?
    
    init(flag: FeatureFlag, fallback: AnyView? = nil) {
        self.flag = flag
        self.fallback = fallback
    }
    
    func body(content: Content) -> some View {
        if FeatureFlagManager.shared.isEnabled(flag) {
            content
        } else if let fallback = fallback {
            fallback
        } else {
            EmptyView()
        }
    }
}

extension View {
    func featureGated(_ flag: FeatureFlag, fallback: AnyView? = nil) -> some View {
        modifier(FeatureGated(flag: flag, fallback: fallback))
    }
}

// MARK: - Feature Flag Configuration View (Debug Only)

#if DEBUG
struct FeatureFlagConfigurationView: View {
    @State private var flagManager = FeatureFlagManager.shared
    
    var body: some View {
        NavigationView {
            List {
                ForEach(FeatureFlag.allCases, id: \.rawValue) { flag in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(flag.displayName)
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: binding(for: flag))
                        }
                        Text(flag.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Feature Flags")
        }
    }
    
    private func binding(for flag: FeatureFlag) -> Binding<Bool> {
        Binding(
            get: { flagManager.isEnabled(flag) },
            set: { flagManager.updateFlag(flag, isEnabled: $0) }
        )
    }
}

#Preview {
    FeatureFlagConfigurationView()
}
#endif