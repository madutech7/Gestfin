//
//  DashboardView.swift
//  SamaXaalis — Design Apple Wallet / Health
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings = false
    @State private var balanceVisible = true
    @State private var animateIn = false
    @Environment(\.colorScheme) var colorScheme

    let authManager: AuthenticationManager
    let notifManager: NotificationManager

    // ─────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // 1 ▸ Carte Solde (Wallet-style)
                    balanceCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // 2 ▸ Tuiles Revenus / Dépenses (Health-style)
                    statTiles
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    // 3 ▸ Graphique Semaine
                    chartSection
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    // 4 ▸ Transactions Récentes
                    recentSection
                        .padding(.top, 12)

                    Spacer(minLength: 32)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Bonjour, \(viewModel.userName)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
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

    // ─────────────────────────────────────────────────────────────────
    // MARK: – Toolbar
    // ─────────────────────────────────────────────────────────────────
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 12) {
                Button {
                    Haptics.play(.light)
                    withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                } label: {
                    Image(systemName: balanceVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.secondary)
                }
                Button {
                    Haptics.play(.light)
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 1. Carte Solde (style Apple Wallet)
    // ─────────────────────────────────────────────────────────────────
    private var balanceCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Fond sombre (Wallet-inspired dark card)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark
                      ? Color(UIColor.secondarySystemBackground)
                      : Color(hex: "1C1C1E"))

            // Contenu
            VStack(alignment: .leading, spacing: 0) {
                // Ligne supérieure : label + chip épargne
                HStack(alignment: .firstTextBaseline) {
                    Text("Solde disponible")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.55))
                    Spacer()
                    // Capsule épargne
                    let rate = viewModel.savingsRate
                    HStack(spacing: 3) {
                        Image(systemName: rate >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(viewModel.formatPercentage(abs(rate)))")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(rate >= 0 ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (rate >= 0 ? Color(UIColor.systemGreen) : Color(UIColor.systemRed)).opacity(0.2)
                    )
                    .clipShape(Capsule())
                }
                .padding(.top, 22)

                // Montant principal
                Text(balanceVisible
                     ? viewModel.formatAmount(viewModel.totalBalance)
                     : "••••••")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.top, 6)

                Spacer(minLength: 20)

                // Séparateur
                Divider()
                    .overlay(Color.white.opacity(0.12))

                // Revenus / Dépenses inline
                HStack(spacing: 0) {
                    inlineStatView(
                        label: "Revenus",
                        value: viewModel.formatAmount(viewModel.totalIncome),
                        color: Color(UIColor.systemGreen)
                    )
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 1, height: 36)
                    inlineStatView(
                        label: "Dépenses",
                        value: viewModel.formatAmount(viewModel.totalExpenses),
                        color: Color(UIColor.systemRed)
                    )
                }
                .padding(.bottom, 18)
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 210)
        .shadow(color: Color.black.opacity(0.22), radius: 20, x: 0, y: 8)
        .scaleEffect(animateIn ? 1 : 0.96)
        .opacity(animateIn ? 1 : 0)
    }

    private func inlineStatView(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 3) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Text(value)
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 2. Tuiles statistiques (style Apple Health)
    // ─────────────────────────────────────────────────────────────────
    private var statTiles: some View {
        let expenses = viewModel.expensesByCategory.prefix(4)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Répartition")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)

            if expenses.isEmpty {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .frame(height: 80)
                    .overlay(
                        Label("Aucune dépense", systemImage: "chart.pie")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(expenses.enumerated()), id: \.element.category) { _, item in
                        categoryTile(item: item)
                    }
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }

    private func categoryTile(item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(item.category.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: item.category.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(item.category.color)
                }
                Spacer()
                Text("\(Int(item.percentage))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(item.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.category.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(viewModel.formatAmount(item.amount))
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            // Mini barre de progression
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.1)).frame(height: 4)
                    Capsule()
                        .fill(item.category.color)
                        .frame(width: geo.size.width * CGFloat(min(item.percentage / 100, 1)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 3. Graphique semaine
    // ─────────────────────────────────────────────────────────────────
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cette semaine")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Menu {
                    ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                        Button(period.rawValue) {
                            withAnimation { viewModel.selectedPeriod = period }
                        }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text(viewModel.selectedPeriod.rawValue)
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color(UIColor.systemBlue))
                }
            }
            .padding(.horizontal, 4)

            GlassBarChart(data: viewModel.dailyExpenses)
                .frame(height: 110)
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 4. Transactions Récentes (native List row)
    // ─────────────────────────────────────────────────────────────────
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Récentes")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Button("Voir tout") {}
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(UIColor.systemBlue))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            if viewModel.recentTransactions.isEmpty {
                Label("Appuyez sur + pour commencer", systemImage: "plus.circle")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 28)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 2)
                        if index < viewModel.recentTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassBarChart (épuré, pas de fond custom)
// ─────────────────────────────────────────────────────────────────────

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]

    private var maxAmount: Double { data.map(\.amount).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let isLast = index == data.count - 1
                let ratio = maxAmount > 0 ? CGFloat(item.amount / maxAmount) : 0

                VStack(spacing: 5) {
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(isLast
                                      ? Color(UIColor.systemBlue)
                                      : Color(UIColor.systemBlue).opacity(0.18))
                                .frame(height: max(geo.size.height * ratio, 5))
                        }
                    }
                    Text(item.day)
                        .font(.system(size: 10, weight: isLast ? .bold : .regular))
                        .foregroundStyle(isLast ? Color(UIColor.systemBlue) : .secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassCategoryRow (utilisé dans BudgetView)
// ─────────────────────────────────────────────────────────────────────

struct GlassCategoryRow: View {
    let category: TransactionCategory
    let amount: String
    let percentage: Double

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(category.color.opacity(0.14))
                    .frame(width: 36, height: 36)
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(category.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue).font(.subheadline.weight(.medium))
                    Spacer()
                    Text(amount).font(.subheadline.weight(.semibold)).fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.1)).frame(height: 4)
                        Capsule()
                            .fill(category.color)
                            .frame(width: geo.size.width * CGFloat(min(percentage / 100, 1)), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 3)
    }
}

#Preview {
    DashboardView(
        authManager: AuthenticationManager(),
        notifManager: NotificationManager()
    )
    .environmentObject(FinanceViewModel())
}
