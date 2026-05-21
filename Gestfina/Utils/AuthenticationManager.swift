//
//  AuthenticationManager.swift
//  Gestfina
//
//  Gestion Face ID / Touch ID — sécurité de l'application
//

import Foundation
import LocalAuthentication
import SwiftUI

class AuthenticationManager: ObservableObject {
    
    // MARK: - État
    
    @Published var isUnlocked: Bool = false
    @Published var isAuthEnabled: Bool {
        didSet { UserDefaults.standard.set(isAuthEnabled, forKey: Keys.authEnabled) }
    }
    @Published var biometricType: LABiometryType = .none
    @Published var authError: String? = nil
    @Published var isAuthenticating: Bool = false
    
    // MARK: - Clés
    
    private enum Keys {
        static let authEnabled = "gestfina_auth_enabled"
    }
    
    // MARK: - Init
    
    init() {
        self.isAuthEnabled = UserDefaults.standard.bool(forKey: Keys.authEnabled)
        detectBiometricType()
        
        // Si l'auth n'est pas activée, on déverrouille directement
        if !isAuthEnabled {
            isUnlocked = true
        }
    }
    
    // MARK: - Détection type biométrique
    
    func detectBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }
    
    // MARK: - Authentification
    
    func authenticate() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil
        
        let context = LAContext()
        context.localizedCancelTitle = "Annuler"
        
        var error: NSError?
        
        // Essaie d'abord la biométrie, avec fallback sur le code de l'appareil
        let policy: LAPolicy = .deviceOwnerAuthentication
        
        guard context.canEvaluatePolicy(policy, error: &error) else {
            DispatchQueue.main.async {
                self.authError = "Biométrie non disponible sur cet appareil."
                self.isAuthenticating = false
                // Déverrouiller quand même si aucune biométrie disponible
                self.isUnlocked = true
            }
            return
        }
        
        let reason = "Déverrouillez SamaXaalis pour accéder à vos finances."
        
        context.evaluatePolicy(policy, localizedReason: reason) { success, authError in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        self.isUnlocked = true
                    }
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                } else {
                    if let error = authError as? LAError, error.code == .userCancel {
                        self.authError = nil
                    } else {
                        self.authError = "Authentification échouée. Réessayez."
                        let feedback = UINotificationFeedbackGenerator()
                        feedback.notificationOccurred(.error)
                    }
                }
            }
        }
    }
    
    // MARK: - Verrouillage
    
    func lock() {
        guard isAuthEnabled else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            isUnlocked = false
        }
    }
    
    // MARK: - Helpers UI
    
    var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }
    
    var biometricName: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Code de l'appareil"
        }
    }
    
    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
}
