// Breed.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-22 19:39 GMT.

import Foundation

// MARK: - Breed

/// Veterinary breed enumeration organized by species
enum Breed: String, CaseIterable, Sendable, Hashable {
    // MARK: - Dog Breeds

    case dogLabrador = "dog_labrador"
    case dogGermanShepherd = "dog_german_shepherd"
    case dogGoldenRetriever = "dog_golden_retriever"
    case dogBulldog = "dog_bulldog"
    case dogBeagle = "dog_beagle"
    case dogPoodle = "dog_poodle"
    case dogRottweiler = "dog_rottweiler"
    case dogSiberianHusky = "dog_siberian_husky"
    case dogChihuahua = "dog_chihuahua"
    case dogBorderCollie = "dog_border_collie"
    case dogMixed = "dog_mixed"
    case dogUnknown = "dog_unknown"

    // MARK: - Cat Breeds

    case catPersian = "cat_persian"
    case catMaineCoon = "cat_maine_coon"
    case catSiamese = "cat_siamese"
    case catBritishShorthair = "cat_british_shorthair"
    case catRagdoll = "cat_ragdoll"
    case catAbyssinian = "cat_abyssinian"
    case catBengal = "cat_bengal"
    case catRussianBlue = "cat_russian_blue"
    case catMixed = "cat_mixed"
    case catUnknown = "cat_unknown"

    // MARK: - Bird Breeds

    case birdParrot = "bird_parrot"
    case birdCanary = "bird_canary"
    case birdFinch = "bird_finch"
    case birdCockatiel = "bird_cockatiel"
    case birdBudgerigar = "bird_budgerigar"
    case birdCockatoo = "bird_cockatoo"
    case birdLovebird = "bird_lovebird"
    case birdOther = "bird_other"
    case birdUnknown = "bird_unknown"

    // MARK: - Rabbit Breeds

    case rabbitHollandLop = "rabbit_holland_lop"
    case rabbitLionhead = "rabbit_lionhead"
    case rabbitDutch = "rabbit_dutch"
    case rabbitRex = "rabbit_rex"
    case rabbitAngora = "rabbit_angora"
    case rabbitMini = "rabbit_mini"
    case rabbitMixed = "rabbit_mixed"
    case rabbitUnknown = "rabbit_unknown"

    // MARK: - Other

    case otherUnknown = "other_unknown"

    /// Display name for UI
    var displayName: String {
        switch self {
        // Dog breeds
        case .dogLabrador: "Labrador Retriever"
        case .dogGermanShepherd: "German Shepherd"
        case .dogGoldenRetriever: "Golden Retriever"
        case .dogBulldog: "Bulldog"
        case .dogBeagle: "Beagle"
        case .dogPoodle: "Poodle"
        case .dogRottweiler: "Rottweiler"
        case .dogSiberianHusky: "Siberian Husky"
        case .dogChihuahua: "Chihuahua"
        case .dogBorderCollie: "Border Collie"
        case .dogMixed: "Mixed Breed"
        case .dogUnknown: "Unknown"
        // Cat breeds
        case .catPersian: "Persian"
        case .catMaineCoon: "Maine Coon"
        case .catSiamese: "Siamese"
        case .catBritishShorthair: "British Shorthair"
        case .catRagdoll: "Ragdoll"
        case .catAbyssinian: "Abyssinian"
        case .catBengal: "Bengal"
        case .catRussianBlue: "Russian Blue"
        case .catMixed: "Mixed Breed"
        case .catUnknown: "Unknown"
        // Bird breeds
        case .birdParrot: "Parrot"
        case .birdCanary: "Canary"
        case .birdFinch: "Finch"
        case .birdCockatiel: "Cockatiel"
        case .birdBudgerigar: "Budgerigar"
        case .birdCockatoo: "Cockatoo"
        case .birdLovebird: "Lovebird"
        case .birdOther: "Other Bird"
        case .birdUnknown: "Unknown"
        // Rabbit breeds
        case .rabbitHollandLop: "Holland Lop"
        case .rabbitLionhead: "Lionhead"
        case .rabbitDutch: "Dutch"
        case .rabbitRex: "Rex"
        case .rabbitAngora: "Angora"
        case .rabbitMini: "Mini"
        case .rabbitMixed: "Mixed Breed"
        case .rabbitUnknown: "Unknown"
        // Other
        case .otherUnknown: "Unknown"
        }
    }

    /// The species this breed belongs to
    var species: Species {
        switch self {
        case .dogLabrador, .dogGermanShepherd, .dogGoldenRetriever, .dogBulldog, .dogBeagle,
             .dogPoodle, .dogRottweiler, .dogSiberianHusky, .dogChihuahua, .dogBorderCollie,
             .dogMixed, .dogUnknown:
            .dog

        case .catPersian, .catMaineCoon, .catSiamese, .catBritishShorthair, .catRagdoll,
             .catAbyssinian, .catBengal, .catRussianBlue, .catMixed, .catUnknown:
            .cat

        case .birdParrot, .birdCanary, .birdFinch, .birdCockatiel, .birdBudgerigar,
             .birdCockatoo, .birdLovebird, .birdOther, .birdUnknown:
            .bird

        case .rabbitHollandLop, .rabbitLionhead, .rabbitDutch, .rabbitRex, .rabbitAngora,
             .rabbitMini, .rabbitMixed, .rabbitUnknown:
            .rabbit

        case .otherUnknown:
            .other
        }
    }
}

// MARK: - CustomStringConvertible

extension Breed: CustomStringConvertible {
    var description: String {
        displayName
    }
}
