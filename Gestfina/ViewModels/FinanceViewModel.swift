//
//  FinanceViewModel.swift
//  Gestfina
//
//  ViewModel principal gérant toute la logique financière
//

import Foundation
import SwiftUI
import Combine

class FinanceViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var transactions: [Transaction] = [] {
        didSet { saveTransactions() }
    }
    
    @Published var budgets: [Budget] = [] {
        didSet { saveBudgets() }
    }
    
    @Published var selectedPeriod: TimePeriod = .month
    @Published var searchText: String = ""
    @Published var selectedFilter: TransactionType? = nil
    @Published var userName: String = "Madu"
    @Published var currency: String = "EUR" {
        didSet { UserDefaults.standard.set(currency, forKey: "gestfina_currency") }
    }
    
    /// Symbole de la devise active
    var currencySymbol: String {
        AppCurrency.all.first(where: { $0.code == currency })?.symbol ?? "€"
    }
    
    // MARK: - Keys de stockage
    
    private let transactionsKey = "gestfina_transactions"
    private let budgetsKey       = "gestfina_budgets"
    private let userNameKey      = "gestfina_username"
    private let currencyKey      = "gestfina_currency"
    
    // MARK: - Init
    
    init() {
        loadTransactions()
        loadBudgets()
        loadUserName()
        if let saved = UserDefaults.standard.string(forKey: currencyKey) {
            currency = saved
        }
        // Pas de données mock - l'utilisateur commence avec une application vide
    }
    
    // MARK: - Période de temps
    
    enum TimePeriod: String, CaseIterable {
        case week = "Semaine"
        case month = "Mois"
        case year = "Année"
        case all = "Tout"
        
        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            let end = now
            
            switch self {
            case .week:
                let start = calendar.date(byAdding: .day, value: -7, to: now)!
                return (start, end)
            case .month:
                let start = calendar.date(byAdding: .month, value: -1, to: now)!
                return (start, end)
            case .year:
                let start = calendar.date(byAdding: .year, value: -1, to: now)!
                return (start, end)
            case .all:
                return (Date.distantPast, end)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Transactions filtrées par période
    var filteredTransactions: [Transaction] {
        let range = selectedPeriod.dateRange
        var result = transactions.filter { $0.date >= range.start && $0.date <= range.end }
        
        if let filter = selectedFilter {
            result = result.filter { $0.type == filter }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted { $0.date > $1.date }
    }
    
    /// Solde total
    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }
    
    /// Total des revenus pour la période
    var totalIncome: Double {
        filteredTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Total des dépenses pour la période
    var totalExpenses: Double {
        filteredTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Taux d'épargne
    var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return ((totalIncome - totalExpenses) / totalIncome) * 100
    }
    
    /// Dépenses par catégorie
    var expensesByCategory: [(category: TransactionCategory, amount: Double, percentage: Double)] {
        let expenses = filteredTransactions.filter { $0.type == .expense }
        let total = expenses.reduce(0) { $0 + $1.amount }
        
        var categoryTotals: [TransactionCategory: Double] = [:]
        for transaction in expenses {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals.map { (category, amount) in
            (category: category, amount: amount, percentage: total > 0 ? (amount / total) * 100 : 0)
        }.sorted { $0.amount > $1.amount }
    }
    
    /// Revenus par catégorie
    var incomeByCategory: [(category: TransactionCategory, amount: Double, percentage: Double)] {
        let incomes = filteredTransactions.filter { $0.type == .income }
        let total = incomes.reduce(0) { $0 + $1.amount }
        
        var categoryTotals: [TransactionCategory: Double] = [:]
        for transaction in incomes {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        
        return categoryTotals.map { (category, amount) in
            (category: category, amount: amount, percentage: total > 0 ? (amount / total) * 100 : 0)
        }.sorted { $0.amount > $1.amount }
    }
    
    /// Dépenses quotidiennes pour le graphique (7 derniers jours)
    var dailyExpenses: [(day: String, amount: Double)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "EEE"
        
        var result: [(day: String, amount: Double)] = []
        
        for i in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayExpenses = transactions
                .filter { $0.type == .expense && $0.date >= dayStart && $0.date < dayEnd }
                .reduce(0) { $0 + $1.amount }
            
            result.append((day: dateFormatter.string(from: date).capitalized, amount: dayExpenses))
        }
        
        return result
    }
    
    /// Dépenses mensuelles pour le graphique (6 derniers mois)
    var monthlyExpenses: [(month: String, amount: Double)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fr_FR")
        dateFormatter.dateFormat = "MMM"
        
        var result: [(month: String, amount: Double)] = []
        
        for i in (0..<6).reversed() {
            let date = calendar.date(byAdding: .month, value: -i, to: Date())!
            let components = calendar.dateComponents([.year, .month], from: date)
            let monthStart = calendar.date(from: components)!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            
            let monthExpenses = transactions
                .filter { $0.type == .expense && $0.date >= monthStart && $0.date < monthEnd }
                .reduce(0) { $0 + $1.amount }
            
            result.append((month: dateFormatter.string(from: date).capitalized, amount: monthExpenses))
        }
        
        return result
    }
    
    /// Progression du budget par catégorie
    func budgetProgress(for budget: Budget) -> (spent: Double, percentage: Double) {
        let range = budget.period == .monthly ? TimePeriod.month.dateRange :
                    budget.period == .weekly ? TimePeriod.week.dateRange :
                    TimePeriod.year.dateRange
        
        let spent = transactions
            .filter { $0.type == .expense && $0.category == budget.category && $0.date >= range.start && $0.date <= range.end }
            .reduce(0) { $0 + $1.amount }
        
        let percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0
        return (spent: spent, percentage: min(percentage, 100))
    }
    
    /// Retourne le pourcentage budget (spent/limit) pour une catégorie, ou nil si aucun budget n'existe
    func budgetPercentage(for category: TransactionCategory) -> Double? {
        guard let budget = budgets.first(where: { $0.category == category && $0.isActive }) else {
            return nil
        }
        return budgetProgress(for: budget).percentage
    }
    
    /// Transactions récentes (5 dernières)
    var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(5))
    }
    
    // MARK: - Actions
    
    /// Ajouter une transaction
    func addTransaction(_ transaction: Transaction) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            transactions.append(transaction)
        }
        // Notification confirmation
        let notif = NotificationManager.shared
        notif.sendTransactionAdded(
            title: transaction.title,
            amount: transaction.formattedAmount,
            type: transaction.type.rawValue
        )
        // Vérifier les alertes budget
        checkBudgetAlerts(for: transaction)
    }
    
    /// Vérifie si un budget est dépassé après une transaction
    private func checkBudgetAlerts(for transaction: Transaction) {
        guard transaction.type == .expense else { return }
        
        let affectedBudgets = budgets.filter { $0.category == transaction.category && $0.isActive }
        let notif = NotificationManager.shared
        
        for budget in affectedBudgets {
            let progress = budgetProgress(for: budget)
            notif.sendBudgetAlert(
                category: budget.category.rawValue,
                percentage: progress.percentage,
                spent: progress.spent,
                limit: budget.limit
            )
        }
    }
    
    /// Supprimer une transaction
    func deleteTransaction(_ transaction: Transaction) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            transactions.removeAll { $0.id == transaction.id }
        }
    }
    
    /// Modifier une transaction
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
    }
    
    /// Ajouter un budget
    func addBudget(_ budget: Budget) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            budgets.append(budget)
        }
    }
    
    /// Supprimer un budget
    func deleteBudget(_ budget: Budget) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            budgets.removeAll { $0.id == budget.id }
        }
    }
    
    /// Mettre à jour un budget
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
        }
    }
    
    // MARK: - Formatage
    
    /// Formater un montant en devise
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: NSNumber(value: amount)) ?? "0,00 €"
    }
    
    /// Formater un pourcentage
    func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
    
    // MARK: - Persistance (UserDefaults + JSON)
    
    private func saveTransactions() {
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: transactionsKey)
        }
    }
    
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
    
    private func saveBudgets() {
        if let data = try? JSONEncoder().encode(budgets) {
            UserDefaults.standard.set(data, forKey: budgetsKey)
        }
    }
    
    private func loadBudgets() {
        if let data = UserDefaults.standard.data(forKey: budgetsKey),
           let decoded = try? JSONDecoder().decode([Budget].self, from: data) {
            budgets = decoded
        }
    }
    
    private func loadUserName() {
        if let name = UserDefaults.standard.string(forKey: userNameKey) {
            userName = name
        }
    }
    
    func saveUserName() {
        UserDefaults.standard.set(userName, forKey: userNameKey)
    }
    
    /// Réinitialiser toutes les données
    func resetAllData() {
        transactions = []
        budgets = []
    }
}
