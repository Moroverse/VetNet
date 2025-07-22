import Foundation
import QuickForm

final class PatientValidator: Sendable {
    private let dateProvider: DateProvider

    init(dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }

    func isValidName(_ name: String) -> Bool {
        nameValidation.validate(name) == .success
    }

    func isValidBirthDate(_ birthDate: Date) -> Bool {
        birthdateValidation.validate(birthDate) == .success
    }

    func isValidWeight(_ weight: Measurement<UnitMass>, for species: AnimalSpecies) -> Bool {
        weightValidation(for: species).validate(weight) == .success
    }
    
    func isValidMicrochip(_ microchip: String) -> Bool {
        microchipValidation.validate(microchip) == .success
    }
    
    func isValidNotes(_ notes: String) -> Bool {
        notesValidation.validate(notes) == .success
    }
}

// Custom validation rules
struct MaxDateRule: ValidationRule {
    let dateProvider: DateProvider
    
    init(_ dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
    }

    func validate(_ value: Date) -> ValidationResult {
        if value > dateProvider.now() {
            .failure("Date cannot be in the future")
        } else {
            .success
        }
    }
}

struct MaxDateRangeRule: ValidationRule {
    let dateProvider: DateProvider
    let range: DateComponents

    init(maxRange: DateComponents, _ dateProvider: DateProvider = SystemDateProvider()) {
        self.dateProvider = dateProvider
        self.range = maxRange
    }

    func validate(_ value: Date) -> ValidationResult {
        guard let minDate = dateProvider.calendar.date(byAdding: range, to: dateProvider.now()) else {
            return .failure("Invalid date range")
        }
        let result = dateProvider.calendar.compare(value, to: minDate, toGranularity: .second)
        switch result {
        case .orderedDescending, .orderedSame:
            return .success
        case .orderedAscending:
            return .failure("Date must be after \(minDate.formatted())")
        }
    }
}

struct SpeciesWeightRangeRule: ValidationRule {
    let species: AnimalSpecies

    init(_ species: AnimalSpecies) {
        self.species = species
    }

    func validate(_ value: Measurement<UnitMass>) -> ValidationResult {
        let weightInKg = value.converted(to: .kilograms).value

        switch species {
        case .dog:
            if weightInKg >= 0.5, weightInKg <= 100 {
                return .success
            } else {
                return .failure("Dogs must weigh between 0.5kg and 100kg")
            }

        case .cat:
            if weightInKg >= 0.5, weightInKg <= 15 {
                return .success
            } else {
                return .failure("Cats must weigh between 0.5kg and 15kg")
            }

        case .bird:
            if weightInKg >= 0.01, weightInKg <= 20 {
                return .success
            } else {
                return .failure("Birds must weigh between 0.01kg and 20kg")
            }
        case .rabbit:
            if weightInKg >= 0.3, weightInKg <= 8.0 {
                return .success
            } else {
                return .failure("Rabbits must weigh between 0.3kg and 8kg")
            }
        case .reptile:
            if weightInKg >= 0.01, weightInKg <= 50.0 {
                return .success
            } else {
                return .failure("Reptiles must weigh between 0.01kg and 50kg")
            }
        case .exotic:
            if weightInKg >= 0.01, weightInKg <= 5.0 {
                return .success
            } else {
                return .failure("Exotic pets must weigh between 0.01kg and 5kg")
            }
        }
    }
}

struct MicrochipFormatRule: ValidationRule {
    func validate(_ value: String) -> ValidationResult {
        let cleaned = value.replacingOccurrences(of: " ", with: "")
        
        if cleaned.isEmpty {
            return .success // Optional field
        }
        
        if cleaned.allSatisfy(\.isNumber) && cleaned.count == 15 {
            return .success
        } else {
            return .failure("Microchip number must be exactly 15 digits")
        }
    }
}

struct AllowedCharactersRule: ValidationRule {
    let allowedCharacters: CharacterSet
    
    init(_ allowedCharacters: CharacterSet) {
        self.allowedCharacters = allowedCharacters
    }

    func validate(_ value: String) -> ValidationResult {
        let filteredText = value.filter { char in
            let unicodeScalars = String(char).unicodeScalars
            return !unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
        }

        if filteredText.isEmpty {
            return .success
        } else {
            return .failure("Contains invalid characters: \(filteredText)")
        }
    }
}

// Validation rule combinations
extension PatientValidator {
    var nameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(50),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-'")))
        )
    }

    var birthdateValidation: AnyValidationRule<Date> {
        .combined(
            MaxDateRule(dateProvider),
            MaxDateRangeRule(maxRange: .init(year: -50), dateProvider) // Pets can live up to 50 years
        )
    }

    func weightValidation(for species: AnimalSpecies) -> AnyValidationRule<Measurement<UnitMass>> {
        .of(SpeciesWeightRangeRule(species))
    }
    
    var microchipValidation: AnyValidationRule<String> {
        .of(MicrochipFormatRule())
    }
    
    var notesValidation: AnyValidationRule<String> {
        .of(.maxLength(500))
    }
}

// Date range helpers
extension PatientValidator {
    var birthDateRange: ClosedRange<Date> {
        let now = dateProvider.now()
        let fiftyYearsAgo = dateProvider.calendar.date(byAdding: .year, value: -50, to: now) ?? now
        return fiftyYearsAgo...now
    }
}

protocol DateProvider: Sendable {
    func now() -> Date
    var calendar: Calendar { get }
}

struct SystemDateProvider: DateProvider {
    func now() -> Date {
        Date()
    }

    let calendar: Calendar

    init(calendar: Calendar = Calendar.current) {
        self.calendar = calendar
    }
}
