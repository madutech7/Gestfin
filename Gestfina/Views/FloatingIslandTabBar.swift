//
//  FloatingIslandTabBar.swift
//  Gestfina
//
//  Created by Antigravity on 2026-06-04.
//  Design: Floating Island + Detached FAB (Apple-tier UX)
//

import SwiftUI

/// Représente les onglets de l'application
enum Tab: String, CaseIterable {
    case home = "house"
    case transactions = "arrow.left.arrow.right"
    case coach = "sparkles"
    case budget = "chart.pie"
    
    var title: String {
        switch self {
        case .home: return "Accueil"
        case .transactions: return "Transactions"
        case .coach: return "SamaCoach"
        case .budget: return "Budget"
        }
    }
}

struct FloatingIslandTabBar: View {
    @Binding var selectedTab: Tab
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Floating Island (Main Bar)
            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                        hapticFeedback(.light)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? "\(tab.rawValue).fill" : tab.rawValue)
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text(tab.title)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 70)
            .background(.ultraThinMaterial) // Apple style blur
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // MARK: - Detached FAB (+)
            Button {
                hapticFeedback(.medium)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                    action()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { isPressed = false }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(LinearGradient(colors: [.accentColor, .accentColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .scaleEffect(isPressed ? 0.85 : 1.0)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24) // Spacing from bottom
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Integration Example (ZStack Layout)
struct MainContainerView: View {
    @State private var currentTab: Tab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Content Layer
            Group {
                switch currentTab {
                case .home:
                    DashboardContent()
                case .transactions:
                    TransactionsContent()
                case .coach:
                    CoachContent()
                case .budget:
                    BudgetContent()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 2. Navigation Layer (Floating)
            FloatingIslandTabBar(selectedTab: $currentTab) {
                print("Action button tapped!")
            }
        }
        .ignoresSafeArea(.keyboard) // Important for FAB UX
    }
}

// MARK: - Placeholder Contents for Demo
struct DashboardContent: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tableau de Bord")
                    .font(.largeTitle.bold())
                    .padding(.top, 60)
                
                ForEach(1...20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 100)
                        .overlay(Text("Transaction #\(i)").foregroundColor(.secondary))
                }
            }
            .padding()
        }
    }
}

struct TransactionsContent: View { var body: some View { Text("Historique").font(.title) } }
struct CoachContent: View { var body: some View { Text("SamaCoach AI").font(.title) } }
struct BudgetContent: View { var body: some View { Text("Budgets").font(.title) } }

#Preview {
    MainContainerView()
}
