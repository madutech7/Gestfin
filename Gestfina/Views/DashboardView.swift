//
//  DashboardView.swift
//  SamaXaalis
//
//  Apple-level design — Stocks · Wallet · Santé
//  + Quick Actions · Interactive Chart · Budget Rings
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings    = false
    @State private var balanceVisible  = true
    @State private var selectedDay: String? = nil
    @State private var selectedAmount: Double? = nil
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager

    // ─────────────────────────────────────────────────────────────────
    var body: some View {
        NavigationView {
            List {

                // ── 1. Solde ─────────────────────────────────────────
                Section {
                    balanceHeader
                }
                .listRowBackground(Color.clear)
                .listSectionSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

                // ── 2. Actions rapides (Apple Wallet style) ───────────
                Section {
                    quickActionsStrip
                }
                .listRowBackground(Color.clear)
                .listSectionSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))

                // ── 3. Graphique interactif ───────────────────────────
                Section {
                    interactiveChart
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

                // ── 4. Flux financier ─────────────────────────────────
                Section {
                    HStack(spacing: 0) {
                        cashCell(symbol: "arrow.down.left",
                                 label: "Revenus",
                                 value: viewModel.formatAmount(viewModel.totalIncome),
                                 color: Color(UIColor.systemGreen))
                        Divider().frame(height: 40)
                        cashCell(symbol: "arrow.up.right",
                                 label: "Dépenses",
                                 value: viewModel.formatAmount(viewModel.totalExpenses),
                                 color: Color(UIColor.systemRed))
                    }
                    .frame(height: 64)
                    .listRowInsets(EdgeInsets())
                }

                // ── 5. Catégories ─────────────────────────────────────
                Section(header: Text("Catégories")) {
                    if viewModel.expensesByCategory.isEmpty {
                        emptyPlaceholder(icon: "chart.pie", text: "Aucune dépense enregistrée")
                    } else {
                        ForEach(viewModel.expensesByCategory.prefix(5), id: \.category) { item in
                            categoryRow(item: item)
                        }
                    }
                }

                // ── 6. Transactions récentes ──────────────────────────
                Section(header: Text("Récentes")) {
                    if viewModel.recentTransactions.isEmpty {
                        emptyPlaceholder(icon: "plus.circle", text: "Appuyez sur + pour commencer")
                    } else {
                        ForEach(viewModel.recentTransactions) { t in
                            TransactionRow(transaction: t)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation { viewModel.deleteTransaction(t) }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }

            }
            .listStyle(.insetGrouped)
            .navigationTitle("SamaXaalis")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarItems }
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
    private var toolbarItems: some ToolbarContent {
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

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 1. Balance Header
    // ─────────────────────────────────────────────────────────────────
    private var balanceHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Solde total")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            Text(balanceVisible
                 ? viewModel.formatAmount(viewModel.totalBalance)
                 : "••••••••")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                .minimumScaleFactor(0.45)
                .lineLimit(1)

            // Variation (style Apple Stocks)
            let net      = viewModel.totalIncome - viewModel.totalExpenses
            let rate     = viewModel.savingsRate
            let positive = net >= 0
            HStack(spacing: 5) {
                Image(systemName: positive ? "arrow.up.right" : "arrow.down.right")
                    .font(.footnote.weight(.bold))
                Text("\(positive ? "+" : "")\(viewModel.formatAmount(net))  ·  \(positive ? "+" : "")\(viewModel.formatPercentage(rate))")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(positive ? Color(UIColor.systemGreen) : Color(UIColor.systemRed))
        }
        .padding(.vertical, 8)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 2. Quick Actions (Apple Wallet style)
    // ─────────────────────────────────────────────────────────────────
    private var quickActionsStrip: some View {
        HStack(spacing: 12) {
            quickAction(label: "Ajouter",     icon: "plus",              color: Color(UIColor.systemBlue))
            quickAction(label: "Budgets",     icon: "chart.pie.fill",    color: Color(UIColor.systemGreen))
            quickAction(label: "Historique",  icon: "clock.fill",        color: Color(UIColor.systemOrange))
            quickAction(label: "Rapport",     icon: "doc.text.fill",     color: Color(UIColor.systemPurple))
        }
        .padding(.vertical, 8)
    }

    private func quickAction(label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 54, height: 54)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – 3. Interactive Area Chart (Apple Stocks style)
    // ─────────────────────────────────────────────────────────────────
    private var interactiveChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Amount callout when dragging
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedDay != nil ? "Jour sélectionné" : viewModel.selectedPeriod.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(selectedAmount != nil
                         ? viewModel.formatAmount(selectedAmount!)
                         : viewModel.formatAmount(viewModel.totalExpenses))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(selectedAmount != nil ? Color(UIColor.systemBlue) : .primary)
                        .contentTransition(.numericText())
                        .animation(.easeOut(duration: 0.1), value: selectedAmount)
                }
                Spacer()
                periodPills
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Chart
            Chart(viewModel.dailyExpenses, id: \.day) { item in
                AreaMark(
                    x: .value("Jour", item.day),
                    y: .value("Montant", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemBlue).opacity(0.3),
                            Color(UIColor.systemBlue).opacity(0.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Jour", item.day),
                    y: .value("Montant", item.amount)
                )
                .foregroundStyle(Color(UIColor.systemBlue))
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)

                // Curseur vertical quand sélectionné
                if let day = selectedDay, day == item.day {
                    RuleMark(x: .value("Jour", item.day))
                        .foregroundStyle(Color(UIColor.systemBlue).opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    PointMark(
                        x: .value("Jour", item.day),
                        y: .value("Montant", item.amount)
                    )
                    .foregroundStyle(Color(UIColor.systemBlue))
                    .symbolSize(60)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) {
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondary)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 140)
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
            // Gesture drag interactif (style Apple Stocks)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let xPos = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                    if let day: String = proxy.value(atX: xPos) {
                                        if let match = viewModel.dailyExpenses.first(where: { $0.day == day }) {
                                            if selectedDay != match.day {
                                                Haptics.play(.selection)
                                            }
                                            selectedDay    = match.day
                                            selectedAmount = match.amount
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        selectedDay    = nil
                                        selectedAmount = nil
                                    }
                                }
                        )
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – Period Pills (extracted for type inference)
    // ─────────────────────────────────────────────────────────────────
    private var periodPills: some View {
        let periods: [FinanceViewModel.TimePeriod] = FinanceViewModel.TimePeriod.allCases
        return HStack(spacing: 6) {
            ForEach(periods, id: \.self) { p in
                let sel = viewModel.selectedPeriod == p
                Button {
                    Haptics.play(.selection)
                    withAnimation(.spring(response: 0.25)) {
                        viewModel.selectedPeriod = p
                        selectedDay = nil; selectedAmount = nil
                    }
                } label: {
                    Text(p.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(sel ? Color(UIColor.systemBackground) : .primary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(sel ? Color(UIColor.label) : Color(UIColor.secondarySystemFill))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MARK: – Helpers
    // ─────────────────────────────────────────────────────────────────

    private func cashCell(symbol: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: symbol).imageScale(.small).foregroundStyle(color)
                Text(label).font(.caption).foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(.callout, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    private func categoryRow(item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        HStack(spacing: 12) {
            // Icône style Apple Réglages (symbole blanc sur carré couleur)
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(item.category.color)
                    .frame(width: 32, height: 32)
                Image(systemName: item.category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(item.category.rawValue)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(UIColor.systemFill)).frame(height: 3)
                        Capsule().fill(item.category.color)
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
// MARK: – GlassBarChart (utilisé par StatisticsView)
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
                    .fill(category.color).frame(width: 32, height: 32)
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
