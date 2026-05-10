//
//  NotificationManager.swift
//  Gestfina
//
//  Gestion des notifications locales — alertes budget + rappels
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    // MARK: - Préférences
    
    @Published var isNotificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(isNotificationsEnabled, forKey: Keys.notifEnabled) }
    }
    @Published var budgetAlertEnabled: Bool {
        didSet { UserDefaults.standard.set(budgetAlertEnabled, forKey: Keys.budgetAlert) }
    }
    @Published var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: Keys.dailyReminder)
            if dailyReminderEnabled {
                scheduleDailyReminder()
            } else {
                cancelDailyReminder()
            }
        }
    }
    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: Keys.reminderHour)
            if dailyReminderEnabled { scheduleDailyReminder() }
        }
    }
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Clés
    
    private enum Keys {
        static let notifEnabled = "gestfina_notif_enabled"
        static let budgetAlert  = "gestfina_budget_alert"
        static let dailyReminder = "gestfina_daily_reminder"
        static let reminderHour  = "gestfina_reminder_hour"
    }
    
    // MARK: - Init
    
    init() {
        self.isNotificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notifEnabled)
        self.budgetAlertEnabled     = UserDefaults.standard.object(forKey: Keys.budgetAlert) as? Bool ?? true
        self.dailyReminderEnabled   = UserDefaults.standard.bool(forKey: Keys.dailyReminder)
        self.reminderHour           = UserDefaults.standard.object(forKey: Keys.reminderHour) as? Int ?? 20
        checkAuthorizationStatus()
    }
    
    // MARK: - Autorisation
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                self.checkAuthorizationStatus()
                if granted && self.dailyReminderEnabled {
                    self.scheduleDailyReminder()
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                if settings.authorizationStatus != .authorized {
                    self.isNotificationsEnabled = false
                }
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Alerte Budget
    
    /// Envoie une notification si le budget dépasse 80% ou 100%
    func sendBudgetAlert(category: String, percentage: Double, spent: Double, limit: Double) {
        guard isNotificationsEnabled, budgetAlertEnabled else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "fr_FR")
        let spentStr = formatter.string(from: NSNumber(value: spent)) ?? "\(spent)€"
        let limitStr = formatter.string(from: NSNumber(value: limit)) ?? "\(limit)€"
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if percentage >= 100 {
            content.title = "Budget dépassé — \(category)"
            content.body  = "Vous avez dépensé \(spentStr) sur un budget de \(limitStr). Limite atteinte !"
            content.badge = 1
        } else if percentage >= 80 {
            content.title = "Budget presque atteint — \(category)"
            content.body  = "Il vous reste \(Int(100 - percentage))% de votre budget \(category) (\(spentStr) / \(limitStr))."
        } else {
            return
        }
        
        let id = "budget_\(category)_\(Int(percentage))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Rappel Quotidien
    
    func scheduleDailyReminder() {
        guard isNotificationsEnabled else { return }
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "Gestfina — Suivi du jour"
        content.body  = "N'oubliez pas d'enregistrer vos dépenses du jour pour garder vos finances à jour."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "gestfina_daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["gestfina_daily_reminder"])
    }
    
    // MARK: - Notification Nouvelle Transaction
    
    func sendTransactionAdded(title: String, amount: String, type: String) {
        guard isNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Transaction enregistrée"
        content.body  = "\(title) — \(amount)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
