//
//  BackendAuthManager.swift
//  Gestfina
//
//  Gestionnaire d'authentification centralis\u{00E9} pour SwiftUI (Backend)
//

import Foundation

class BackendAuthManager: ObservableObject {
    static let shared = BackendAuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var currentUserEmail: String = ""
    @Published var currentUserName: String = ""
    
    private let service = "com.madu.gestfina"
    private let tokenKey = "jwt_token"
    
    private init() {
        // Tentative de lecture du token depuis le Keychain
        let token = KeychainHelper.shared.readString(service: service, account: tokenKey)
        
        // Migration depuis UserDefaults si pr\u{00E9}sent (pour les anciens utilisateurs)
        if token == nil, let oldToken = UserDefaults.standard.string(forKey: "gestfina_jwt_token") {
            KeychainHelper.shared.save(string: oldToken, service: service, account: tokenKey)
            UserDefaults.standard.removeObject(forKey: "gestfina_jwt_token")
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = (token != nil)
        }
        
        self.currentUserEmail = UserDefaults.standard.string(forKey: "gestfina_user_email") ?? ""
        self.currentUserName = UserDefaults.standard.string(forKey: "gestfina_user_name") ?? ""
    }
    
    func setLoginState(token: String, email: String, name: String) {
        // Sauvegarde s\u{00E9}curis\u{00E9}e du token
        KeychainHelper.shared.save(string: token, service: service, account: tokenKey)
        
        // Autres infos non-sensibles dans UserDefaults
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
        KeychainHelper.shared.save(string: "GUEST_MODE", service: service, account: tokenKey)
        
        UserDefaults.standard.set("Mode Hors-ligne", forKey: "gestfina_user_name")
        UserDefaults.standard.set("invit\u{00E9}@gestfina.local", forKey: "gestfina_user_email")
        UserDefaults.standard.set("Mode Hors-ligne", forKey: "gestfina_username") // Synchroniser
        
        // Vider la file d'attente hors-ligne pour le mode invit\u{00E9} pur
        UserDefaults.standard.removeObject(forKey: "gestfina_pending_sync_queue")
        
        DispatchQueue.main.async {
            self.isLoggedIn = true
            self.currentUserName = "Mode Hors-ligne"
            self.currentUserEmail = "invit\u{00E9}@gestfina.local"
        }
    }
    
    func logout() {
        // Suppression Keychain
        KeychainHelper.shared.delete(service: service, account: tokenKey)
        
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
