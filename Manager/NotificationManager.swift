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
    func setNotification(title: String, body: String, date: Date)
    func setTransactionReminder(isLend: Bool, personName: String, amount: Float, dueDate: Date)
}

final class NotificationManager: NotificationManagerProtocol {
    static let shared = NotificationManager()
    
    private let notificationCenter: UNUserNotificationCenter
    private let application: UIApplication
    private let userDefaults: UserDefaults
    
    private let isEnabledKey = "isNotificationEnabled"
    private var numberOfNotifications: Int = 0
    
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
        numberOfNotifications = 0
    }
    
    func setNotification(title: String, body: String, date: Date) {
        guard isNotificationEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: numberOfNotifications + 1)
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "reminderDebt", content: content, trigger: trigger)
        
        notificationCenter.add(request) { [weak self] error in
            if let error {
                self?.logMessage("Error adding notification: \(error.localizedDescription)")
            } else {
                self?.numberOfNotifications += 1
                self?.logMessage("Notification added successfully")
            }
        }
    }
    
    func setTransactionReminder(isLend: Bool, personName: String, amount: Float, dueDate: Date) {
        let title = isLend ? "Lending Reminder" : "Borrow Reminder"
        let body = isLend
            ? "\(personName) owes you $\(amount)"
            : "You owe \(personName) $\(amount)"
        
        setNotification(title: title, body: body, date: dueDate)
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
