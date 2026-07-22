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
        case .home: return L10n.tabHome
        case .transactions: return L10n.tabTransactions
        case .coach: return L10n.tabCoach
        case .budget: return L10n.tabBudget
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
            
            // MARK: - Detached FAB (+) — Liquid Glass Style (iOS 26)
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
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 60, height: 60)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                    )
                    .scaleEffect(isPressed ? 0.85 : 1.0)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
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


#Preview {
    struct PreviewWrapper: View {
        @State var tab: Tab = .home
        var body: some View {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                FloatingIslandTabBar(selectedTab: $tab) {}
            }
        }
    }
    return PreviewWrapper()
}

