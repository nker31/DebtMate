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
    var isNotificationEnabled: Bool { get }
    func getCurrentUserData() -> (name: String, imageURL: String?)
    func toggleNotificationSetting(isEnabled: Bool, completion: @escaping (Bool) -> Void)
    func signOut()
}

protocol SettingViewModelDelegate: AnyObject {
    func showAlert(title: String, message: String)
    func didSettingNotifactionPermissionDenied()
    func didSignOut()
}

class SettingViewModel: SettingViewModelProtocol {
    private var authManager: AuthenticationManagerProtocol
    private var userDataStoringManager: UserDataStoringManagerProtocol
    private var notificationManager: NotificationManagerProtocol
    
    weak var delegate: SettingViewModelDelegate?
    var settingSection: [SettingSection] = [
        SettingSection(title: String(localized: "setting_account_section"), rows: [String(localized: "setting_account_section")]),
        SettingSection(title: String(localized: "setting_app_preference_section"), rows: [String(localized: "setting_notification_label"), String(localized: "setting_language_label")]),
        SettingSection(title: String(localized: "setting_about_section"), rows: [String(localized: "setting_privacy_label"), String(localized: "setting_contact_us_label")]),
        SettingSection(title: "", rows: [String(localized: "setting_signout_button")])
    ]
    var isNotificationEnabled: Bool {
        notificationManager.isNotificationEnabled
    }
    
    init(authManager: AuthenticationManagerProtocol = AuthenticationManager.shared, userDataStoringManager: UserDataStoringManagerProtocol = UserDataStoringManager.shared, notificationManager: NotificationManagerProtocol = NotificationManager.shared, isNotificationEnabled: Bool = false) {
        self.authManager = authManager
        self.userDataStoringManager = userDataStoringManager
        self.notificationManager = notificationManager
    }
    
    func getCurrentUserData() -> (name: String, imageURL: String?) {
        if let currentUser = userDataStoringManager.currentUser {
            return (name: currentUser.fullName, imageURL: currentUser.imageURL)
        }
        
        return (name: "Guest", imageURL: nil)
    }
    
    func toggleNotificationSetting(isEnabled: Bool, completion: @escaping (Bool) -> Void) {
        if isEnabled {
            notificationManager.enableNotification { [weak self] isGranted in
                DispatchQueue.main.async {
                    guard !isGranted else {
                        completion(true)
                        return
                    }
                    
                    self?.delegate?.didSettingNotifactionPermissionDenied()
                    completion(false)
                }
            }
        } else {
            notificationManager.disableNotification()
            completion(false)
        }
    }
    
    func signOut() {
        do {
            try authManager.signOut()
            delegate?.didSignOut()
        } catch {
            delegate?.showAlert(title: String(localized: "setting_sign_out_failed_title"),
                                message: String(localized: "setting_sign_out_failed_message"))
        }
    }
}
