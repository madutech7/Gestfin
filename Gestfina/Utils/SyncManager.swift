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
class BackendAuthManager: ObservableObject {
    static let shared = BackendAuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUserEmail: String = ""
    @Published var currentUserName: String = ""
    
    private init() {
        self.isLoggedIn = UserDefaults.standard.string(forKey: "gestfina_jwt_token") != nil
        self.currentUserEmail = UserDefaults.standard.string(forKey: "gestfina_user_email") ?? ""
        self.currentUserName = UserDefaults.standard.string(forKey: "gestfina_user_name") ?? ""
    }
    
    func setLoginState(token: String, email: String, name: String) {
        UserDefaults.standard.set(token, forKey: "gestfina_jwt_token")
        UserDefaults.standard.set(email, forKey: "gestfina_user_email")
        UserDefaults.standard.set(name, forKey: "gestfina_user_name")
        UserDefaults.standard.set(name, forKey: "gestfina_username") // Synchroniser avec FinanceViewModel
        
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.currentUserEmail = email
            self.currentUserName = name
        }
    }
    
    func skipAuthentication() {
        // Enregistre un faux token "GUEST_MODE" pour contourner la vue d'authentification
        UserDefaults.standard.set("GUEST_MODE", forKey: "gestfina_jwt_token")
        UserDefaults.standard.set("Mode Hors-ligne", forKey: "gestfina_user_name")
        UserDefaults.standard.set("invité@gestfina.local", forKey: "gestfina_user_email")
        UserDefaults.standard.set("Mode Hors-ligne", forKey: "gestfina_username") // Synchroniser
        
        // Vider la file d'attente hors-ligne pour le mode invité pur
        UserDefaults.standard.removeObject(forKey: "gestfina_pending_sync_queue")
        
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.currentUserName = "Mode Hors-ligne"
            self.currentUserEmail = "invité@gestfina.local"
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "gestfina_jwt_token")
        UserDefaults.standard.removeObject(forKey: "gestfina_user_email")
        UserDefaults.standard.removeObject(forKey: "gestfina_user_name")
        UserDefaults.standard.removeObject(forKey: "gestfina_username") // Reset
        
        // Vider la file d'attente hors-ligne
        UserDefaults.standard.removeObject(forKey: "gestfina_pending_sync_queue")
        
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.currentUserEmail = ""
            self.currentUserName = ""
        }
    }
}

