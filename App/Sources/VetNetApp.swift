// VetNetApp.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-21 18:27 GMT.

import FactoryKit
import SwiftUI

@main
struct VetNetApp: App {
    #if DEBUG
        @State private var developmentConfig = DevelopmentConfigurationService()
        @State private var showingDebugSettings = false
    #endif

    var body: some Scene {
        WindowGroup {
            PatientManagementView()
                .onAppear {
                    initializeConfiguration()
                }
            #if DEBUG
                .onShake {
                    // Enable shake to access debug settings
                    showingDebugSettings = true
                }
                .sheet(isPresented: $showingDebugSettings) {
                    DebugSettingsView()
                }
            #endif
        }
    }

    // MARK: - Configuration

    private func initializeConfiguration() {
        // Ensure feature flags are properly initialized
        let featureFlagService = Container.shared.featureFlagService()

        // Log current configuration in debug mode
        #if DEBUG
            print("🚀 VetNet starting up...")
            print("📊 Patient Management V1: \(featureFlagService.isEnabled(.patientManagementV1) ? "enabled" : "disabled")")
            print("🔧 Mock Data: \(featureFlagService.isEnabled(.useMockData) ? "enabled" : "disabled")")
            print("☁️ CloudKit Sync: \(featureFlagService.isEnabled(.cloudKitSync) ? "enabled" : "disabled")")
            print("✨ Liquid Glass UI: \(featureFlagService.isEnabled(.liquidGlassUI) ? "enabled" : "disabled")")

            // Initialize development configuration
            Task {
                await developmentConfig.initialize()
            }
        #endif
    }
}

#if DEBUG

    // MARK: - Shake Gesture Extension

    extension UIWindow {
        override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                NotificationCenter.default.post(name: .deviceShakeNotification, object: nil)
            }
        }
    }

    extension Notification.Name {
        static let deviceShakeNotification = Notification.Name("DeviceShakeNotification")
    }

    extension View {
        func onShake(perform action: @escaping () -> Void) -> some View {
            onReceive(NotificationCenter.default.publisher(for: .deviceShakeNotification)) { _ in
                action()
            }
        }
    }
#endif
