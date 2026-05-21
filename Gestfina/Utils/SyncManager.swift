//
//  SyncManager.swift
//  Gestfina
//
//  Gestionnaire de synchronisation automatique et de détection réseau (Offline-first)
//

import Foundation
import Network
import Combine

/// Représente une action de synchronisation en attente d'envoi au serveur
enum PendingActionType: String, Codable {
    case create
    case update
    case delete
}

struct PendingSyncAction: Codable, Identifiable {
    var id: UUID { itemId }
    let itemId: UUID
    let itemType: PendingItemType
    let actionType: PendingActionType
    let timestamp: Date
    
    enum PendingItemType: String, Codable {
        case transaction
        case budget
    }
}

/// Détecteur de connexion internet natif
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    @Published var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let connected = path.status == .satisfied
                if connected != self?.isConnected {
                    self?.isConnected = connected
                    if connected {
                        print("📡 Connexion internet rétablie ! Lancement de la synchronisation...")
                        // Déclencher la synchronisation automatique
                        SyncManager.shared.triggerSynchronization()
                    } else {
                        print("🚫 Connexion internet perdue. Mode hors-ligne activé.")
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
}

/// Gestionnaire d'API pour communiquer avec le backend NestJS
extension TransactionCategory {
    var backendKey: String {
        switch self {
        case .salary: return "salary"
        case .freelance: return "freelance"
        case .investment: return "investment"
        case .food: return "food"
        case .housing: return "housing"
        case .transport: return "transport"
        case .utilities: return "utilities"
        case .entertainment: return "entertainment"
        case .shopping: return "shopping"
        case .health: return "health"
        case .education: return "education"
        case .savings: return "savings"
        case .other: return "other"
        }
    }
}

/// Gestionnaire d'authentification centralisé pour SwiftUI


/// Coordinateur principal pour synchroniser les données hors-ligne
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    private let pendingQueueKey = "gestfina_pending_sync_queue"
    @Published var isSyncing = false
    @Published var pendingCount = 0
    
    private init() {
        self.pendingCount = pendingActions.count
    }
    
    // MARK: - Gestion de la file d'attente
    
    var pendingActions: [PendingSyncAction] {
        get {
            guard let data = UserDefaults.standard.data(forKey: pendingQueueKey),
                  let actions = try? JSONDecoder().decode([PendingSyncAction].self, from: data) else {
                return []
            }
            return actions
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: pendingQueueKey)
                DispatchQueue.main.async {
                    self.pendingCount = newValue.count
                }
            }
        }
    }
    
    private var isUserPremium: Bool {
        UserDefaults.standard.bool(forKey: "gestfina_is_premium") || UserDefaults.standard.bool(forKey: "debug_premium_bypass")
    }
    
    func queueAction(itemId: UUID, itemType: PendingSyncAction.PendingItemType, actionType: PendingActionType) {
        // Si on est en mode invité (hors-ligne), on ne met rien en file d'attente
        guard let token = APIManager.shared.token, token != "GUEST_MODE" else { return }
        
        // Retirer toute action doublon sur le même item pour optimiser la file
        var current = pendingActions
        current.removeAll { $0.itemId == itemId }
        
        let newAction = PendingSyncAction(
            itemId: itemId,
            itemType: itemType,
            actionType: actionType,
            timestamp: Date()
        )
        
        current.append(newAction)
        pendingActions = current
        
        print("💾 Action mise en file d'attente hors-ligne : \(actionType.rawValue) sur \(itemType.rawValue) (\(itemId))")
        
        // Tenter de synchroniser immédiatement si connecté
        if NetworkMonitor.shared.isConnected {
            triggerSynchronization()
        }
    }
    
    // MARK: - Lancement de la synchronisation
    
    func triggerSynchronization() {
        guard NetworkMonitor.shared.isConnected, !isSyncing else { return }
        
        // Si on est en mode invité (hors-ligne), on ne tente aucune synchronisation
        guard let token = APIManager.shared.token, token != "GUEST_MODE" else { return }
        
        let actions = pendingActions
        guard !actions.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.isSyncing = true
        }
        print("🔄 Début de la synchronisation de \(actions.count) action(s) en attente...")
        
        // Charger les données locales
        let transactions = loadLocalTransactions()
        let budgets = loadLocalBudgets()
        
        processNextAction(actions: actions, index: 0, localTransactions: transactions, localBudgets: budgets)
    }
    
    private func processNextAction(
        actions: [PendingSyncAction],
        index: Int,
        localTransactions: [AppTransaction],
        localBudgets: [Budget]
    ) {
        guard index < actions.count else {
            // Synchronisation terminée avec succès
            DispatchQueue.main.async {
                self.isSyncing = false
            }
            print("🎉 Synchronisation terminée avec succès !")
            return
        }
        
        let action = actions[index]
        
        switch action.itemType {
        case .transaction:
            if action.actionType == .create {
                if let tx = localTransactions.first(where: { $0.id == action.itemId }) {
                    APIManager.shared.createTransaction(tx) { [weak self] success in
                        self?.handleActionResult(action: action, success: success, actions: actions, index: index, localTransactions: localTransactions, localBudgets: localBudgets)
                    }
                } else {
                    // L'item a été supprimé localement entre temps
                    removeFromQueue(id: action.itemId)
                    processNextAction(actions: actions, index: index + 1, localTransactions: localTransactions, localBudgets: localBudgets)
                }
            } else if action.actionType == .update {
                if let tx = localTransactions.first(where: { $0.id == action.itemId }) {
                    APIManager.shared.updateTransaction(tx) { [weak self] success in
                        self?.handleActionResult(action: action, success: success, actions: actions, index: index, localTransactions: localTransactions, localBudgets: localBudgets)
                    }
                } else {
                    removeFromQueue(id: action.itemId)
                    processNextAction(actions: actions, index: index + 1, localTransactions: localTransactions, localBudgets: localBudgets)
                }
            } else if action.actionType == .delete {
                APIManager.shared.deleteTransaction(id: action.itemId) { [weak self] success in
                    self?.handleActionResult(action: action, success: success, actions: actions, index: index, localTransactions: localTransactions, localBudgets: localBudgets)
                }
            }
            
        case .budget:
            if action.actionType == .create {
                if let budget = localBudgets.first(where: { $0.id == action.itemId }) {
                    APIManager.shared.createBudget(budget) { [weak self] success in
                        self?.handleActionResult(action: action, success: success, actions: actions, index: index, localTransactions: localTransactions, localBudgets: localBudgets)
                    }
                } else {
                    removeFromQueue(id: action.itemId)
                    processNextAction(actions: actions, index: index + 1, localTransactions: localTransactions, localBudgets: localBudgets)
                }
            } else if action.actionType == .update {
                if let budget = localBudgets.first(where: { $0.id == action.itemId }) {
                    APIManager.shared.updateBudget(budget) { [weak self] success in
                        self?.handleActionResult(action: action, success: success, actions: actions, index: index, localTransactions: localTransactions, localBudgets: localBudgets)
                    }
                } else {
                    removeFromQueue(id: action.itemId)
                    processNextAction(actions: actions, index: index + 1, localTransactions: localTransactions, localBudgets: localBudgets)
                }
            } else if action.actionType == .delete {
                APIManager.shared.deleteBudget(id: action.itemId) { [weak self] success in
                    self?.handleActionResult(action: action, success: success, actions: actions, index: index, localTransactions: localTransactions, localBudgets: localBudgets)
                }
            }
        }
    }
    
    private func handleActionResult(
        action: PendingSyncAction,
        success: Bool,
        actions: [PendingSyncAction],
        index: Int,
        localTransactions: [AppTransaction],
        localBudgets: [Budget]
    ) {
        if success {
            removeFromQueue(id: action.itemId)
            print("✅ Action synchronisée : \(action.actionType.rawValue) \(action.itemType.rawValue)")
            processNextAction(actions: actions, index: index + 1, localTransactions: localTransactions, localBudgets: localBudgets)
        } else {
            // Arrêter la synchro en cas d'erreur serveur et réessayer plus tard
            DispatchQueue.main.async {
                self.isSyncing = false
            }
            print("⚠️ Échec de la synchronisation pour \(action.itemType.rawValue) (\(action.itemId)). Reporté.")
        }
    }
    
    private func removeFromQueue(id: UUID) {
        var current = pendingActions
        current.removeAll { $0.itemId == id }
        pendingActions = current
    }
    
    // MARK: - Helpers de lecture locale
    
    private func loadLocalTransactions() -> [AppTransaction] {
        if let data = UserDefaults.standard.data(forKey: "gestfina_transactions"),
           let decoded = try? JSONDecoder().decode([AppTransaction].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func loadLocalBudgets() -> [Budget] {
        if let data = UserDefaults.standard.data(forKey: "gestfina_budgets"),
           let decoded = try? JSONDecoder().decode([Budget].self, from: data) {
            return decoded
        }
        return []
    }
}
