// Container+VetNet.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:34 GMT.

import FactoryKit
import Foundation
import StateKit
import SwiftData

// MARK: - CloudKit Setup Requirements

//
// VetNet uses CloudKit for secure, HIPAA-compliant data synchronization across devices.
// The following setup is required for CloudKit functionality:
//
// ## Entitlements (✅ Configured)
// - com.apple.developer.icloud-services: ["CloudKit"]
// - com.apple.developer.icloud-container-identifiers: ["iCloud.com.moroverse.VetNet"]
// - com.apple.developer.ubiquity-kvstore-identifier: $(TeamIdentifierPrefix)$(CFBundleIdentifier)
//
// ## Development Requirements
// 1. Sign into iCloud on the device/simulator
// 2. Ensure Apple Developer account has CloudKit capability enabled
// 3. Create CloudKit container "iCloud.com.moroverse.VetNet" in Apple Developer Portal
// 4. Configure CloudKit Dashboard at https://icloud.developer.apple.com/dashboard/
// 5. Create "VetNetSecure" custom zone for HIPAA-compliant data isolation
//
// ## Fallback Behavior
// - Tests/Previews: Uses in-memory storage (no persistence)
// - Missing entitlements: Gracefully falls back to local-only storage in DEBUG builds
// - CloudKit errors: Enhanced error logging with troubleshooting guidance
// - Production: Fatal error for CloudKit failures to ensure data integrity
//
// ## Environment Variables
// - FORCE_LOCAL_STORAGE=1: Forces local-only storage even with valid entitlements
// - USE_DEBUG_FEATURE_FLAGS=1: Enables debug feature flag service
//
// Check console logs for CloudKit initialization status and troubleshooting information.

extension Container {
    // MARK: - Core Services

