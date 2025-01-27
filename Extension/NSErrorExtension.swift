//
//  NSErrorExtension.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/7/24.
//

import Foundation
import FirebaseAuth

extension NSError {
    func toAuthenticationError() -> AuthenticationError {
        print("NSError: code \(self.code) ")
        guard let errorCode = AuthErrorCode(rawValue: self.code) else {
            return .unknownError(message: self.localizedDescription)
        }

        switch errorCode {
        case .invalidCredential:
            return .invalidCredential
        case .invalidEmail:
            return .invalidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .wrongPassword
        case .networkError:
            return .networkError
        default:
            return .unknownError(message: self.localizedDescription)
        }
    }
}

