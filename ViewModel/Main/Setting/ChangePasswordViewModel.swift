//
//  ChangePasswordViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/9/24.
//

import Foundation

protocol ChangePasswordViewModelProtocol {
    var delegate: ChangePasswordViewModelDelegate? { get set }
    func validatePassword(oldPassword: String?, newPassword: String?, confirmPassword: String?)
    func changePassword(oldPassword: String?, newPassword: String?)
}

protocol ChangePasswordViewModelDelegate: AnyObject {
    func didStateChange(to state: ViewState)
    func didValidatePassword(isValid: Bool)
}

class ChangePasswordViewModel: ChangePasswordViewModelProtocol {
    private var authManager: AuthenticationManagerProtocol
    weak var delegate: ChangePasswordViewModelDelegate?
    var viewState: ViewState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didStateChange(to: self.viewState)
            }
        }
    }
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared) {
        self.authManager = authManager
    }
    
    func validatePassword(oldPassword: String?, newPassword: String?, confirmPassword: String?) {
        guard let oldPassword, let newPassword, let confirmPassword else { return }
        
        let isValid = InputValidator.validatePassword(oldPassword) &&
                          InputValidator.validatePassword(newPassword) &&
                          InputValidator.passwordMatch(newPassword, confirmPassword: confirmPassword)
        
        delegate?.didValidatePassword(isValid: isValid)
    }
    
    func changePassword(oldPassword: String?, newPassword: String?) {
        guard let oldPassword, let newPassword else {
            return
        }
        
        guard oldPassword != newPassword else {
            viewState = .failure(AuthenticationError.samePassword)
            return
        }
        
        viewState = .loading
        
        Task {
            do {
                try await authManager.changePassword(oldPassword: oldPassword,
                                                     newPassword: newPassword)
                viewState = .success
            } catch {
                viewState = .failure(error)
            }
        }
    }
}
