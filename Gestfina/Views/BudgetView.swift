//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — Design premium Apple Activity Rings
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
                // Overview ring card
                Section {
                    overviewCard
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                // Budget list
                if viewModel.budgets.isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appBlue.opacity(0.12), Color.appCyan.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                Image(systemName: "chart.pie")
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundStyle(Color.appBlue)
                            }

                            VStack(spacing: 6) {
                                Text("Aucun budget défini")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Text("Créez votre premier budget pour\nsuivre vos dépenses intelligemment.")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    Section(header:
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet.circle.fill")
                                .foregroundColor(.appBlue)
                                .font(.system(size: 13))
                            Text("Mes budgets")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .textCase(nil)
                    ) {
                        ForEach(viewModel.budgets) { budget in
                            PremiumBudgetCard(
                                budget: budget,
                                progress: viewModel.budgetProgress(for: budget),
                                viewModel: viewModel
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
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
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                BudgetFormSheet(viewModel: viewModel, budgetToEdit: nil)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            .sheet(item: $budgetToEdit) { budget in
                BudgetFormSheet(viewModel: viewModel, budgetToEdit: budget)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
        }
    }

    // MARK: - Overview Card with Activity Ring

    private var overviewCard: some View {
        let totalBudget = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + $1.limit }
        let totalSpent  = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + viewModel.budgetProgress(for: $1).spent }
        let pct         = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
        let remaining   = max(totalBudget - totalSpent, 0)
        let ringColor: [Color] = pct > 90 ? [.appRed, .appOrange] : pct > 60 ? [.appOrange, .appYellow] : [.appGreen, .appCyan]

        return VStack(spacing: 20) {
            HStack(spacing: 28) {
                // Activity Ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.secondary.opacity(0.1), lineWidth: 12)
                        .frame(width: 100, height: 100)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                        .stroke(
                            AngularGradient(
                                colors: ringColor + [ringColor.first!],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: pct)

                    // Center label
                    VStack(spacing: 1) {
                        Text("\(Int(pct))%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("utilisé")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                // Stats
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Budget total")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(viewModel.formatAmount(totalBudget))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Circle().fill(Color.appRed).frame(width: 6, height: 6)
                                Text("Dépensé")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            Text(viewModel.formatAmount(totalSpent))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appRed)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Circle().fill(Color.appGreen).frame(width: 6, height: 6)
                                Text("Restant")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            Text(viewModel.formatAmount(remaining))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appGreen)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Premium Budget Card

struct PremiumBudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel
    @Environment(\.colorScheme) var colorScheme

    private var progressColor: Color {
        progress.percentage > 90 ? .appRed : progress.percentage > 70 ? .appOrange : budget.category.color
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [budget.category.color.opacity(0.18), budget.category.color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(budget.category.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(budget.category.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(1)
                    Text(budget.period.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(viewModel.formatAmount(progress.spent))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("/ \(budget.formattedLimit)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [progressColor, progressColor.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(min(progress.percentage, 100) / 100), height: 6)
                        .animation(.spring(response: 0.6), value: progress.percentage)
                }
            }
            .frame(height: 6)

            HStack {
                if progress.percentage > 90 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.appRed)
                        Text("\(Int(progress.percentage))% utilisé")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.appRed)
                    }
                } else {
                    Text("\(Int(progress.percentage))% utilisé")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Reste \(viewModel.formatAmount(max(budget.limit - progress.spent, 0)))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appGreen)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Budget Form Sheet (Add & Edit)

struct BudgetFormSheet: View {
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
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 130)
                }

                Section(header: Text("Limite")) {
                    HStack {
                        Text(viewModel.currencySymbol)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        TextField("0,00", text: $limitText)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .focused($limitFocused)
                    }
                    .padding(.vertical, 4)
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
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
                    } label: {
                        Text(isEditing ? "Enregistrer" : "Ajouter")
                            .fontWeight(.bold)
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { limitFocused = false }
                }
            }
            .onAppear {
                if let b = budgetToEdit {
                    category  = b.category
                    limitText = String(format: "%.2f", b.limit).replacingOccurrences(of: ".", with: ",")
                    period    = b.period
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
        PremiumBudgetCard(budget: budget, progress: progress, viewModel: viewModel)
    }
}

#Preview {
    BudgetView()
        .environmentObject(FinanceViewModel())
}
