//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — Strict Apple Native iOS Design (HIG)
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showAddBudget = false
    @State private var budgetToEdit: Budget? = nil
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            List {
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
                            Image(systemName: "chart.pie")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.appBlue)
                            Text("Aucun budget défini")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Créez votre premier budget pour suivre vos dépenses de manière intelligente.")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                } else {
                    Section(header: Text("Mes budgets")) {
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
                                    Label("Modifier", systemImage: "pencil")
                                }
                                .tint(.appBlue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation(.spring(response: 0.35)) {
                                        viewModel.deleteBudget(budget)
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                NativeBudgetFormSheet(viewModel: viewModel, budgetToEdit: nil)
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $budgetToEdit) { budget in
                NativeBudgetFormSheet(viewModel: viewModel, budgetToEdit: budget)
                    .presentationDragIndicator(.visible)
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
        pct > 90 ? Color.appRed : pct > 60 ? Color.appOrange : Color.appBlue
    }

    var body: some View {
        HStack(spacing: 20) {
            // Activity Ring
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 12)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                    .stroke(
                        ringColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: pct)

                VStack(spacing: 0) {
                    Text("\(Int(pct))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("utilisé")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Text Info
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Budget global")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                    Text(viewModel.formatAmount(totalBudget))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dépensé")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                        Text(viewModel.formatAmount(totalSpent))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appRed)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Restant")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                        Text(viewModel.formatAmount(remaining))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            Spacer()
        }
    }
}

// MARK: - Native Budget Card

struct NativeBudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel

    private var progressColor: Color {
        progress.percentage > 90 ? Color.appRed : progress.percentage > 70 ? Color.appOrange : budget.category.color
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(budget.category.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(budget.category.color)
                }

                // Title & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.category.rawValue)
                        .font(.system(size: 17, weight: .semibold))
                    Text(budget.period.rawValue)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Amounts
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.formatAmount(progress.spent))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text("sur \(budget.formattedLimit)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }

            // Progress Bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(progressColor)
                            .frame(width: geo.size.width * CGFloat(min(progress.percentage, 100) / 100), height: 6)
                            .animation(.spring(response: 0.6), value: progress.percentage)
                    }
                }
                .frame(height: 6)

                // Footer
                HStack {
                    Text("\(Int(progress.percentage))% utilisé")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(progress.percentage > 90 ? Color.appRed : .secondary)
                    
                    Spacer()
                    
                    let remainingAmount = max(budget.limit - progress.spent, 0)
                    Text("Reste \(viewModel.formatAmount(remainingAmount))")
                        .font(.system(size: 12, weight: .regular))
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
                Section(header: Text("Catégorie")) {
                    Picker("Catégorie", selection: $category) {
                        ForEach(TransactionCategory.expenseCategories) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section(header: Text("Limite de dépense")) {
                    HStack {
                        Text(viewModel.currencySymbol)
                            .foregroundStyle(.secondary)
                        TextField("0,00", text: $limitText)
                            .keyboardType(.decimalPad)
                            .focused($limitFocused)
                    }
                }

                Section(header: Text("Fréquence")) {
                    Picker("Période", selection: $period) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(isEditing ? "Modifier le budget" : "Nouveau budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Enregistrer" : "Ajouter") {
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
                    Button("Terminé") {
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
