//
//  MainTabView.swift
//  Gestfina
//
//  Navigation native avec Tab Bar transparent (effet Contacts/Téléphone)
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showAddTransaction = false
    @EnvironmentObject var viewModel: FinanceViewModel
    
    enum Tab: String, CaseIterable {
        case dashboard = "Accueil"
        case transactions = "Transactions"
        case add = "Ajouter"
        case budget = "Budget"
        case statistics = "Stats"
        
        var icon: String {
            switch self {
            case .dashboard: return "house"
            case .transactions: return "arrow.left.arrow.right"
            case .add: return "plus.circle.fill"
            case .budget: return "chart.pie"
            case .statistics: return "chart.bar.xaxis"
            }
        }
        
        var iconFilled: String {
            switch self {
            case .dashboard: return "house.fill"
            case .transactions: return "arrow.left.arrow.right"
            case .add: return "plus.circle.fill"
            case .budget: return "chart.pie.fill"
            case .statistics: return "chart.bar.xaxis"
            }
        }
    }
    
    init() {
        // Apparence native iOS pour la Tab Bar (transparence et effet de flou)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // Effet "Liquid Glass" natif
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { newTab in
                if newTab == .add {
                    showAddTransaction = true
                } else {
                    selectedTab = newTab
                }
            }
        )) {
            DashboardView()
                .tabItem {
                    Label(Tab.dashboard.rawValue, systemImage: selectedTab == .dashboard ? Tab.dashboard.iconFilled : Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)
            
            TransactionsView()
                .tabItem {
                    Label(Tab.transactions.rawValue, systemImage: selectedTab == .transactions ? Tab.transactions.iconFilled : Tab.transactions.icon)
                }
                .tag(Tab.transactions)
            
            // Onglet Ajouter
            Color.clear
                .tabItem {
                    Label(Tab.add.rawValue, systemImage: Tab.add.icon)
                }
                .tag(Tab.add)
            
            BudgetView()
                .tabItem {
                    Label(Tab.budget.rawValue, systemImage: selectedTab == .budget ? Tab.budget.iconFilled : Tab.budget.icon)
                }
                .tag(Tab.budget)
            
            StatisticsView()
                .tabItem {
                    Label(Tab.statistics.rawValue, systemImage: selectedTab == .statistics ? Tab.statistics.iconFilled : Tab.statistics.icon)
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
    MainTabView()
        .environmentObject(FinanceViewModel())
}

