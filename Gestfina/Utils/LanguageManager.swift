//
//  LanguageManager.swift
//  Gestfina
//
//  Application 100% fixée en Français — Bridge L10n forcé sur la locale 'fr'.
//

import SwiftUI

/// Bridge L10n : redirige tous les appels vers le String Catalog natif en garantissant la locale française.
struct L10n {
    private static let frLocale = Locale(identifier: "fr")

    private static func localized(_ key: String) -> String {
        return String(localized: String.LocalizationValue(key), locale: frLocale)
    }

    // MARK: - Tab Bar
    static var tabHome: String { localized("tabHome") }
    static var tabTransactions: String { localized("tabTransactions") }
    static var tabCoach: String { localized("tabCoach") }
    static var tabBudget: String { localized("tabBudget") }
    static var tabAdd: String { localized("tabAdd") }

    // MARK: - Dashboard
    static var totalBalance: String { localized("totalBalance") }
    static var income: String { localized("income") }
    static var expenses: String { localized("expenses") }
    static var activity: String { localized("activity") }
    static var sevenDays: String { localized("sevenDays") }
    static var categories: String { localized("categories") }
    static var recent: String { localized("recent") }
    static var noTransaction: String { localized("noTransaction") }
    static var addFirstTransaction: String { localized("addFirstTransaction") }
    static var edit: String { localized("edit") }
    static var delete: String { localized("delete") }
    static var deleteTransactionConfirm: String { localized("deleteTransactionConfirm") }
    static func willBeDeleted(_ title: String) -> String { String(format: localized("willBeDeleted %@"), title) }
    static var cancel: String { localized("cancel") }
    static var offline: String { localized("offline") }
    static var pending: String { localized("pending") }

    // MARK: - Settings
    static var settings: String { localized("settings") }
    static var subscription: String { localized("subscription") }
    static var activeSubscription: String { localized("activeSubscription") }
    static var unlockPremium: String { localized("unlockPremium") }
    static var active: String { localized("active") }
    static var profile: String { localized("profile") }
    static var tapToEdit: String { localized("tapToEdit") }
    static var currency: String { localized("currency") }
    static var currencyFooter: String { localized("currencyFooter") }
    static var display: String { localized("display") }
    static var appearance: String { localized("appearance") }
    static var systemTheme: String { localized("systemTheme") }
    static var lightTheme: String { localized("lightTheme") }
    static var darkTheme: String { localized("darkTheme") }
    static var security: String { localized("security") }
    static var biometricUnavailable: String { localized("biometricUnavailable") }
    static func securityFooterEnabled(_ biometricName: String) -> String { localized("securityFooterEnabled") }
    static func securityFooterDisabled(_ biometricName: String) -> String { String(format: localized("securityFooterDisabled %@"), biometricName) }
    static var encryptedStorage: String { localized("encryptedStorage") }
    static var notifications: String { localized("notifications") }
    static var enableNotifications: String { localized("enableNotifications") }
    static var openSystemSettings: String { localized("openSystemSettings") }
    static var notifDenied: String { localized("notifDenied") }
    static var budgetAlerts: String { localized("budgetAlerts") }
    static var budgetAlertSubtitle: String { localized("budgetAlertSubtitle") }
    static var dailyReminder: String { localized("dailyReminder") }
    static var dailyReminderSubtitle: String { localized("dailyReminderSubtitle") }
    static var reminderTime: String { localized("reminderTime") }
    static var data: String { localized("data") }
    static var savedTransactions: String { localized("savedTransactions") }
    static var activeBudgets: String { localized("activeBudgets") }
    static var logout: String { localized("logout") }
    static var resetDevice: String { localized("resetDevice") }
    static var resetConfirm: String { localized("resetConfirm") }
    static var deleteAll: String { localized("deleteAll") }
    static var resetMessage: String { localized("resetMessage") }
    static var dataFooter: String { localized("dataFooter") }
    static var about: String { localized("about") }
    static var developer: String { localized("developer") }
    static var localData: String { localized("localData") }
    static var privacyPolicy: String { localized("privacyPolicy") }
    static var termsOfUse: String { localized("termsOfUse") }
    static var version: String { localized("version") }
    static var editProfile: String { localized("editProfile") }
    static var yourName: String { localized("yourName") }
    static var firstName: String { localized("firstName") }
    static var save: String { localized("save") }
    static var searchCurrency: String { localized("searchCurrency") }
    static var chooseCurrency: String { localized("chooseCurrency") }

