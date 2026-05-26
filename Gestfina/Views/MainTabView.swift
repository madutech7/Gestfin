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
        case coach        = "SamaCoach"
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
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(authManager: authManager, notifManager: notifManager)
                    .tag(AppTab.dashboard)
                    .toolbar(.hidden, for: .tabBar)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }

                TransactionsView()
                    .tag(AppTab.transactions)
                    .toolbar(.hidden, for: .tabBar)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }

                CoachView()
                    .tag(AppTab.coach)
                    .toolbar(.hidden, for: .tabBar)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }

                BudgetView()
                    .tag(AppTab.budget)
                    .toolbar(.hidden, for: .tabBar)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }
            }
            .ignoresSafeArea()

            customFloatingTabBar
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

    // MARK: - Custom Floating Tab Bar
    
    private var customFloatingTabBar: some View {
        HStack(spacing: 12) {
            // Main Island: Tabs
            HStack(spacing: 0) {
                ForEach([AppTab.dashboard, .transactions, .coach, .budget], id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(8)
            .liquidGlassFloating(cornerRadius: 32)
            
            // Separate Island: Add Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                if viewModel.transactions.count >= 25 && !subManager.isPremium {
                    showPaywall = true
                } else {
                    showAddTransaction = true
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 54, height: 54)
                    .liquidGlassFloating(cornerRadius: 27) // Round for circle look
            }
        }
        .floating() // Restore liquid floating animation
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        
        Button {
            if !isSelected {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: iconName(for: tab, isSelected: isSelected))
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .foregroundColor(isSelected ? .appBlue : .textSecondary)
            .padding(.horizontal, 4)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.appBlue.opacity(0.12))
                        .matchedGeometryEffect(id: "tabSelection", in: animationNamespace)
                }
            }
        }
    }

    @Namespace private var animationNamespace

    private func iconName(for tab: AppTab, isSelected: Bool) -> String {
        switch tab {
        case .dashboard:    return isSelected ? "house.fill" : "house"
        case .transactions: return "arrow.left.arrow.right"
        case .coach:        return isSelected ? "sparkles" : "sparkles"
        case .budget:       return isSelected ? "chart.pie.fill" : "chart.pie"
        case .add:          return "plus.circle.fill"
        }
    }
}

#Preview {
    MainTabView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
