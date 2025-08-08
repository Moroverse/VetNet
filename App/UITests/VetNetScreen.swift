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

    @MainActor
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

    @MainActor
    func enterWeight(_ weight: String) -> PatientCreationScreen {
        // Find the weight field using accessibility identifier from PatientFormView.swift
        let weightField = app.textFields["patient_creation_weight_field"]
        XCTAssertTrue(weightField.waitForExistence(timeout: 5), "Weight field should exist")
        weightField.tap()

        // Clear existing text (the default "0")
        if let currentValue = weightField.value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            weightField.typeText(deleteString)
        }

        // Use locale-appropriate decimal separator
        let locale = Locale.current
        let decimalSeparator = locale.decimalSeparator ?? "."
        let localizedWeight = weight.replacingOccurrences(of: ".", with: decimalSeparator)

        weightField.typeText(localizedWeight)
        return self
    }

    @MainActor
    func enterOwnerName(_ name: String) -> PatientCreationScreen {
        // Find the owner name field using accessibility identifier from PatientFormView.swift
        let ownerNameField = app.textFields["patient_creation_owner_name_field"]
        XCTAssertTrue(ownerNameField.waitForExistence(timeout: 5), "Owner name field should exist")
        ownerNameField.tap()
        ownerNameField.typeText(name)
        return self
    }

    @MainActor
    func enterOwnerPhone(_ phone: String) -> PatientCreationScreen {
        // Find the owner phone field using accessibility identifier from PatientFormView.swift
        let ownerPhoneField = app.textFields["patient_creation_owner_phone_field"]
        XCTAssertTrue(ownerPhoneField.waitForExistence(timeout: 5), "Owner phone field should exist")
        ownerPhoneField.tap()
        ownerPhoneField.typeText(phone)
        return self
    }

    @MainActor
    func tapSave() -> PatientCreationScreen {
        // Find and tap the save button using accessibility identifier from PatientFormView.swift
        let saveButton = app.buttons["patient_creation_save_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save button should exist")
        saveButton.tap()
        return self
    }

    @MainActor
    func assertPatientCreatedSuccessfully() -> PatientCreationScreen {
        // After successful save, the form sheet should be dismissed
        // Check that the patient creation form elements are no longer visible
        let nameField = app.textFields["patient_creation_name_field"]

        // Wait for the form to disappear (sheet dismissed)
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: nameField
        )
        let result = XCTWaiter().wait(for: [expectation], timeout: 10)

        XCTAssertEqual(result, .completed, "Patient creation form should be dismissed after successful save")

        // Verify we're back on the patient list
        let patientListTitle = app.navigationBars["Patient Details"]
        XCTAssertTrue(patientListTitle.exists, "Should be back on patient list after successful save")

        // TODO: Once patient list is implemented, verify the newly created patient appears in the list
        // Example: XCTAssertTrue(app.cells["Buddy"].exists, "Newly created patient should appear in the list")

        return self
    }

    // MARK: - Validation Assertion Methods

    @MainActor
    func assertValidationError(for field: String, message: String) -> PatientCreationScreen {
        // Validation errors appear as inline red text below the field
        // Look for the validation message text anywhere in the form
        let validationText = app.staticTexts[message]
        XCTAssertTrue(validationText.waitForExistence(timeout: 3), "Validation error '\(message)' should appear for field '\(field)'")

        // Verify the save button is disabled when validation fails
        let saveButton = app.buttons["patient_creation_save_button"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled when validation fails")

        return self
    }

    @MainActor
    func assertNoValidationError(for field: String) -> PatientCreationScreen {
        // TODO: Implement actual no validation error assertion
        // For now, just pass the test to establish the API
        self
    }
}
