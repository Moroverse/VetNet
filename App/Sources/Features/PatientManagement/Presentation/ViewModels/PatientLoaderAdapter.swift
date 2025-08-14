// PatientLoaderAdapter.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 06:38 GMT.

import FactoryKit
import Foundation
import StateKit

// MARK: - Patient Search Query

/// Query object for patient search operations
nonisolated struct PatientQuery: Sendable, Equatable {
    let searchText: String
    let scope: SearchScope

    init(searchText: String = "", scope: SearchScope = .all) {
        self.searchText = searchText
        self.scope = scope
    }
}

// MARK: - Patient Loader Adapter

/// Adapter that bridges PatientPaginationRepository to StateKit ModelLoader
/// Handles conversion between repository Paginated results and ModelLoader expectations
final class PatientLoaderAdapter {
    @Injected(\.patientPaginationRepository)
    private var repository

    // MARK: - ModelLoader Implementation

    func load(query: PatientQuery) async throws -> Paginated<Patient> {
        if query.searchText.isEmpty {
            // Use findWithPagination for full patient list
            try await repository.findWithPagination(limit: 20)
        } else {
            // Use searchByNameWithPagination for filtered results with scope
            try await repository.searchWithPagination(
                query.searchText,
                scope: query.scope,
                limit: 20
            )
        }
    }
}
