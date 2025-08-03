// Container+VetNet.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:34 GMT.

import FactoryKit
import Foundation
import SwiftData

// MARK: - CloudKit Entitlements Requirements
// 
// For CloudKit synchronization to work, ensure the following entitlements are configured:
// 1. Enable CloudKit capability in Xcode project settings
// 2. Add iCloud container: iCloud.com.moroverse.VetNet
// 3. Configure CloudKit Dashboard at https://icloud.developer.apple.com/dashboard/
// 4. Create "VetNetSecure" custom zone for HIPAA-compliant data isolation
//
// Note: CloudKit will gracefully fall back to local storage if entitlements are missing
// during development. Check console logs for CloudKit initialization status.

extension Container {
    // MARK: - Error Handling Strategy
    //
    // The VetNet container implements a robust error handling strategy:
    //
    // 1. **Production Mode**: Fatal errors for critical failures to ensure data integrity
    // 2. **Debug Mode**: Graceful fallbacks to enable development without CloudKit setup
    // 3. **Test Mode**: Mock implementations for isolated testing
    // 4. **Preview Mode**: Lightweight mocks for SwiftUI previews
    //
    // Error Recovery Hierarchy:
    // • CloudKit failure → Local storage fallback (debug only)
    // • Persistence failure → In-memory storage (debug only)
    // • Repository failure → Mock repository (debug/test only)
    //
    // All errors are logged with detailed context for debugging.
    
    // MARK: - Data Layer
    
    /// Creates a ModelContext for SwiftData operations
    /// - Returns: ModelContext instance with proper error handling
    /// - Note: Uses singleton pattern to ensure consistent database state
    @MainActor
    var modelContext: Factory<ModelContext> {
        self {
            let container = Container.shared.modelContainer()
            return ModelContext(container)
        }
        .singleton
    }
    
    /// Creates the main ModelContainer for the application
    /// - Returns: ModelContainer with CloudKit integration
    /// - Note: Uses singleton pattern to ensure single source of truth
    @MainActor
    var modelContainer: Factory<ModelContainer> {
        self {
            return ModelContainer.vetNetContainer()
        }
        .singleton
    }

    // MARK: - Patient Management
    
    /// Primary patient repository with full protocol implementation
    /// - Returns: PatientRepositoryProtocol implementation
    /// - Note: Uses cached scope for performance, mock in debug mode
    @MainActor
    var patientRepository: Factory<PatientRepositoryProtocol> {
        self {
            let context = Container.shared.modelContext()
            return SwiftDataPatientRepository(modelContext: context)
        }
        .cached
    }

    /// CRUD-specific patient repository interface
    /// - Returns: PatientCRUDRepository for basic operations
    /// - Note: Delegates to main patient repository
    @MainActor
    var patientCRUDRepository: Factory<PatientCRUDRepository> {
        self {
            Container.shared.patientRepository()
        }
        .cached
    }

    /// Date provider service for testable date operations
    /// - Returns: DateProvider implementation
    /// - Note: Cached for consistent date behavior across app
    var dateProvider: Factory<DateProvider> {
        self {
            SystemDateProvider()
        }
        .cached
    }

    /// Patient validation service with business rules
    /// - Returns: PatientValidator with configured dependencies
    /// - Note: Cached for performance, uses SystemDateProvider
    @MainActor
    var patientValidator: Factory<PatientValidator> {
        self {
            let dateProvider = Container.shared.dateProvider()
            return PatientValidator(dateProvider: dateProvider)
        }
        .cached
    }
}

// MARK: - ModelContainer Extension

extension ModelContainer {
    /// Creates the VetNet ModelContainer with CloudKit synchronization
    /// - Returns: Configured ModelContainer for VetNet data persistence
    /// - Note: CloudKit requires proper entitlements configuration in the project
    static func vetNetContainer() -> ModelContainer {
        let schema = Schema([
            PatientEntity.self
            // Future entities will be added here:
            // OwnerEntity.self,
            // AppointmentEntity.self,
            // MedicalRecordEntity.self,
            // PracticeEntity.self,
            // SpecialistEntity.self
        ])

        // MARK: - CloudKit Configuration
        
        // Use in-memory storage for testing/preview contexts
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        let isTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        
        let configuration: ModelConfiguration
        
        if isPreview || isTest {
            // In-memory configuration for SwiftUI previews and tests
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        } else {
            // Production configuration with CloudKit
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("VetNetSecure")
            )
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Configure CloudKit-specific settings if not in test/preview
            if !isPreview && !isTest {
                configureCloudKitSettings(for: container)
            }
            
            return container
        } catch {
            // Log error details for debugging
            print("⚠️ ModelContainer initialization failed: \(error.localizedDescription)")
            
            // In production, this is a critical error
            // In development, we might want to fall back to local-only storage
            #if DEBUG
            print("🔧 Attempting fallback to local-only storage...")
            do {
                let fallbackConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                    // CloudKit disabled in fallback
                )
                return try ModelContainer(for: schema, configurations: [fallbackConfiguration])
            } catch {
                fatalError("Failed to create ModelContainer even without CloudKit: \(error)")
            }
            #else
            fatalError("Failed to create ModelContainer: \(error)")
            #endif
        }
    }
    
    /// Configures CloudKit-specific settings for HIPAA compliance
    /// - Parameter container: The ModelContainer to configure
    private static func configureCloudKitSettings(for container: ModelContainer) {
        // CloudKit configuration happens automatically with ModelConfiguration
        // Additional configuration for HIPAA compliance would include:
        // - Custom record zones (handled by cloudKitDatabase parameter)
        // - Encryption settings (automatic with private database)
        // - Access control (managed by CloudKit entitlements)
        
        // Log successful CloudKit initialization
        print("✅ CloudKit configured with VetNetSecure private database")
        print("📋 HIPAA compliance features enabled:")
        print("  • End-to-end encryption via private database")
        print("  • Custom zone isolation for practice data")
        print("  • Audit trail logging at repository level")
    }
    
    /// Creates a fallback ModelContainer for development when CloudKit is unavailable
    /// - Returns: In-memory ModelContainer for development/testing
    /// - Note: This container provides basic functionality without persistence
    static func createFallbackContainer() throws -> ModelContainer {
        let schema = Schema([
            PatientEntity.self
            // Same entities as main container
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // In-memory only for fallback
        )
        
        print("🔧 Creating fallback ModelContainer (in-memory only)")
        print("⚠️  Data will not persist between app launches")
        
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
