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
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("gestfina_appearance") private var appearanceMode: Int = 0
    @ObservedObject private var backendAuth = BackendAuthManager.shared
    
    private var colorSchemeOverride: ColorScheme? {
        switch appearanceMode {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if backendAuth.isLoggedIn {
                    MainTabView(authManager: authManager, notifManager: notifManager)
                        .environmentObject(viewModel)
                } else {
                    AuthView()
                        .environmentObject(viewModel)
                }
                
                // Écran de verrouillage par-dessus si non déverrouillé
                if authManager.isAuthEnabled && !authManager.isUnlocked {
                    LockScreenView(authManager: authManager)
                        .transition(.opacity)
                        .zIndex(1000)
                }
                
                // Onboarding par-dessus tout au premier lancement
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2000)
                }
                
                // Écran de confidentialité quand l'app est en arrière-plan
                if scenePhase == .background || scenePhase == .inactive {
                    PrivacyBlurOverlay()
                        .transition(.opacity)
                        .zIndex(3000)
                }
            }
            .environment(\.locale, Locale(identifier: "fr_FR"))
            .preferredColorScheme(colorSchemeOverride)
            .animation(.easeInOut(duration: 0.25), value: authManager.isUnlocked)
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: backendAuth.isLoggedIn)
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
