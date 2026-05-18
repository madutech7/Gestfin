//
//  StatisticsView.swift
//  Gestfina
//
//  Statistiques — Design premium Apple Health × Stocks
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var selectedChart: ChartType = .expenses
    @State private var showPaywall = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var subManager = SubscriptionManager.shared

    enum ChartType: String, CaseIterable {
        case expenses = "Dépenses"
        case income = "Revenus"
        case trend = "Tendance"
    }

    var body: some View {
        NavigationView {
            List {
                // Metrics grid
                Section {
                    metricsGrid
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                // Chart selector
                Section {
                    Picker("Vue", selection: $selectedChart) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }

                // Chart
                Section {
                    chartView
                        .padding(.vertical, 8)
                }

                // Top expenses
                if !viewModel.expensesByCategory.isEmpty {
                    Section(header:
                        HStack(spacing: 6) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.appOrange)
                                .font(.system(size: 13))
                            Text("Top dépenses")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .textCase(nil)
                    ) {
                        ForEach(Array(viewModel.expensesByCategory.prefix(5).enumerated()), id: \.element.category) { index, item in
                            topCategoryRow(index: index, item: item)
                        }
                    }
                }
            .listStyle(.insetGrouped)
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                            Button {
                                withAnimation(.spring(response: 0.35)) {
                                    viewModel.selectedPeriod = period
                                }
                            } label: {
                                HStack {
                                    Text(period.rawValue)
                                    if viewModel.selectedPeriod == period {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedPeriod.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Color.appBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appBlue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            StatMetricCard(title: "Revenus", value: viewModel.isBalanceVisible ? viewModel.formatAmount(viewModel.totalIncome) : "••••", icon: "arrow.down.left.circle.fill", color: .appGreen)
            StatMetricCard(title: "Dépenses", value: viewModel.isBalanceVisible ? viewModel.formatAmount(viewModel.totalExpenses) : "••••", icon: "arrow.up.right.circle.fill", color: .appRed)
            StatMetricCard(title: "Épargne", value: viewModel.isBalanceVisible ? viewModel.formatPercentage(viewModel.savingsRate) : "••••", icon: "leaf.circle.fill", color: .appCyan)
            StatMetricCard(title: "Opérations", value: "\(viewModel.filteredTransactions.count)", icon: "number.circle.fill", color: .appBlue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Chart View

    @ViewBuilder
    private var chartView: some View {
        if selectedChart == .trend {
            if subManager.isPremium {
                trendChart
            } else {
                ZStack {
                    trendChart
                        .blur(radius: 8)
                        .disabled(true)
                    
                    // Glassmorphic Premium Overlay
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.appBlue, Color.appPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Analyse de Tendance Premium")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Débloquez les analyses de tendance mensuelles et l'historique d'épargne complet.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showPaywall = true
                        } label: {
                            Text("Débloquer SamaXaalis Premium")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [Color.appBlue, Color.appPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                }
            }
        } else {
            breakdownChart
        }
    }

    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tendance mensuelle")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.primary)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(viewModel.monthlyExpenses.indices, id: \.self) { i in
                        let item = viewModel.monthlyExpenses[i]
                        let maxVal = viewModel.monthlyExpenses.map(\.amount).max() ?? 1
                        let isMax = item.amount == maxVal && maxVal > 0

                        BarMark(
                            x: .value("Mois", item.month),
                            y: .value("Montant", item.amount)
                        )
                        .foregroundStyle(
                            isMax
                            ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appCyan], startPoint: .bottom, endPoint: .top))
                            : AnyShapeStyle(Color.secondary.opacity(0.12))
                        )
                        .cornerRadius(8)
                    }
                }
                .frame(height: 170)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.system(size: 10, weight: .medium))
                    }
                }
                .chartYAxis(.hidden)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<viewModel.monthlyExpenses.count, id: \.self) { i in
                        let item = viewModel.monthlyExpenses[i]
                        let maxVal = viewModel.monthlyExpenses.map(\.amount).max() ?? 1
                        let isMax = item.amount == maxVal && maxVal > 0

                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isMax
                                    ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appCyan], startPoint: .bottom, endPoint: .top))
                                    : AnyShapeStyle(Color.secondary.opacity(0.12))
                                )
                                .frame(height: maxVal > 0 ? max(CGFloat(item.amount / maxVal) * 120, 6) : 6)

                            Text(item.month)
                                .font(.system(size: 10, weight: isMax ? .bold : .medium))
                                .foregroundStyle(isMax ? Color.appBlue : Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 170)
            }
        }
    }

    private var breakdownChart: some View {
        let data = selectedChart == .expenses ? viewModel.expensesByCategory : viewModel.incomeByCategory

        return VStack(alignment: .leading, spacing: 14) {
            Text("Répartition \(selectedChart.rawValue.lowercased())")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.primary)

            if data.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(.tertiary)
                        Text("Aucune donnée")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 30)
            } else {
                ForEach(data.prefix(6), id: \.category) { item in
                    VStack(spacing: 7) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 8, height: 8)
                            Text(item.category.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Text(viewModel.isBalanceVisible ? viewModel.formatAmount(item.amount) : "••••")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text(viewModel.formatPercentage(item.percentage))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(width: 42, alignment: .trailing)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.secondary.opacity(0.1))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            colors: [item.category.color, item.category.color.opacity(0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * CGFloat(item.percentage / 100), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
        }
    }

    // MARK: - Top Category Row

    private func topCategoryRow(index: Int, item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        HStack(spacing: 14) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(index == 0 ? Color.appOrange.opacity(0.15) : Color.secondary.opacity(0.08))
                    .frame(width: 28, height: 28)
                Text("\(index + 1)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(index == 0 ? Color.appOrange : Color.secondary)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.category.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: item.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(item.category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.category.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                Text("\(Int(item.percentage))% du total")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(viewModel.isBalanceVisible ? viewModel.formatAmount(item.amount) : "••••")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
    }
}

// MARK: - Stat Metric Card

struct StatMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    StatisticsView()
        .environmentObject(FinanceViewModel())
}
