//
//  SignUpViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import Foundation
import UIKit

protocol SignUpViewModelProtocol {
    var isAcceptedTerms: Bool { get }
    var delegate: SignUpViewModelDelegate? { get set }
    func signUp(fullName: String, email: String, password: String, confirmPassword: String)
    func setSelectedImage(image: UIImage)
    func acceptTermsAndConditions(isAccepted: Bool)
}

protocol SignUpViewModelDelegate: AnyObject {
    func showAlert(title: String, message: String)
    func didAcceptTermsAndConditions(isAccepted: Bool)
    func didStartSignUp()
    func didFinishSignUp()
    func didFailSignUp()
}

class SignUpViewModel: SignUpViewModelProtocol {
    private(set) var selectedImage: UIImage?
    
    var isAcceptedTerms: Bool
    weak var delegate: SignUpViewModelDelegate?
    private var authManager: AuthenticationManagerProtocol
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared, isAcceptedTerms: Bool = false) {
        self.authManager = authManager
        self.isAcceptedTerms = isAcceptedTerms
    }
    
    func signUp(fullName: String, email: String, password: String, confirmPassword: String) {
        guard InputValidator.validateFullName(fullName) else {
            delegate?.showAlert(title: String(localized: "signup_invalid_full_name_alert_title"), message: String(localized: "signup_invalid_full_name_alert_message"))
            return
        }
        guard InputValidator.validateEmail(email) else {
            delegate?.showAlert(title: String(localized: "signup_invalid_email_alert_title"), message: String(localized: "signup_invalid_email_alert_message"))
            return
        }

        guard InputValidator.validatePassword(password) else {
            delegate?.showAlert(title: String(localized: "signup_invalid_password_alert_title"), message: String(localized: "signup_invalid_password_alert_message"))
            return
        }

        guard confirmPassword == password else {
            delegate?.showAlert(title: String(localized: "signup_password_mismatch_alert_title"), message: String(localized: "signup_password_mismatch_alert_message"))
            return
        }
        
        delegate?.didStartSignUp()
        
        Task {
            do {
                try await authManager.signUp(profileImage: selectedImage, fullName: fullName, email: email, password: password)
                await MainActor.run { [weak self] in
                    delegate?.didFinishSignUp()
                }
            } catch let error as AuthenticationError {
                await MainActor.run { [weak self] in
                    delegate?.didFailSignUp()
                    delegate?.showAlert(title: String(localized: "signup_failed_alert_title"), message: error.errorDescription ?? String(localized: "signup_failed_alert_message"))
                }
            } catch {
                await MainActor.run { [weak self] in
                    delegate?.didFailSignUp()
                    delegate?.showAlert(title: String(localized: "signup_failed_alert_title"), message: String(localized: "signup_failed_alert_message"))
                }
            }
        }
    }
    
    func setSelectedImage(image: UIImage) {
        self.selectedImage = image
    }
    
    func acceptTermsAndConditions(isAccepted: Bool) {
        self.isAcceptedTerms = isAccepted
        delegate?.didAcceptTermsAndConditions(isAccepted: isAccepted)
    }
}
