//
//  AccountDetailViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/8/24.
//

import Foundation

protocol AccountDetailViewModelProtocol {
    var delegate: AccountDetailViewModelDelegate? { get set }
    var accountMenu: [String] { get }
    func fetchCurrentUser()
}

protocol AccountDetailViewModelDelegate: AnyObject {
    func didFetchCurrentUser(_ currentUser: User)
    func didFetchCurrentUserFailed(error: Error)
}

class AccountDetailViewModel: AccountDetailViewModelProtocol {
    private let userDataStoringManager: UserDataStoringManagerProtocol
    
    weak var delegate: AccountDetailViewModelDelegate?
    var accountMenu: [String] = [
        String(localized: "account_edit_details_label"),
        String(localized: "account_change_password_label")
    ]
    
    init(userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.userDataStoringManager = userDataStoringManager
    }
    
    func fetchCurrentUser() {
        guard let currentUser = userDataStoringManager.currentUser else {
            let fetchError = DataStoringError.fetchDataFailed
            delegate?.didFetchCurrentUserFailed(error: fetchError)
            return
        }
        
        delegate?.didFetchCurrentUser(currentUser)
    }
}
