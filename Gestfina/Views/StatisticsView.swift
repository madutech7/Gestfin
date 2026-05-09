//
//  StatisticsView.swift
//  Gestfina
//
//  Statistiques Liquid Glass
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var selectedChart: ChartType = .expenses
    @State private var animateIn = false
    
    enum ChartType: String, CaseIterable {
        case expenses = "Dépenses"
        case income = "Revenus"
        case trend = "Tendance"
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    overviewGrid
                    chartSelector
                    chartSection
                    topCategoriesSection
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.clear)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { animateIn = true }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Statistiques")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Text("Analysez vos finances")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(.textSecondary)
            }
            Spacer()
            Menu {
                ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                    Button(period.rawValue) { viewModel.selectedPeriod = period }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.selectedPeriod.rawValue).font(.system(size: 12, weight: .medium))
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold))
                }
                .foregroundColor(.appBlue)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .liquidGlassButton(isActive: true, activeColor: .appBlue)
            }
        }
        .padding(.top, 16)
    }
    
    private var overviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            glassMetric(title: "Revenus", value: viewModel.formatAmount(viewModel.totalIncome), icon: "arrow.down.left", color: .appGreen)
            glassMetric(title: "Dépenses", value: viewModel.formatAmount(viewModel.totalExpenses), icon: "arrow.up.right", color: .appRed)
            glassMetric(title: "Épargne", value: viewModel.formatPercentage(viewModel.savingsRate), icon: "leaf.fill", color: .appCyan)
            glassMetric(title: "Opérations", value: "\(viewModel.filteredTransactions.count)", icon: "rectangle.stack.fill", color: .appPurple)
        }
        .opacity(animateIn ? 1 : 0).offset(y: animateIn ? 0 : 20)
    }
    
    private func glassMetric(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.15), lineWidth: 0.4))
                    .frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 10)).foregroundColor(.textTertiary)
                Text(value).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.textPrimary)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            Spacer()
        }
        .padding(14)
        .liquidGlass(cornerRadius: 16, opacity: 0.05)
    }
    
    private var chartSelector: some View {
        HStack(spacing: 4) {
            ForEach(ChartType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedChart = type }
                } label: {
                    Text(type.rawValue)
                        .font(.system(size: 13, weight: selectedChart == type ? .semibold : .medium))
                        .foregroundColor(selectedChart == type ? .white : .textTertiary)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedChart == type {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.appBlue.opacity(0.25))
                                        .overlay(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial).opacity(0.3))
                                        .shadow(color: Color.appBlue.opacity(0.15), radius: 4, y: 2)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .liquidGlass(cornerRadius: 14, opacity: 0.04)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedChart == .trend {
                trendChart
            } else {
                breakdownChart
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 24)
    }
    
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tendance mensuelle").font(.system(size: 15, weight: .semibold)).foregroundColor(.textPrimary)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.monthlyExpenses.indices, id: \.self) { i in
                    let item = viewModel.monthlyExpenses[i]
                    let maxVal = viewModel.monthlyExpenses.map(\.amount).max() ?? 1
                    let isMax = item.amount == maxVal && maxVal > 0
                    
                    VStack(spacing: 6) {
                        if isMax {
                            Text(viewModel.formatAmount(item.amount))
                                .font(.system(size: 8, weight: .semibold)).foregroundColor(.appBlue)
                        }
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                isMax
                                ? AnyShapeStyle(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .bottom, endPoint: .top))
                                : AnyShapeStyle(Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isMax ? Color.appBlue.opacity(0.3) : Color.white.opacity(0.04), lineWidth: 0.5)
                            )
                            .frame(height: maxVal > 0 ? max(CGFloat(item.amount / maxVal) * 120, 6) : 6)
                            .shadow(color: isMax ? Color.appBlue.opacity(0.3) : .clear, radius: 6, y: 3)
                        
                        Text(item.month)
                            .font(.system(size: 10, weight: isMax ? .bold : .medium))
                            .foregroundColor(isMax ? .appBlue : .textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }.frame(height: 170)
        }
    }
    
    private var breakdownChart: some View {
        let data = selectedChart == .expenses ? viewModel.expensesByCategory : viewModel.incomeByCategory
        
        return VStack(alignment: .leading, spacing: 14) {
            Text("Répartition \(selectedChart.rawValue.lowercased())")
                .font(.system(size: 15, weight: .semibold)).foregroundColor(.textPrimary)
            
            if data.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "chart.pie").font(.system(size: 32)).foregroundColor(.textTertiary)
                        Text("Aucune donnée").font(.system(size: 13)).foregroundColor(.textTertiary)
                    }
                    Spacer()
                }.padding(.vertical, 30)
            } else {
                ForEach(data.prefix(6), id: \.category) { item in
                    VStack(spacing: 6) {
                        HStack(spacing: 10) {
                            Circle().fill(item.category.color).frame(width: 8, height: 8)
                            Text(item.category.rawValue).font(.system(size: 13, weight: .medium)).foregroundColor(.textPrimary)
                            Spacer()
                            Text(viewModel.formatAmount(item.amount)).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.textPrimary)
                            Text(viewModel.formatPercentage(item.percentage)).font(.system(size: 11)).foregroundColor(.textSecondary).frame(width: 40, alignment: .trailing)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.03)).frame(height: 3)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(LinearGradient(colors: [item.category.color, item.category.color.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * CGFloat(item.percentage / 100), height: 3)
                                    .shadow(color: item.category.color.opacity(0.3), radius: 3, y: 1)
                            }
                        }.frame(height: 3)
                    }
                }
            }
        }
    }
    
    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("🏆 Top dépenses").font(.system(size: 16, weight: .semibold)).foregroundColor(.textPrimary)
            
            ForEach(Array(viewModel.expensesByCategory.prefix(3).enumerated()), id: \.element.category) { index, item in
                HStack(spacing: 14) {
                    // Rang
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(index == 0 ? .appOrange : .textTertiary)
                        .frame(width: 20)
                    
                    ZStack {
                        Circle().fill(item.category.color.opacity(0.12))
                            .overlay(Circle().stroke(item.category.color.opacity(0.15), lineWidth: 0.4))
                            .frame(width: 44, height: 44)
                        Image(systemName: item.category.icon).font(.system(size: 18)).foregroundColor(item.category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.category.rawValue).font(.system(size: 14, weight: .semibold)).foregroundColor(.textPrimary)
                        Text("\(Int(item.percentage))% du total").font(.system(size: 11)).foregroundColor(.textTertiary)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.formatAmount(item.amount))
                        .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.textPrimary)
                }
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 24)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        StatisticsView()
    }
    .environmentObject(FinanceViewModel()).preferredColorScheme(.dark)
}
