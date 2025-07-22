// Container+VetNet.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:31 GMT.

import FactoryKit
import Foundation
import SwiftData

extension Container {
    // MARK: - Data Layer

    // TODO: Uncomment when SwiftData entities are implemented
    // var modelContext: Factory<ModelContext> {
    //    self {
    //        let container = ModelContainer.vetNetContainer()
    //        return ModelContext(container)
    //    }
    //    .singleton
    // }

    // MARK: - Patient Management

    // TODO: Uncomment when repository protocols are implemented

    // var patientRepository: Factory<PatientRepositoryProtocol> {
    //    self {
    //        SwiftDataPatientRepository(context: self.modelContext())
    //    }
    //    .cached
    // }
    //
    // // MARK: - Services
    //
    // var patientService: Factory<PatientServiceProtocol> {
    //    self {
    //        PatientService(repository: self.patientRepository())
    //    }
    //    .cached
    // }
}

// TODO: Uncomment when PatientEntity is implemented
// // MARK: - ModelContainer Extension
//
// extension ModelContainer {
//    static func vetNetContainer() -> ModelContainer {
//        let schema = Schema([
//            PatientEntity.self
//            // Future entities will be added here
//        ])
//
//        let configuration = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false,
//            cloudKitConfiguration: .init(containerIdentifier: "iCloud.com.moroverse.VetNet")
//        )
//
//        do {
//            return try ModelContainer(for: schema, configurations: [configuration])
//        } catch {
//            fatalError("Failed to create ModelContainer: \(error)")
//        }
//    }
// }
