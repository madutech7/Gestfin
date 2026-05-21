//
//  APIManager.swift
//  Gestfina
//
//  Gestionnaire d'API pour communiquer avec le backend NestJS
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private let baseURL = "https://madutech7-samaxaalis-backend.hf.space/api"
    private let service = "com.madu.gestfina"
    private let tokenKey = "jwt_token"
    
    private init() {}
    
    var token: String? {
        get { KeychainHelper.shared.readString(service: service, account: tokenKey) }
        set { 
            if let newValue = newValue {
                KeychainHelper.shared.save(string: newValue, service: service, account: tokenKey)
            } else {
                KeychainHelper.shared.delete(service: service, account: tokenKey)
            }
        }
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
                completion(.failure(NSError(domain: "InvalidJSON", code: -2, userInfo: [NSLocalizedDescriptionKey: AppFeedback.Sync.syncFailed])))
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
                let message = json["message"] as? String ?? AppFeedback.Auth.loginFailed
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
                completion(.failure(NSError(domain: "InvalidJSON", code: -2, userInfo: [NSLocalizedDescriptionKey: AppFeedback.Sync.syncFailed])))
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
                let message = json["message"] as? String ?? AppFeedback.Auth.registerFailed
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
                completion(.failure(NSError(domain: "InvalidJSON", code: -2, userInfo: [NSLocalizedDescriptionKey: AppFeedback.Sync.syncFailed])))
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
                let message = json["message"] as? String ?? AppFeedback.Auth.googleAuthFailed
                completion(.failure(NSError(domain: "AuthFailed", code: 401, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }
    
    // MARK: - Synchronisation Transactions
    
    func createTransaction(_ transaction: AppTransaction, completion: @escaping (Bool) -> Void) {
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
    
    func updateTransaction(_ transaction: AppTransaction, completion: @escaping (Bool) -> Void) {
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
    
    // MARK: - Date Parsing Helpers
    
    /// Parse une date ISO8601 de mani\u{00E8}re robuste (avec ou sans fractions de secondes)
    private func parseISO8601Date(_ dateStr: String) -> Date? {
        // 1. Essayer avec fractions de secondes (format backend NestJS: "2026-05-20T15:30:00.000Z")
        let formatterWithFractional = ISO8601DateFormatter()
        formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatterWithFractional.date(from: dateStr) {
            return date
        }
        
        // 2. Essayer sans fractions de secondes ("2026-05-20T15:30:00Z")
        let formatterStandard = ISO8601DateFormatter()
        formatterStandard.formatOptions = [.withInternetDateTime]
        if let date = formatterStandard.date(from: dateStr) {
            return date
        }
        
        // 3. Fallback avec DateFormatter g\u{00E9}n\u{00E9}rique
        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd"] {
            fallback.dateFormat = format
            if let date = fallback.date(from: dateStr) {
                return date
            }
        }
        
        print("\u{26A0}\u{FE0F} [APIManager] Impossible de parser la date: '\(dateStr)'")
        return nil
    }
    
    /// Extrait un Double de mani\u{00E8}re robuste (g\u{00E8}re Int, Double, String, NSNumber)
    private func parseAmount(_ value: Any?) -> Double? {
        if let d = value as? Double { return d }
        if let n = value as? NSNumber { return n.doubleValue }
        if let i = value as? Int { return Double(i) }
        if let s = value as? String, let d = Double(s) { return d }
        return nil
    }
    
    // MARK: - Fetch APIs
    
    func fetchTransactions(completion: @escaping ([AppTransaction]?) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/transactions?limit=1000") else {
                print("\u{274C} [APIManager] fetchTransactions: authentification \u{00E9}chou\u{00E9}e ou URL invalide")
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { completion(nil); return }
                
                // V\u{00E9}rifier l'erreur r\u{00E9}seau
                if let error = error {
                    print("\u{274C} [APIManager] fetchTransactions erreur r\u{00E9}seau: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                // V\u{00E9}rifier le code HTTP
                let httpStatus = (response as? HTTPURLResponse)?.statusCode ?? 0
                if httpStatus == 401 {
                    print("\u{274C} [APIManager] fetchTransactions: Token expir\u{00E9} (401). D\u{00E9}connexion.")
                    DispatchQueue.main.async { BackendAuthManager.shared.logout() }
                    completion(nil)
                    return
                }
                
                guard (200...299).contains(httpStatus) else {
                    let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "vide"
                    print("\u{274C} [APIManager] fetchTransactions: HTTP \(httpStatus) \u{2014} \(body)")
                    completion(nil)
                    return
                }
                
                // Parser le JSON
                guard let data = data else {
                    print("\u{274C} [APIManager] fetchTransactions: data nil")
                    completion(nil)
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    let raw = String(data: data, encoding: .utf8) ?? "illisible"
                    print("\u{274C} [APIManager] fetchTransactions: JSON invalide \u{2014} \(raw.prefix(500))")
                    completion(nil)
                    return
                }
                
                guard let items = json["data"] as? [[String: Any]] else {
                    print("\u{274C} [APIManager] fetchTransactions: cl\u{00E9} 'data' absente ou format incorrect. JSON keys: \(json.keys)")
                    completion(nil)
                    return
                }
                
                print("\u{1F4E5} [APIManager] fetchTransactions: \(items.count) transactions re\u{00E7}ues du serveur")
                
                var skippedCount = 0
                let parsed: [AppTransaction] = items.compactMap { dict in
                    guard let idStr = dict["id"] as? String,
                          let id = UUID(uuidString: idStr) else {
                        print("\u{26A0}\u{FE0F} [APIManager] Transaction ignor\u{00E9}e: id manquant ou invalide \u{2014} \(dict["id"] ?? "nil")")
                        skippedCount += 1
                        return nil
                    }
                    
                    guard let title = dict["title"] as? String else {
                        print("\u{26A0}\u{FE0F} [APIManager] Transaction \(idStr) ignor\u{00E9}e: title manquant")
                        skippedCount += 1
                        return nil
                    }
                    
                    guard let amount = self.parseAmount(dict["amount"]) else {
                        print("\u{26A0}\u{FE0F} [APIManager] Transaction \(idStr) ignor\u{00E9}e: amount invalide \u{2014} \(String(describing: dict["amount"]))")
                        skippedCount += 1
                        return nil
                    }
                    
                    guard let typeStr = dict["type"] as? String else {
                        print("\u{26A0}\u{FE0F} [APIManager] Transaction \(idStr) ignor\u{00E9}e: type manquant")
                        skippedCount += 1
                        return nil
                    }
                    
                    let catStr = dict["category"] as? String ?? "other"
                    
                    // Parser la date de mani\u{00E8}re robuste
                    let date: Date
                    if let dateStr = dict["date"] as? String, let parsed = self.parseISO8601Date(dateStr) {
                        date = parsed
                    } else {
                        // Utiliser la date actuelle comme fallback plut\u{00F4}t que d'ignorer la transaction
                        print("\u{26A0}\u{FE0F} [APIManager] Transaction \(idStr): date invalide '\(dict["date"] ?? "nil")', utilisation de la date actuelle")
                        date = Date()
                    }
                    
                    let type: TransactionType = typeStr == "income" ? .income : .expense
                    let category = TransactionCategory.allCases.first(where: { $0.backendKey == catStr.lowercased() }) ?? .other
                    let note = dict["note"] as? String ?? ""
                    
                    return AppTransaction(id: id, title: title, amount: amount, date: date, category: category, type: type, note: note)
                }
                
                if skippedCount > 0 {
                    print("\u{26A0}\u{FE0F} [APIManager] \(skippedCount) transaction(s) ignor\u{00E9}e(s) lors du parsing")
                }
                print("\u{2705} [APIManager] \(parsed.count) transaction(s) pars\u{00E9}e(s) avec succ\u{00E8}s")
                
                completion(parsed)
            }.resume()
        }
    }
    
    func fetchBudgets(completion: @escaping ([Budget]?) -> Void) {
        ensureAuthenticated { [weak self] authSuccess in
            guard authSuccess, let self = self, let url = URL(string: "\(self.baseURL)/budgets") else {
                print("\u{274C} [APIManager] fetchBudgets: authentification \u{00E9}chou\u{00E9}e ou URL invalide")
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(self.token ?? "")", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { completion(nil); return }
                
                if let error = error {
                    print("\u{274C} [APIManager] fetchBudgets erreur r\u{00E9}seau: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                let httpStatus = (response as? HTTPURLResponse)?.statusCode ?? 0
                if httpStatus == 401 {
                    print("\u{274C} [APIManager] fetchBudgets: Token expir\u{00E9} (401)")
                    DispatchQueue.main.async { BackendAuthManager.shared.logout() }
                    completion(nil)
                    return
                }
                
                guard (200...299).contains(httpStatus) else {
                    let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "vide"
                    print("\u{274C} [APIManager] fetchBudgets: HTTP \(httpStatus) \u{2014} \(body)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    print("\u{274C} [APIManager] fetchBudgets: data nil")
                    completion(nil)
                    return
                }
                
                guard let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    let raw = String(data: data, encoding: .utf8) ?? "illisible"
                    print("\u{274C} [APIManager] fetchBudgets: JSON invalide \u{2014} \(raw.prefix(500))")
                    completion(nil)
                    return
                }
                
                print("\u{1F4E5} [APIManager] fetchBudgets: \(items.count) budget(s) re\u{00E7}u(s) du serveur")
                
                let parsed: [Budget] = items.compactMap { dict in
                    guard let idStr = dict["id"] as? String,
                          let id = UUID(uuidString: idStr),
                          let catStr = dict["category"] as? String,
                          let periodStr = dict["period"] as? String else {
                        print("\u{26A0}\u{FE0F} [APIManager] Budget ignor\u{00E9}e: champs requis manquants")
                        return nil
                    }
                    
                    let limit = self.parseAmount(dict["limitAmount"]) ?? 0
                    let isActive = dict["isActive"] as? Bool ?? true
                    
                    let category = TransactionCategory.allCases.first(where: { $0.backendKey == catStr.lowercased() }) ?? .other
                    let period: BudgetPeriod = periodStr == "weekly" ? .weekly : (periodStr == "yearly" ? .yearly : .monthly)
                    
                    return Budget(id: id, category: category, limit: limit, period: period, isActive: isActive)
                }
                
                print("\u{2705} [APIManager] \(parsed.count) budget(s) pars\u{00E9}e(s) avec succ\u{00E8}s")
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
