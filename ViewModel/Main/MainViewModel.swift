//
//  MainViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/5/24.
//

import Foundation

protocol MainViewModelProtocol {
    var delegate: MainViewModelDelegate? { get set }
    func fetchUserData()
}

protocol MainViewModelDelegate: AnyObject {
    func showAlert(title: String, message: String)
    func didStartFetchingUserData()
    func didFinishFetchingUserData()
    func didFaiedFetchingUserData()
}

class MainViewModel: MainViewModelProtocol {
    weak var delegate: MainViewModelDelegate?
    
    var authManager: AuthenticationManagerProtocol
    var userDataStoringManager: UserDataStoringManagerProtocol
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared, userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.authManager = authManager
        self.userDataStoringManager = userDataStoringManager
    }
    
    func fetchUserData() {
        delegate?.didStartFetchingUserData()
        Task {
            do {
                guard let userSessionID = authManager.userSession?.uid else {
                    await MainActor.run {
                        delegate?.didFaiedFetchingUserData()
                        delegate?.showAlert(title: "Error", message: "No current user session, please login")
                    }
                    return
                }
                
                try await userDataStoringManager.fetchUserData(userID: userSessionID)
                
                print("MainViewModel: Fetch user data successful")
                
                await MainActor.run {
                    delegate?.didFinishFetchingUserData()
                }
            } catch {
                print("MainViewModel: Error fetching data - \(error)")
                await MainActor.run {
                    delegate?.didFaiedFetchingUserData()
                    delegate?.showAlert(title: "Error", message: "Failed to fetch user data, please try again later")
                }
            }
        }
    }
}
