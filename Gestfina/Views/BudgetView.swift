//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — Design premium Apple Activity Rings & Liquid Glass
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showAddBudget = false
    @State private var budgetToEdit: Budget? = nil
    @State private var isAppeared = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                // ── BACKGROUND ──
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Subtle glowing orb in background
                Circle()
                    .fill(Color.appBlue.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: 100, y: -200)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // ── HERO OVERVIEW RING ──
                        HeroOverviewCard(viewModel: viewModel)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .scaleEffect(isAppeared ? 1 : 0.95)
                            .opacity(isAppeared ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAppeared)

                        // ── BUDGET LIST ──
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Mes Budgets")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if !viewModel.budgets.isEmpty {
                                    Text("\(viewModel.budgets.count)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.appBlue)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 24)
                            .opacity(isAppeared ? 1 : 0)
                            .animation(.easeIn.delay(0.1), value: isAppeared)

                            if viewModel.budgets.isEmpty {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.appBlue.opacity(0.15), Color.appCyan.opacity(0.05)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                        Image(systemName: "target")
                                            .font(.system(size: 40, weight: .light))
                                            .foregroundStyle(Color.appBlue)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("Aucun budget")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                        Text("Créez votre premier budget pour\nmaîtriser vos dépenses.")
                                            .font(.system(size: 15))
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    Button {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        showAddBudget = true
                                    } label: {
                                        Text("Créer un budget")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 200, height: 50)
                                            .background(Color.appBlue)
                                            .clipShape(Capsule())
                                            .shadow(color: Color.appBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                    .padding(.top, 10)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                .padding(.horizontal, 20)
                                .opacity(isAppeared ? 1 : 0)
                                .animation(.easeIn.delay(0.2), value: isAppeared)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(Array(viewModel.budgets.enumerated()), id: \.element.id) { index, budget in
                                        PremiumBudgetCard(
                                            budget: budget,
                                            progress: viewModel.budgetProgress(for: budget),
                                            viewModel: viewModel,
                                            onEdit: {
                                                budgetToEdit = budget
                                            },
                                            onDelete: {
                                                withAnimation(.spring(response: 0.35)) {
                                                    viewModel.deleteBudget(budget)
                                                }
                                            }
                                        )
                                        .padding(.horizontal, 20)
                                        .opacity(isAppeared ? 1 : 0)
                                        .offset(y: isAppeared ? 0 : 20)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1 + Double(index) * 0.05), value: isAppeared)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for bottom action button if needed
                    }
                }
                
                // ── FLOATING ADD BUTTON ──
                if !viewModel.budgets.isEmpty {
                    VStack {
                        Spacer()
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showAddBudget = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Nouveau")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.appBlue)
                            .clipShape(Capsule())
                            .shadow(color: Color.appBlue.opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                isAppeared = true
            }
            .sheet(isPresented: $showAddBudget) {
                BudgetFormSheet(viewModel: viewModel, budgetToEdit: nil)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            .sheet(item: $budgetToEdit) { budget in
                BudgetFormSheet(viewModel: viewModel, budgetToEdit: budget)
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
        }
    }
}

// MARK: - Hero Overview Card

struct HeroOverviewCard: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.colorScheme) var colorScheme
    
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
    
    private var ringColor: [Color] {
        pct > 90 ? [Color.appRed, Color.appOrange] : pct > 60 ? [Color.appOrange, Color.appYellow] : [Color.appGreen, Color.appCyan]
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 30) {
                // Large Activity Ring
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 16)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                        .stroke(
                            AngularGradient(
                                colors: ringColor + [ringColor.first!],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.2, dampingFraction: 0.7), value: pct)

                    VStack(spacing: 2) {
                        Text("\(Int(pct))%")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("utilisé")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .shadow(color: ringColor.first!.opacity(0.2), radius: 15, x: 0, y: 10)

                // Global Stats
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Budget global")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(viewModel.formatAmount(totalBudget))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Circle().fill(Color.appRed).frame(width: 6, height: 6)
                            Text("Dépensé")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(viewModel.formatAmount(totalSpent))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appRed)
                        }
                        
                        HStack {
                            Circle().fill(Color.appGreen).frame(width: 6, height: 6)
                            Text("Restant")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(viewModel.formatAmount(remaining))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appGreen)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Premium Budget Card

