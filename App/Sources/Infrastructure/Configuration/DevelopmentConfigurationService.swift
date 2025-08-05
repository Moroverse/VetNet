// DevelopmentConfigurationService.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-05 03:57 GMT.

import FactoryKit
import Foundation
import SwiftUI

// MARK: - Development Configuration Service

@Observable
final class DevelopmentConfigurationService: Sendable {
    @ObservationIgnored
    @Injected(\.featureFlagService) private var featureFlagService
    @ObservationIgnored
    @Injected(\.dataSeedingService) private var dataSeedingService

    var isConfigured = false
    var sampleDataSeeded = false
    var currentFlags: [FeatureFlag: Bool] = [:]

    private let lock = NSLock()
    @ObservationIgnored
    private nonisolated let notificationToken: NotificationCenter.ObservationToken

    // MARK: - Initialization

    init() {
        weak var weakSelf: DevelopmentConfigurationService?
        // Listen for feature flag changes using new Message API
        notificationToken = NotificationCenter.default.addObserver(
            for: FeatureFlagDidChangeMessage.self
        ) { _ in
            Task {
                weakSelf?.updateCurrentFlags()
            }
        }

        weakSelf = self

        Task { @MainActor in
            await initialize()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(notificationToken)
    }

    // MARK: - Public Interface

    /// Initialize development configuration
    func initialize() async {
        updateCurrentFlags()

        // Check if sample data is already seeded
        do {
            sampleDataSeeded = try await dataSeedingService.isSampleDataSeeded()
        } catch {
            print("⚠️ Failed to check sample data status: \(error)")
            sampleDataSeeded = false
        }

        isConfigured = true
        print("🔧 Development configuration initialized")
    }

    /// Toggle between mock and real data
    func toggleMockData() {
        let currentValue = featureFlagService.isEnabled(.useMockData)
        featureFlagService.setEnabled(.useMockData, !currentValue)
        updateCurrentFlags()

        print("🔄 Mock data toggle: \(!currentValue ? "enabled" : "disabled")")
    }

    /// Seed sample data
    func seedSampleData(force: Bool = false) async {
        do {
            try await dataSeedingService.seedPatientData(force: force)
            await MainActor.run {
                sampleDataSeeded = true
            }
        } catch {
            print("❌ Failed to seed sample data: \(error)")
        }
    }

    /// Clear all sample data
    func clearSampleData() async {
        do {
            try await dataSeedingService.clearAllPatientData()
            await MainActor.run {
                sampleDataSeeded = false
            }
        } catch {
            print("❌ Failed to clear sample data: \(error)")
        }
    }

    /// Toggle a specific feature flag
    func toggleFeatureFlag(_ flag: FeatureFlag) {
        let currentValue = featureFlagService.isEnabled(flag)
        featureFlagService.setEnabled(flag, !currentValue)
        updateCurrentFlags()
    }

    /// Reset all feature flags to defaults
    func resetAllFeatureFlags() {
        featureFlagService.resetAll()
        updateCurrentFlags()
    }

    /// Get current repository type based on feature flags
    var repositoryType: RepositoryType {
        if featureFlagService.isEnabled(.useMockData) {
            .mock
        } else {
            .production
        }
    }

    /// Check if sample data seeding is available (only for production)
    var canSeedSampleData: Bool {
        repositoryType == .production
    }

    // MARK: - Private Methods

    private func updateCurrentFlags() {
        currentFlags = featureFlagService.getAllFlags()
    }
}

// MARK: - Repository Type

enum RepositoryType: String, CaseIterable {
    case mock = "Mock Repository"
    case production = "Production Database"

    var description: String {
        switch self {
        case .mock:
            "In-memory with 5 built-in test patients. Data resets on app restart."
        case .production:
            "Persistent SwiftData database. Can be seeded with 22 sample patients."
        }
    }

    var icon: String {
        switch self {
        case .mock:
            "testtube.2"
        case .production:
            "cylinder.fill"
        }
    }

    var capabilities: String {
        switch self {
        case .mock:
            "⚠️ Sample data seeding disabled"
        case .production:
            "✅ Sample data seeding available"
        }
    }
}
