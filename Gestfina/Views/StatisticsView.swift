//
//  StatisticsView.swift
//  Gestfina
//
//  Statistiques — Style iOS natif professionnel, adaptive Light/Dark
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var selectedChart: ChartType = .expenses
    @Environment(\.colorScheme) var colorScheme
    
    enum ChartType: String, CaseIterable {
        case expenses = "Dépenses"
        case income = "Revenus"
        case trend = "Tendance"
    }
    
    var body: some View {
        NavigationView {
            List {
                // Grille métriques
                Section {
                    metricsGrid
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Sélecteur de graphique
                Section {
                    Picker("Vue", selection: $selectedChart) {
                        ForEach(ChartType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }
                
                // Graphique
                Section {
                    chartView
                        .padding(.vertical, 8)
                }
                
                // Top dépenses
                if !viewModel.expensesByCategory.isEmpty {
                    Section(header:
                    Label("Top dépenses", systemImage: "trophy.fill")
                        .foregroundColor(.primary)
                ) {
                        ForEach(Array(viewModel.expensesByCategory.prefix(5).enumerated()), id: \.element.category) { index, item in
                            topCategoryRow(index: index, item: item)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(
                ZStack {
                    Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                    Circle()
                        .fill(Color.appCyan.opacity(colorScheme == .dark ? 0.05 : 0.03))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -150, y: 150)
                }
            )
            .scrollContentBackground(.hidden)
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                            Button(period.rawValue) {
                                withAnimation { viewModel.selectedPeriod = period }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedPeriod.rawValue)
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.appBlue)
                    }
                }
            }
        }
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            metricCard(title: "Revenus", value: viewModel.formatAmount(viewModel.totalIncome), icon: "arrow.down.left", color: .appGreen)
            metricCard(title: "Dépenses", value: viewModel.formatAmount(viewModel.totalExpenses), icon: "arrow.up.right", color: .appRed)
            metricCard(title: "Épargne", value: viewModel.formatPercentage(viewModel.savingsRate), icon: "leaf.fill", color: .appCyan)
            metricCard(title: "Opérations", value: "\(viewModel.filteredTransactions.count)", icon: "rectangle.stack.fill", color: .appPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
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
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Chart View
    
    @ViewBuilder
    private var chartView: some View {
        if selectedChart == .trend {
            trendChart
        } else {
            breakdownChart
        }
    }
    
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tendance mensuelle — Dépenses")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
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
                            ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .bottom, endPoint: .top))
                            : AnyShapeStyle(Color.secondary.opacity(0.15))
                        )
                        .cornerRadius(6)
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
                    ForEach(viewModel.monthlyExpenses.indices, id: \.self) { i in
                        let item = viewModel.monthlyExpenses[i]
                        let maxVal = viewModel.monthlyExpenses.map(\.amount).max() ?? 1
                        let isMax = item.amount == maxVal && maxVal > 0
                        
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isMax
                                    ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .bottom, endPoint: .top))
                                    : AnyShapeStyle(Color.secondary.opacity(0.15))
                                )
                                .frame(height: maxVal > 0 ? max(CGFloat(item.amount / maxVal) * 120, 6) : 6)
                                .shadow(color: isMax ? Color.appBlue.opacity(0.3) : .clear, radius: 6, y: 3)
                            
                            Text(item.month)
                                .font(.system(size: 10, weight: isMax ? .bold : .medium))
                                .foregroundColor(isMax ? .appBlue : .secondary)
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
            
            if data.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("Aucune donnée")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
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
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            Text(viewModel.formatAmount(item.amount))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(viewModel.formatPercentage(item.percentage))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .frame(width: 42, alignment: .trailing)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.secondary.opacity(0.12))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(LinearGradient(colors: [item.category.color, item.category.color.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
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
            Text("\(index + 1)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(index == 0 ? .appOrange : .secondary)
                .frame(width: 22)
            
            ZStack {
                Circle()
                    .fill(item.category.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: item.category.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(item.category.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.category.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(Int(item.percentage))% du total")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(viewModel.formatAmount(item.amount))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(FinanceViewModel())
}
