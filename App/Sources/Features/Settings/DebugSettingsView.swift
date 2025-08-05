// DebugSettingsView.swift
// Copyright (c) 2025 Moroverse
// Debug settings view for development configuration

#if DEBUG
import SwiftUI
import FactoryKit

struct DebugSettingsView: View {
    @State private var configService = DevelopmentConfigurationService()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Header Section
                Section {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text("Development Mode")
                                .font(.headline)
                            Text("Configuration tools for development and testing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // Data Configuration Section
                Section("Data Configuration") {
                    HStack {
                        Image(systemName: configService.repositoryType.icon)
                            .foregroundColor(configService.repositoryType == .mock ? .orange : .blue)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Data Source")
                                .font(.headline)
                            Text(configService.repositoryType.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text(configService.repositoryType.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(configService.repositoryType.capabilities)
                                .font(.caption)
                                .foregroundColor(configService.repositoryType == .mock ? .orange : .green)
                        }
                        Spacer()
                        Button("Switch") {
                            configService.toggleMockData()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 2)
                    
                    if configService.canSeedSampleData {
                        // Sample data seeding - only available for production
                        HStack {
                            Image(systemName: configService.sampleDataSeeded ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(configService.sampleDataSeeded ? .green : .gray)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sample Data (22 Patients)")
                                    .font(.headline)
                                Text(configService.sampleDataSeeded ? "Sample data loaded" : "No sample data")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("Realistic veterinary patient dataset")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Group {
                                if configService.sampleDataSeeded {
                                    Button("Clear") {
                                        Task {
                                            await configService.clearSampleData()
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                } else {
                                    Button("Seed") {
                                        Task {
                                            await configService.seedSampleData()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    } else {
                        // Mock repository info
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mock Data Active")
                                    .font(.headline)
                                Text("5 built-in test patients loaded")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("Switch to Production Database to seed sample data")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // Feature Flags Section
                Section("Feature Flags") {
                    ForEach(Array(configService.currentFlags.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { flag in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatFlagName(flag.rawValue))
                                    .font(.headline)
                                Text(flag.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { configService.currentFlags[flag] ?? flag.defaultValue },
                                set: { _ in configService.toggleFeatureFlag(flag) }
                            ))
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Button("Reset All to Defaults") {
                        configService.resetAllFeatureFlags()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
                
                // System Information Section
                Section("System Information") {
                    HStack {
                        Text("Configuration Status")
                        Spacer()
                        Text(configService.isConfigured ? "Ready" : "Loading...")
                            .foregroundColor(configService.isConfigured ? .green : .orange)
                    }
                    
                    HStack {
                        Text("Build Configuration")
                        Spacer()
                        Text("Debug")
                            .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("Repository Type")
                        Spacer()
                        Text(configService.repositoryType.rawValue)
                            .foregroundColor(.primary)
                    }
                }
                
                // Actions Section
                Section("Actions") {
                    Button("Refresh Configuration") {
                        Task {
                            await configService.initialize()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    if configService.canSeedSampleData {
                        Button("Force Reseed Sample Data") {
                            Task {
                                await configService.seedSampleData(force: true)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Debug Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                if !configService.isConfigured {
                    await configService.initialize()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatFlagName(_ rawValue: String) -> String {
        rawValue
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

// MARK: - Preview

#Preview {
    DebugSettingsView()
}
#endif