    // MARK: - Add / Edit Transaction
    static var amount: String { localized("amount") }
    static var transactionTitle: String { localized("transactionTitle") }
    static var noteOptional: String { localized("noteOptional") }
    static var recurringTransaction: String { localized("recurringTransaction") }
    static var frequency: String { localized("frequency") }
    static var information: String { localized("information") }
    static var category: String { localized("category") }
    static var newTransaction: String { localized("newTransaction") }
    static var addButton: String { localized("addButton") }
    static var editTransaction: String { localized("editTransaction") }
    static var deleteThisTransaction: String { localized("deleteThisTransaction") }

    // MARK: - Transactions List
    static var searchTransaction: String { localized("searchTransaction") }
    static var all: String { localized("all") }
    static func operationsCount(_ count: Int) -> String { String(format: localized("operationsCount %d"), count) }
    static var addFirstViaPlus: String { localized("addFirstViaPlus") }
    static var exportCSV: String { localized("exportCSV") }
    static var exportPDF: String { localized("exportPDF") }
    static var export: String { localized("export") }

    // MARK: - Budget
    static var budgets: String { localized("budgets") }
    static var myBudgets: String { localized("myBudgets") }
    static var noBudget: String { localized("noBudget") }
    static var createFirstBudget: String { localized("createFirstBudget") }
    static var used: String { localized("used") }
    static var globalBudget: String { localized("globalBudget") }
    static var spent: String { localized("spent") }
    static var remaining: String { localized("remaining") }
    static func usedPercent(_ pct: Int) -> String { String(format: localized("usedPercent %d"), pct) }
    static func remainsAmount(_ formatted: String) -> String { String(format: localized("remainsAmount %@"), formatted) }
    static func ofLimit(_ limit: String) -> String { String(format: localized("ofLimit %@"), limit) }
    static var spendingLimit: String { localized("spendingLimit") }
    static var period: String { localized("period") }
    static var newBudget: String { localized("newBudget") }
    static var editBudget: String { localized("editBudget") }
    static var done: String { localized("done") }

    // MARK: - Coach / AI
    static var askCoach: String { localized("askCoach") }
    static var editQuestion: String { localized("editQuestion") }
    static var coachSuggestion1: String { localized("coachSuggestion1") }
    static var coachSuggestion2: String { localized("coachSuggestion2") }
    static var coachSuggestion3: String { localized("coachSuggestion3") }

    // MARK: - Lock Screen / Security
    static var isLocked: String { localized("isLocked") }
    static func useBiometric(_ name: String) -> String { String(format: localized("useBiometric %@"), name) }

    // MARK: - Onboarding
    static var welcomeTitle: String { localized("welcomeTitle") }
    static var welcomeDesc: String { localized("welcomeDesc") }
    static var trackTitle: String { localized("trackTitle") }
    static var trackDesc: String { localized("trackDesc") }
    static var securityTitle: String { localized("securityTitle") }
    static var securityDesc: String { localized("securityDesc") }
    static var skip: String { localized("skip") }
    static var start: String { localized("start") }
    static var continueButton: String { localized("continueButton") }

    // MARK: - Type
    static var incomeType: String { localized("incomeType") }
    static var expenseType: String { localized("expenseType") }
    static var copyAmount: String { localized("copyAmount") }
    static var copyTitle: String { localized("copyTitle") }

    // MARK: - Dates
    static var dateLocaleIdentifier: String { "fr" }
    static var today: String { localized("today") }
    static var yesterday: String { localized("yesterday") }
    static func daysAgo(_ n: Int) -> String { String(format: localized("daysAgo %d"), n) }

    // MARK: - Complex (Bridge)
    static func categoryName(_ cat: TransactionCategory) -> String {
        return cat.rawValue
    }

    static func frequencyName(_ freq: RecurringFrequency) -> String {
        return freq.rawValue
    }

    static func periodName(_ period: FinanceViewModel.TimePeriod) -> String {
        return period.rawValue
    }

    static func budgetPeriodName(_ period: BudgetPeriod) -> String {
        return period.rawValue
    }
}
