//
//  MainTabView.swift
//  Gestfina
//
//  Navigation native avec Tab Bar — 5 onglets + Réglages
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showAddTransaction = false
    @EnvironmentObject var viewModel: FinanceViewModel
    
    let authManager: AuthenticationManager
    let notifManager: NotificationManager
    
    enum Tab: String, CaseIterable {
        case dashboard    = "Accueil"
        case transactions = "Transactions"
        case add          = "Ajouter"
        case budget       = "Budget"
        case statistics   = "Stats"
    }
    
    init(authManager: AuthenticationManager, notifManager: NotificationManager) {
        self.authManager  = authManager
        self.notifManager = notifManager
        
        // Tab Bar apparence native (translucide avec flou iOS)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { newTab in
                if newTab == .add {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    showAddTransaction = true
                } else {
                    selectedTab = newTab
                }
            }
        )) {
            DashboardView()
                .tabItem {
                    Label("Accueil", systemImage: selectedTab == .dashboard ? "house.fill" : "house")
                }
                .tag(Tab.dashboard)
            
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "arrow.left.arrow.right")
                }
                .tag(Tab.transactions)
            
            // Onglet central "+" déclencheur
            Color.clear
                .tabItem {
                    Label("Ajouter", systemImage: "plus.circle.fill")
                }
                .tag(Tab.add)
            
            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: selectedTab == .budget ? "chart.pie.fill" : "chart.pie")
                }
                .tag(Tab.budget)
            
            SettingsView(authManager: authManager, notifManager: notifManager)
                .tabItem {
                    Label("Réglages", systemImage: selectedTab == .statistics ? "gearshape.fill" : "gearshape")
                }
                .tag(Tab.statistics)
        }
        .tint(.appBlue)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }
}

#Preview {
    MainTabView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
