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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Balance Hero Card
                    balanceHeroCard
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Quick Stats
                    quickStatsRow
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Graphique
                    weeklyChartSection
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Catégories
                    categoryBreakdown
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Transactions récentes
                    recentTransactionsSection
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    Spacer(minLength: 40)
                }
            }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Bonjour, \(viewModel.userName) 👋")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                    } label: {
                        Image(systemName: balanceVisible ? "eye" : "eye.slash")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                    animateIn = true
                }
            }
        }
    }
    
    // MARK: - Balance Hero Card (Ultra Premium)
    
    private var balanceHeroCard: some View {
        ZStack {
            // Fond dégradé dynamique (Apple Card style)
            LinearGradient(
                colors: [Color(hex: "00C6FF"), Color(hex: "0072FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Texture / Orbes
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 250, height: 250)
                .blur(radius: 40)
                .offset(x: 100, y: -80)
            
            Circle()
                .fill(Color.appPurple.opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -80, y: 100)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Solde Total")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(balanceVisible ? viewModel.formatAmount(viewModel.totalBalance) : "••••••")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3), value: viewModel.totalBalance)
                    }
                    Spacer()
                    // Puce / Icône de carte
                    Image(systemName: "contactless.radiowaves.right")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(-90))
                }
                
                Spacer()
                
                // Taux d'épargne
                HStack(spacing: 8) {
                    Image(systemName: viewModel.savingsRate >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.formatPercentage(abs(viewModel.savingsRate))) d'épargne")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Gestfina")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.15))
                .background(Material.ultraThinMaterial.opacity(0.3))
                .clipShape(Capsule())
            }
            .padding(28)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color(hex: "0072FF").opacity(0.4), radius: 24, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(animateIn ? 1 : 0.92)
        .opacity(animateIn ? 1 : 0)
        .shimmer()
        // Effet de survol / parallaxe subtil
        .rotation3DEffect(.degrees(animateIn ? 0 : 8), axis: (x: 1, y: 0.5, z: 0))
    }
    
    // MARK: - Stats rapides
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Revenus",
                amount: viewModel.formatAmount(viewModel.totalIncome),
                icon: "arrow.down.left",
                color: .appGreen
            )
            statCard(
                title: "Dépenses",
                amount: viewModel.formatAmount(viewModel.totalExpenses),
                icon: "arrow.up.right",
                color: .appRed
            )
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }
    
    private func statCard(title: String, amount: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(amount)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Graphique hebdomadaire
    
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cette semaine")
                    .font(.system(size: 17, weight: .semibold))
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
            Text("Par catégorie")
                .font(.system(size: 17, weight: .semibold))
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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Voir tout")
                    .font(.system(size: 14, weight: .medium))
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
                            ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .bottom, endPoint: .top))
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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(amount)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
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
    DashboardView()
        .environmentObject(FinanceViewModel())
}
