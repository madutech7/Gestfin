//
//  DashboardView.swift
//  Gestfina
//
//  Tableau de bord Liquid Glass
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var animateIn = false
    @State private var balanceVisible = true
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    balanceCard
                    quickStatsRow
                    weeklyChartSection
                    categoryBreakdown
                    recentTransactionsSection
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.clear)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                    animateIn = true
                }
            }
        }
    }
    
    // MARK: - En-tête
    
    private var headerSection: some View {
        HStack(spacing: 14) {
            // Avatar Liquid Glass
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle().stroke(Color.glassBorder, lineWidth: 0.6)
                    )
                
                Text(String(viewModel.userName.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.gradientPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Bonjour 👋")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.userName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            // Bouton notif glass
            Button { } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 42, height: 42)
                        .overlay(Circle().stroke(Color.glassBorder, lineWidth: 0.6))
                    
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    // Badge
                    Circle()
                        .fill(Color.appRed)
                        .frame(width: 8, height: 8)
                        .offset(x: 6, y: -6)
                }
            }
        }
        .padding(.top, 16)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : -10)
    }
    
    // MARK: - Carte de solde Liquid Glass
    
    private var balanceCard: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Solde Total")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        balanceVisible.toggle()
                    }
                } label: {
                    Image(systemName: balanceVisible ? "eye" : "eye.slash")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.06)))
                }
            }
            
            Text(balanceVisible ? viewModel.formatAmount(viewModel.totalBalance) : "••••••")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())
            
            // Taux d'épargne pill
            HStack(spacing: 6) {
                Image(systemName: viewModel.savingsRate >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                
                Text("\(viewModel.formatPercentage(abs(viewModel.savingsRate))) d'épargne ce mois")
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(viewModel.savingsRate >= 0 ? Color.appGreen.opacity(0.15) : Color.appRed.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(viewModel.savingsRate >= 0 ? Color.appGreen.opacity(0.2) : Color.appRed.opacity(0.2), lineWidth: 0.5)
            )
            .foregroundColor(viewModel.savingsRate >= 0 ? .appGreen : .appRed)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .liquidGlass(cornerRadius: 28, opacity: 0.10)
        .animatedGlassBorder(cornerRadius: 28, colors: [.appBlue.opacity(0.6), .appPurple.opacity(0.4), .appCyan.opacity(0.3), .appBlue.opacity(0.6)])
        .scaleEffect(animateIn ? 1 : 0.92)
        .opacity(animateIn ? 1 : 0)
    }
    
    // MARK: - Stats rapides
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            glassStatCard(
                title: "Revenus",
                amount: viewModel.formatAmount(viewModel.totalIncome),
                icon: "arrow.down.left",
                color: .appGreen
            )
            
            glassStatCard(
                title: "Dépenses",
                amount: viewModel.formatAmount(viewModel.totalExpenses),
                icon: "arrow.up.right",
                color: .appRed
            )
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 20)
    }
    
    private func glassStatCard(title: String, amount: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                }
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.textSecondary)
            
            Text(amount)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 20, opacity: 0.06)
    }
    
    // MARK: - Graphique hebdomadaire
    
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cette semaine")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
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
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.appBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .liquidGlassButton(isActive: true, activeColor: .appBlue)
                }
            }
            
            // Barres glass
            GlassBarChart(data: viewModel.dailyExpenses)
        }
        .padding(20)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Catégories
    
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Par catégorie")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            if viewModel.expensesByCategory.isEmpty {
                Text("Aucune dépense")
                    .font(.system(size: 14))
                    .foregroundColor(.textTertiary)
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
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
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Transactions récentes
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Récentes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("Voir tout →")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appBlue)
            }
            
            ForEach(viewModel.recentTransactions) { transaction in
                TransactionRow(transaction: transaction)
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 24)
    }
}

// MARK: - Glass Bar Chart

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]
    
    private var maxAmount: Double {
        data.map(\.amount).max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(data.indices, id: \.self) { index in
                let isLast = index == data.count - 1
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isLast
                            ? AnyShapeStyle(LinearGradient(colors: [Color.appBlue, Color.appPurple], startPoint: .bottom, endPoint: .top))
                            : AnyShapeStyle(Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isLast ? Color.appBlue.opacity(0.4) : Color.white.opacity(0.06),
                                    lineWidth: 0.5
                                )
                        )
                        .frame(height: maxAmount > 0 ? max(CGFloat(data[index].amount / maxAmount) * 110, 6) : 6)
                        .shadow(color: isLast ? Color.appBlue.opacity(0.3) : .clear, radius: 8, y: 4)
                    
                    Text(data[index].day)
                        .font(.system(size: 10, weight: isLast ? .bold : .medium))
                        .foregroundColor(isLast ? .appBlue : .textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 140)
    }
}

// MARK: - Glass Category Row

struct GlassCategoryRow: View {
    let category: TransactionCategory
    let amount: String
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(category.color.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(category.color.opacity(0.15), lineWidth: 0.5))
                    .frame(width: 38, height: 38)
                
                Image(systemName: category.icon)
                    .font(.system(size: 15))
                    .foregroundColor(category.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text(amount)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.04))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(colors: [category.color, category.color.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(percentage / 100), height: 4)
                            .shadow(color: category.color.opacity(0.4), radius: 4, y: 1)
                    }
                }.frame(height: 4)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        DashboardView()
    }
    .environmentObject(FinanceViewModel())
    .preferredColorScheme(.dark)
}
