// PatientDetailsViewModel.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-08-13 15:33 GMT.

import FactoryKit
import Foundation
import SwiftUI

@Observable
final class PatientDetailsViewModel {
    let patient: Patient

    @ObservationIgnored
    @Injected(\.dateProvider) private var dateProvider

    init(patient: Patient) {
        self.patient = patient
    }

    var ageDisplay: String {
        calculateAgeDescription(from: patient.birthDate, to: dateProvider.now())
    }

    // MARK: - Private Methods

    private func calculateAgeDescription(from birthDate: Date, to currentDate: Date) -> String {
        let calendar = dateProvider.calendar
        let components = calendar.dateComponents([.year, .month, .day], from: birthDate, to: currentDate)

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        // Handle different age ranges
        if years > 0 {
            if months == 0 {
                return "\(years) \(years == 1 ? "year" : "years")"
            } else if years == 1, months < 6 {
                return "1 year, \(months) \(months == 1 ? "month" : "months")"
            } else {
                return "\(years) \(years == 1 ? "year" : "years"), \(months) \(months == 1 ? "month" : "months")"
            }
        } else if months > 0 {
            return "\(months) \(months == 1 ? "month" : "months")"
        } else if days > 0 {
            return "\(days) \(days == 1 ? "day" : "days")"
        } else {
            return "Less than a day old"
        }
    }

    var weightDisplay: String {
        patient.weight.formatted(.measurement(width: .abbreviated))
    }

    var speciesDisplay: String {
        patient.species.description
    }

    var breedDisplay: String {
        patient.breed.description
    }
}
