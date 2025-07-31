// Container+VetNet.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:34 GMT.

import FactoryKit
import Foundation
import SwiftData

extension Container {
    // MARK: - Data Layer

    @MainActor
    var modelContext: Factory<ModelContext> {
        self {
            let container = ModelContainer.vetNetContainer()
            return ModelContext(container)
        }
        .singleton
    }
    
    @MainActor
    var modelContainer: Factory<ModelContainer> {
        self {
            ModelContainer.vetNetContainer()
        }
        .singleton
    }

    // MARK: - Patient Management

    @MainActor
    var patientRepository: Factory<PatientRepositoryProtocol> {
        self {
            SwiftDataPatientRepository(modelContext: self.modelContext())
        }
        .cached
        .onDebug {
            MockPatientRepository(behavior: .duplicateKeyError)
        }
    }

    @MainActor
    var patientCRUDRepository: Factory<PatientCRUDRepository> {
        self {
            self.patientRepository()
        }
    }

    var dateProvider: Factory<DateProvider> {
        self {
            SystemDateProvider()
        }
        .cached
    }

    @MainActor
    var patientValidator: Factory<PatientValidator> {
        self {
            PatientValidator(dateProvider: SystemDateProvider())
        }
        .cached
    }
}

// MARK: - ModelContainer Extension

extension ModelContainer {
    static func vetNetContainer() -> ModelContainer {
        let schema = Schema([
            PatientEntity.self
            // Future entities will be added here
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
            // CloudKit disabled for development - uncomment when CloudKit entitlements are configured
            // cloudKitDatabase: .private("VetNetSecure")
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
