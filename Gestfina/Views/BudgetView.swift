//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — avec édition et suppression
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
                // Carte de synthèse globale
                Section {
                    overviewCard
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Liste des budgets
                if viewModel.budgets.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.appBlue.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.appBlue)
                                    .shadow(color: Color.appBlue.opacity(0.5), radius: 10, x: 0, y: 5)
                            }
                            
                            Text("Aucun budget défini")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Créez votre premier budget pour commencer à suivre vos dépenses intelligemment.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 10, x: 0, y: 4)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    Section(header: Text("Mes budgets")) {
                        ForEach(viewModel.budgets) { budget in
                            BudgetCard(
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
                                    viewModel.deleteBudget(budget)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(
                ZStack {
                    Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                    Circle()
                        .fill(Color.appOrange.opacity(colorScheme == .dark ? 0.05 : 0.03))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -150, y: 200)
                }
            )
            .scrollContentBackground(.hidden)
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            // Ajout d'un budget
            .sheet(isPresented: $showAddBudget) {
                BudgetFormSheet(viewModel: viewModel, budgetToEdit: nil)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            // Édition d'un budget
            .sheet(item: $budgetToEdit) { budget in
                BudgetFormSheet(viewModel: viewModel, budgetToEdit: budget)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
        }
    }
    
    private var overviewCard: some View {
        let totalBudget = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + $1.limit }
        let totalSpent  = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + viewModel.budgetProgress(for: $1).spent }
        let pct         = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
        let remaining   = max(totalBudget - totalSpent, 0)
        
        return VStack(spacing: 20) {
            HStack(spacing: 24) {
                // Anneau de progression
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 10)
                        .frame(width: 90, height: 90)
                    Circle()
                        .trim(from: 0, to: CGFloat(min(pct, 100)) / 100)
                        .stroke(
                            LinearGradient(
                                colors: pct > 90 ? [.appRed, .appOrange] : [.appGreen, .appCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8), value: pct)
                    
                    VStack(spacing: 1) {
                        Text("\(Int(pct))%")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("utilisé")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Budget total").font(.system(size: 12)).foregroundColor(.secondary)
                        Text(viewModel.formatAmount(totalBudget))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Dépensé").font(.system(size: 11)).foregroundColor(.secondary)
                            Text(viewModel.formatAmount(totalSpent))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.appRed)
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Restant").font(.system(size: 11)).foregroundColor(.secondary)
                            Text(viewModel.formatAmount(remaining))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.appGreen)
                                .lineLimit(1)
                                .minimumScaleFactor(0.4)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Budget Card

struct BudgetCard: View {
    let budget: Budget
    let progress: (spent: Double, percentage: Double)
    let viewModel: FinanceViewModel
    @State private var appeared = false
    @Environment(\.colorScheme) var colorScheme
    
    private var progressColor: Color {
        progress.percentage > 90 ? .appRed : progress.percentage > 70 ? .appOrange : budget.category.color
    }
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(budget.category.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: budget.category.icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(budget.category.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(budget.category.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(budget.period.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.formatAmount(progress.spent))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("/ \(budget.formattedLimit)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            
            // Barre de progression
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [progressColor, progressColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * CGFloat(min(progress.percentage, 100) / 100), height: 7)
                        .animation(.spring(response: 0.6), value: progress.percentage)
                }
            }
            .frame(height: 7)
            
            HStack {
                if progress.percentage > 90 {
                    Label {
                        Text("\(Int(progress.percentage))% utilisé")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.appRed)
                    } icon: {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.appRed)
                            .font(.system(size: 12))
                    }
                } else {
                    Text("\(Int(progress.percentage))% utilisé")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Il reste \(viewModel.formatAmount(max(budget.limit - progress.spent, 0)))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appGreen)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 4, x: 0, y: 2)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { appeared = true }
        }
    }
}

// MARK: - Budget Form Sheet (Ajout ET Édition)

struct BudgetFormSheet: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    let budgetToEdit: Budget?   // nil = nouveau budget
    
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
                            .foregroundColor(.secondary)
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
                        .foregroundColor(.secondary)
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
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        dismiss()
                    } label: {
                        Text(isEditing ? "Enregistrer" : "Ajouter")
                            .fontWeight(.semibold)
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

#Preview {
    BudgetView()
        .environmentObject(FinanceViewModel())
}
