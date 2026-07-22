//
//  MainTabView.swift
//  Gestfina
//
//  Navigation premium — Floating Island Tab Bar + Bouton "+" Glass détaché (iOS 26 style)
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddTransaction = false
    @State private var showPaywall = false
    @EnvironmentObject var viewModel: FinanceViewModel
    @ObservedObject private var subManager = SubscriptionManager.shared

    let authManager: AuthenticationManager
    let notifManager: NotificationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - 1. Content Layer
            Group {
                switch selectedTab {
                case .home:
                    DashboardView(authManager: authManager, notifManager: notifManager)
                case .transactions:
                    TransactionsView()
                case .coach:
                    CoachView()
                case .budget:
                    BudgetView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: - 2. Floating Tab Bar + Detached Glass "+" Button
            FloatingIslandTabBar(selectedTab: $selectedTab) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if viewModel.transactions.count >= 25 && !subManager.isPremium {
                    showPaywall = true
                } else {
                    showAddTransaction = true
                }
            }
        }
        .ignoresSafeArea(.keyboard)
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
