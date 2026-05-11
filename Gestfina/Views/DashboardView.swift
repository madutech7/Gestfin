//
//  DashboardView.swift
//  SamaXaalis
//
//  Design Apple HIG — Wallet / Santé style
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
            List {
                // ── SECTION 1 : Solde ──────────────────────────────────
                Section {
                    balanceCell
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                // ── SECTION 2 : Flux ───────────────────────────────────
                Section {
                    HStack(spacing: 0) {
                        flowCell(
                            title: "Revenus",
                            value: viewModel.formatAmount(viewModel.totalIncome),
                            icon: "arrow.down.left",
                            color: .appGreen
                        )
                        Divider().frame(height: 44)
                        flowCell(
                            title: "Dépenses",
                            value: viewModel.formatAmount(viewModel.totalExpenses),
                            icon: "arrow.up.right",
                            color: .appRed
                        )
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                // ── SECTION 3 : Graphique ──────────────────────────────
                Section(header: sectionHeader("Cette semaine", trailingMenu: periodMenu)) {
                    GlassBarChart(data: viewModel.dailyExpenses)
                        .frame(height: 130)
                        .padding(.vertical, 8)
                }

                // ── SECTION 4 : Catégories ─────────────────────────────
                Section(header: sectionHeader("Par catégorie", trailingMenu: nil)) {
                    if viewModel.expensesByCategory.isEmpty {
                        emptyCategoryCell
                    } else {
                        ForEach(viewModel.expensesByCategory.prefix(5), id: \.category) { item in
                            categoryCell(item: item)
                        }
                    }
                }

                // ── SECTION 5 : Transactions récentes ─────────────────
                Section(header: sectionHeader("Récentes", trailingMenu: nil)) {
                    if viewModel.recentTransactions.isEmpty {
                        emptyTransactionCell
                    } else {
                        ForEach(viewModel.recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Bonjour, \(viewModel.userName)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 14) {
                        Button {
                            Haptics.play(.light)
                            withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                        } label: {
                            Image(systemName: balanceVisible ? "eye" : "eye.slash")
                                .foregroundStyle(Color.secondary)
                        }
                        Button {
                            Haptics.play(.light)
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(Color.secondary)
                        }
                    }
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

    // ── MARK: Solde Cell ─────────────────────────────────────────────

    private var balanceCell: some View {
        VStack(spacing: 4) {
            Text("Solde total")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(balanceVisible
                 ? viewModel.formatAmount(viewModel.totalBalance)
                 : "••••••")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            // Indicateur épargne
            let saving = viewModel.savingsRate
            HStack(spacing: 4) {
                Image(systemName: saving >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .semibold))
                Text("\(viewModel.formatPercentage(abs(saving))) d'épargne")
                    .font(.footnote.weight(.medium))
            }
            .foregroundStyle(saving >= 0 ? Color.appGreen : Color.appRed)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background((saving >= 0 ? Color.appGreen : Color.appRed).opacity(0.1))
            .clipShape(Capsule())
            .padding(.top, 2)
        }
        .padding(.vertical, 20)
    }

    // ── MARK: Flow Cells ─────────────────────────────────────────────

    private func flowCell(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
            Text(value)
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // ── MARK: Section Header ─────────────────────────────────────────

    private func sectionHeader(_ title: String, trailingMenu: AnyView?) -> some View {
        HStack {
            Text(title)
            Spacer()
            trailingMenu
        }
    }

    private var periodMenu: AnyView {
        AnyView(
            Menu {
                ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                    Button(period.rawValue) {
                        withAnimation { viewModel.selectedPeriod = period }
                    }
                }
            } label: {
                Text(viewModel.selectedPeriod.rawValue)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.appBlue)
            }
        )
    }

    // ── MARK: Category Cell ──────────────────────────────────────────

    private func categoryCell(item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        HStack(spacing: 14) {
            // Icône
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.category.color.opacity(0.14))
                    .frame(width: 38, height: 38)
                Image(systemName: item.category.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(item.category.color)
            }

            // Nom + barre
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.category.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.primary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.1))
                            .frame(height: 5)
                        Capsule()
                            .fill(item.category.color)
                            .frame(width: geo.size.width * CGFloat(min(item.percentage, 100) / 100), height: 5)
                            .animation(.spring(response: 0.6), value: item.percentage)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(.vertical, 4)
    }

    // ── MARK: Empty States ───────────────────────────────────────────

    private var emptyCategoryCell: some View {
        Label("Aucune dépense enregistrée", systemImage: "chart.pie")
            .foregroundStyle(Color.secondary)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 12)
    }

    private var emptyTransactionCell: some View {
        Label("Appuyez sur + pour commencer", systemImage: "plus.circle")
            .foregroundStyle(Color.secondary)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 12)
    }
}

// ── MARK: GlassBarChart ──────────────────────────────────────────────

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]
    @Environment(\.colorScheme) var colorScheme

    private var maxAmount: Double { data.map(\.amount).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let isLast = index == data.count - 1
                let height = maxAmount > 0 ? max(CGFloat(item.amount / maxAmount) * 100, 6) : 6

                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isLast ? Color.appBlue : Color.secondary.opacity(0.15))
                        .frame(height: height)
                        .animation(.spring(response: 0.5), value: item.amount)

                    Text(item.day)
                        .font(.system(size: 10, weight: isLast ? .bold : .regular))
                        .foregroundStyle(isLast ? Color.appBlue : Color.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// ── MARK: GlassCategoryRow (Dashboard compact) ───────────────────────

struct GlassCategoryRow: View {
    let category: TransactionCategory
    let amount: String
    let percentage: Double

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(category.color.opacity(0.14))
                    .frame(width: 38, height: 38)
                Image(systemName: category.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(category.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(amount)
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.secondary.opacity(0.1)).frame(height: 5)
                        Capsule()
                            .fill(category.color)
                            .frame(width: geo.size.width * CGFloat(min(percentage, 100) / 100), height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(.vertical, 3)
    }
}

#Preview {
    DashboardView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