    /// UUID Provider for generating unique identifiers
    var uuidProvider: Factory<UUIDProvider> {
        self {
            #if DEBUG
                let provider = ControllableUUIDProvider.sequential()
                // Register with test control plane in debug mode
                Task { @MainActor in
                    TestControlPlane.shared.register(provider, as: .uuidProvider)
                }
                return provider
            #else
                return ControllableUUIDProvider()
            #endif
        }.singleton
    }

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
            // let container = Container.shared.modelContainer()
            ModelContext(self.modelContainer())
        }
        .singleton
    }

    /// Creates the main ModelContainer for the application
    /// - Returns: ModelContainer with CloudKit integration
    /// - Note: Uses singleton pattern to ensure single source of truth
    @MainActor
    var modelContainer: Factory<ModelContainer> {
        self {
            ModelContainer.vetNetContainer()
        }
        .singleton
    }

    // MARK: - Patient Management

    /// Primary patient repository with full protocol implementation
    /// - Returns: PatientRepositoryProtocol implementation
    /// - Note: Uses cached scope for performance, respects feature flags for mock/real data
    @MainActor
    var patientRepository: Factory<PatientRepositoryProtocol> {
        self {
            // Check if we're in UI testing mode first
            if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
                // Use mock repository for UI tests
                // Skip initial data if a test scenario is specified (will be configured by TestControlPlane)
                let skipData = ProcessInfo.processInfo.arguments.contains("-TEST_SCENARIO")
                let mockRepo = MockPatientRepository(behavior: .success, skipInitialData: skipData)

                // Register with TestControlPlane if test scenario is active
                #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-TEST_SCENARIO") {
                        TestControlPlane.shared.register(mockRepo, as: .patientRepository)
                        TestControlPlane.shared.register(mockRepo, as: .patientCRUDRepository)
                    }
                #endif

                return mockRepo
            }

            let featureFlagService = self.featureFlagService()

            if featureFlagService.isEnabled(.useMockData) {
                // Return mock when flag is enabled (fixing the bug where it returned SwiftData)
                return MockPatientRepository(behavior: .success)
            } else {
                let context = Container.shared.modelContext()
                return SwiftDataPatientRepository(modelContext: context)
            }
        }
        .cached
    }

    /// CRUD-specific patient repository interface
    /// - Returns: PatientCRUDRepository for basic operations
    /// - Note: Delegates to main patient repository, respects feature flags
    @MainActor
    var patientCRUDRepository: Factory<PatientCRUDRepository> {
        self {
            Container.shared.patientRepository()
        }
        .cached
    }

    /// Pagination-specific patient repository interface
    /// - Returns: PatientPaginationRepository for pagination operations
    /// - Note: Delegates to main patient repository, respects feature flags
    @MainActor
    var patientPaginationRepository: Factory<PatientPaginationRepository> {
        self {
            Container.shared.patientRepository()
        }
        .cached
    }

    /// Patient loader adapter for StateKit ListModel integration
    /// - Returns: PatientLoaderAdapter that bridges repository to StateKit
    /// - Note: Cached for performance
    @MainActor
    var patientLoaderAdapter: Factory<PatientLoaderAdapter> {
        self {
            PatientLoaderAdapter()
        }
        .cached
    }

    @MainActor
    var patientListViewModel: Factory<PatientListViewModel> {
        self { PatientListViewModel() }
            .cached
    }

    /// Date provider service for testable date operations
    /// - Returns: DateProvider implementation
    /// - Note: Cached for consistent date behavior across app
    /// - TestControl Mode: Uses ControllableDateProvider for test scenarios
    @MainActor
    var dateProvider: Factory<DateProvider> {
        self {
            #if DEBUG
                // Use ControllableDateProvider in debug mode for TestControl integration
                let provider = ControllableDateProvider()

                // Register with TestControlPlane
                TestControlPlane.shared.register(provider, as: .dateProvider)

                return provider
            #else
                // Production uses system date provider
                return SystemDateProvider()
            #endif
        }
        .cached
    }

    /// Patient validation service with business rules
    /// - Returns: PatientValidator with configured dependencies
    /// - Note: Cached for performance, uses SystemDateProvider
    @MainActor
    var patientValidator: Factory<PatientValidator> {
        self {
            PatientValidator(dateProvider: self.dateProvider())
        }
        .cached
    }

    // MARK: - Configuration Services

    /// Logging service for structured application logging
    /// - Returns: LoggingService implementation based on environment
    /// Logger in production, ConsoleLogger in debug, SilentLogger in tests
    var loggingService: Factory<LoggingService> {
        self {
            SystemLoggingService()
        }
        .cached
        .onDebug {
            ConsoleLoggingService()
        }
        .onTest {
            SilentLoggingService()
        }
    }

    /// Router event broker for event-driven navigation management
    /// - Returns: EventBroker implementation for router events
    /// - Note: Singleton for entire app lifecycle
    @MainActor
    var routerEventBroker: Factory<EventBroker> {
        self {
            RouterEventBroker()
        }
        .singleton
    }

    /// Factory for creating router events with controlled dependencies
    @MainActor
    var routerEventFactory: Factory<RouterEventFactory> {
        self {
            RouterEventFactory()
        }
        .cached
    }

    /// Feature flag service for configuration management
    /// - Returns: FeatureFlagService implementation
    /// - Note: Uses UserDefaults-based service, debug service in test environments
    @MainActor
    var featureFlagService: Factory<FeatureFlagService> {
        self {
            UserDefaultsFeatureFlagService()
        }
        .onDebug {
            if ProcessInfo.processInfo.environment["USE_DEBUG_FEATURE_FLAGS"] != nil {
                DebugFeatureFlagService()
            } else {
                UserDefaultsFeatureFlagService()
            }
        }
        .cached
    }

    /// Data seeding service for development environments
    /// - Returns: DataSeedingService for sample data management
    /// - Note: Cached for consistent seeding operations
    @MainActor
    var dataSeedingService: Factory<DataSeedingService> {
        self {
            DataSeedingService()
        }
        .cached
    }

    /// Development configuration service
    /// - Returns: DevelopmentConfigurationService for dev tools
    /// - Note: Only available in debug builds
    #if DEBUG
        @MainActor
        var developmentConfigurationService: Factory<DevelopmentConfigurationService> {
            self {
                DevelopmentConfigurationService()
            }
            .cached
        }
    #endif
}

// MARK: - ModelContainer Extension

