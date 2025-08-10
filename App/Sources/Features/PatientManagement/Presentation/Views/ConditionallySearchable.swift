// ConditionallySearchable.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-03-31 06:20 GMT.

import SwiftUI

struct ConditionallySearchable: ViewModifier {
    let isSearchable: Bool
    let text: Binding<String>
    let placement: SearchFieldPlacement
    let prompt: Text?

    func body(content: Content) -> some View {
        if isSearchable {
            content
                .searchable(text: text, placement: placement, prompt: prompt)
        } else {
            content
        }
    }

    init(isSearchable: Bool, text: Binding<String>, placement: SearchFieldPlacement = .automatic, prompt: Text? = nil) {
        self.isSearchable = isSearchable
        self.text = text
        self.placement = placement
        self.prompt = prompt
    }
}

public extension View {
    func conditionallySearchable(
        isSearchable: Bool,
        text: Binding<String>,
        placement: SearchFieldPlacement = .automatic,
        prompt: Text? = nil
    ) -> some View {
        modifier(ConditionallySearchable(isSearchable: isSearchable, text: text, placement: placement, prompt: prompt))
    }
}
