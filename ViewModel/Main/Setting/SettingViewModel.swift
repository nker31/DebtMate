//
//  SettingViewModel.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/6/24.
//

import Foundation

protocol SettingViewModelProtocol {
    var delegate: SettingViewModelDelegate? { get set }
    var settingSection: [SettingSection] { get }
    func getCurrentUserData() -> (name: String, imageURL: String?)
    func signOut()
}

protocol SettingViewModelDelegate: AnyObject {
    func showAlert(title: String, message: String)
    func didSignOut()
}

class SettingViewModel: SettingViewModelProtocol {
    var authManager: AuthenticationManagerProtocol
    var userDataStoringManager: UserDataStoringManagerProtocol
    
    weak var delegate: SettingViewModelDelegate?
    var settingSection: [SettingSection] = [
        SettingSection(title: String(localized: "setting_account_section"), rows: [String(localized: "setting_account_section")]),
        SettingSection(title: String(localized: "setting_app_preference_section"), rows: [String(localized: "setting_notification_label"), String(localized: "setting_language_label")]),
        SettingSection(title: String(localized: "setting_about_section"), rows: [String(localized: "setting_privacy_label"), String(localized: "setting_contact_us_label")]),
        SettingSection(title: "", rows: [String(localized: "setting_signout_button")])
    ]
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared, userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared) {
        self.authManager = authManager
        self.userDataStoringManager = userDataStoringManager
    }
    
    func signOut() {
        do {
            try authManager.signOut()
            delegate?.didSignOut()
        } catch {
            delegate?.showAlert(title: "Error", message: "Sign out failed")
        }
    }
    
    func getCurrentUserData() -> (name: String, imageURL: String?) {
        if let currentUser = userDataStoringManager.currentUser {
            return (name: currentUser.fullName, imageURL: currentUser.imageURL)
        }
        
        return (name: "Guest", imageURL: nil)
    }
}
