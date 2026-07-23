//
//  MainTabView.swift
//  Gestfina
//
//  Navigation premium avec Tab Bar natif — Design Apple-tier
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showAddTransaction = false
    @State private var showPaywall = false
    @EnvironmentObject var viewModel: FinanceViewModel
    @ObservedObject private var subManager = SubscriptionManager.shared

    let authManager: AuthenticationManager
    let notifManager: NotificationManager

    enum AppTab: String, CaseIterable {
        case dashboard    = "Accueil"
        case transactions = "Transactions"
        case coach        = "Coach IA"
        case budget       = "Budget"
        case add          = "Ajouter"
    }

    init(authManager: AuthenticationManager, notifManager: NotificationManager) {
        self.authManager  = authManager
        self.notifManager = notifManager

        // Premium tab bar appearance
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
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if viewModel.transactions.count >= 25 && !subManager.isPremium {
                        showPaywall = true
                    } else {
                        showAddTransaction = true
                    }
                } else {
                    if newTab != selectedTab {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    selectedTab = newTab
                }
            }
        )) {
            DashboardView(authManager: authManager, notifManager: notifManager)
                .tabItem {
                    Label(L10n.tabHome, systemImage: selectedTab == .dashboard ? "house.fill" : "house")
                }
                .tag(AppTab.dashboard)

            TransactionsView()
                .tabItem {
                    Label(L10n.tabTransactions, systemImage: "arrow.left.arrow.right")
                }
                .tag(AppTab.transactions)

            CoachView()
                .tabItem {
                    Label(L10n.tabCoach, systemImage: "sparkles")
                }
                .tag(AppTab.coach)

            BudgetView()
                .tabItem {
                    Label(L10n.tabBudget, systemImage: selectedTab == .budget ? "chart.pie.fill" : "chart.pie")
                }
                .tag(AppTab.budget)

            // "+" trigger tab (last position)
            Color.clear
                .tabItem {
                    Label(L10n.tabAdd, systemImage: "plus.circle.fill")
                }
                .tag(AppTab.add)
        }
        .tint(.appBlue)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    MainTabView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
