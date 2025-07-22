import Foundation
import QuickForm

final class OwnerValidator: Sendable {
    
    func isValidFirstName(_ firstName: String) -> Bool {
        firstNameValidation.validate(firstName) == .success
    }
    
    func isValidLastName(_ lastName: String) -> Bool {
        lastNameValidation.validate(lastName) == .success
    }
    
    func isValidEmail(_ email: String) -> Bool {
        emailValidation.validate(email) == .success
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        phoneNumberValidation.validate(phoneNumber) == .success
    }
}

// Custom validation rules for Owner
struct PhoneNumberFormatRule: ValidationRule {
    func validate(_ value: String) -> ValidationResult {
        let cleaned = value.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        
        // Allow international format with +
        let phoneRegex = #"^[\+]?[1-9][\d]{7,15}$"#
        
        if cleaned.range(of: phoneRegex, options: .regularExpression) != nil {
            return .success
        } else {
            return .failure("Invalid phone number format")
        }
    }
}

// Validation rule combinations
extension OwnerValidator {
    var firstNameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(50),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-'")))
        )
    }
    
    var lastNameValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .minLength(2),
            .maxLength(50),
            AllowedCharactersRule(.letters.union(.whitespaces).union(.init(charactersIn: "-'")))
        )
    }
    
    var emailValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            .maxLength(255),
            .email
        )
    }
    
    var phoneNumberValidation: AnyValidationRule<String> {
        .combined(
            .notEmpty,
            PhoneNumberFormatRule()
        )
    }
}