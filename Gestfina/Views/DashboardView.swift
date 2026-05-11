//
//  DashboardView.swift
//  SamaXaalis
//
//  Architecture identique aux apps Apple (Stocks, Santé, Wallet)
//  — Grande typo, fond système, composants natifs, Swift Charts
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings    = false
    @State private var balanceVisible  = true
    @State private var animateIn       = false
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager

    // ─────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationView {
            List {

                // ─── Bloc Solde (flottant, pas de carte) ─────────────
                Section {
                    VStack(spacing: 6) {
                        Text("Solde disponible")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Solde géant — style Apple Stocks
                        Text(balanceVisible
                             ? viewModel.formatAmount(viewModel.totalBalance)
                             : "••••••")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)

                        // Indicateur épargne — style Stocks (+/-)
                        let rate = viewModel.savingsRate
                        let positive = rate >= 0
                        Label(
                            "\(positive ? "+" : "")\(viewModel.formatPercentage(rate)) ce mois",
                            systemImage: positive ? "arrow.up.right" : "arrow.down.right"
                        )
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(positive ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
                        .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                // ─── Revenus / Dépenses ──────────────────────────────
                Section {
                    HStack(spacing: 0) {
                        cashFlowCell(
                            icon:  "arrow.down.left.circle.fill",
                            label: "Revenus",
                            value: viewModel.formatAmount(viewModel.totalIncome),
                            color: Color(UIColor.systemGreen)
                        )
                        Rectangle()
                            .fill(Color(UIColor.separator))
                            .frame(width: 0.5, height: 52)
                        cashFlowCell(
                            icon:  "arrow.up.right.circle.fill",
                            label: "Dépenses",
                            value: viewModel.formatAmount(viewModel.totalExpenses),
                            color: Color(UIColor.systemRed)
                        )
                    }
                    .padding(.vertical, 4)
                }

                // ─── Graphique (Swift Charts — niveau Apple) ─────────
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dépenses")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text(viewModel.formatAmount(viewModel.totalExpenses))
                                    .font(.title3.weight(.semibold))
                                    .fontDesign(.rounded)
                            }
                            Spacer()
                            Menu {
                                ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { p in
                                    Button(p.rawValue) {
                                        withAnimation { viewModel.selectedPeriod = p }
                                    }
                                }
                            } label: {
                                HStack(spacing: 3) {
                                    Text(viewModel.selectedPeriod.rawValue)
                                    Image(systemName: "chevron.down")
                                        .imageScale(.small)
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color(UIColor.systemBlue))
                            }
                        }

                        // Swift Charts bar chart
                        Chart(viewModel.dailyExpenses, id: \.day) { item in
                            BarMark(
                                x: .value("Jour", item.day),
                                y: .value("Montant", item.amount)
                            )
                            .foregroundStyle(Color(UIColor.systemBlue).gradient)
                            .cornerRadius(5)
                        }
                        .frame(height: 120)
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .chartYAxis(.hidden)
                    }
                    .padding(.vertical, 6)
                }

                // ─── Catégories ──────────────────────────────────────
                Section(header: Text("Par catégorie")) {
                    if viewModel.expensesByCategory.isEmpty {
                        Label("Aucune dépense", systemImage: "chart.pie")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.expensesByCategory.prefix(5), id: \.category) { item in
                            categoryRow(item: item)
                        }
                    }
                }

                // ─── Transactions récentes ───────────────────────────
                Section(header: Text("Récentes")) {
                    if viewModel.recentTransactions.isEmpty {
                        Label("Appuyez sur + pour commencer", systemImage: "plus.circle")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.recentTransactions) { t in
                            TransactionRow(transaction: t)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
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

    // ─────────────────────────────────────────────────────────────────
    // MARK: – Cash Flow Cell
    // ─────────────────────────────────────────────────────────────────
    private func cashFlowCell(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – Category Row
    // ─────────────────────────────────────────────────────────────────
    private func categoryRow(item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        HStack(spacing: 14) {
            // Icône dans carré arrondi (style Apple Raccourcis)
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(item.category.color)
                    .frame(width: 34, height: 34)
                Image(systemName: item.category.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Texte + barre
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.category.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemFill))
                            .frame(height: 4)
                        Capsule()
                            .fill(item.category.color)
                            .frame(
                                width: geo.size.width * CGFloat(min(item.percentage / 100, 1)),
                                height: 4
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: item.percentage)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.vertical, 4)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassBarChart  (still used by StatisticsView)
// ─────────────────────────────────────────────────────────────────────

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]

    private var maxAmount: Double { data.map(\.amount).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let isLast  = index == data.count - 1
                let ratio   = maxAmount > 0 ? CGFloat(item.amount / maxAmount) : 0.05

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
                        .foregroundStyle(isLast ? Color(UIColor.systemBlue) : Color.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassCategoryRow  (utilisé par BudgetView / StatisticsView)
// ─────────────────────────────────────────────────────────────────────

struct GlassCategoryRow: View {
    let category:   TransactionCategory
    let amount:     String
    let percentage: Double

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(category.color)
                    .frame(width: 34, height: 34)
                Image(systemName: category.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue).font(.subheadline.weight(.medium))
                    Spacer()
                    Text(amount).font(.subheadline.weight(.semibold)).fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemFill))
                            .frame(height: 4)
                        Capsule()
                            .fill(category.color)
                            .frame(
                                width: geo.size.width * CGFloat(min(percentage / 100, 1)),
                                height: 4
                            )
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
        authManager:  AuthenticationManager(),
        notifManager: NotificationManager()
    )
    .environmentObject(FinanceViewModel())
}
