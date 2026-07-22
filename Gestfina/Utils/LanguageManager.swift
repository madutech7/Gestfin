//
//  LanguageManager.swift
//  Gestfina
//
//  Application 100% en Français — Textes français directs pour une fiabilité absolue.
//

import SwiftUI

/// Bridge L10n : Fournit directement tous les textes de l'application en Français.
struct L10n {
    // MARK: - Tab Bar
    static var tabHome: String { "Accueil" }
    static var tabTransactions: String { "Transactions" }
    static var tabCoach: String { "SamaCoach" }
    static var tabBudget: String { "Budget" }
    static var tabAdd: String { "Ajouter" }

    // MARK: - Dashboard
    static var totalBalance: String { "Solde total" }
    static var income: String { "Revenus" }
    static var expenses: String { "Dépenses" }
    static var activity: String { "Activité" }
    static var sevenDays: String { "7 jours" }
    static var categories: String { "catégories" }
    static var recent: String { "Récentes" }
    static var noTransaction: String { "Aucune transaction" }
    static var addFirstTransaction: String { "Ajoutez votre première opération" }
    static var edit: String { "Modifier" }
    static var delete: String { "Supprimer" }
    static var deleteTransactionConfirm: String { "Supprimer cette transaction ?" }
    static func willBeDeleted(_ title: String) -> String { "La transaction \"\(title)\" sera définitivement supprimée." }
    static var cancel: String { "Annuler" }
    static var offline: String { "Hors-ligne" }
    static var pending: String { "En attente" }

    // MARK: - Settings
    static var settings: String { "Réglages" }
    static var subscription: String { "Mon abonnement" }
    static var activeSubscription: String { "Abonnement actif — Merci pour votre soutien !" }
    static var unlockPremium: String { "Débloquez les transactions illimitées & stats" }
    static var active: String { "Actif" }
    static var profile: String { "Profil" }
    static var tapToEdit: String { "Toucher pour modifier" }
    static var currency: String { "Devise" }
    static var currencyFooter: String { "Toutes les valeurs seront affichées avec le symbole de cette devise." }
    static var display: String { "Affichage" }
    static var appearance: String { "Apparence" }
    static var systemTheme: String { "Système" }
    static var lightTheme: String { "Clair" }
    static var darkTheme: String { "Sombre" }
    static var security: String { "Sécurité" }
    static var biometricUnavailable: String { "Biométrie non disponible sur cet appareil" }
    static func securityFooterEnabled(_ biometricName: String) -> String { "Verrouillage par \(biometricName) activé à chaque ouverture." }
    static func securityFooterDisabled(_ biometricName: String) -> String { "Activez \(biometricName) pour sécuriser l'accès à vos données." }
    static var encryptedStorage: String { "Stockage chiffré local (AES-256)" }
    static var notifications: String { "Notifications" }
    static var enableNotifications: String { "Autoriser les notifications" }
    static var openSystemSettings: String { "Ouvrir les Réglages Système" }
    static var notifDenied: String { "Les notifications sont désactivées dans les réglages système." }
    static var budgetAlerts: String { "Alertes de budget" }
    static var budgetAlertSubtitle: String { "Recevoir une alerte en cas de dépassement" }
    static var dailyReminder: String { "Rappel quotidien" }
    static var dailyReminderSubtitle: String { "Rappel pour enregistrer vos dépenses" }
    static var reminderTime: String { "Heure du rappel" }
    static var data: String { "Données" }
    static var savedTransactions: String { "Transactions enregistrées" }
    static var activeBudgets: String { "Budgets actifs" }
    static var logout: String { "Se déconnecter" }
    static var resetDevice: String { "Réinitialiser les données" }
    static var resetConfirm: String { "Réinitialiser" }
    static var deleteAll: String { "Tout supprimer" }
    static var resetMessage: String { "Toutes vos transactions et budgets locaux seront définitivement supprimés." }
    static var dataFooter: String { "Vos données restent strictement confidentielles et chiffrées sur votre appareil." }
    static var about: String { "À propos" }
    static var developer: String { "Développeur" }
    static var localData: String { "Données locales uniquement" }
    static var privacyPolicy: String { "Politique de confidentialité" }
    static var termsOfUse: String { "Conditions d'utilisation" }
    static var version: String { "Version 1.0 (iOS 26)" }
    static var editProfile: String { "Modifier le profil" }
    static var yourName: String { "Votre nom" }
    static var firstName: String { "Prénom ou pseudo" }
    static var save: String { "Enregistrer" }
    static var searchCurrency: String { "Rechercher une devise..." }
    static var chooseCurrency: String { "Choisir la devise" }