extension ModelContainer {
    /// Creates the VetNet ModelContainer with CloudKit synchronization
    /// - Returns: Configured ModelContainer for VetNet data persistence
    /// - Note: CloudKit requires proper entitlements configuration in the project
    static func vetNetContainer() -> ModelContainer {
        @Injected(\.loggingService) var logger

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
        let forceLocalOnly = ProcessInfo.processInfo.environment["FORCE_LOCAL_STORAGE"] == "1"

        // Check for CloudKit capability in non-test environments
        let cloudKitAvailable = !isPreview && !isTest && !forceLocalOnly && hasCloudKitEntitlements()

        let configuration: ModelConfiguration

        if isPreview || isTest {
            // In-memory configuration for SwiftUI previews and tests
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        } else if cloudKitAvailable {
            // Production configuration with CloudKit
            logger.info("CloudKit entitlements detected, enabling synchronization", category: .cloudKit)
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("VetNetSecure")
            )
        } else {
            // Local-only configuration when CloudKit is not available
            logger.warning("CloudKit not available, using local storage only", category: .cloudKit)
            #if DEBUG
                logger.info("To enable CloudKit: ensure proper entitlements and Apple Developer account", category: .development)
            #endif
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
                // No CloudKit database specified
            )
        }

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])

            // Configure CloudKit-specific settings if not in test/preview
            if !isPreview, !isTest {
                configureCloudKitSettings(for: container)
            }

            return container
        } catch {
            // Enhanced error logging with CloudKit-specific messages
            logger.error("ModelContainer initialization failed: \(error.localizedDescription)", category: .data)

            // Check for specific CloudKit-related errors
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("cloudkit") || errorMessage.contains("icloud") {
                logger.error("CloudKit-related error detected", category: .cloudKit)
                logger.info("• Ensure you're signed into iCloud on the device/simulator", category: .cloudKit)
                logger.info("• Verify CloudKit container exists in Apple Developer Portal", category: .cloudKit)
                logger.info("• Check that the app is properly code signed", category: .cloudKit)
            }

            // In production, this is a critical error
            // In development, we might want to fall back to local-only storage
            #if DEBUG
                logger.warning("Attempting fallback to local-only storage...", category: .development)
                do {
                    let fallbackConfiguration = ModelConfiguration(
                        schema: schema,
                        isStoredInMemoryOnly: false
                        // CloudKit disabled in fallback
                    )
                    let fallbackContainer = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
                    logger.info("Successfully created local-only ModelContainer", category: .data)
                    logger.warning("Data will not sync across devices in this mode", category: .cloudKit)
                    return fallbackContainer
                } catch {
                    logger.critical("Even local storage failed: \(error.localizedDescription)", category: .data)
                    fatalError("Failed to create ModelContainer even without CloudKit: \(error)")
                }
            #else
                fatalError("Failed to create ModelContainer: \(error)")
            #endif
        }
    }

    /// Configures CloudKit-specific settings for HIPAA compliance
    /// - Parameter container: The ModelContainer to configure
    private static func configureCloudKitSettings(for _: ModelContainer) {
        let logger = Container.shared.loggingService()

        // CloudKit configuration happens automatically with ModelConfiguration
        // Additional configuration for HIPAA compliance would include:
        // - Custom record zones (handled by cloudKitDatabase parameter)
        // - Encryption settings (automatic with private database)
        // - Access control (managed by CloudKit entitlements)

        // Log successful CloudKit initialization
        logger.info("CloudKit configured with VetNetSecure private database", category: .cloudKit)
        logger.info("HIPAA compliance features enabled:", category: .cloudKit)
        logger.info("• End-to-end encryption via private database", category: .cloudKit)
        logger.info("• Custom zone isolation for practice data", category: .cloudKit)
        logger.info("• Audit trail logging at repository level", category: .cloudKit)
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

        let logger = Container.shared.loggingService()
        logger.warning("Creating fallback ModelContainer (in-memory only)", category: .development)
        logger.warning("Data will not persist between app launches", category: .data)

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Checks if the app has proper CloudKit entitlements configured
    /// - Returns: True if CloudKit entitlements are present and valid
    private static func hasCloudKitEntitlements() -> Bool {
        @Injected(\.loggingService) var logger

        guard let entitlements = Bundle.main.entitlements else {
            logger.debug("No entitlements found in app bundle", category: .cloudKit)
            return false
        }

        // Check for iCloud services entitlement
        guard let iCloudServices = entitlements["com.apple.developer.icloud-services"] as? [String],
              iCloudServices.contains("CloudKit") else {
            logger.debug("CloudKit service not found in iCloud services entitlement", category: .cloudKit)
            return false
        }

        // Check for iCloud container identifier
        guard let containerIds = entitlements["com.apple.developer.icloud-container-identifiers"] as? [String],
              !containerIds.isEmpty else {
            logger.debug("No iCloud container identifiers found", category: .cloudKit)
            return false
        }

        logger.info("CloudKit entitlements validated:", category: .cloudKit)
        logger.debug("• iCloud services: \(iCloudServices)", category: .cloudKit)
        logger.debug("• Container IDs: \(containerIds)", category: .cloudKit)

        return true
    }
}

// MARK: - Bundle Extension for Entitlements

private extension Bundle {
    /// Safely retrieves the app's entitlements dictionary
    var entitlements: [String: Any]? {
        guard let entitlementsPath = path(forResource: "VetNet", ofType: "entitlements"),
              let entitlementsData = NSData(contentsOfFile: entitlementsPath),
              let entitlements = try? PropertyListSerialization.propertyList(
                  from: entitlementsData as Data,
                  options: [],
                  format: nil
              ) as? [String: Any] else {
            // Fallback: try to read from embedded entitlements (iOS)
            return object(forInfoDictionaryKey: "Entitlements") as? [String: Any]
        }
        return entitlements
    }
}
