// UUIDProvider.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-10 19:38 GMT.

import Foundation

// MARK: - UUID Provider Protocol

/// Protocol for UUID generation, allowing for test control
public nonisolated protocol UUIDProvider: Sendable {
    /// Generate a new UUID
    func generate() -> UUID
}

// MARK: - System UUID Provider

/// Default UUID provider using system random generation
struct SystemUUIDProvider: UUIDProvider {
    func generate() -> UUID {
        UUID()
    }
}

// MARK: - Controllable UUID Provider

/// UUID provider that can be controlled for testing
/// Supports random, sequential, and fixed UUID generation
public final nonisolated class ControllableUUIDProvider: UUIDProvider, TestControllable, @unchecked Sendable {
    // MARK: - Behavior Definition

    public enum Behavior: Sendable {
        /// Generate random UUIDs (default)
        case random

        /// Generate sequential UUIDs starting from a base value
        case sequential(start: Int = 1)

        /// Always return the same fixed UUID
        case fixed(UUID)

        /// Return UUIDs from a predefined list, cycling when exhausted
        case cycle([UUID])
    }

    // MARK: - Properties

    private var behavior: Behavior = .random
    private var counter = 0
    private var cycleIndex = 0

    // MARK: - UUIDProvider

    public func generate() -> UUID {
        switch behavior {
        case .random:
            return UUID()

        case let .sequential(start):
            let uuidString = String(format: "00000000-0000-0000-0000-%012d", start + counter)
            counter += 1
            return UUID(uuidString: uuidString) ?? UUID()

        case let .fixed(uuid):
            return uuid

        case let .cycle(uuids):
            guard !uuids.isEmpty else { return UUID() }
            let uuid = uuids[cycleIndex % uuids.count]
            cycleIndex += 1
            return uuid
        }
    }

    // MARK: - TestControllable

    public func applyBehavior(_ behavior: Behavior) {
        self.behavior = behavior
        counter = 0
        cycleIndex = 0
    }

    public func resetBehavior() {
        behavior = .random
        counter = 0
        cycleIndex = 0
    }
}

// MARK: - Test Helpers

#if DEBUG
    extension ControllableUUIDProvider {
        /// Create a sequential UUID provider for testing
        static func sequential(start: Int = 1) -> ControllableUUIDProvider {
            let provider = ControllableUUIDProvider()
            provider.applyBehavior(.sequential(start: start))
            return provider
        }

        /// Create a fixed UUID provider for testing
        static func fixed(_ uuid: UUID) -> ControllableUUIDProvider {
            let provider = ControllableUUIDProvider()
            provider.applyBehavior(.fixed(uuid))
            return provider
        }

        /// Helper to generate a predictable UUID string for testing
        static func sequentialUUID(index: Int) -> String {
            String(format: "00000000-0000-0000-0000-%012d", index)
        }
    }
#endif
