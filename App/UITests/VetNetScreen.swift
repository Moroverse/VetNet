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
        let patientListTitle = navigationBars["Patients"]
        XCTAssertTrue(patientListTitle.waitForExistence(timeout: 2), "Patient list should be displayed")
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
        XCTAssertTrue(addButton.waitForExistence(timeout: 2), "Add button should exist")
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
        XCTAssertTrue(nameField.waitForExistence(timeout: 2), "Patient name field should exist")
        nameField.tap()
        nameField.typeText(name)
        return self
    }

    @MainActor
    func selectSpecies(_ species: String) -> PatientCreationScreen {
        // Find and tap the species picker using accessibility identifier
        let speciesPicker = app.buttons["patient_creation_species_picker"]
        XCTAssertTrue(speciesPicker.waitForExistence(timeout: 2), "Species picker should exist")
        speciesPicker.tap()

        // Select the species from the picker - use buttons like Belfalas does
        let speciesOption = app.buttons[species].firstMatch
        XCTAssertTrue(speciesOption.waitForExistence(timeout: 2), "Species option '\(species)' should exist")
        speciesOption.tap()

        return self
    }

    @MainActor
    func selectBreed(_ breed: String) -> PatientCreationScreen {
        // Find and tap the breed picker using accessibility identifier
        let breedPicker = app.buttons["patient_creation_breed_picker"]
        XCTAssertTrue(breedPicker.waitForExistence(timeout: 2), "Breed picker should exist")
        breedPicker.tap()

        // Select the breed from the picker
        let breedOption = app.buttons[breed].firstMatch
        XCTAssertTrue(breedOption.waitForExistence(timeout: 2), "Breed option '\(breed)' should exist")
        breedOption.tap()

        return self
    }

    @MainActor
    func enterWeight(_ weight: String) -> PatientCreationScreen {
        // Find the weight field using accessibility identifier from PatientFormView.swift
        let weightField = app.textFields["patient_creation_weight_field"]
        XCTAssertTrue(weightField.waitForExistence(timeout: 2), "Weight field should exist")
        weightField.tap()

//        // Clear existing text (the default "0")
//        if let currentValue = weightField.value as? String, !currentValue.isEmpty {
//            // Select all and delete
//            weightField.tap()
//            weightField.press(forDuration: 1.0) // Long press to bring up menu
//
//            // Try to select all from menu
//            let selectAll = app.menuItems["Select All"]
//            if selectAll.waitForExistence(timeout: 1.0) {
//                selectAll.tap()
//            } else {
//                // Fallback: triple-tap to select all
//                weightField.tap(withNumberOfTaps: 3, numberOfTouches: 1)
//            }
//
//            // Type delete key
//            weightField.typeText(XCUIKeyboardKey.delete.rawValue)
//        }

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
        XCTAssertTrue(ownerNameField.waitForExistence(timeout: 2), "Owner name field should exist")
        ownerNameField.tap()
        ownerNameField.typeText(name)
        return self
    }

    @MainActor
    func enterOwnerPhone(_ phone: String) -> PatientCreationScreen {
        // Find the owner phone field using accessibility identifier from PatientFormView.swift
        let ownerPhoneField = app.textFields["patient_creation_owner_phone_field"]
        XCTAssertTrue(ownerPhoneField.waitForExistence(timeout: 2), "Owner phone field should exist")
        ownerPhoneField.tap()
        ownerPhoneField.typeText(phone)
        return self
    }

    @MainActor
    @discardableResult
    func tapSave() -> PatientCreationScreen {
        // Find and tap the save button using accessibility identifier from PatientFormView.swift
        let saveButton = app.buttons["patient_creation_save_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button should exist")
        saveButton.tap()
        return self
    }

    @MainActor
    @discardableResult
    func assertPatientCreatedSuccessfully(id: String) -> PatientCreationScreen {
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
        let patientListTitle = app.navigationBars["Patients"]
        XCTAssertTrue(patientListTitle.exists, "Should be back on patient list after successful save")

        // Verify the newly created patient appears in the list
        let patientRowIdentifier = "patient_row_\(id)"
        let patientRows = app.descendants(matching: .other).containing(.staticText, identifier: patientRowIdentifier)
        XCTAssertTrue(
            patientRows.firstMatch.waitForExistence(timeout: 3.0),
            "Newly created patient with id'\(id)' should appear in the patient list"
        )

        return self
    }

    // MARK: - Date Picker Interaction Methods

    @MainActor
    func selectFutureBirthDate() -> PatientCreationScreen {
        // With fixed date "2023-08-09T08:00:00Z", we can select a specific future date
        // Let's select September 15, 2023 (clearly in the future)

        // Tap on the date picker to open it
        let datePicker = app.buttons["Date Picker"].firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 2), "Date picker should exist")
        datePicker.tap()

        // Find and tap the month/year button (should show "August 2023" initially)
        let monthYearButton = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '2023'")).firstMatch
        XCTAssertTrue(monthYearButton.waitForExistence(timeout: 2), "Month/Year button should exist")
        monthYearButton.tap()

        // Adjust picker wheels to select September 2023
        // swiftformat:disable:next isEmpty
        if app.pickerWheels.count > 0 {
            // First picker wheel is the month - select September
            app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "September")
        }

        // Year should already be 2023, but ensure it's set
        // swiftformat:disable:next isEmpty
        if app.pickerWheels.count > 1 {
            // Second picker wheel is the year
            app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2023")
        }

        // Confirm month/year selection
        let septemberText = app.staticTexts["September 2023"].firstMatch
        if septemberText.waitForExistence(timeout: 2) {
            septemberText.tap()
        }

        // Select day 15
        let day15Button = app.staticTexts["15"].firstMatch
        if day15Button.waitForExistence(timeout: 2) {
            day15Button.tap()
        }

        // Dismiss the picker
        let dismissButton = app.buttons["PopoverDismissRegion"].firstMatch
        if dismissButton.waitForExistence(timeout: 2) {
            dismissButton.tap()
        } else {
            // Alternative: tap outside the picker
            app.tap()
        }

        return self
    }

    // MARK: - Validation Assertion Methods

    @MainActor
    @discardableResult
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
        // Check that validation error indicators are not present for the specified field
        let errorIcon = app.images["exclamationmark.circle"]
        let fieldSpecificError = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", field))

        // Ensure no error icon is displayed near the field
        XCTAssertFalse(errorIcon.exists, "No validation error icon should be displayed for \(field)")

        // Ensure no field-specific error text is shown
        let hasFieldError = fieldSpecificError.allElementsBoundByIndex.contains { element in
            element.label.lowercased().contains("error") ||
                element.label.lowercased().contains("invalid") ||
                element.label.lowercased().contains("required")
        }
        XCTAssertFalse(hasFieldError, "No validation error text should be displayed for \(field)")

        return self
    }

    @MainActor
    @discardableResult
    func assertBreedPickerContains(_ expectedBreeds: [String]) -> PatientCreationScreen {
        // First, tap on the breed picker to open it
        let breedPicker = app.buttons["patient_creation_breed_picker"]
        XCTAssertTrue(breedPicker.waitForExistence(timeout: 2), "Breed picker should exist")
        breedPicker.tap()

        // Verify each expected breed is present in the picker
        for breed in expectedBreeds {
            let breedOption = app.buttons[breed]
            XCTAssertTrue(breedOption.exists, "Breed '\(breed)' should be available in the picker")
        }

        // Dismiss the picker by tapping outside or the dismiss region
        let dismissButton = app.buttons["PopoverDismissRegion"].firstMatch
        if dismissButton.waitForExistence(timeout: 2) {
            dismissButton.tap()
        } else {
            // Alternative: tap on a safe area outside the picker
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }

        return self
    }

    // MARK: - Alert Testing Methods

    @MainActor
    @discardableResult
    func assertValidationAlert() -> PatientCreationScreen {
        // Wait for alert to appear
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 3.0), "Validation error alert should appear")

        // Verify alert title
        let errorTitle = alert.staticTexts["Error"]
        XCTAssertTrue(errorTitle.exists, "Alert should have 'Error' title")

        // Verify OK button exists (non-retryable error)
        let okButton = alert.buttons["OK"]
        XCTAssertTrue(okButton.exists, "Alert should have OK button for validation errors")

        // Verify Retry button does NOT exist for validation errors
        let retryButton = alert.buttons["Retry"]
        XCTAssertFalse(retryButton.exists, "Alert should not have Retry button for validation errors")

        return self
    }

    @MainActor
    @discardableResult
    func dismissAlert() -> PatientCreationScreen {
        let alert = app.alerts.firstMatch
        if alert.exists {
            let okButton = alert.buttons["OK"]
            let cancelButton = alert.buttons["Cancel"]

            if okButton.exists {
                okButton.tap()
            } else if cancelButton.exists {
                cancelButton.tap()
            }
        }

        // Wait for alert to disappear
        XCTAssertTrue(alert.waitForNonExistence(timeout: 2.0), "Alert should dismiss")

        return self
    }

    // MARK: - Helper Methods
}
