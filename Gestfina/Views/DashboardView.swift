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
                VStack(spacing: 0) {
                    // Wave-style gradient header
                    headerSection
                    
                    // Quick Stats
                    quickStatsRow
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
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
            .background(Color(UIColor.systemGroupedBackground))
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
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
    
    // MARK: - Header Section (Wave-inspired)
    
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Grand fond gradient
            LinearGradient(
                colors: [Color(hex: "007AFF"), Color(hex: "0A84FF"), Color(hex: "34AADC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 340)
            .overlay(
                // Orbes décoratifs subtils
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                        .offset(x: 120, y: -60)
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 160, height: 160)
                        .blur(radius: 25)
                        .offset(x: -100, y: 40)
                }
            )
            
            VStack(spacing: 0) {
                // Top bar: gear + nom + eye
                HStack {
                    Button {
                        Haptics.play(.light)
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("SamaXaalis")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        Haptics.play(.light)
                        withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                    } label: {
                        Image(systemName: balanceVisible ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Balance card flottante
                balanceCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, -30)
            }
            .frame(height: 340)
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Balance Card
    
    private var balanceCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Solde Total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(balanceVisible ? viewModel.formatAmount(viewModel.totalBalance) : "••••••")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: viewModel.totalBalance)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            HStack(spacing: 12) {
                // Revenus
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.left.circle.fill")
                        .foregroundColor(.appGreen)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Revenus")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.formatAmount(viewModel.totalIncome))
                            .font(.caption)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 30)
                
                // Dépenses
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundColor(.appRed)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Dépenses")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.formatAmount(viewModel.totalExpenses))
                            .font(.caption)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 30)
                
                // Épargne
                HStack(spacing: 6) {
                    Image(systemName: viewModel.savingsRate >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                        .foregroundColor(viewModel.savingsRate >= 0 ? .appGreen : .appRed)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Épargne")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(viewModel.formatPercentage(abs(viewModel.savingsRate)))
                            .font(.caption)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
        .scaleEffect(animateIn ? 1 : 0.92)
        .opacity(animateIn ? 1 : 0)
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
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(amount)
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
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
