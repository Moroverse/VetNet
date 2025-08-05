// FeatureFlagService.swift
// Copyright (c) 2025 Moroverse
// Feature flag management service using iOS 26 Configuration patterns

import Foundation
import FactoryKit

// MARK: - Feature Flag Keys

enum FeatureFlag: String, CaseIterable, Sendable {
    case patientManagementV1 = "patient_management_v1"
    case useMockData = "use_mock_data"
    case advancedDiagnostics = "advanced_diagnostics"
    case cloudKitSync = "cloudkit_sync"
    case liquidGlassUI = "liquid_glass_ui"
    
    var defaultValue: Bool {
        switch self {
        case .patientManagementV1:
            return true // Main feature is enabled by default
        case .useMockData:
            #if DEBUG
            return false // Use real data by default in debug, can be toggled
            #else
            return false // Always use real data in release
            #endif
        case .advancedDiagnostics:
            return false // Future feature, disabled by default
        case .cloudKitSync:
            return true // Core functionality
        case .liquidGlassUI:
            return true // iOS 26 UI enhancement
        }
    }
    
    var description: String {
        switch self {
        case .patientManagementV1:
            return "Patient Management V1 - Controls visibility and functionality of patient management features"
        case .useMockData:
            return "Use Mock Data - Toggle between mock and real data for development and testing"
        case .advancedDiagnostics:
            return "Advanced Diagnostics - Enable AI-powered diagnostic assistance features"
        case .cloudKitSync:
            return "CloudKit Sync - Enable CloudKit synchronization for patient data"
        case .liquidGlassUI:
            return "Liquid Glass UI - Enable iOS 26 Liquid Glass design system components"
        }
    }
}

// MARK: - Feature Flag Change Message
struct FeatureFlagDidChangeMessage: NotificationCenter.MainActorMessage {
    typealias Subject = AnyFeatureFlagService

    let flag: FeatureFlag
    let enabled: Bool
}

// MARK: - Feature Flag Service Protocol

protocol FeatureFlagService: AnyObject  {
    func isEnabled(_ flag: FeatureFlag) -> Bool
    func setEnabled(_ flag: FeatureFlag, _ enabled: Bool)
    func reset(_ flag: FeatureFlag)
    func resetAll()
    func getAllFlags() -> [FeatureFlag: Bool]
}

final class AnyFeatureFlagService: FeatureFlagService {
    private let _isEnabled: @MainActor (FeatureFlag) -> Bool
    private let _setEnabled: @MainActor (FeatureFlag, Bool) -> Void
    private let _reset: @MainActor (FeatureFlag) -> Void
    private let _resetAll: @MainActor () -> Void
    private let _getAllFlags: @MainActor () -> [FeatureFlag: Bool]

    init<T: FeatureFlagService>(_ service: T) where T: Sendable {
        self._isEnabled = { flag in
            service.isEnabled(flag)
        }
        self._setEnabled = { flag, enabled in
            service.setEnabled(flag, enabled)
        }
        self._reset = { flag in
            service.reset(flag)
        }
        self._resetAll = {
            service.resetAll()
        }
        self._getAllFlags = {
            service.getAllFlags()
        }
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        _isEnabled(flag)
    }

    func setEnabled(_ flag: FeatureFlag, _ enabled: Bool) {
        _setEnabled(flag, enabled)
    }

    func reset(_ flag: FeatureFlag) {
        _reset(flag)
    }

    func resetAll() {
        _resetAll()
    }

    func getAllFlags() -> [FeatureFlag: Bool] {
        _getAllFlags()
    }
}

// MARK: - UserDefaults Feature Flag Service

final class UserDefaultsFeatureFlagService: FeatureFlagService {

    private let userDefaults: UserDefaults
    private let keyPrefix = "FeatureFlag."
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        let key = keyPrefix + flag.rawValue
        
        // If the key doesn't exist, return the default value
        if !userDefaults.hasKey(key) {
            return flag.defaultValue
        }
        
        return userDefaults.bool(forKey: key)
    }
    
    func setEnabled(_ flag: FeatureFlag, _ enabled: Bool) {
        let key = keyPrefix + flag.rawValue
        userDefaults.set(enabled, forKey: key)
        
        // Post notification for real-time updates
        NotificationCenter.default.post(
            FeatureFlagDidChangeMessage(flag: flag, enabled: enabled)
        )
    }
    
    func reset(_ flag: FeatureFlag) {
        let key = keyPrefix + flag.rawValue
        userDefaults.removeObject(forKey: key)
        
        // Post notification for real-time updates
        NotificationCenter.default.post(
            FeatureFlagDidChangeMessage(flag: flag, enabled: flag.defaultValue)
        )
    }
    
    func resetAll() {
        for flag in FeatureFlag.allCases {
            reset(flag)
        }
    }
    
    func getAllFlags() -> [FeatureFlag: Bool] {
        var flags: [FeatureFlag: Bool] = [:]
        for flag in FeatureFlag.allCases {
            flags[flag] = isEnabled(flag)
        }
        return flags
    }
}

// MARK: - Debug Feature Flag Service

#if DEBUG
final class DebugFeatureFlagService: FeatureFlagService {
    
    private var flags: [FeatureFlag: Bool] = [:]
    private let lock = NSLock()
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return flags[flag] ?? flag.defaultValue
    }
    
    func setEnabled(_ flag: FeatureFlag, _ enabled: Bool) {
        lock.lock()
        flags[flag] = enabled
        lock.unlock()
        
        // Post notification for real-time updates
        NotificationCenter.default.post(
            FeatureFlagDidChangeMessage(flag: flag, enabled: enabled)
        )
    }
    
    func reset(_ flag: FeatureFlag) {
        lock.lock()
        flags.removeValue(forKey: flag)
        lock.unlock()
        
        // Post notification for real-time updates
        NotificationCenter.default.post(
            FeatureFlagDidChangeMessage(flag: flag, enabled: flag.defaultValue)
        )
    }
    
    func resetAll() {
        lock.lock()
        flags.removeAll()
        lock.unlock()
        
        for flag in FeatureFlag.allCases {
            NotificationCenter.default.post(
                FeatureFlagDidChangeMessage(flag: flag, enabled: flag.defaultValue)
            )
        }
    }
    
    func getAllFlags() -> [FeatureFlag: Bool] {
        lock.lock()
        defer { lock.unlock() }
        
        var result: [FeatureFlag: Bool] = [:]
        for flag in FeatureFlag.allCases {
            result[flag] = flags[flag] ?? flag.defaultValue
        }
        return result
    }
}
#endif

// MARK: - Extensions

extension UserDefaults {
    func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
}

