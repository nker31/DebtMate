//
//  InputValidator.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation

class InputValidator {
    static func validateEmail(_ email: String) -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validatePassword(_ password: String) -> Bool {
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return password.count >= 8 && password.count <= 12
    }
    
    static func validateFullName(_ fullName: String) -> Bool {
        let fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return fullName.count >= 3 && fullName.count <= 25
    }
    
    static func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        return phoneNumber.count >= 7 && phoneNumber.count <= 12
    }
    
    static func passwordMatch(_ password: String, confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
}
