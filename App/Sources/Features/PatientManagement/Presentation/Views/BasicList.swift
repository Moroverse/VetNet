// BasicList.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 06:38 GMT.

import StateKit
import SwiftUI

extension ListModel {
    /// Returns the current content if available, regardless of the current loading state
    var currentContent: Model? {
        switch state {
        case .empty:
            return nil

        case let .loaded(model, _):
            return model

        case let .inProgress(_, previousState: currentState):
            // Extract content from the currentState if it's in ready state
            if case let .loaded(model, _) = currentState {
                return model
            }
            return nil

        case let .error(_, previousState: previousState):
            if case let .loaded(model, _) = previousState {
                return model
            }
            return nil
        }
    }

    var loadMoreState: LoadMoreState<Model> {
        switch state {
        case let .loaded(_, state):
            state
        case .empty, .inProgress, .error:
            .unavailable
        }
    }

    var isError: Bool {
        switch state {
        case .error:
            true
        default:
            false
        }
    }

    var errorMessage: LocalizedStringResource? {
        switch state {
        case let .error(message, _):
            message
        default:
            nil
        }
    }
}

struct BasicList<Model: RandomAccessCollection, Query: Sendable, R: View, V: Hashable>: View
    where Model: Sendable, Query: Sendable & Equatable, Model.Element: Identifiable & Sendable {
    @State var viewModel: SearchScopeListModel<Model, Query, V>
    @State private var shouldShowError = false
    @State private var searchText: String = ""
    private let listRow: (Model.Element) -> R
    private let isSearchable: Bool

    var body: some View {
        ZStack {
            // Always render the list when we have content
            if let model = viewModel.currentContent {
                list(model)
            } else if case let .empty(label, imageResource) = viewModel.state {
                ContentUnavailableView(
                    String(localized: label),
                    systemImage: imageResource
                )
            }

            // Overlay the progress indicator only when needed
            if case let .inProgress(task, _) = viewModel.state {
                ContentUnavailableView {
                    ProgressView()
                } description: {
                    Text("Loading")
                }
                actions: {
                    Button("Cancel", role: .cancel) {
                        task.cancel()
                    }
                }
                .padding()
                .fixedSize()
                .background(in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .conditionallySearchable(isSearchable: isSearchable, text: $searchText)
        .task {
            await viewModel.load()
        }
        .alert("Error", isPresented: $shouldShowError, actions: {}, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .onChange(of: viewModel.isError) { _, newValue in
            if newValue {
                shouldShowError = true
            }
        }
        .onChange(of: searchText) { _, newValue in
            Task {
                await viewModel.search(newValue)
            }
        }
    }

    init(
        viewModel: SearchScopeListModel<Model, Query, V>,
        isSearchable: Bool = true,
        @ViewBuilder listRow: @escaping (Model.Element) -> R
    ) {
        self.viewModel = viewModel
        self.listRow = listRow
        self.isSearchable = isSearchable
    }

    private func list(_ model: Model) -> some View {
        resolvedList(model)
            .refreshable {
                await viewModel.load(forceReload: true)
            }
    }

    @ViewBuilder
    private func resolvedList(_ model: Model) -> some View {
        if viewModel.canHandleSelection {
            List(selection: $viewModel.selection) {
                listInnerContent(model)
            }
        } else {
            List {
                listInnerContent(model)
            }
        }
    }

    @ViewBuilder
    private func listInnerContent(_ model: Model) -> some View {
        ForEach(model) { element in
            listRow(element)
        }

        Section {
            switch viewModel.loadMoreState {
            case .unavailable:
                EmptyView()

            case let .inProgress(task):
                HStack {
                    ProgressView()
                    Text("Loading...")
                    Button("", systemImage: "xmark.circle", role: .cancel) {
                        task.cancel()
                    }
                }

            case .ready:
                Button("Load More") {
                    Task {
                        try await viewModel.loadMore()
                    }
                }
            }
        }
    }
}
