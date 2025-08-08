// VetNetScreen.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-06 17:31 GMT.

import XCTest

/// Base class for all screen objects in VetNet UI tests
class VetNetScreen {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }
}

// MARK: - XCUIApplication Extensions

extension XCUIApplication {
    /// Navigate to the patient list screen (app starts here)
    func navigateToPatientList() -> PatientListScreen {
        // App already starts on patient list, just wait for it to load
        let patientListTitle = navigationBars["Patient Details"]
        XCTAssertTrue(patientListTitle.waitForExistence(timeout: 5), "Patient list should be displayed")
        return PatientListScreen(app: self)
    }
}

// MARK: - Screen Objects

/// Patient list screen object
class PatientListScreen: VetNetScreen {
    /// Tap the create new patient button
    @MainActor
    func tapCreateNewPatient() -> PatientCreationScreen {
        // Find and tap the "Add" button
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add button should exist")
        addButton.tap()

        return PatientCreationScreen(app: app)
    }
}

/// Patient creation screen object
class PatientCreationScreen: VetNetScreen {
    @MainActor
    func enterPatientName(_ name: String) -> PatientCreationScreen {
        // Find the name field using accessibility identifier from PatientFormView.swift
        let nameField = app.textFields["patient_creation_name_field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Patient name field should exist")
        nameField.tap()
        nameField.typeText(name)
        return self
    }

    @MainActor
    func selectSpecies(_ species: String) -> PatientCreationScreen {
        // Find and tap the species picker using accessibility identifier
        let speciesPicker = app.buttons["patient_creation_species_picker"]
        XCTAssertTrue(speciesPicker.waitForExistence(timeout: 5), "Species picker should exist")
        speciesPicker.tap()

        // Select the species from the picker - use buttons like Belfalas does
        let speciesOption = app.buttons[species].firstMatch
        XCTAssertTrue(speciesOption.waitForExistence(timeout: 5), "Species option '\(species)' should exist")
        speciesOption.tap()

        return self
    }

    @Main
    func selectBreed(_ breed: String) -> PatientCreationScreen {
        // Find and tap the breed picker using accessibility identifier
        let breedPicker = app.buttons["patient_creation_breed_picker"]
        XCTAssertTrue(breedPicker.waitForExistence(timeout: 5), "Breed picker should exist")
        breedPicker.tap()

        // Select the breed from the picker
        let breedOption = app.buttons[breed].firstMatch
        XCTAssertTrue(breedOption.waitForExistence(timeout: 5), "Breed option '\(breed)' should exist")
        breedOption.tap()

        return self
    }

    func enterOwnerName(_ name: String) -> PatientCreationScreen {
        // TODO: Find owner name field and enter text
        self
    }

    func enterOwnerPhone(_ phone: String) -> PatientCreationScreen {
        // TODO: Find owner phone field and enter text
        self
    }

    func tapSave() -> PatientCreationScreen {
        // TODO: Find and tap save button
        self
    }

    func assertPatientCreatedSuccessfully() -> PatientCreationScreen {
        // TODO: Assert success state
        self
    }
}
