// Container+VetNet.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:34 GMT.

import FactoryKit
import Foundation
import SwiftData

extension Container {
    // MARK: - Data Layer

    var modelContext: Factory<ModelContext> {
        self {
            let container = ModelContainer.vetNetContainer()
            return ModelContext(container)
        }
        .singleton
    }

    // MARK: - Patient Management

    var patientRepository: Factory<PatientRepositoryProtocol> {
        self {
            SwiftDataPatientRepository(modelContext: self.modelContext())
        }
        .cached
    }

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
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("VetNetSecure")
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