struct PremiumBudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var offset: CGFloat = 0

    private var progressColor: Color {
        progress.percentage > 90 ? Color.appRed : progress.percentage > 70 ? Color.appOrange : budget.category.color
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(budget.category.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(budget.category.color)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category.rawValue)
                        .font(.system(size: 17, weight: .bold))
                    Text(budget.period.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Amounts
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.formatAmount(progress.spent))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text("sur \(budget.formattedLimit)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Custom Slim Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [progressColor, progressColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(progress.percentage, 100) / 100), height: 8)
                            .animation(.spring(response: 0.6), value: progress.percentage)
                            .shadow(color: progressColor.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 8)

                // Footer
                HStack {
                    if progress.percentage > 90 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 11))
                            Text("\(Int(progress.percentage))% utilisé")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(Color.appRed)
                    } else {
                        Text("\(Int(progress.percentage))% utilisé")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    let remainingAmount = max(budget.limit - progress.spent, 0)
                    Text("Reste \(viewModel.formatAmount(remainingAmount))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(remainingAmount == 0 ? Color.appRed : Color.appGreen)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
        .contextMenu {
            Button { onEdit() } label: { Label("Modifier", systemImage: "pencil") }
            Button(role: .destructive) { onDelete() } label: { Label("Supprimer", systemImage: "trash") }
        }
    }
}

// MARK: - Premium Budget Form Sheet

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
            ZStack(alignment: .top) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // ── HERO AMOUNT INPUT ──
                        VStack(spacing: 12) {
                            Text("Limite du budget")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            
                            HStack(alignment: .center, spacing: 4) {
                                Text(viewModel.currencySymbol)
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                TextField("0,00", text: $limitText)
                                    .font(.system(size: 54, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.appBlue)
                                    .keyboardType(.decimalPad)
                                    .focused($limitFocused)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 40)
                        
                        // ── CONTROLS ──
                        VStack(spacing: 20) {
                            
                            // Category Selector
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Catégorie")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(TransactionCategory.expenseCategories) { cat in
                                            let isSelected = category == cat
                                            VStack(spacing: 8) {
                                                ZStack {
                                                    Circle()
                                                        .fill(isSelected ? cat.color : Color.secondary.opacity(0.1))
                                                        .frame(width: 56, height: 56)
                                                    Image(systemName: cat.icon)
                                                        .font(.system(size: 24, weight: .medium))
                                                        .foregroundStyle(isSelected ? Color.white : cat.color)
                                                }
                                                Text(cat.rawValue)
                                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                            }
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3)) {
                                                    category = cat
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            
                            // Frequency Selector
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Fréquence")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 8)
                                
                                HStack(spacing: 0) {
                                    ForEach(BudgetPeriod.allCases, id: \.self) { p in
                                        let isSelected = period == p
                                        Text(p.rawValue)
                                            .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                                            .foregroundStyle(isSelected ? Color.white : Color.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(isSelected ? Color.appBlue : Color.clear)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3)) {
                                                    period = p
                                                }
                                            }
                                    }
                                }
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // ── SAVE BUTTON ──
                VStack {
                    Spacer()
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
                        Text(isEditing ? "Enregistrer les modifications" : "Créer le budget")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(canSave ? Color.appBlue : Color.appBlue.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: canSave ? Color.appBlue.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(isEditing ? "Modifier" : "Nouveau")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.secondary.opacity(0.5))
                    }
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
        PremiumBudgetCard(budget: budget, progress: progress, viewModel: viewModel, onEdit: {}, onDelete: {})
    }
}

#Preview {
    BudgetView()
        .environmentObject(FinanceViewModel())
}
