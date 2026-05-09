//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets Liquid Glass
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showAddBudget = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    overviewCard
                    budgetsList
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.clear)
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddBudget) {
                AddBudgetSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Budgets")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Text("Suivez vos limites")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            Button { showAddBudget = true } label: {
                ZStack {
                    Circle().fill(.ultraThinMaterial).frame(width: 42, height: 42)
                        .overlay(Circle().stroke(Color.glassBorder, lineWidth: 0.5))
                    Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.gradientPrimary)
                }
            }
        }
        .padding(.top, 16)
    }
    
    private var overviewCard: some View {
        let totalBudget = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + $1.limit }
        let totalSpent = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + viewModel.budgetProgress(for: $1).spent }
        let pct = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
        
        return HStack(spacing: 20) {
            // Cercle de progression glass
            ZStack {
                Circle().stroke(Color.white.opacity(0.06), lineWidth: 8).frame(width: 80, height: 80)
                Circle().trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                    .stroke(
                        pct > 90
                        ? LinearGradient(colors: [.appRed, .appOrange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [.appGreen, .appCyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8), value: pct)
                
                VStack(spacing: 0) {
                    Text("\(Int(pct))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                    Text("utilisé")
                        .font(.system(size: 9)).foregroundColor(.textTertiary)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Budget total").font(.system(size: 11)).foregroundColor(.textSecondary)
                    Text(viewModel.formatAmount(totalBudget))
                        .font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.textPrimary)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Dépensé").font(.system(size: 9)).foregroundColor(.textTertiary)
                        Text(viewModel.formatAmount(totalSpent))
                            .font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.appRed)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Restant").font(.system(size: 9)).foregroundColor(.textTertiary)
                        Text(viewModel.formatAmount(max(totalBudget - totalSpent, 0)))
                            .font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.appGreen)
                    }
                }
            }
            
            Spacer()
        }
        .padding(22)
        .liquidGlass(cornerRadius: 24, opacity: 0.08)
        .animatedGlassBorder(cornerRadius: 24, colors: [.appGreen.opacity(0.5), .appCyan.opacity(0.3), .appPurple.opacity(0.3), .appGreen.opacity(0.5)])
    }
    
    private var budgetsList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.budgets) { budget in
                GlassBudgetCard(budget: budget, progress: viewModel.budgetProgress(for: budget), viewModel: viewModel)
            }
        }
    }
}

// MARK: - Glass Budget Card

struct GlassBudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel
    @State private var appeared = false
    
    private var progressColor: Color {
        progress.percentage > 90 ? .appRed : progress.percentage > 70 ? .appOrange : budget.category.color
    }
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(budget.category.color.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(budget.category.color.opacity(0.15), lineWidth: 0.5))
                        .frame(width: 42, height: 42)
                    Image(systemName: budget.category.icon).font(.system(size: 17)).foregroundColor(budget.category.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.category.rawValue).font(.system(size: 15, weight: .semibold)).foregroundColor(.textPrimary)
                    Text(budget.period.rawValue).font(.system(size: 11)).foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.formatAmount(progress.spent)).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.textPrimary)
                    Text("/ \(budget.formattedLimit)").font(.system(size: 11)).foregroundColor(.textTertiary)
                }
            }
            
            // Progress bar glass
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.04)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(colors: [progressColor, progressColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress.percentage / 100), height: 8)
                        .shadow(color: progressColor.opacity(0.4), radius: 4, y: 1)
                        .animation(.spring(response: 0.6), value: progress.percentage)
                }
            }.frame(height: 8)
            
            HStack {
                Text("\(Int(progress.percentage))% utilisé")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(progress.percentage > 90 ? .appRed : .textSecondary)
                Spacer()
                Text("Reste \(viewModel.formatAmount(max(budget.limit - progress.spent, 0)))")
                    .font(.system(size: 11, weight: .medium)).foregroundColor(.appGreen)
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 18, opacity: 0.05)
        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 15)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) { appeared = true }
        }
    }
}

// MARK: - Add Budget Sheet

struct AddBudgetSheet: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    @State private var category: TransactionCategory = .food
    @State private var limitText = ""
    @State private var period: BudgetPeriod = .monthly
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Picker("Catégorie", selection: $category) {
                        ForEach(TransactionCategory.expenseCategories) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }.pickerStyle(.wheel).frame(height: 120)
                    
                    HStack {
                        Text("€").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.textTertiary)
                        TextField("Limite", text: $limitText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .liquidGlass(cornerRadius: 16, opacity: 0.06)
                    
                    Picker("Période", selection: $period) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { p in Text(p.rawValue).tag(p) }
                    }.pickerStyle(.segmented)
                    
                    Button {
                        let limit = Double(limitText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        if limit > 0 {
                            viewModel.addBudget(Budget(category: category, limit: limit, period: period))
                            dismiss()
                        }
                    } label: {
                        Text("Ajouter le budget").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .leading, endPoint: .trailing))
                                    .overlay(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial).opacity(0.15))
                            )
                            .shadow(color: Color.appBlue.opacity(0.2), radius: 12, y: 4)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Nouveau Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.textTertiary)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        BudgetView()
    }
    .environmentObject(FinanceViewModel()).preferredColorScheme(.dark)
}
