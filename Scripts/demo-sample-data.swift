#!/usr/bin/env swift

// demo-sample-data.swift
// Copyright (c) 2025 Moroverse
// Demonstration script for VetNet sample data functionality

import Foundation

print("🐾 VetNet Sample Data Demonstration")
print("==================================")
print()

// Demonstrate the patient data that would be generated
print("📊 Sample Data Overview:")
print("• 22 total patients across multiple species")
print("• 10 Dogs (various breeds: Labrador, German Shepherd, Golden Retriever, etc.)")
print("• 8 Cats (Persian, Maine Coon, Siamese, Russian Blue, British Shorthair)")
print("• 4 Exotic pets (Rabbit, Parrot, Bearded Dragon, Guinea Pig)")
print()

print("🏥 Realistic Medical Data:")
print("• Age ranges from newborn to 8+ years")
print("• Species-appropriate weight ranges")
print("• Medical conditions typical for each species")
print("• Microchip numbers following ISO standards")
print("• Owner demographics with varied contact information")
print()

print("🔧 Development Features:")
print("• Feature flag: patient_management_v1 (controls feature visibility)")
print("• Feature flag: use_mock_data (toggles between mock and real data)")
print("• Data seeding service for development environments")
print("• Progressive rollout capability")
print("• A/B testing support")
print()

print("🚀 Usage in Development:")
print("1. Shake device to access debug settings (DEBUG builds only)")
print("2. Toggle between Mock Data and Production Data")
print("3. Seed sample data with 22 realistic patients")
print("4. Clear sample data when needed")
print("5. Feature flags persist across app launches")
print()

print("🎯 Production Considerations:")
print("• Mock data flag automatically disabled in release builds")
print("• Feature flags use UserDefaults for persistence")
print("• CloudKit sync can be controlled via feature flag")
print("• Sample data service only active in DEBUG builds")
print()

print("✅ Implementation Complete!")
print("All sample data and feature flag infrastructure is ready for use.")
print()

// Example feature flag states
let exampleFlags = [
    "patient_management_v1": true,
    "use_mock_data": false,
    "advanced_diagnostics": false,
    "cloudkit_sync": true,
    "liquid_glass_ui": true
]

print("🔍 Current Feature Flag States (example):")
for (flag, enabled) in exampleFlags.sorted(by: { $0.key < $1.key }) {
    let status = enabled ? "✅ ENABLED" : "❌ DISABLED"
    let formattedName = flag.replacingOccurrences(of: "_", with: " ").capitalized
    print("  \(formattedName): \(status)")
}
print()

print("🏁 Ready to test patient management features!")