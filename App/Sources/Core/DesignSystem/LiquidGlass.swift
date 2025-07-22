// LiquidGlass.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:29 GMT.

import SwiftUI

// MARK: - Glass Effect Container

@MainActor
struct GlassEffectContainer<Content: View>: View {
    let content: Content
    let effectID: String

    init(effectID: String = UUID().uuidString, @ViewBuilder content: () -> Content) {
        self.effectID = effectID
        self.content = content()
    }

    var body: some View {
        content
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .glassEffectID(effectID)
    }
}

// MARK: - Glass Card

@MainActor
struct GlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        GlassEffectContainer {
            content
                .padding()
        }
    }
}

// MARK: - Glass Form Field

@MainActor
struct GlassFormField<Content: View>: View {
    let label: String
    let content: Content
    let isRequired: Bool

    init(
        label: String,
        isRequired: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.isRequired = isRequired
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.primary)

                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }

                Spacer()
            }

            GlassEffectContainer {
                content
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Glass Button

@MainActor
struct GlassButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let isDisabled: Bool

    enum ButtonStyle {
        case primary
        case secondary
        case destructive

        var backgroundColor: Color {
            switch self {
            case .primary:
                .blue
            case .secondary:
                .secondary
            case .destructive:
                .red
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive:
                .white
            case .secondary:
                .primary
            }
        }
    }

    init(
        title: String,
        style: ButtonStyle = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(style.backgroundColor.opacity(isDisabled ? 0.3 : 1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .disabled(isDisabled)
    }
}

// MARK: - View Extensions

extension View {
    func glassEffectID(_ id: String) -> some View {
        self.id(id)
    }
}