/// Gestionnaire d'API pour communiquer avec le backend NestJS
class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "https://madutech7-samaxaalis-backend.hf.space/api"
    private let tokenKey = "gestfina_jwt_token"
    
    private init() {}
    
    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }
    
    func ensureAuthenticated(completion: @escaping (Bool) -> Void) {
        if let t = token, t != "GUEST_MODE" {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // MARK: - Auth API
    
    func login(email: String, password: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(NSError(domain: "URLInvalid", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "InvalidJSON", code: -2)))
                return
            }
            
            if let accessToken = json["accessToken"] as? String,
               let userDict = json["user"] as? [String: Any],
               let email = userDict["email"] as? String,
               let name = userDict["name"] as? String {
                self?.token = accessToken
                BackendAuthManager.shared.setLoginState(token: accessToken, email: email, name: name)
                completion(.success(json))
            } else {
                let message = json["message"] as? String ?? "Erreur de connexion"
                completion(.failure(NSError(domain: "AuthFailed", code: 401, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    func register(email: String, password: String, name: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            completion(.failure(NSError(domain: "URLInvalid", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password, "name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "InvalidJSON", code: -2)))
                return
            }
            
            if let accessToken = json["accessToken"] as? String,
               let userDict = json["user"] as? [String: Any],
               let email = userDict["email"] as? String,
               let name = userDict["name"] as? String {
                self?.token = accessToken
                BackendAuthManager.shared.setLoginState(token: accessToken, email: email, name: name)
                completion(.success(json))
            } else {
                let message = json["message"] as? String ?? "Erreur d'inscription"
                completion(.failure(NSError(domain: "AuthFailed", code: 400, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    func googleLogin(idToken: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/google") else {
            completion(.failure(NSError(domain: "URLInvalid", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["idToken": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "InvalidJSON", code: -2)))
                return
            }
            
            if let accessToken = json["accessToken"] as? String,
               let userDict = json["user"] as? [String: Any],
               let email = userDict["email"] as? String,
               let name = userDict["name"] as? String {
                self?.token = accessToken
                BackendAuthManager.shared.setLoginState(token: accessToken, email: email, name: name)
                completion(.success(json))
            } else {
                let message = json["message"] as? String ?? "Erreur d'authentification Google"
                completion(.failure(NSError(domain: "AuthFailed", code: 401, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    // MARK: - Synchronisation Transactions
    
    func createTransaction(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/transactions") else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            let formatter = ISO8601DateFormatter()
            let body: [String: Any] = [
                "id": transaction.id.uuidString.lowercased(),
                "title": transaction.title,
                "amount": transaction.amount,
                "type": transaction.type == .income ? "income" : "expense",
                "category": transaction.category.backendKey,
                "note": transaction.note,
                "date": formatter.string(from: transaction.date)
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 201
                completion(success)
            }.resume()
        }
    }
    
    func updateTransaction(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/transactions/\(transaction.id.uuidString.lowercased())") else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            let formatter = ISO8601DateFormatter()
            let body: [String: Any] = [
                "title": transaction.title,
                "amount": transaction.amount,
                "type": transaction.type == .income ? "income" : "expense",
                "category": transaction.category.backendKey,
                "note": transaction.note,
                "date": formatter.string(from: transaction.date)
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion(success)
            }.resume()
        }
    }
    
    func deleteTransaction(id: UUID, completion: @escaping (Bool) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/transactions/\(id.uuidString.lowercased())") else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion(success)
            }.resume()
        }
    }
    
    // MARK: - Synchronisation Budgets
    
    func createBudget(_ budget: Budget, completion: @escaping (Bool) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/budgets") else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            let body: [String: Any] = [
                "id": budget.id.uuidString.lowercased(),
                "category": budget.category.backendKey,
                "limitAmount": budget.limit,
                "period": budget.period == .weekly ? "weekly" : (budget.period == .yearly ? "yearly" : "monthly"),
                "isActive": budget.isActive
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 201
                completion(success)
            }.resume()
        }
    }
    
    func updateBudget(_ budget: Budget, completion: @escaping (Bool) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/budgets/\(budget.id.uuidString.lowercased())") else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            let body: [String: Any] = [
                "category": budget.category.backendKey,
                "limitAmount": budget.limit,
                "period": budget.period == .weekly ? "weekly" : (budget.period == .yearly ? "yearly" : "monthly"),
                "isActive": budget.isActive
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion(success)
            }.resume()
        }
    }
    
    func deleteBudget(id: UUID, completion: @escaping (Bool) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/budgets/\(id.uuidString.lowercased())") else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                let success = (response as? HTTPURLResponse)?.statusCode == 200
                completion(success)
            }.resume()
        }
    }
    
    // MARK: - Fetch APIs
    
    func fetchTransactions(completion: @escaping ([Transaction]?) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/transactions?limit=1000") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let items = json["data"] as? [[String: Any]] else {
                    completion(nil)
                    return
                }
                
                let formatter = ISO8601DateFormatter()
                let parsed: [Transaction] = items.compactMap { dict in
                    guard let idStr = dict["id"] as? String,
                          let id = UUID(uuidString: idStr),
                          let title = dict["title"] as? String,
                          let amount = dict["amount"] as? Double,
                          let typeStr = dict["type"] as? String,
                          let catStr = dict["category"] as? String,
                          let dateStr = dict["date"] as? String,
                          let date = formatter.date(from: dateStr) else {
                        return nil
                    }
                    
                    let type: TransactionType = typeStr == "income" ? .income : .expense
                    let category = TransactionCategory.allCases.first(where: { $0.backendKey == catStr.lowercased() }) ?? .other
                    let note = dict["note"] as? String ?? ""
                    
                    return Transaction(id: id, title: title, amount: amount, date: date, category: category, type: type, note: note)
                }
                completion(parsed)
            }.resume()
        }
    }
    
    func fetchBudgets(completion: @escaping ([Budget]?) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/budgets") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    completion(nil)
                    return
                }
                
                let parsed: [Budget] = items.compactMap { dict in
                    guard let idStr = dict["id"] as? String,
                          let id = UUID(uuidString: idStr),
                          let catStr = dict["category"] as? String,
                          let limit = dict["limitAmount"] as? Double,
                          let periodStr = dict["period"] as? String,
                          let isActive = dict["isActive"] as? Bool else {
                        return nil
                    }
                    
                    let category = TransactionCategory.allCases.first(where: { $0.backendKey == catStr.lowercased() }) ?? .other
                    let period: BudgetPeriod = periodStr == "weekly" ? .weekly : (periodStr == "yearly" ? .yearly : .monthly)
                    
                    return Budget(id: id, category: category, limit: limit, period: period, isActive: isActive)
                }
                completion(parsed)
            }.resume()
        }
    }
    
    // MARK: - AI SamaCoach APIs
    
    func fetchAIAnalysis(completion: @escaping (Result<AIAnalysis, Error>) -> Void) {
        let currency = UserDefaults.standard.string(forKey: "gestfina_currency") ?? "EUR"
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/ai/analyze?currency=\(currency)") else {
                completion(.failure(NSError(domain: "AuthFailed", code: 401)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoData", code: -1)))
                    return
                }
                
                do {
                    let analysis = try JSONDecoder().decode(AIAnalysis.self, from: data)
                    completion(.success(analysis))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func sendAIChatMessage(message: String, history: [AIChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/ai/chat") else {
                completion(.failure(NSError(domain: "AuthFailed", code: 401)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            // Mapper l'historique pour ne garder que role et content comme attendu par le DTO
            let historyList = history.map { ["role": $0.role, "content": $0.content] }
            let currency = UserDefaults.standard.string(forKey: "gestfina_currency") ?? "EUR"
            let body: [String: Any] = [
                "message": message,
                "history": historyList,
                "currency": currency
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let reply = json["reply"] as? String else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: -2)))
                    return
                }
                
                completion(.success(reply))
            }.resume()
        }
    }
}

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
        localTransactions: [Transaction],
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
        localTransactions: [Transaction],
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
    
    private func loadLocalTransactions() -> [Transaction] {
        if let data = UserDefaults.standard.data(forKey: "gestfina_transactions"),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
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
