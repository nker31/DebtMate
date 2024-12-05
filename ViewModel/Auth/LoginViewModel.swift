//
//  LoginViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/4/24.
//

import Foundation

protocol LoginViewModelProtocol {
    var delegate: LoginViewModelDelegate? { get set }
    func login(email: String, password: String)
}

protocol LoginViewModelDelegate: AnyObject {
    func showAlert(with title: String, message: String)
    func navigateToHome()
}

class LoginViewModel: LoginViewModelProtocol {
    weak var delegate: LoginViewModelDelegate?
    var authManager: AuthenticationManagerProtocol
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared) {
        self.authManager = authManager
    }
    
    func login(email: String, password: String) {
        guard InputValidator.validateEmail(email) else {
            delegate?.showAlert(with: "Login Failure", message: "Invalid email! \n please try again")
            return
        }
        
        guard InputValidator.validatePassword(password) else {
            delegate?.showAlert(with: "Login Failure", message: "Password must have 8-12 characters.")
            return
        }
        
        Task {
            do {
                try await authManager.login(email: email, password: password)
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.navigateToHome()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.showAlert(with: "Login Failure", message: "Password or email is incorrect!")
                }
            }
        }
    }
}
