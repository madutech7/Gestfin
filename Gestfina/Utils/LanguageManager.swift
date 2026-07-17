//
//  LanguageManager.swift
//  Gestfina
//
//  Application fixée en Français — Bridge L10n vers String Catalogs natif.
//

import SwiftUI

/// Bridge L10n : redirige les appels vers le String Catalog natif (fr uniquement).
struct L10n {
    // MARK: - Tab Bar
    static var tabHome: String { String(localized: "tabHome") }
    static var tabTransactions: String { String(localized: "tabTransactions") }
    static var tabCoach: String { String(localized: "tabCoach") }
    static var tabBudget: String { String(localized: "tabBudget") }
    static var tabAdd: String { String(localized: "tabAdd") }

    // MARK: - Dashboard
    static var totalBalance: String { String(localized: "totalBalance") }
    static var income: String { String(localized: "income") }
    static var expenses: String { String(localized: "expenses") }
    static var activity: String { String(localized: "activity") }
    static var sevenDays: String { String(localized: "sevenDays") }
    static var categories: String { String(localized: "categories") }
    static var recent: String { String(localized: "recent") }
    static var noTransaction: String { String(localized: "noTransaction") }
    static var addFirstTransaction: String { String(localized: "addFirstTransaction") }
    static var edit: String { String(localized: "edit") }
    static var delete: String { String(localized: "delete") }
    static var deleteTransactionConfirm: String { String(localized: "deleteTransactionConfirm") }
    static func willBeDeleted(_ title: String) -> String { String(localized: "willBeDeleted \(title)") }
    static var cancel: String { String(localized: "cancel") }
    static var offline: String { String(localized: "offline") }
    static var pending: String { String(localized: "pending") }

    // MARK: - Settings
    static var settings: String { String(localized: "settings") }
    static var subscription: String { String(localized: "subscription") }
    static var activeSubscription: String { String(localized: "activeSubscription") }
    static var unlockPremium: String { String(localized: "unlockPremium") }
    static var active: String { String(localized: "active") }
    static var profile: String { String(localized: "profile") }
    static var tapToEdit: String { String(localized: "tapToEdit") }
    static var currency: String { String(localized: "currency") }
    static var currencyFooter: String { String(localized: "currencyFooter") }
    static var display: String { String(localized: "display") }
    static var appearance: String { String(localized: "appearance") }
    static var systemTheme: String { String(localized: "systemTheme") }
    static var lightTheme: String { String(localized: "lightTheme") }
    static var darkTheme: String { String(localized: "darkTheme") }
    static var security: String { String(localized: "security") }
    static var biometricUnavailable: String { String(localized: "biometricUnavailable") }
    static func securityFooterEnabled(_ biometricName: String) -> String { String(localized: "securityFooterEnabled") }
    static func securityFooterDisabled(_ biometricName: String) -> String { String(localized: "securityFooterDisabled \(biometricName)") }
    static var encryptedStorage: String { String(localized: "encryptedStorage") }
    static var notifications: String { String(localized: "notifications") }
    static var enableNotifications: String { String(localized: "enableNotifications") }
    static var openSystemSettings: String { String(localized: "openSystemSettings") }
    static var notifDenied: String { String(localized: "notifDenied") }
    static var budgetAlerts: String { String(localized: "budgetAlerts") }
    static var budgetAlertSubtitle: String { String(localized: "budgetAlertSubtitle") }
    static var dailyReminder: String { String(localized: "dailyReminder") }
    static var dailyReminderSubtitle: String { String(localized: "dailyReminderSubtitle") }
    static var reminderTime: String { String(localized: "reminderTime") }
    static var data: String { String(localized: "data") }
    static var savedTransactions: String { String(localized: "savedTransactions") }
    static var activeBudgets: String { String(localized: "activeBudgets") }
    static var logout: String { String(localized: "logout") }
    static var resetDevice: String { String(localized: "resetDevice") }
    static var resetConfirm: String { String(localized: "resetConfirm") }
    static var deleteAll: String { String(localized: "deleteAll") }
    static var resetMessage: String { String(localized: "resetMessage") }
    static var dataFooter: String { String(localized: "dataFooter") }
    static var about: String { String(localized: "about") }
    static var developer: String { String(localized: "developer") }
    static var localData: String { String(localized: "localData") }
    static var privacyPolicy: String { String(localized: "privacyPolicy") }
    static var termsOfUse: String { String(localized: "termsOfUse") }
    static var version: String { String(localized: "version") }
    static var editProfile: String { String(localized: "editProfile") }
    static var yourName: String { String(localized: "yourName") }
    static var firstName: String { String(localized: "firstName") }
    static var save: String { String(localized: "save") }
    static var searchCurrency: String { String(localized: "searchCurrency") }
    static var chooseCurrency: String { String(localized: "chooseCurrency") }

