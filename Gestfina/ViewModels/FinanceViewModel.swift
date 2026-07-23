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
    
    @Published var transactions: [AppTransaction] = [] {
        didSet { saveTransactions() }
    }
    
    @Published var budgets: [Budget] = [] {
        didSet { saveBudgets() }
    }
    
    @Published var accounts: [Account] = [] {
        didSet { saveAccounts() }
    }
    
    @Published var savingsGoals: [SavingsGoal] = [] {
        didSet { saveSavingsGoals() }
    }
    
    @Published var selectedPeriod: TimePeriod = .month
    @Published var searchText: String = ""
    @Published var selectedFilter: TransactionType? = nil
    @Published var userName: String = "Madu"
    @Published var currency: String = "EUR" {
        didSet { UserDefaults.standard.set(currency, forKey: "gestfina_currency") }
    }
    @Published var isBalanceVisible: Bool = true {
        didSet { UserDefaults.standard.set(isBalanceVisible, forKey: "gestfina_is_balance_visible") }
    }
    
    /// Symbole de la devise active
    var currencySymbol: String {
        AppCurrency.all.first(where: { $0.code == currency })?.symbol ?? "€"
    }
    
    // MARK: - Keys de stockage
    
    private let transactionsKey     = "gestfina_transactions"
    private let budgetsKey          = "gestfina_budgets"
    private let accountsKey         = "gestfina_accounts"
    private let savingsGoalsKey    = "gestfina_savings_goals"
    private let userNameKey         = "gestfina_username"
    private let currencyKey         = "gestfina_currency"
    private let isBalanceVisibleKey = "gestfina_is_balance_visible"
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Formatter partagé pour éviter de recréer un NumberFormatter à chaque appel
    private var cachedFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "fr_FR")
        return f
    }()
    private var cachedCurrencyCode: String = ""
    
    // MARK: - Init
    
    init() {
        loadTransactions()
        loadBudgets()
        loadAccounts()
        loadSavingsGoals()
        loadUserName()
        if let saved = UserDefaults.standard.string(forKey: currencyKey) {
            currency = saved
        }
        if UserDefaults.standard.object(forKey: isBalanceVisibleKey) != nil {
            isBalanceVisible = UserDefaults.standard.bool(forKey: isBalanceVisibleKey)
        }
        
        // Écouter les changements de nom d'utilisateur depuis BackendAuthManager
        BackendAuthManager.shared.$currentUserName
            .receive(on: RunLoop.main)
            .sink { [weak self] newName in
                if !newName.isEmpty {
                    self?.userName = newName
                } else {
                    self?.userName = "Madu"
                }
            }
            .store(in: &cancellables)
        
        // Charger les données cloud directement au démarrage si l'utilisateur est connecté
        if BackendAuthManager.shared.isLoggedIn,
           let token = APIManager.shared.token, token != "GUEST_MODE" {
            fetchCloudData()
        }
        
        // Synchroniser les actions hors-ligne en attente
        SyncManager.shared.triggerSynchronization()
        
        // Générer les transactions récurrentes au démarrage
        generateRecurringTransactions()
        
        // Rafraîchir depuis le cloud après chaque fin de synchronisation
        SyncManager.shared.$isSyncing
            .receive(on: RunLoop.main)
            .dropFirst() // ignorer la valeur initiale
            .sink { [weak self] isSyncing in
                guard let self = self else { return }
                // Quand la synchro vient de se terminer, on recharge depuis le serveur
                if !isSyncing {
                    if BackendAuthManager.shared.isLoggedIn && APIManager.shared.token != "GUEST_MODE" {
                        self.fetchCloudData()
                    }
                    self.generateRecurringTransactions()
                }
            }
            .store(in: &cancellables)
            
        setupAnalyticsPipeline()
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
    
    // Variables précédemment synchrones, dorénavant calculées en arrière-plan
    @Published var filteredTransactions: [AppTransaction] = []
    @Published var totalBalance: Double = 0
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var savingsRate: Double = 0
    @Published var expensesByCategory: [(category: TransactionCategory, amount: Double, percentage: Double)] = []
    @Published var incomeByCategory: [(category: TransactionCategory, amount: Double, percentage: Double)] = []
    @Published var dailyExpenses: [(day: String, amount: Double)] = []
    @Published var monthlyExpenses: [(month: String, amount: Double)] = []
    
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
    
    @Published var recentTransactions: [AppTransaction] = []
    
    // MARK: - Pipeline Analytique Asynchrone
    
    private func setupAnalyticsPipeline() {
        Publishers.CombineLatest4($transactions, $selectedPeriod, $searchText, $selectedFilter)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] txs, period, text, filter in
                self?.calculateAnalytics(transactions: txs, period: period, text: text, filter: filter)
            }
            .store(in: &cancellables)
    }
    
    private func calculateAnalytics(transactions: [AppTransaction], period: TimePeriod, text: String, filter: TransactionType?) {
        Task.detached(priority: .userInitiated) {
            let range = period.dateRange
            var filtered = transactions.filter { $0.date >= range.start && $0.date <= range.end }
            if let f = filter { filtered = filtered.filter { $0.type == f } }
            if !text.isEmpty {
                let lowerText = text.lowercased()
                filtered = filtered.filter {
                    $0.title.lowercased().contains(lowerText) ||
                    $0.category.rawValue.lowercased().contains(lowerText)
                }
            }
            let sortedFiltered = filtered.sorted { $0.date > $1.date }
            
            let totalBal = transactions.reduce(0) { $0 + $1.signedAmount }
            let tInc = sortedFiltered.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let tExp = sortedFiltered.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            let sRate = tInc > 0 ? ((tInc - tExp) / tInc) * 100 : 0
            
            var expTotals: [TransactionCategory: Double] = [:]
            for t in sortedFiltered where t.type == .expense { expTotals[t.category, default: 0] += t.amount }
            let expCat = expTotals.map { (cat, amount) in
                (category: cat, amount: amount, percentage: tExp > 0 ? (amount / tExp) * 100 : 0)
            }.sorted { $0.amount > $1.amount }
            
            var incTotals: [TransactionCategory: Double] = [:]
            for t in sortedFiltered where t.type == .income { incTotals[t.category, default: 0] += t.amount }
            let incCat = incTotals.map { (cat, amount) in
                (category: cat, amount: amount, percentage: tInc > 0 ? (amount / tInc) * 100 : 0)
            }.sorted { $0.amount > $1.amount }
            
            let recents = Array(transactions.sorted { $0.date > $1.date }.prefix(5))
            
            let calendar = Calendar.current
            let now = Date()
            
            let dFormatter = DateFormatter()
            dFormatter.locale = Locale(identifier: "fr_FR")
            dFormatter.dateFormat = "EEE"
            var dExp: [(day: String, amount: Double)] = []
            for i in (0..<7).reversed() {
                guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
                let dayStart = calendar.startOfDay(for: date)
                guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }
                let sum = transactions.filter { $0.type == .expense && $0.date >= dayStart && $0.date < dayEnd }.reduce(0) { $0 + $1.amount }
                dExp.append((day: dFormatter.string(from: date).capitalized, amount: sum))
            }
            
            let mFormatter = DateFormatter()
            mFormatter.locale = Locale(identifier: "fr_FR")
            mFormatter.dateFormat = "MMM"
            var mExp: [(month: String, amount: Double)] = []
            for i in (0..<6).reversed() {
                guard let date = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
                let components = calendar.dateComponents([.year, .month], from: date)
                guard let monthStart = calendar.date(from: components),
                      let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { continue }
                let sum = transactions.filter { $0.type == .expense && $0.date >= monthStart && $0.date < monthEnd }.reduce(0) { $0 + $1.amount }
                mExp.append((month: mFormatter.string(from: date).capitalized, amount: sum))
            }
            
            Task { @MainActor [weak self] in
                self?.filteredTransactions = sortedFiltered
                self?.totalBalance = totalBal
                self?.totalIncome = tInc
                self?.totalExpenses = tExp
                self?.savingsRate = sRate
                self?.expensesByCategory = expCat
                self?.incomeByCategory = incCat
                self?.recentTransactions = recents
                self?.dailyExpenses = dExp
                self?.monthlyExpenses = mExp
            }
        }
    }
    
    // MARK: - Actions
    
    /// Ajouter une transaction
    func addTransaction(_ transaction: AppTransaction) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            transactions.append(transaction)
        }
        
        // Sync hors-ligne / en-ligne automatique
        SyncManager.shared.queueAction(itemId: transaction.id, itemType: .transaction, actionType: .create)
        
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
    private func checkBudgetAlerts(for transaction: AppTransaction) {
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
    func deleteTransaction(_ transaction: AppTransaction) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            transactions.removeAll { $0.id == transaction.id }
        }
        // Enregistrer la suppression hors-ligne
        SyncManager.shared.queueAction(itemId: transaction.id, itemType: .transaction, actionType: .delete)
    }
    
    /// Modifier une transaction
    func updateTransaction(_ transaction: AppTransaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            // Mettre à jour sur le backend
            SyncManager.shared.queueAction(itemId: transaction.id, itemType: .transaction, actionType: .update)
        }
    }
    
    /// Ajouter un budget
    func addBudget(_ budget: Budget) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            budgets.append(budget)
        }
        // Sync hors-ligne / en-ligne
        SyncManager.shared.queueAction(itemId: budget.id, itemType: .budget, actionType: .create)
    }
    
    /// Supprimer un budget
    func deleteBudget(_ budget: Budget) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            budgets.removeAll { $0.id == budget.id }
        }
        // Enregistrer la suppression hors-ligne
        SyncManager.shared.queueAction(itemId: budget.id, itemType: .budget, actionType: .delete)
    }
    
    /// Mettre à jour un budget
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            // Mettre à jour sur le backend
            SyncManager.shared.queueAction(itemId: budget.id, itemType: .budget, actionType: .update)
        }
    }
    
    // MARK: - Formatage
    
    /// Formater un montant en devise (utilise un formatter partagé pour la performance)
    func formatAmount(_ amount: Double) -> String {
        if cachedCurrencyCode != currency {
            cachedFormatter.currencyCode = currency
            cachedCurrencyCode = currency
        }
        return cachedFormatter.string(from: NSNumber(value: amount)) ?? "0,00 €"
    }
    
    /// Formater un pourcentage
    func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
    
    // MARK: - Persistance Chiffrée (iOS Data Protection API)
    
    private func saveTransactions() {
        _ = EncryptedStorageManager.shared.save(transactions, forKey: transactionsKey)
    }
    
    private func loadTransactions() {
        EncryptedStorageManager.shared.migrateFromUserDefaultsIfNeeded(
            userDefaultsKey: transactionsKey,
            storageKey: transactionsKey,
            type: [AppTransaction].self
        )
        if let loaded = EncryptedStorageManager.shared.load(forKey: transactionsKey, as: [AppTransaction].self) {
            transactions = loaded
        }
    }
    
    private func saveBudgets() {
        _ = EncryptedStorageManager.shared.save(budgets, forKey: budgetsKey)
    }
    
    private func loadBudgets() {
        EncryptedStorageManager.shared.migrateFromUserDefaultsIfNeeded(
            userDefaultsKey: budgetsKey,
            storageKey: budgetsKey,
            type: [Budget].self
        )
        if let loaded = EncryptedStorageManager.shared.load(forKey: budgetsKey, as: [Budget].self) {
            budgets = loaded
        }
    }
    
    private func loadUserName() {
        if let name = UserDefaults.standard.string(forKey: userNameKey) {
            userName = name
        }
    }
    
    func saveUserName() {
        UserDefaults.standard.set(userName, forKey: userNameKey)
        // Synchroniser avec BackendAuthManager
        if BackendAuthManager.shared.currentUserName != userName {
            DispatchQueue.main.async {
                BackendAuthManager.shared.currentUserName = self.userName
            }
            UserDefaults.standard.set(userName, forKey: "gestfina_user_name")
        }
    }
    
    /// Réinitialiser toutes les données
    func resetAllData() {
        transactions = []
        budgets = []
        BackendAuthManager.shared.logout()
    }
    
    /// Charger les données depuis le backend NestJS/Firebase
    func fetchCloudData() {
        print("☁️ [FinanceVM] fetchCloudData() lancé...")
        
        APIManager.shared.fetchTransactions { [weak self] txs in
            guard let self = self else { return }
            
            if let txs = txs {
                print("☁️ [FinanceVM] \(txs.count) transaction(s) reçues du cloud")
                DispatchQueue.main.async {
                    // Ne remplacer que si le cloud a des données, ou si le local est déjà vide
                    if !txs.isEmpty || self.transactions.isEmpty {
                        self.transactions = txs
                    } else {
                        print("⚠️ [FinanceVM] Cloud a retourné 0 transactions mais local en a \(self.transactions.count). Données locales conservées.")
                    }
                }
            } else {
                print("❌ [FinanceVM] fetchTransactions a retourné nil (erreur réseau/auth/parsing). Données locales conservées.")
            }
        }
        
        APIManager.shared.fetchBudgets { [weak self] bgts in
            guard let self = self else { return }
            
            if let bgts = bgts {
                print("☁️ [FinanceVM] \(bgts.count) budget(s) reçu(s) du cloud")
                DispatchQueue.main.async {
                    if !bgts.isEmpty || self.budgets.isEmpty {
                        self.budgets = bgts
                    }
                }
            } else {
                print("❌ [FinanceVM] fetchBudgets a retourné nil. Données locales conservées.")
            }
        }
    }

    /// Génère automatiquement les nouvelles occurrences des transactions récurrentes
    private func generateRecurringTransactions() {
        let now = Date()
        var newTransactions: [AppTransaction] = []
        
        for (index, tx) in transactions.enumerated() {
            guard tx.isRecurring, let freq = tx.recurringFrequency else { continue }
            
            var currentRefDate = tx.lastRecurrenceDate ?? tx.date
            var hasGenerated = false
            
            while let nextDate = Calendar.current.date(byAdding: freq.calendarComponent, value: 1, to: currentRefDate),
                  nextDate <= now {
                
                let newTx = AppTransaction(
                    title: tx.title,
                    amount: tx.amount,
                    date: nextDate,
                    category: tx.category,
                    type: tx.type,
                    note: tx.note,
                    isRecurring: false
                )
                newTransactions.append(newTx)
                currentRefDate = nextDate
                hasGenerated = true
            }
            
            if hasGenerated {
                transactions[index].lastRecurrenceDate = currentRefDate
            }
        }
        
        if !newTransactions.isEmpty {
            transactions.append(contentsOf: newTransactions)
        }
    }
    
    // MARK: - Comptes & Épargne
    
    func loadAccounts() {
        EncryptedStorageManager.shared.migrateFromUserDefaultsIfNeeded(
            userDefaultsKey: accountsKey,
            storageKey: accountsKey,
            type: [Account].self
        )
        if let loaded = EncryptedStorageManager.shared.load(forKey: accountsKey, as: [Account].self) {
            accounts = loaded
        } else {
            accounts = Account.defaultAccounts
        }
    }
    
    func saveAccounts() {
        _ = EncryptedStorageManager.shared.save(accounts, forKey: accountsKey)
    }
    
    func loadSavingsGoals() {
        EncryptedStorageManager.shared.migrateFromUserDefaultsIfNeeded(
            userDefaultsKey: savingsGoalsKey,
            storageKey: savingsGoalsKey,
            type: [SavingsGoal].self
        )
        if let loaded = EncryptedStorageManager.shared.load(forKey: savingsGoalsKey, as: [SavingsGoal].self) {
            savingsGoals = loaded
        } else {
            savingsGoals = SavingsGoal.sampleGoals
        }
    }
    
    func saveSavingsGoals() {
        _ = EncryptedStorageManager.shared.save(savingsGoals, forKey: savingsGoalsKey)
    }
    
    func addSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.append(goal)
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) {
        savingsGoals.removeAll(where: { $0.id == goal.id })
    }
    
    func depositToSavingsGoal(goalId: UUID, amount: Double) {
        if let index = savingsGoals.firstIndex(where: { $0.id == goalId }) {
            savingsGoals[index].currentAmount += amount
            
            // Créer une transaction dépense automatique liée au versement d'épargne
            let goalTitle = savingsGoals[index].title
            let tx = AppTransaction(
                title: "Épargne : \(goalTitle)",
                amount: amount,
                date: Date(),
                category: .savings,
                type: .expense,
                note: "Versement vers la cagnotte \(goalTitle)"
            )
            addTransaction(tx)
        }
    }
}
