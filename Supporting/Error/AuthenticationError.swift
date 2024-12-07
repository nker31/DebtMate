//
//  AuthenticationError.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation

enum AuthenticationError: LocalizedError {
    case invalidCredential
    case invalidEmail
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case networkError
    case unknownError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return String(localized: "authentication_error_invalid_credential")
        case .invalidEmail:
            return String(localized: "authentication_error_invalid_email")
        case .emailAlreadyInUse:
            return String(localized: "authentication_error_email_already_in_use")
        case .userNotFound:
            return String(localized: "authentication_error_user_not_found")
        case .wrongPassword:
            return String(localized: "authentication_error_wrong_password")
        case .networkError:
            return String(localized: "authentication_error_network_error")
        case .unknownError(let message):
            return message
        }
    }
}
