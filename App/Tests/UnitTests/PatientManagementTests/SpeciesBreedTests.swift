// SpeciesBreedTests.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-31 19:05 GMT.

import Foundation
import Testing
@testable import VetNet

@Suite("Species and Breed Tests")
@MainActor
struct SpeciesBreedTests {
    // MARK: - Species Tests

    @Test("Species display names are correct")
    func speciesDisplayNames() {
        #expect(Species.dog.displayName == "Dog")
        #expect(Species.cat.displayName == "Cat")
        #expect(Species.bird.displayName == "Bird")
        #expect(Species.rabbit.displayName == "Rabbit")
        #expect(Species.other.displayName == "Other")
    }

    // MARK: - Breed Tests

    @Test("Breed species relationship is correct")
    func breedSpeciesRelationship() {
        // Dog breeds
        #expect(Breed.dogLabrador.species == .dog)
        #expect(Breed.dogGermanShepherd.species == .dog)
        #expect(Breed.dogGoldenRetriever.species == .dog)
        #expect(Breed.dogMixed.species == .dog)

        // Cat breeds
        #expect(Breed.catPersian.species == .cat)
        #expect(Breed.catSiamese.species == .cat)
        #expect(Breed.catMaineCoon.species == .cat)
        #expect(Breed.catMixed.species == .cat)

        // Other species breeds
        #expect(Breed.birdParrot.species == .bird)
        #expect(Breed.rabbitMixed.species == .rabbit)
        #expect(Breed.otherUnknown.species == .other)
    }

    @Test("Breed display names are correct")
    func breedDisplayNames() {
        #expect(Breed.dogLabrador.displayName == "Labrador Retriever")
        #expect(Breed.dogGermanShepherd.displayName == "German Shepherd")
        #expect(Breed.catPersian.displayName == "Persian")
        #expect(Breed.dogMixed.displayName == "Mixed Breed")
        #expect(Breed.catMixed.displayName == "Mixed Breed")
    }

    @Test("Species has available breeds")
    func speciesAvailableBreeds() {
        let dogBreeds = Species.dog.availableBreeds
        #expect(dogBreeds.contains(.dogLabrador))
        #expect(dogBreeds.contains(.dogGermanShepherd))
        #expect(dogBreeds.contains(.dogMixed))
        #expect(!dogBreeds.contains(.catPersian))

        let catBreeds = Species.cat.availableBreeds
        #expect(catBreeds.contains(.catPersian))
        #expect(catBreeds.contains(.catSiamese))
        #expect(catBreeds.contains(.catMixed))
        #expect(!catBreeds.contains(.dogLabrador))

        let birdBreeds = Species.bird.availableBreeds
        #expect(birdBreeds.contains(.birdParrot))
        #expect(birdBreeds.contains(.birdOther))

        let rabbitBreeds = Species.rabbit.availableBreeds
        #expect(rabbitBreeds.contains(.rabbitMixed))
        #expect(rabbitBreeds.contains(.rabbitUnknown))
    }
}
