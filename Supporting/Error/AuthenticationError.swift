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
            return "Your email or password seems incorrect. Please try again."
        case .invalidEmail:
            return "The email address is invalid."
        case .emailAlreadyInUse:
            return "The email address is already in use."
        case .userNotFound:
            return "No user found with the provided credentials."
        case .wrongPassword:
            return "The password is incorrect. Please try again."
        case .networkError:
            return "There was a network error. Please check your connection and try again."
        case .unknownError(let message):
            return message
        }
    }
}
