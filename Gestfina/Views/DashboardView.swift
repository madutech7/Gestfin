//
//  DashboardView.swift
//  Gestfina
//
//  Tableau de bord — Style iOS natif professionnel, adaptive Light/Dark
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var animateIn = false
    @State private var balanceVisible = true
    @State private var showSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    let authManager: AuthenticationManager
    let notifManager: NotificationManager
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Solde principal
                    balanceSection
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    // Revenus / Dépenses
                    flowCardsRow
                        .padding(.horizontal, 20)
                    
                    // Graphique
                    weeklyChartSection
                        .padding(.horizontal, 20)
                    
                    // Catégories
                    categoryBreakdown
                        .padding(.horizontal, 20)
                    
                    // Transactions récentes
                    recentTransactionsSection
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Bonjour, \(viewModel.userName)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            Haptics.play(.light)
                            withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                        } label: {
                            Image(systemName: balanceVisible ? "eye" : "eye.slash")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Button {
                            Haptics.play(.light)
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                    animateIn = true
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView(authManager: authManager, notifManager: notifManager)
                    .environmentObject(viewModel)
            }
        }
    }
    
    // MARK: - Solde Principal
    
    private var balanceSection: some View {
        VStack(spacing: 8) {
            Text("Solde total")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(balanceVisible ? viewModel.formatAmount(viewModel.totalBalance) : "••••••")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: viewModel.totalBalance)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            
            // Taux d'épargne pill
            HStack(spacing: 5) {
                Image(systemName: viewModel.savingsRate >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                Text("\(viewModel.formatPercentage(abs(viewModel.savingsRate))) d'épargne")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(viewModel.savingsRate >= 0 ? Color(hex: "34C759") : Color(hex: "FF3B30"))
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background((viewModel.savingsRate >= 0 ? Color(hex: "34C759") : Color(hex: "FF3B30")).opacity(0.1))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .scaleEffect(animateIn ? 1 : 0.95)
        .opacity(animateIn ? 1 : 0)
    }
    
    // MARK: - Revenus / Dépenses Cards
    
    private var flowCardsRow: some View {
        HStack(spacing: 12) {
            flowCard(
                title: "Revenus",
                amount: viewModel.formatAmount(viewModel.totalIncome),
                icon: "arrow.down.left",
                color: Color(hex: "34C759")
            )
            flowCard(
                title: "Dépenses",
                amount: viewModel.formatAmount(viewModel.totalExpenses),
                icon: "arrow.up.right",
                color: Color(hex: "FF3B30")
            )
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 15)
    }
    
    private func flowCard(title: String, amount: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(amount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .frame(maxWidth: .infinity)
    }
    

    
    // MARK: - Graphique hebdomadaire
    
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cette semaine")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Menu {
                    ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                        Button(period.rawValue) {
                            withAnimation { viewModel.selectedPeriod = period }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedPeriod.rawValue)
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.appBlue)
                }
            }
            
            GlassBarChart(data: viewModel.dailyExpenses)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Catégories
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dépenses par catégorie")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if viewModel.expensesByCategory.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("Aucune dépense enregistrée")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 24)
            } else {
                ForEach(viewModel.expensesByCategory.prefix(5), id: \.category) { item in
                    GlassCategoryRow(
                        category: item.category,
                        amount: viewModel.formatAmount(item.amount),
                        percentage: item.percentage
                    )
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Transactions récentes
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Récentes")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                Text("Voir tout")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.appBlue)
            }
            
            if viewModel.recentTransactions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("Aucune transaction")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Appuyez sur + pour commencer")
                            .font(.system(size: 13))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                            .padding(.vertical, 8)
                        
                        if index < viewModel.recentTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Glass Bar Chart

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]
    @Environment(\.colorScheme) var colorScheme
    
    private var maxAmount: Double {
        data.map(\.amount).max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(data.indices, id: \.self) { index in
                let isLast = index == data.count - 1
                let height = maxAmount > 0 ? max(CGFloat(data[index].amount / maxAmount) * 110, 6) : 6
                
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isLast
                            ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appCyan], startPoint: .bottom, endPoint: .top))
                            : AnyShapeStyle(Color.secondary.opacity(0.15))
                        )
                        .frame(height: height)
                        .shadow(color: isLast ? Color.appBlue.opacity(0.3) : .clear, radius: 6, y: 3)
                    
                    Text(data[index].day)
                        .font(.system(size: 10, weight: isLast ? .bold : .medium))
                        .foregroundColor(isLast ? .appBlue : .secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 140)
    }
}

// MARK: - Category Row

struct GlassCategoryRow: View {
    let category: TransactionCategory
    let amount: String
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(category.color.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: category.icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(category.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Spacer()
                    Text(amount)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 5)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(colors: [category.color, category.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(percentage / 100), height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
    }
}

#Preview {
    DashboardView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