    // MARK: - Add / Edit Transaction
    static var amount: String { "Montant" }
    static var transactionTitle: String { "Titre de la transaction" }
    static var noteOptional: String { "Note (optionnelle)" }
    static var recurringTransaction: String { "Transaction récurrente" }
    static var frequency: String { "Fréquence" }
    static var information: String { "Informations" }
    static var category: String { "Catégorie" }
    static var newTransaction: String { "Nouvelle transaction" }
    static var addButton: String { "Ajouter" }
    static var editTransaction: String { "Modifier la transaction" }
    static var deleteThisTransaction: String { "Supprimer cette transaction" }

    // MARK: - Transactions List
    static var searchTransaction: String { "Rechercher une transaction..." }
    static var all: String { "Tout" }
    static func operationsCount(_ count: Int) -> String { "\(count) opération\(count > 1 ? "s" : "")" }
    static var addFirstViaPlus: String { "Ajoutez votre première transaction avec le bouton +" }
    static var exportCSV: String { "Exporter en CSV" }
    static var exportPDF: String { "Exporter le rapport PDF" }
    static var export: String { "Exporter" }

    // MARK: - Budget
    static var budgets: String { "Budgets" }
    static var myBudgets: String { "Mes Budgets" }
    static var noBudget: String { "Aucun budget défini" }
    static var createFirstBudget: String { "Fixez des limites de dépenses pour maîtriser vos finances" }
    static var used: String { "utilisé" }
    static var globalBudget: String { "Budget Global" }
    static var spent: String { "Dépensé" }
    static var remaining: String { "Restant" }
    static func usedPercent(_ pct: Int) -> String { "\(pct)% utilisé" }
    static func remainsAmount(_ formatted: String) -> String { "Reste \(formatted)" }
    static func ofLimit(_ limit: String) -> String { "sur \(limit)" }
    static var spendingLimit: String { "Limite de dépense" }
    static var period: String { "Période" }
    static var newBudget: String { "Nouveau budget" }
    static var editBudget: String { "Modifier le budget" }
    static var done: String { "Terminé" }

    // MARK: - Coach / AI
    static var askCoach: String { "Posez votre question à SamaCoach..." }
    static var editQuestion: String { "Modifier ma question" }
    static var coachSuggestion1: String { "Comment optimiser mes dépenses ce mois-ci ?" }
    static var coachSuggestion2: String { "Analyse mon budget alimentation" }
    static var coachSuggestion3: String { "Combien puis-je épargner pour mes projets ?" }

    // MARK: - Lock Screen / Security
    static var isLocked: String { "Gestfina est verrouillé" }
    static func useBiometric(_ name: String) -> String { "Déverrouiller avec \(name)" }

    // MARK: - Onboarding
    static var welcomeTitle: String { "Bienvenue sur SamaXaalis" }
    static var welcomeDesc: String { "Votre compagnon financier personnel ultra-premium." }
    static var trackTitle: String { "Suivez vos finances" }
    static var trackDesc: String { "Gérez vos revenus, dépenses et budgets en toute simplicité." }
    static var securityTitle: String { "Sécurité maximale" }
    static var securityDesc: String { "Vos données restent 100% privées et chiffrées sur votre iPhone." }
    static var skip: String { "Passer" }
    static var start: String { "Commencer" }
    static var continueButton: String { "Continuer" }

    // MARK: - Type
    static var incomeType: String { "Revenu" }
    static var expenseType: String { "Dépense" }
    static var copyAmount: String { "Copier le montant" }
    static var copyTitle: String { "Copier le titre" }

    // MARK: - Dates
    static var dateLocaleIdentifier: String { "fr" }
    static var today: String { "Aujourd'hui" }
    static var yesterday: String { "Hier" }
    static func daysAgo(_ n: Int) -> String { "Il y a \(n) jours" }

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
