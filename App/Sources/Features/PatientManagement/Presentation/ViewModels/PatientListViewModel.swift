// PatientListViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-15 04:23 GMT.

import FactoryKit
import Foundation
import StateKit
import SwiftUI

/// ViewModel for managing patient list state and router event subscriptions
@MainActor
@Observable
final class PatientListViewModel {
    // MARK: - State

    var listModel: SearchScopeListModel<Paginated<Patient>, PatientQuery, SearchScope>
    private(set) var isRefreshing = false

    // MARK: - Event Subscriptions

    @ObservationIgnored
    private var formCompletedSubscription: EventSubscription?

    // MARK: - Initialization

    init() {
        @Injected(\.patientLoaderAdapter) var loader

        // Initialize list model with the loader
        listModel = SearchScopeListModel(
            searchScope: SearchScope.all,
            loader: loader.load
        ) { searchText, scope in
            PatientQuery(searchText: searchText, scope: scope)
        }

        // Set up event subscriptions after initialization
        setupEventSubscriptions()
    }

    @MainActor
    deinit {
        // Store subscription in local variable to avoid Sendable issues
        let subscription = formCompletedSubscription

        // Unsubscribe on MainActor
        subscription?.unsubscribe()
    }

    // MARK: - Event Subscriptions

    private func setupEventSubscriptions() {
        @Injected(\.routerEventBroker) var eventBroker
        // Subscribe to form completion events
        formCompletedSubscription = eventBroker.subscribe(FormPresentationCompleted.self) { [weak self] event in
            Task { @MainActor [weak self] in
                await self?.handleFormCompletion(event)
            }
        }
    }

    // MARK: - Event Handlers

    private func handleFormCompletion(_ event: FormPresentationCompleted) async {
        // Refresh list when a patient is created or updated
        switch event.result {
        case .created, .updated:
            await refreshList()
        case .deleted:
            await refreshList()
        case .cancelled, .error:
            // No action needed for cancelled forms or errors
            break
        }
    }

    // MARK: - Public Methods

    func refreshList() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        await listModel.load(forceReload: true)
    }

    func initialLoad() async {
        await listModel.load(forceReload: false)
    }
}
