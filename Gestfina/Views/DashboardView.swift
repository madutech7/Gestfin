//
//  DashboardView.swift
//  SamaXaalis
//
//  Design inspiré des applications Apple natives (Wallet, Santé, Réglages)
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings   = false
    @State private var balanceVisible = true
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // ── 1. CARTE STYLE APPLE WALLET ──
                    WalletCardHeader(viewModel: viewModel, balanceVisible: $balanceVisible)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // ── 2. ACTIONS RAPIDES ──
                    QuickActionsRow(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // ── 3. ACTIVITÉ (STYLE APPLE STOCKS) ──
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activité")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 24)
                        
                        ActivityChartCard(viewModel: viewModel)
                            .padding(.horizontal, 20)
                    }

                    // ── 4. CATÉGORIES (STYLE SANTÉ/RÉGLAGES) ──
                    if !viewModel.expensesByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dépenses")
                                .font(.title3.weight(.bold))
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.expensesByCategory.prefix(5).enumerated()), id: \.element.category) { index, item in
                                    CategoryAppleRow(item: item, viewModel: viewModel)
                                    if index < min(viewModel.expensesByCategory.count, 5) - 1 {
                                        Divider().padding(.leading, 64)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }

                    // ── 5. TRANSACTIONS RÉCENTES ──
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Récentes")
                            .font(.title3.weight(.bold))
                            .padding(.horizontal, 24)
                        
                        if viewModel.recentTransactions.isEmpty {
                            Text("Aucune transaction")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, t in
                                    TransactionRow(transaction: t)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                withAnimation { viewModel.deleteTransaction(t) }
                                            } label: {
                                                Label("Supprimer", systemImage: "trash")
                                            }
                                        }
                                    
                                    if index < viewModel.recentTransactions.count - 1 {
                                        Divider().padding(.leading, 64)
                                    }
                                }
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("SamaXaalis")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.secondary, Color(UIColor.secondarySystemFill))
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
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: – Composants
// ──────────────────────────────────────────────────────────────────

struct WalletCardHeader: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Binding var balanceVisible: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Solde total")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.8))
                    
                    Text(balanceVisible
                         ? viewModel.formatAmount(viewModel.totalBalance)
                         : "••••••••")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                } label: {
                    Image(systemName: balanceVisible ? "eye" : "eye.slash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark) // Force dark material
                        .clipShape(Circle())
                }
            }
            
            Spacer(minLength: 20)
            
            let rate = viewModel.savingsRate
            let positive = rate >= 0
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Variation")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .textCase(.uppercase)
                    
                    HStack(spacing: 4) {
                        Image(systemName: positive ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                        Text("\(positive ? "+" : "")\(viewModel.formatPercentage(rate))")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "applelogo")
                    Text("SamaXaalis")
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .padding(24)
        .frame(height: 210)
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 40/255, green: 40/255, blue: 45/255), Color(red: 20/255, green: 20/255, blue: 25/255)] // Dark Titanium
                    : [Color.black, Color(red: 40/255, green: 40/255, blue: 40/255)], // Sleek Black
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        // Effet de brillance subtil
        .overlay(
            LinearGradient(
                colors: [Color.white.opacity(0.2), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15), radius: 20, x: 0, y: 10)
    }
}

struct QuickActionsRow: View {
    @ObservedObject var viewModel: FinanceViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            actionCard(
                title: "Revenus",
                amount: viewModel.formatAmount(viewModel.totalIncome),
                icon: "arrow.down.left",
                color: .green
            )
            actionCard(
                title: "Dépenses",
                amount: viewModel.formatAmount(viewModel.totalExpenses),
                icon: "arrow.up.right",
                color: .red
            )
        }
    }
    
    private func actionCard(title: String, amount: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(amount)
                    .font(.subheadline.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct ActivityChartCard: View {
    @ObservedObject var viewModel: FinanceViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Chart(viewModel.dailyExpenses, id: \.day) { item in
                AreaMark(
                    x: .value("Jour", item.day),
                    y: .value("Montant", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.25), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value("Jour", item.day),
                    y: .value("Montant", item.amount)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel().font(.caption2.weight(.medium)).foregroundStyle(.secondary)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 150)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct CategoryAppleRow: View {
    let item: (category: TransactionCategory, amount: Double, percentage: Double)
    @ObservedObject var viewModel: FinanceViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(item.category.color)
                    .frame(width: 32, height: 32)
                Image(systemName: item.category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.category.rawValue)
                        .font(.body)
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.body.weight(.medium))
                        .fontDesign(.rounded)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        Capsule()
                            .fill(item.category.color)
                            .frame(width: geo.size.width * CGFloat(min(item.percentage / 100, 1)))
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – Anciens composants conservés pour StatisticsView / BudgetView
// ─────────────────────────────────────────────────────────────────────

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]
    private var maxAmount: Double { data.map(\.amount).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let isLast = index == data.count - 1
                let ratio  = maxAmount > 0 ? CGFloat(item.amount / maxAmount) : 0.05
                VStack(spacing: 5) {
                    GeometryReader { geo in
                        VStack { Spacer()
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(isLast ? Color(UIColor.systemBlue) : Color(UIColor.systemBlue).opacity(0.18))
                                .frame(height: max(geo.size.height * ratio, 5))
                        }
                    }
                    Text(item.day)
                        .font(.system(size: 10, weight: isLast ? .bold : .regular))
                        .foregroundStyle(isLast ? Color(UIColor.systemBlue) : Color.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct GlassCategoryRow: View {
    let category: TransactionCategory; let amount: String; let percentage: Double
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(category.color).frame(width: 30, height: 30)
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue).font(.subheadline.weight(.medium))
                    Spacer()
                    Text(amount).font(.subheadline.weight(.semibold)).fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(UIColor.systemFill)).frame(height: 3)
                        Capsule().fill(category.color)
                            .frame(width: geo.size.width * CGFloat(min(percentage / 100, 1)), height: 3)
                    }
                }.frame(height: 3)
            }
        }.padding(.vertical, 3)
    }
}

#Preview {
    DashboardView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
