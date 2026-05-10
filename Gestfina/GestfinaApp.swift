//
//  GestfinaApp.swift
//  Gestfina
//
//  Created by Madu - 2026
//  Application de gestion financière personnelle
//

import SwiftUI

@main
struct GestfinaApp: App {
    @StateObject private var viewModel        = FinanceViewModel()
    @StateObject private var authManager      = AuthenticationManager()
    @StateObject private var notifManager     = NotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView(authManager: authManager, notifManager: notifManager)
                    .environmentObject(viewModel)
                
                // Écran de verrouillage par-dessus si non déverrouillé
                if authManager.isAuthEnabled && !authManager.isUnlocked {
                    LockScreenView(authManager: authManager)
                        .transition(.opacity)
                        .zIndex(1000)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: authManager.isUnlocked)
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                // Verrouiller quand l'app passe en arrière-plan
                authManager.lock()
            case .active:
                // Rafraîchir le statut des notifications
                notifManager.checkAuthorizationStatus()
            default:
                break
            }
        }
    }
}


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
        
        let reason = "Déverrouillez Gestfina pour accéder à vos finances."
        
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


//
//  NotificationManager.swift
//  Gestfina
//
//  Gestion des notifications locales — alertes budget + rappels
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    
    static let shared = NotificationManager()
    
    // MARK: - Préférences
    
    @Published var isNotificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(isNotificationsEnabled, forKey: Keys.notifEnabled) }
    }
    @Published var budgetAlertEnabled: Bool {
        didSet { UserDefaults.standard.set(budgetAlertEnabled, forKey: Keys.budgetAlert) }
    }
    @Published var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: Keys.dailyReminder)
            if dailyReminderEnabled {
                scheduleDailyReminder()
            } else {
                cancelDailyReminder()
            }
        }
    }
    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: Keys.reminderHour)
            if dailyReminderEnabled { scheduleDailyReminder() }
        }
    }
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Clés
    
    private enum Keys {
        static let notifEnabled = "gestfina_notif_enabled"
        static let budgetAlert  = "gestfina_budget_alert"
        static let dailyReminder = "gestfina_daily_reminder"
        static let reminderHour  = "gestfina_reminder_hour"
    }
    
    // MARK: - Init
    
    init() {
        self.isNotificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notifEnabled)
        self.budgetAlertEnabled     = UserDefaults.standard.object(forKey: Keys.budgetAlert) as? Bool ?? true
        self.dailyReminderEnabled   = UserDefaults.standard.bool(forKey: Keys.dailyReminder)
        self.reminderHour           = UserDefaults.standard.object(forKey: Keys.reminderHour) as? Int ?? 20
        checkAuthorizationStatus()
    }
    
    // MARK: - Autorisation
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                self.checkAuthorizationStatus()
                if granted && self.dailyReminderEnabled {
                    self.scheduleDailyReminder()
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                if settings.authorizationStatus != .authorized {
                    self.isNotificationsEnabled = false
                }
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Alerte Budget
    
    /// Envoie une notification si le budget dépasse 80% ou 100%
    func sendBudgetAlert(category: String, percentage: Double, spent: Double, limit: Double) {
        guard isNotificationsEnabled, budgetAlertEnabled else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "fr_FR")
        let spentStr = formatter.string(from: NSNumber(value: spent)) ?? "\(spent)€"
        let limitStr = formatter.string(from: NSNumber(value: limit)) ?? "\(limit)€"
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if percentage >= 100 {
            content.title = "Budget dépassé — \(category)"
            content.body  = "Vous avez dépensé \(spentStr) sur un budget de \(limitStr). Limite atteinte !"
            content.badge = 1
        } else if percentage >= 80 {
            content.title = "Budget presque atteint — \(category)"
            content.body  = "Il vous reste \(Int(100 - percentage))% de votre budget \(category) (\(spentStr) / \(limitStr))."
        } else {
            return
        }
        
        let id = "budget_\(category)_\(Int(percentage))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Rappel Quotidien
    
    func scheduleDailyReminder() {
        guard isNotificationsEnabled else { return }
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "Gestfina — Suivi du jour"
        content.body  = "N'oubliez pas d'enregistrer vos dépenses du jour pour garder vos finances à jour."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "gestfina_daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["gestfina_daily_reminder"])
    }
    
    // MARK: - Notification Nouvelle Transaction
    
    func sendTransactionAdded(title: String, amount: String, type: String) {
        guard isNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Transaction enregistrée"
        content.body  = "\(title) — \(amount)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}


//
//  LockScreenView.swift
//  Gestfina
//
//  Écran de verrouillage — Face ID / Touch ID / Code
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var shakeOffset: CGFloat = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Fond dégradé subtil
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "0F172A"), Color(hex: "1E293B")]
                    : [Color(hex: "F8FAFF"), Color(hex: "EEF2FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Orbes de couleur subtils
            Circle()
                .fill(Color.appBlue.opacity(0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: -80, y: -200)
            
            Circle()
                .fill(Color.appPurple.opacity(0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 100, y: 250)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo + Nom app
                VStack(spacing: 20) {
                    // Icône de l'app
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appBlue, Color.appPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                            .shadow(color: Color.appBlue.opacity(0.35), radius: 30, y: 12)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    VStack(spacing: 8) {
                        Text("Gestfina")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Vos finances en sécurité")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .opacity(logoOpacity)
                }
                
                Spacer()
                
                // Zone d'authentification
                VStack(spacing: 24) {
                    // Message d'erreur
                    if let error = authManager.authError {
                        Text(error)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appRed)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .offset(x: shakeOffset)
                    }
                    
                    // Bouton principal biométrie
                    Button {
                        authManager.authenticate()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: authManager.biometricIcon)
                                .font(.system(size: 22, weight: .medium))
                            
                            Text("Déverrouiller avec \(authManager.biometricName)")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appBlue, Color.appPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.appBlue.opacity(0.4), radius: 16, y: 6)
                        .scaleEffect(authManager.isAuthenticating ? 0.97 : 1)
                        .animation(.spring(response: 0.2), value: authManager.isAuthenticating)
                    }
                    .padding(.horizontal, 32)
                    
                    // Sous-texte fallback
                    Button {
                        authManager.authenticate()
                    } label: {
                        Text("Utiliser le code de l'appareil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1
                logoOpacity = 1
            }
            // Déclenchement automatique de Face ID à l'ouverture
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                authManager.authenticate()
            }
        }
        .onChange(of: authManager.authError) { error in
            if error != nil {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3).repeatCount(4, autoreverses: true)) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    shakeOffset = 0
                }
            }
        }
    }
}

#Preview {
    LockScreenView(authManager: AuthenticationManager())
}