    // MARK: - Add / Edit Transaction
    static var amount: String { String(localized: "amount") }
    static var transactionTitle: String { String(localized: "transactionTitle") }
    static var noteOptional: String { String(localized: "noteOptional") }
    static var recurringTransaction: String { String(localized: "recurringTransaction") }
    static var frequency: String { String(localized: "frequency") }
    static var information: String { String(localized: "information") }
    static var category: String { String(localized: "category") }
    static var newTransaction: String { String(localized: "newTransaction") }
    static var addButton: String { String(localized: "addButton") }
    static var editTransaction: String { String(localized: "editTransaction") }
    static var deleteThisTransaction: String { String(localized: "deleteThisTransaction") }

    // MARK: - Transactions List
    static var searchTransaction: String { String(localized: "searchTransaction") }
    static var all: String { String(localized: "all") }
    static func operationsCount(_ count: Int) -> String { String(localized: "operationsCount \(count)") }
    static var addFirstViaPlus: String { String(localized: "addFirstViaPlus") }
    static var exportCSV: String { String(localized: "exportCSV") }
    static var exportPDF: String { String(localized: "exportPDF") }
    static var export: String { String(localized: "export") }

    // MARK: - Budget
    static var budgets: String { String(localized: "budgets") }
    static var myBudgets: String { String(localized: "myBudgets") }
    static var noBudget: String { String(localized: "noBudget") }
    static var createFirstBudget: String { String(localized: "createFirstBudget") }
    static var used: String { String(localized: "used") }
    static var globalBudget: String { String(localized: "globalBudget") }
    static var spent: String { String(localized: "spent") }
    static var remaining: String { String(localized: "remaining") }
    static func usedPercent(_ pct: Int) -> String { String(localized: "usedPercent \(pct)") }
    static func remainsAmount(_ formatted: String) -> String { String(localized: "remainsAmount \(formatted)") }
    static func ofLimit(_ limit: String) -> String { String(localized: "ofLimit \(limit)") }
    static var spendingLimit: String { String(localized: "spendingLimit") }
    static var period: String { String(localized: "period") }
    static var newBudget: String { String(localized: "newBudget") }
    static var editBudget: String { String(localized: "editBudget") }
    static var done: String { String(localized: "done") }

    // MARK: - Coach / AI
    static var askCoach: String { String(localized: "askCoach") }
    static var editQuestion: String { String(localized: "editQuestion") }
    static var coachSuggestion1: String { String(localized: "coachSuggestion1") }
    static var coachSuggestion2: String { String(localized: "coachSuggestion2") }
    static var coachSuggestion3: String { String(localized: "coachSuggestion3") }

    // MARK: - Lock Screen / Security
    static var isLocked: String { String(localized: "isLocked") }
    static func useBiometric(_ name: String) -> String { String(localized: "useBiometric \(name)") }

    // MARK: - Onboarding
    static var welcomeTitle: String { String(localized: "welcomeTitle") }
    static var welcomeDesc: String { String(localized: "welcomeDesc") }
    static var trackTitle: String { String(localized: "trackTitle") }
    static var trackDesc: String { String(localized: "trackDesc") }
    static var securityTitle: String { String(localized: "securityTitle") }
    static var securityDesc: String { String(localized: "securityDesc") }
    static var skip: String { String(localized: "skip") }
    static var start: String { String(localized: "start") }
    static var continueButton: String { String(localized: "continueButton") }

    // MARK: - Type
    static var incomeType: String { String(localized: "incomeType") }
    static var expenseType: String { String(localized: "expenseType") }
    static var copyAmount: String { String(localized: "copyAmount") }
    static var copyTitle: String { String(localized: "copyTitle") }

    // MARK: - Dates
    static var dateLocaleIdentifier: String { "fr" }
    static var today: String { String(localized: "today") }
    static var yesterday: String { String(localized: "yesterday") }
    static func daysAgo(_ n: Int) -> String { String(localized: "daysAgo \(n)") }

    // MARK: - Complex (Bridge)
    static func categoryName(_ cat: TransactionCategory) -> String {
        return String(localized: LocalizedStringResource(stringLiteral: cat.rawValue))
    }

    static func frequencyName(_ freq: RecurringFrequency) -> String {
        return String(localized: LocalizedStringResource(stringLiteral: freq.rawValue))
    }

    static func periodName(_ period: FinanceViewModel.TimePeriod) -> String {
        return String(localized: LocalizedStringResource(stringLiteral: period.rawValue))
    }

    static func budgetPeriodName(_ period: BudgetPeriod) -> String {
        return String(localized: LocalizedStringResource(stringLiteral: period.rawValue))
    }
}
