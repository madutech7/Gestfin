//
//  DashboardView.swift
//  SamaXaalis
//
//  Design identique aux apps Apple (Stocks · Santé · Wallet)
//  — AreaMark chart, subtitle date, icônes Réglages-style, swipe actions
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings   = false
    @State private var balanceVisible = true
    @State private var animateIn      = false
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager

    // ────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationView {
            List {

                // ── 1. Solde + variation mensuelle ──────────────────
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Solde total")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .textCase(nil)

                        // Montant principal — 52 pt (style Stocks)
                        Text(balanceVisible
                             ? viewModel.formatAmount(viewModel.totalBalance)
                             : "••••••••")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)

                        // Variation mois (style Stocks "+500 XOF · +12,5 %")
                        let rate     = viewModel.savingsRate
                        let positive = rate >= 0
                        HStack(spacing: 6) {
                            Image(systemName: positive ? "arrow.up.right" : "arrow.down.right")
                                .imageScale(.small)
                                .fontWeight(.semibold)
                            Text("\(viewModel.formatAmount(viewModel.totalIncome - viewModel.totalExpenses))  ·  \(positive ? "+" : "")\(viewModel.formatPercentage(rate))")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(positive ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                        .padding(.top, 2)
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color.clear)
                }
                .listSectionSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

                // ── 2. Area chart (style Apple Stocks) ──────────────
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        // Sélecteur période (boutons pill, style Stocks)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { p in
                                    let selected = viewModel.selectedPeriod == p
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            viewModel.selectedPeriod = p
                                        }
                                    } label: {
                                        Text(p.rawValue)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(selected
                                                             ? Color(UIColor.systemBackground)
                                                             : Color.primary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(
                                                selected
                                                ? Color(UIColor.label)
                                                : Color(UIColor.secondarySystemFill)
                                            )
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 12)
                        }

                        // Area chart
                        Chart(viewModel.dailyExpenses, id: \.day) { item in
                            AreaMark(
                                x: .value("Jour", item.day),
                                y: .value("Montant", item.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(UIColor.systemBlue).opacity(0.35),
                                        Color(UIColor.systemBlue).opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            LineMark(
                                x: .value("Jour", item.day),
                                y: .value("Montant", item.amount)
                            )
                            .foregroundStyle(Color(UIColor.systemBlue))
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                            .interpolationMethod(.catmullRom)
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) {
                                AxisValueLabel()
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .chartYAxis(.hidden)
                        .frame(height: 130)
                        .padding(.bottom, 10)
                    }
                }

                // ── 3. Revenus / Dépenses (ligne unique, séparé) ────
                Section {
                    HStack(spacing: 0) {
                        cashCell(
                            symbol: "arrow.down.left",
                            label:  "Revenus",
                            value:  viewModel.formatAmount(viewModel.totalIncome),
                            color:  Color(UIColor.systemGreen)
                        )
                        Divider()
                        cashCell(
                            symbol: "arrow.up.right",
                            label:  "Dépenses",
                            value:  viewModel.formatAmount(viewModel.totalExpenses),
                            color:  Color(UIColor.systemRed)
                        )
                    }
                    .frame(height: 64)
                    .listRowInsets(EdgeInsets())
                }

                // ── 4. Catégories (icônes style Réglages) ───────────
                Section(header: Text("Dépenses par catégorie")) {
                    if viewModel.expensesByCategory.isEmpty {
                        emptyPlaceholder(icon: "chart.pie", text: "Aucune dépense")
                    } else {
                        ForEach(viewModel.expensesByCategory.prefix(5), id: \.category) { item in
                            categoryRow(item: item)
                        }
                    }
                }

                // ── 5. Transactions (swipe to delete) ───────────────
                Section(header: Text("Récentes")) {
                    if viewModel.recentTransactions.isEmpty {
                        emptyPlaceholder(icon: "plus.circle", text: "Appuyez sur + pour commencer")
                    } else {
                        ForEach(viewModel.recentTransactions) { t in
                            TransactionRow(transaction: t)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.deleteTransaction(t)
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

            } // end List
            .listStyle(.insetGrouped)
            .navigationTitle("SamaXaalis")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
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
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView(authManager: authManager, notifManager: notifManager)
                    .environmentObject(viewModel)
            }
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: – Helpers
    // ──────────────────────────────────────────────────────────────────

    private func cashCell(symbol: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .imageScale(.small)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    /// Icône style Apple Réglages/Raccourcis : symbole blanc sur carré plein
    private func settingsIcon(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func categoryRow(item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        HStack(spacing: 12) {
            // Icône style Réglages
            settingsIcon(systemName: item.category.icon, color: item.category.color)

            // Infos
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.category.rawValue)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                }
                // Barre de progression (comme dans Santé)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemFill))
                            .frame(height: 3)
                        Capsule()
                            .fill(item.category.color)
                            .frame(
                                width: geo.size.width * CGFloat(min(item.percentage / 100, 1)),
                                height: 3
                            )
                            .animation(.spring(response: 0.6), value: item.percentage)
                    }
                }
                .frame(height: 3)
            }
        }
        .padding(.vertical, 3)
    }

    private func emptyPlaceholder(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 10)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassBarChart (encore utilisé par StatisticsView)
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

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassCategoryRow (utilisé par BudgetView / StatisticsView)
// ─────────────────────────────────────────────────────────────────────

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
