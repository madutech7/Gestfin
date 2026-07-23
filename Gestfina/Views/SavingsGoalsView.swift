//
//  SavingsGoalsView.swift
//  Gestfina
//
//  Design Épuré & Sobriété Native iOS — Cagnottes & Objectifs d'Épargne
//

import SwiftUI

struct SavingsGoalsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddGoalSheet = false
    @State private var selectedGoalForDeposit: SavingsGoal?
    @State private var goalToDelete: SavingsGoal?
    @State private var showingDeleteAlert = false
    
    // Champs nouvel objectif
    @State private var newTitle: String = ""
    @State private var newTargetAmount: String = ""
    @State private var newCurrentAmount: String = ""
    @State private var newSelectedColor: String = "#007AFF"
    @State private var newSelectedIcon: String = "target"
    
    private let availableIcons = ["target", "shield.fill", "airplane", "car.fill", "house.fill", "desktopcomputer", "bag.fill", "gift.fill"]
    private let availableColors = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#32ADE6"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // En-tête Récapitulatif Épuré
                        savingsHeaderCard
                        
                        // Liste des Cagnottes
                        if viewModel.savingsGoals.isEmpty {
                            emptyStateView
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Mes cagnottes (\(viewModel.savingsGoals.count))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                
                                ForEach(viewModel.savingsGoals) { goal in
                                    savingsGoalCard(goal)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Cagnottes & Épargne")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        resetFields()
                        showingAddGoalSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.appBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoalSheet) {
                addGoalSheet
            }
            .sheet(item: $selectedGoalForDeposit) { goal in
                DepositSheetView(goal: goal, viewModel: viewModel)
            }
            .alert("Supprimer la cagnotte ?", isPresented: $showingDeleteAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    if let goal = goalToDelete {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.deleteSavingsGoal(goal)
                        }
                    }
                }
            } message: {
                if let goal = goalToDelete {
                    Text("Voulez-vous supprimer « \(goal.title) » ?")
                }
            }
        }
    }
    
    // MARK: - En-tête Sobriété
    
    private var savingsHeaderCard: some View {
        let totalSaved = viewModel.savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let totalTarget = viewModel.savingsGoals.reduce(0) { $0 + $1.targetAmount }
        let globalProgress = totalTarget > 0 ? min((totalSaved / totalTarget) * 100, 100) : 0
        let remainingGlobal = max(0, totalTarget - totalSaved)
        
        return VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Épargné")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalSaved) : "••••••")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(globalProgress))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appGreen)
                    Text("atteint")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Jauge simple et épurée
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(Color.appGreen)
                            .frame(width: geo.size.width * CGFloat(globalProgress / 100), height: 6)
                            .animation(.spring(response: 0.6), value: globalProgress)
                    }
                }
                .frame(height: 6)
                
                HStack {
                    Text("Cible : \(viewModel.isBalanceVisible ? viewModel.formatAmount(totalTarget) : "••••")")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Reste \(viewModel.isBalanceVisible ? viewModel.formatAmount(remainingGlobal) : "••••")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Carte Cagnotte Simple & Lisible
    
    private func savingsGoalCard(_ goal: SavingsGoal) -> some View {
        let isCompleted = goal.isCompleted
        
        return VStack(spacing: 14) {
            HStack(spacing: 12) {
                // Icône native simple
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(goal.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(goal.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.appGreen)
                        }
                    }
                    
                    Text("\(viewModel.isBalanceVisible ? viewModel.formatAmount(goal.currentAmount) : "••••") / \(viewModel.isBalanceVisible ? viewModel.formatAmount(goal.targetAmount) : "••••")")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    selectedGoalForDeposit = goal
                } label: {
                    Text(isCompleted ? "Complété" : "Déposer")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isCompleted ? .secondary : Color.appBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isCompleted ? Color.secondary.opacity(0.1) : Color.appBlue.opacity(0.12))
                        )
                }
            }
            
            // Barre de progression sobre
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 5)
                        
                        Capsule()
                            .fill(goal.color)
                            .frame(width: geo.size.width * CGFloat(goal.progressPercentage / 100), height: 5)
                            .animation(.spring(response: 0.5), value: goal.progressPercentage)
                    }
                }
                .frame(height: 5)
                
                HStack {
                    Text("\(Int(goal.progressPercentage))%")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !isCompleted {
                        Text("Reste \(viewModel.isBalanceVisible ? viewModel.formatAmount(goal.remainingAmount) : "••••")")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contextMenu {
            Button {
                selectedGoalForDeposit = goal
            } label: {
                Label("Verser des fonds", systemImage: "plus.circle")
            }
            
            Button(role: .destructive) {
                goalToDelete = goal
                showingDeleteAlert = true
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }
    
    // MARK: - État Vide Épuré
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color.appBlue)
            
            Text("Aucune cagnotte")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
            
            Text("Ajoutez un objectif d'épargne pour suivre l'avancement de vos projets.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                resetFields()
                showingAddGoalSheet = true
            } label: {
                Text("Créer une cagnotte")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.appBlue)
                    )
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Modale Ajout Native Form
    
    private var addGoalSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("DÉTAILS DE LA CAGNOTTE")) {
                    TextField("Nom de la cagnotte (ex: Vacances)", text: $newTitle)
                    
                    HStack {
                        Text(viewModel.currencySymbol)
                            .foregroundStyle(.secondary)
                        TextField("Montant cible", text: $newTargetAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Somme de départ")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("0", text: $newCurrentAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("ICÔNE")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                newSelectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .frame(width: 44, height: 44)
                                    .background(newSelectedIcon == icon ? Color.appBlue.opacity(0.15) : Color.clear)
                                    .foregroundColor(newSelectedIcon == icon ? Color.appBlue : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("COULEUR")) {
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: newSelectedColor == hex ? 2 : 0)
                                )
                                .onTapGesture {
                                    newSelectedColor = hex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Nouvelle Cagnotte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { showingAddGoalSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        if let target = Double(newTargetAmount.replacingOccurrences(of: ",", with: ".")), !newTitle.isEmpty, target > 0 {
                            let current = Double(newCurrentAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
                            let goal = SavingsGoal(
                                title: newTitle.trimmingCharacters(in: .whitespaces),
                                targetAmount: target,
                                currentAmount: current,
                                hexColor: newSelectedColor,
                                iconName: newSelectedIcon,
                                note: ""
                            )
                            viewModel.addSavingsGoal(goal)
                            showingAddGoalSheet = false
                            resetFields()
                        }
                    }
                    .bold()
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty || (Double(newTargetAmount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0)
                }
            }
        }
    }
    
    private func resetFields() {
        newTitle = ""
        newTargetAmount = ""
        newCurrentAmount = ""
        newSelectedColor = "#007AFF"
        newSelectedIcon = "target"
    }
}

// MARK: - Modale de Dépôt Simple

struct DepositSheetView: View {
    let goal: SavingsGoal
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var depositAmount: String = ""
    @FocusState private var isFieldFocused: Bool
    
    private var enteredAmount: Double {
        Double(depositAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Ajouter des fonds à")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(goal.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.top, 16)
                
                HStack {
                    Text(viewModel.currencySymbol)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.secondary)
                    TextField("0", text: $depositAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .focused($isFieldFocused)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                
                Button {
                    if enteredAmount > 0 {
                        viewModel.depositToSavingsGoal(goalId: goal.id, amount: enteredAmount)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    }
                } label: {
                    Text("Confirmer le dépôt")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(enteredAmount > 0 ? Color.appBlue : Color.gray.opacity(0.4))
                        )
                        .padding(.horizontal, 20)
                }
                .disabled(enteredAmount <= 0)
                
                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Déposer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onAppear {
                isFieldFocused = true
            }
        }
        .presentationDetents([.height(300)])
    }
}

#Preview {
    SavingsGoalsView()
        .environmentObject(FinanceViewModel())
}

#Preview {
    SavingsGoalsView()
        .environmentObject(FinanceViewModel())
}
