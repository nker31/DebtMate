//
//  NotificationManager.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/10/24.
//

import Foundation
import UserNotifications
import UIKit

protocol NotificationManagerProtocol {
    var isNotificationEnabled: Bool { get }
    func enableNotification(completion: @escaping (Bool) -> Void)
    func disableNotification()
}

final class NotificationManager: NotificationManagerProtocol {
    static let shared = NotificationManager()
    
    private let notificationCenter: UNUserNotificationCenter
    private let application: UIApplication
    private let userDefaults: UserDefaults
    
    private let isEnabledKey = "isNotificationEnabled"
    
    var isNotificationEnabled: Bool {
        get {
            userDefaults.bool(forKey: isEnabledKey)
        }
        set {
            userDefaults.set(newValue, forKey: isEnabledKey)
            logMessage("isNotificationEnabled set to \(newValue)")
        }
    }
    
    private init(notificationCenter: UNUserNotificationCenter = .current(),
                 application: UIApplication = .shared,
                 userDefaults: UserDefaults = .standard) {
        self.notificationCenter = notificationCenter
        self.application = application
        self.userDefaults = userDefaults
    }
    
    func enableNotification(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.requestNotificationAuthorization { granted in
                    completion(granted)
                }
            case .denied:
                completion(false)
            case .authorized, .provisional, .ephemeral:
                self?.logMessage("enable notification setting")
                self?.isNotificationEnabled = true
                completion(true)
            @unknown default:
                break
            }
        }
    }
    
    func disableNotification() {
        logMessage("disable notification setting")
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        application.applicationIconBadgeNumber = 0
        isNotificationEnabled = false
    }
    
    // MARK: - Private Methods
    private func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            guard let self = self else { return }
            if let error = error {
                self.logMessage("Authorization failed with error \(error.localizedDescription)")
                completion(false)
                return
            }
            self.isNotificationEnabled = granted
            self.logMessage("Notification permission is \(granted ? "granted" : "denied") by user")
            completion(granted)
        }
    }
    
    private func logMessage(_ message: String) {
        print("Notification Manager: \(message)")
    }
}
