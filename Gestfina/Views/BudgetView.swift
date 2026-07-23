//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — Ultra-Premium Apple iOS Design
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
                // ── OBJECTIFS D'ÉPARGNE (CAGNOTTES HERO BANNER) ──
                Section {
                    SavingsBannerHeroCard(viewModel: viewModel) {
                        showSavingsGoals = true
                    }
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                // ── OVERVIEW RING (Apple Fitness Style) ──
                Section {
                    NativeOverviewCard(viewModel: viewModel)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color(UIColor.secondarySystemGroupedBackground))
                
                // ── BUDGET LIST ──
                if viewModel.budgets.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.appBlue.opacity(0.12))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.appBlue)
                            }
                            Text(L10n.noBudget)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Text(L10n.createFirstBudget)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showAddBudget = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Définir un budget")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient.gradientPrimary)
                                        .shadow(color: Color.appBlue.opacity(0.3), radius: 8, y: 4)
                                )
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                    }
                } else {
                    Section(header: 
                        HStack {
                            Text(L10n.myBudgets)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(viewModel.budgets.count) actifs")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .textCase(nil)
                    ) {
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
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Budget")
                                .font(.system(size: 14, weight: .bold))
                        }
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

// MARK: - Bannière Hero d'Épargne & Cagnottes

struct SavingsBannerHeroCard: View {
    @ObservedObject var viewModel: FinanceViewModel
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                // Icône Cibles animée avec halo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "target")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("OBJECTIFS D'ÉPARGNE")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(Color.white.opacity(0.8))
                        
                        if !viewModel.savingsGoals.isEmpty {
                            Text("\(viewModel.savingsGoals.count)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "#064E3B"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#34D399"))
                                .clipShape(Capsule())
                        }
                    }
                    
                    let totalSaved = viewModel.savingsGoals.reduce(0) { $0 + $1.currentAmount }
                    Text(viewModel.savingsGoals.isEmpty ? "Créer vos cagnottes de projet" : "\(viewModel.formatAmount(totalSaved)) épargnés")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Ouvrir")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(18)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "#059669"),
                            Color(hex: "#10B981"),
                            Color(hex: "#06B6D4")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    RadialGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 150
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color(hex: "#10B981").opacity(colorScheme == .dark ? 0.3 : 0.2), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
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
        HStack(spacing: 20) {
            // Ring d'activité dynamique
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 11)
                    .frame(width: 76, height: 76)

                Circle()
                    .trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 11, lineCap: .round)
                    )
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.9, dampingFraction: 0.7), value: pct)

                VStack(spacing: 0) {
                    Text("\(Int(pct))%")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text(L10n.used)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Infos globales
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.globalBudget)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalBudget) : "••••")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.spent)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalSpent) : "••••")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appRed)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.remaining)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(remaining) : "••••")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            Spacer()
        }
    }
}

// MARK: - Carte de Budget Enrichie avec Badge de Statut

struct NativeBudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel

    private var progressColor: Color {
        progress.percentage > 90 ? Color.appRed : progress.percentage > 70 ? Color.appOrange : budget.category.color
    }

    private var statusBadge: (text: String, color: Color) {
        if progress.percentage > 100 {
            return ("Dépassement !", Color.appRed)
        } else if progress.percentage > 85 {
            return ("Attention", Color.appOrange)
        } else {
            return ("En sécurité", Color.appGreen)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                // Icône avec fond teinté
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(budget.category.color.opacity(0.15))
                        .frame(width: 42, height: 42)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(budget.category.color)
                }

                // Titre & Période
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(L10n.categoryName(budget.category))
                            .font(.system(size: 16, weight: .bold))
                        
                        Text(statusBadge.text)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(statusBadge.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusBadge.color.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    
                    Text(L10n.budgetPeriodName(budget.period))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Montants
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.isBalanceVisible ? viewModel.formatAmount(progress.spent) : "••••")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(progress.percentage > 90 ? Color.appRed : .primary)
                    Text(L10n.ofLimit(viewModel.isBalanceVisible ? budget.formattedLimit : "••••"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Barre de progression dégradée
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(progressColor)
                            .frame(width: geo.size.width * CGFloat(min(progress.percentage, 100) / 100), height: 7)
                            .animation(.spring(response: 0.6), value: progress.percentage)
                    }
                }
                .frame(height: 7)

                // Footer
                HStack {
                    Text(L10n.usedPercent(Int(progress.percentage)))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(progress.percentage > 90 ? Color.appRed : .secondary)
                    
                    Spacer()
                    
                    let remainingAmount = max(budget.limit - progress.spent, 0)
                    Text(L10n.remainsAmount(viewModel.isBalanceVisible ? viewModel.formatAmount(remainingAmount) : "••••"))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
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
                            .font(.headline)
                            .foregroundStyle(Color.appBlue)
                        TextField("0,00", text: $limitText)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
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
                    .fontWeight(.bold)
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
