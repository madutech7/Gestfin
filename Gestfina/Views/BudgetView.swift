//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — Design Native iOS Sobriété
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSavingsGoals = false
    @State private var showAddBudget = false
    @State private var budgetToEdit: Budget? = nil
    @State private var showPaywall = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var subManager = SubscriptionManager.shared

    var body: some View {
        NavigationView {
            List {
                // ── OBJECTIFS D'ÉPARGNE (CAGNOTTES) ──
                Section {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showSavingsGoals = true
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.appGreen.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "target")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appGreen)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Objectifs d'Épargne & Cagnottes")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                let totalSaved = viewModel.savingsGoals.reduce(0) { $0 + $1.currentAmount }
                                Text("\(viewModel.savingsGoals.count) cagnotte(s) • \(viewModel.formatAmount(totalSaved)) épargnés")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // ── OVERVIEW RING ──
                Section {
                    NativeOverviewCard(viewModel: viewModel)
                        .padding(.vertical, 4)
                }
                .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
                
                // ── BUDGET LIST ──
                if viewModel.budgets.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(Color.appBlue)
                            Text(L10n.noBudget)
                                .font(.system(size: 16, weight: .semibold))
                            Text(L10n.createFirstBudget)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                showAddBudget = true
                            } label: {
                                Text("Créer un budget")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.appBlue)
                                    )
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                } else {
                    Section(header: Text(L10n.myBudgets)) {
                        ForEach(viewModel.budgets) { budget in
                            NativeBudgetCard(
                                budget: budget,
                                progress: viewModel.budgetProgress(for: budget),
                                viewModel: viewModel
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    budgetToEdit = budget
                                } label: {
                                    Label(L10n.edit, systemImage: "pencil")
                                }
                                .tint(.appBlue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation(.spring(response: 0.35)) {
                                        viewModel.deleteBudget(budget)
                                    }
                                } label: {
                                    Label(L10n.delete, systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .navigationTitle(L10n.budgets)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        if viewModel.budgets.count >= 2 && !subManager.isPremium {
                            showPaywall = true
                        } else {
                            showAddBudget = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            .sheet(isPresented: $showSavingsGoals) {
                SavingsGoalsView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showAddBudget) {
                NativeBudgetFormSheet(viewModel: viewModel, budgetToEdit: nil)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $budgetToEdit) { budget in
                NativeBudgetFormSheet(viewModel: viewModel, budgetToEdit: budget)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Native Overview Card

struct NativeOverviewCard: View {
    @ObservedObject var viewModel: FinanceViewModel
    
    private var totalBudget: Double {
        viewModel.budgets.filter(\.isActive).reduce(0) { $0 + $1.limit }
    }
    
    private var totalSpent: Double {
        viewModel.budgets.filter(\.isActive).reduce(0) { $0 + viewModel.budgetProgress(for: $1).spent }
    }
    
    private var pct: Double {
        totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
    }
    
    private var remaining: Double {
        max(totalBudget - totalSpent, 0)
    }
    
    private var ringColor: Color {
        pct > 90 ? Color.appRed : pct > 70 ? Color.appOrange : Color.appBlue
    }

    var body: some View {
        HStack(spacing: 16) {
            // Ring sobre
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.12), lineWidth: 10)
                    .frame(width: 70, height: 70)

                Circle()
                    .trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8), value: pct)

                VStack(spacing: 0) {
                    Text("\(Int(pct))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text(L10n.used)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Infos
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.globalBudget)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalBudget) : "••••")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.spent)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalSpent) : "••••")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appRed)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.remaining)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(remaining) : "••••")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            Spacer()
        }
    }
}

// MARK: - Native Budget Card Sobre

struct NativeBudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel

    private var progressColor: Color {
        progress.percentage > 90 ? Color.appRed : progress.percentage > 70 ? Color.appOrange : budget.category.color
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                // Icône
                ZStack {
                    Circle()
                        .fill(budget.category.color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(budget.category.color)
                }

                // Titre
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.categoryName(budget.category))
                        .font(.system(size: 15, weight: .semibold))
                    Text(L10n.budgetPeriodName(budget.period))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Montants
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.isBalanceVisible ? viewModel.formatAmount(progress.spent) : "••••")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Text(L10n.ofLimit(viewModel.isBalanceVisible ? budget.formattedLimit : "••••"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }

            // Barre de progression
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 5)
                        
                        Capsule()
                            .fill(progressColor)
                            .frame(width: geo.size.width * CGFloat(min(progress.percentage, 100) / 100), height: 5)
                            .animation(.spring(response: 0.5), value: progress.percentage)
                    }
                }
                .frame(height: 5)

                // Footer
                HStack {
                    Text(L10n.usedPercent(Int(progress.percentage)))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(progress.percentage > 90 ? Color.appRed : .secondary)
                    
                    Spacer()
                    
                    let remainingAmount = max(budget.limit - progress.spent, 0)
                    Text(L10n.remainsAmount(viewModel.isBalanceVisible ? viewModel.formatAmount(remainingAmount) : "••••"))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Native Budget Form Sheet

struct NativeBudgetFormSheet: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss

    let budgetToEdit: Budget?

    @State private var category: TransactionCategory = .food
    @State private var limitText: String = ""
    @State private var period: BudgetPeriod = .monthly
    @FocusState private var limitFocused: Bool

    private var isEditing: Bool { budgetToEdit != nil }

    private var canSave: Bool {
        (Double(limitText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(L10n.category)) {
                    Picker(L10n.category, selection: $category) {
                        ForEach(TransactionCategory.expenseCategories) { cat in
                            Label(L10n.categoryName(cat), systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section(header: Text(L10n.spendingLimit)) {
                    HStack {
                        Text(viewModel.currencySymbol)
                            .foregroundStyle(.secondary)
                        TextField("0,00", text: $limitText)
                            .keyboardType(.decimalPad)
                            .focused($limitFocused)
                    }
                }

                Section(header: Text(L10n.frequency)) {
                    Picker(L10n.period, selection: $period) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { p in
                            Text(L10n.budgetPeriodName(p)).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(isEditing ? L10n.editBudget : L10n.newBudget)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? L10n.save : L10n.addButton) {
                        let limit = Double(limitText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        if isEditing, var updated = budgetToEdit {
                            updated.category = category
                            updated.limit    = limit
                            updated.period   = period
                            viewModel.updateBudget(updated)
                        } else {
                            viewModel.addBudget(Budget(category: category, limit: limit, period: period))
                        }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.done) {
                        limitFocused = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let b = budgetToEdit {
                    category  = b.category
                    limitText = String(format: "%.2f", b.limit).replacingOccurrences(of: ".", with: ",")
                    period    = b.period
                } else {
                    limitFocused = true
                }
            }
        }
    }
}

// Keep BudgetCard for backward compat
struct BudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel
    
    var body: some View {
        NativeBudgetCard(budget: budget, progress: progress, viewModel: viewModel)
    }
}

#Preview {
    BudgetView()
        .environmentObject(FinanceViewModel())
}
