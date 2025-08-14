// SearchScopeListModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-14 02:41 GMT.

import QuickForm
import StateKit

final class SearchScopeListModel<Model: RandomAccessCollection, Query: Sendable, V: Hashable>: ListModel<Model, Query>
    where Model: Sendable, Query: Sendable & Equatable, Model.Element: Identifiable, Model.Element: Sendable {
    var selectedScope: V {
        didSet {
            Task {
                await load(forceReload: true)
            }
        }
    }

    init(
        selection: Model.Element.ID? = nil,
        searchScope: V,
        configuration: ListModelConfiguration = .default,
        loader: @escaping ModelLoader<Query, Model>,
        queryBuilder: @escaping (String, V) -> Query,
        onSelectionChange: ((Model.Element?) -> Void)? = nil
    ) {
        selectedScope = searchScope
        super.init(
            selection: selection,
            configuration: configuration,
            loader: loader,
            queryBuilder: { string in
                queryBuilder(string, searchScope)
            },
            onSelectionChange: onSelectionChange
        )
        self.queryBuilder = { [weak self] string in
            queryBuilder(string, self?.selectedScope ?? searchScope)
        }
    }
}
