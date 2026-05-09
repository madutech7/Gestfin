//
//  MainTabView.swift
//  Gestfina
//
//  Navigation Liquid Glass — Style iOS 26
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showAddTransaction = false
    @State private var tabBarVisible = true
    @EnvironmentObject var viewModel: FinanceViewModel
    
    enum Tab: String, CaseIterable {
        case dashboard = "Accueil"
        case transactions = "Transactions"
        case add = ""
        case budget = "Budget"
        case statistics = "Stats"
        
        var icon: String {
            switch self {
            case .dashboard: return "house"
            case .transactions: return "arrow.left.arrow.right"
            case .add: return "plus"
            case .budget: return "chart.pie"
            case .statistics: return "chart.bar.xaxis"
            }
        }
        
        var iconFilled: String {
            switch self {
            case .dashboard: return "house.fill"
            case .transactions: return "arrow.left.arrow.right"
            case .add: return "plus"
            case .budget: return "chart.pie.fill"
            case .statistics: return "chart.bar.xaxis"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Fond mesh gradient
            meshBackground
            
            // Contenu principal
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .transactions:
                    TransactionsView()
                case .add:
                    Color.clear
                case .budget:
                    BudgetView()
                case .statistics:
                    StatisticsView()
                }
            }
            .padding(.bottom, 100)
            
            // Tab Bar Liquid Glass flottant
            if tabBarVisible {
                liquidGlassTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }
    
    // MARK: - Mesh Background
    
    private var meshBackground: some View {
        ZStack {
            Color.backgroundPrimary
            
            // Orbe violette en haut à droite
            Circle()
                .fill(Color.appPurple.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 120, y: -200)
            
            // Orbe bleue en bas à gauche
            Circle()
                .fill(Color.appBlue.opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: -100, y: 300)
            
            // Orbe subtile verte
            Circle()
                .fill(Color.appGreen.opacity(0.04))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 50, y: 100)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Liquid Glass Tab Bar
    
    private var liquidGlassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .add {
                    // Bouton central "+" Liquid Glass
                    addButton
                } else {
                    tabButton(for: tab)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .liquidGlassFloating(cornerRadius: 28)
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
    
    // MARK: - Tab Button
    
    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Glow derrière l'icône active
                    if selectedTab == tab {
                        Circle()
                            .fill(Color.appBlue.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .blur(radius: 8)
                    }
                    
                    Image(systemName: selectedTab == tab ? tab.iconFilled : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(
                            selectedTab == tab
                            ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.textTertiary)
                        )
                        .symbolEffect(.bounce.byLayer, value: selectedTab == tab)
                }
                .frame(height: 28)
                
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? .appBlue : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                Group {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.06))
                            .padding(.horizontal, 4)
                    }
                }
            )
        }
    }
    
    // MARK: - Bouton "+"
    
    private var addButton: some View {
        Button {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            showAddTransaction = true
        } label: {
            ZStack {
                // Glow externe
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.appBlue.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 36
                        )
                    )
                    .frame(width: 72, height: 72)
                
                // Cercle glass
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appBlue.opacity(0.3), Color.appPurple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
                    .shadow(color: Color.appBlue.opacity(0.3), radius: 12, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
            }
            .offset(y: -16)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
        .environmentObject(FinanceViewModel())
        .preferredColorScheme(.dark)
}
