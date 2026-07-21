//
//  SavingsGoalsView.swift
//  Gestfina
//
//  Vue pour la gestion et le suivi des objectifs d'épargne (Cagnottes)
//

import SwiftUI

struct SavingsGoalsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddGoalSheet = false
    @State private var showingAddFundsSheet = false
    @State private var selectedGoal: SavingsGoal?
    @State private var depositAmount: String = ""
    
    // Champs pour nouveau goal
    @State private var newTitle: String = ""
    @State private var newTargetAmount: String = ""
    @State private var newCurrentAmount: String = ""
    @State private var newSelectedColor: String = "#007AFF"
    @State private var newSelectedIcon: String = "target"
    
    private let availableIcons = ["target", "shield.fill", "airplane", "car.fill", "house.fill", "desktopcomputer", "bag.fill", "gift.fill"]
    private let availableColors = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#5856D6", "#FFCC00"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Récapitulatif Épargne
                        savingsHeaderCard
                        
                        // Liste des Objectifs
                        if viewModel.savingsGoals.isEmpty {
                            emptyStateView
                        } else {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Mes Cagnottes")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.savingsGoals) { goal in
                                    savingsGoalCard(goal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Objectifs d'Épargne")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray, Color.white.opacity(0.1))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddGoalSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.appBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoalSheet) {
                addGoalSheet
            }
            .sheet(item: $selectedGoal) { goal in
                depositSheet(for: goal)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var savingsHeaderCard: some View {
        let totalSaved = viewModel.savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let totalTarget = viewModel.savingsGoals.reduce(0) { $0 + $1.targetAmount }
        let globalProgress = totalTarget > 0 ? min((totalSaved / totalTarget) * 100, 100) : 0
        
        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Épargné")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(viewModel.formatAmount(totalSaved))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 54, height: 54)
                    
                    Circle()
                        .trim(from: 0, to: globalProgress / 100)
                        .stroke(
                            LinearGradient(colors: [.appGreen, .appBlue], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 54, height: 54)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(globalProgress))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [.appGreen, .appBlue], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(globalProgress / 100), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Objectif global : \(viewModel.formatAmount(totalTarget))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private func savingsGoalCard(_ goal: SavingsGoal) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(0.2))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: goal.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(goal.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.formatAmount(goal.currentAmount)) sur \(viewModel.formatAmount(goal.targetAmount))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { selectedGoal = goal }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Alimenter")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(goal.color)
                    )
                }
            }
            
            // Jauge de progression
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goal.color)
                        .frame(width: geo.size.width * CGFloat(goal.progressPercentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.appCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Aucune cagnotte pour le moment")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Fixez-vous des objectifs d'épargne pour financer vos projets.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showingAddGoalSheet = true }) {
                Text("Créer un objectif")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.appBlue))
            }
            .padding(.top, 8)
        }
        .padding(30)
    }
    
    // MARK: - Sheets
    
    private var addGoalSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Détails de l'objectif")) {
                    TextField("Titre (ex: Fonds d'urgence)", text: $newTitle)
                    TextField("Montant cible", text: $newTargetAmount)
                        .keyboardType(.decimalPad)
                    TextField("Montant déjà épargné", text: $newCurrentAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Couleur")) {
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex) ?? .blue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: newSelectedColor == colorHex ? 3 : 0)
                                )
                                .onTapGesture {
                                    newSelectedColor = colorHex
                                }
                        }
                    }
                }
            }
            .navigationTitle("Nouvel Objectif")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { showingAddGoalSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        if let target = Double(newTargetAmount), !newTitle.isEmpty {
                            let current = Double(newCurrentAmount) ?? 0
                            let goal = SavingsGoal(
                                title: newTitle,
                                targetAmount: target,
                                currentAmount: current,
                                hexColor: newSelectedColor,
                                iconName: newSelectedIcon,
                                note: ""
                            )
                            viewModel.addSavingsGoal(goal)
                            showingAddGoalSheet = false
                            newTitle = ""
                            newTargetAmount = ""
                            newCurrentAmount = ""
                        }
                    }
                    .bold()
                }
            }
        }
    }
    
    private func depositSheet(for goal: SavingsGoal) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Alimenter '\(goal.title)'")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("Montant à ajouter", text: $depositAmount)
                    .keyboardType(.decimalPad)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appCardBackground))
                    .padding(.horizontal)
                
                Button(action: {
                    if let amount = Double(depositAmount), amount > 0 {
                        viewModel.depositToSavingsGoal(goalId: goal.id, amount: amount)
                        depositAmount = ""
                        selectedGoal = nil
                    }
                }) {
                    Text("Valider l'ajout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.appGreen))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 24)
            .background(Color.appBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { selectedGoal = nil }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}
