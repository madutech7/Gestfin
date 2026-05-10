//
//  BudgetView.swift
//  Gestfina
//
//  Gestion des budgets — Style iOS natif professionnel
//

import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showAddBudget = false
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
                        VStack(spacing: 14) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                            Text("Aucun budget défini")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Créez votre premier budget pour\ncommencer à suivre vos dépenses.")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
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
            .sheet(isPresented: $showAddBudget) {
                AddBudgetSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
        }
    }
    
    private var overviewCard: some View {
        let totalBudget = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + $1.limit }
        let totalSpent = viewModel.budgets.filter(\.isActive).reduce(0) { $0 + viewModel.budgetProgress(for: $1).spent }
        let pct = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
        let remaining = max(totalBudget - totalSpent, 0)
        let progressColor: Color = pct > 90 ? .appRed : pct > 70 ? .appOrange : .appGreen
        
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
                    }
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Dépensé").font(.system(size: 11)).foregroundColor(.secondary)
                            Text(viewModel.formatAmount(totalSpent))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.appRed)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Restant").font(.system(size: 11)).foregroundColor(.secondary)
                            Text(viewModel.formatAmount(remaining))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.appGreen)
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
                    Text("/ \(budget.formattedLimit)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            // Barre de progression
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.12))
                        .frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [progressColor, progressColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress.percentage / 100), height: 7)
                        .animation(.spring(response: 0.6), value: progress.percentage)
                }
            }
            .frame(height: 7)
            
            HStack {
                Label {
                    Text("\(Int(progress.percentage))% utilisé")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(progress.percentage > 90 ? .appRed : .secondary)
                } icon: {
                    if progress.percentage > 90 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.appRed)
                            .font(.system(size: 12))
                    }
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

// MARK: - Add Budget Sheet

struct AddBudgetSheet: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    @State private var category: TransactionCategory = .food
    @State private var limitText = ""
    @State private var period: BudgetPeriod = .monthly
    @FocusState private var limitFocused: Bool
    
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
                
                Section(header: Text("Limite mensuelle")) {
                    HStack {
                        Text("€")
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
            .navigationTitle("Nouveau budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let limit = Double(limitText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        viewModel.addBudget(Budget(category: category, limit: limit, period: period))
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        dismiss()
                    } label: {
                        Text("Ajouter").fontWeight(.semibold)
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { limitFocused = false }
                }
            }
        }
    }
}

#Preview {
    BudgetView()
        .environmentObject(FinanceViewModel())
}
