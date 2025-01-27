//
//  EditAccountViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/8/24.
//

import Foundation
import UIKit

protocol EditAccountViewModelProtocol {
    var delegate: EditAccountViewModelDelegate? { get set }
    var originalImage: UIImage? { get set }
    func updateUserDetail(newName: String, newImage: UIImage?)
    func validateAccountDetail(newName: String?, newImage: UIImage?)
    func fetchCurrentUser()
}

protocol EditAccountViewModelDelegate: AnyObject {
    func didFetchCurrentUser(user: User)
    func didValidateAccountDetail(isValid: Bool)
    func didUpdateSuccessfully()
    func showAlert(title: String, message: String)
}

class EditAccountViewModel: EditAccountViewModelProtocol {
    weak var delegate: EditAccountViewModelDelegate?
    var originalImage: UIImage?
    private var userDataStoringManager: UserDataStoringManagerProtocol
    private var user: User?
    
    init(userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.userDataStoringManager = userDataStoringManager
    }
    
    func fetchCurrentUser() {
        self.user = userDataStoringManager.currentUser
        
        guard let user else {
            let fetchError = DataStoringError.fetchDataFailed
            delegate?.showAlert(title: String(localized: "edit_account_alert_error_title"), message: fetchError.localizedDescription)
            return
        }
        
        delegate?.didFetchCurrentUser(user: user)
    }
    
    func updateUserDetail(newName: String, newImage: UIImage?) {
        guard var updatedUser = self.user else {
            return
        }
        
        updatedUser.fullName = newName
        
        Task {
            do {
                if let newImage, let originalImage, originalImage != newImage {
                    try await userDataStoringManager.updateUserData(updatedImage: newImage, updatedUser: updatedUser)
                } else {
                    try await userDataStoringManager.updateUserData(updatedUser: updatedUser)
                }
                
                await MainActor.run { [weak self] in
                    self?.delegate?.didUpdateSuccessfully()
                }
            } catch {
                delegate?.showAlert(title: String(localized: "edit_account_alert_error_title"), message: error.localizedDescription)
            }
        }
    }
    
    func validateAccountDetail(newName: String?, newImage: UIImage?) {
        guard let name = newName, !name.isEmpty else {
            delegate?.didValidateAccountDetail(isValid: false)
            return
        }
        
        guard let user else {
            return
        }
        
        let isNameChanged = newName != user.fullName
        let isImageChanged = newImage != self.originalImage && newImage != nil && self.originalImage != nil
        let isValid = isNameChanged || isImageChanged
        
        delegate?.didValidateAccountDetail(isValid: isValid)
    }
}
