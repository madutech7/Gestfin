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
        .onChange(of: scenePhase) { phase in
            switch phase {
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
