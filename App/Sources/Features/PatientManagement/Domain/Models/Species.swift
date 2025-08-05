// Species.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:58 GMT.

import Foundation

// MARK: - Species

/// Veterinary species enumeration with business rules
enum Species: String, CaseIterable, Sendable, Hashable {
    case dog
    case cat
    case bird
    case rabbit
    case other

    /// Display name for UI
    var displayName: String {
        switch self {
        case .dog: "Dog"
        case .cat: "Cat"
        case .bird: "Bird"
        case .rabbit: "Rabbit"
        case .other: "Other"
        }
    }

    /// Typical maximum age in years for this species
    var typicalMaxAge: Int {
        switch self {
        case .dog: 20
        case .cat: 22
        case .bird: 30 // Varies widely, but reasonable upper bound
        case .rabbit: 12
        case .other: 25 // Conservative estimate
        }
    }

    /// Healthy weight range for this species (in kilograms)
    var typicalWeightRange: ClosedRange<Double> {
        switch self {
        case .dog: 0.5 ... 100.0 // Chihuahua to Great Dane
        case .cat: 0.5 ... 15.0 // Small to large cats
        case .bird: 0.01 ... 20.0 // Hummingbird to large parrot
        case .rabbit: 0.5 ... 8.0 // Small to large rabbit breeds
        case .other: 0.01 ... 1000.0 // Wide range for unknown species
        }
    }

    /// Available breeds for this species
    var availableBreeds: [Breed] {
        switch self {
        case .dog:
            [
                .dogLabrador, .dogGermanShepherd, .dogGoldenRetriever,
                .dogBulldog, .dogBeagle, .dogPoodle, .dogRottweiler,
                .dogSiberianHusky, .dogChihuahua, .dogBorderCollie,
                .dogMixed, .dogUnknown
            ]

        case .cat:
            [
                .catPersian, .catMaineCoon, .catSiamese, .catBritishShorthair,
                .catRagdoll, .catAbyssinian, .catBengal, .catRussianBlue,
                .catMixed, .catUnknown
            ]

        case .bird:
            [
                .birdParrot, .birdCanary, .birdFinch, .birdCockatiel,
                .birdBudgerigar, .birdCockatoo, .birdLovebird,
                .birdOther, .birdUnknown
            ]

        case .rabbit:
            [
                .rabbitHollandLop, .rabbitLionhead, .rabbitDutch,
                .rabbitRex, .rabbitAngora, .rabbitMini,
                .rabbitMixed, .rabbitUnknown
            ]

        case .other:
            [.otherUnknown]
        }
    }
}

// MARK: - CustomStringConvertible

extension Species: CustomStringConvertible {
    var description: String {
        displayName
    }
}
