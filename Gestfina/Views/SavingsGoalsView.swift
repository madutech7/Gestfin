//
//  SavingsGoalsView.swift
//  Gestfina
//
//  Design Ultra-Premium Apple iOS 26 — Cagnottes & Objectifs d'Épargne
//

import SwiftUI

struct SavingsGoalsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddGoalSheet = false
    @State private var selectedGoal: SavingsGoal?
    @State private var depositAmount: String = ""
    
    // Champs pour nouvel objectif
    @State private var newTitle: String = ""
    @State private var newTargetAmount: String = ""
    @State private var newCurrentAmount: String = ""
    @State private var newSelectedColor: String = "#007AFF"
    @State private var newSelectedIcon: String = "target"
    
    private let availableIcons = ["target", "shield.fill", "airplane", "car.fill", "house.fill", "desktopcomputer", "bag.fill", "gift.fill"]
    private let availableColors = ["#6366F1", "#10B981", "#F59E0B", "#F43F5E", "#8B5CF6", "#06B6D4", "#EC4899"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Global Épargne
                        savingsHeaderCard
                        
                        // Liste des Cagnottes
                        if viewModel.savingsGoals.isEmpty {
                            emptyStateView
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Label("Mes Cagnottes", systemImage: "sparkles")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text("\(viewModel.savingsGoals.count) objectifs")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 4)
                                
                                ForEach(viewModel.savingsGoals) { goal in
                                    savingsGoalCard(goal)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Cagnottes & Épargne")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showingAddGoalSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.appBlue.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.appBlue)
                        }
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
    
    // MARK: - Header Récapitulatif
    
    private var savingsHeaderCard: some View {
        let totalSaved = viewModel.savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let totalTarget = viewModel.savingsGoals.reduce(0) { $0 + $1.targetAmount }
        let globalProgress = totalTarget > 0 ? min((totalSaved / totalTarget) * 100, 100) : 0
        
        return VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Épargné")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    Text(viewModel.formatAmount(totalSaved))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: globalProgress / 100)
                        .stroke(
                            LinearGradient.gradientGreen,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(globalProgress))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
            
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(LinearGradient.gradientGreen)
                            .frame(width: geo.size.width * CGFloat(globalProgress / 100), height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text("Objectif global : \(viewModel.formatAmount(totalTarget))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(viewModel.formatAmount(max(0, totalTarget - totalSaved))) restants")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.appGreen)
                }
            }
        }
        .padding(20)
        .liquidGlass(cornerRadius: 24)
        .shadow(color: Color.appGreen.opacity(0.12), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Carte d'objectif d'épargne
    
    private func savingsGoalCard(_ goal: SavingsGoal) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(goal.color.opacity(0.12))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: goal.iconName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(goal.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 4) {
                        Text(viewModel.formatAmount(goal.currentAmount))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(goal.color)
                        Text("/")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text(viewModel.formatAmount(goal.targetAmount))
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedGoal = goal
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Déposer")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(goal.color)
                            .shadow(color: goal.color.opacity(0.3), radius: 8, y: 4)
                    )
                }
            }
            
            // Jauge de progression
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.06))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(goal.color)
                            .frame(width: geo.size.width * CGFloat(goal.progressPercentage / 100), height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(Int(goal.progressPercentage))% atteint")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Reste \(viewModel.formatAmount(goal.remainingAmount))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 22)
    }
    
    // MARK: - État Vide
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appBlue.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "target")
                    .font(.system(size: 38))
                    .foregroundColor(.appBlue)
            }
            
            Text("Aucune cagnotte créée")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("Fixez-vous des objectifs d'épargne clairs pour concrétiser vos projets d'avenir.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showingAddGoalSheet = true
            } label: {
                Text("Créer une cagnotte")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(LinearGradient.gradientPrimary)
                            .shadow(color: Color.appBlue.opacity(0.35), radius: 12, y: 6)
                    )
            }
            .padding(.top, 8)
        }
        .padding(32)
        .liquidGlass(cornerRadius: 24)
    }
    
    // MARK: - Modales Sheets
    
    private var addGoalSheet: some View {
        NavigationView {
            Form {
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appBlue.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "flag.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appBlue)
                        }
                        TextField("Nom de la cagnotte (ex: Vacances)", text: $newTitle)
                    }
                    
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appGreen.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "target")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appGreen)
                        }
                        TextField("Montant cible", text: $newTargetAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appPurple.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "banknote.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appPurple)
                        }
                        TextField("Somme de départ (optionnelle)", text: $newCurrentAmount)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("INFORMATIONS DE LA CAGNOTTE")
                }
                
                Section {
                    HStack(spacing: 14) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 34, height: 34)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: newSelectedColor == colorHex ? 2.5 : 0)
                                )
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    newSelectedColor = colorHex
                                }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("COULEUR D'ACCENTUATION")
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
                        if let target = Double(newTargetAmount.replacingOccurrences(of: ",", with: ".")), !newTitle.isEmpty {
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
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Ajouter des fonds à")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(goal.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                }
                
                TextField("Montant à ajouter", text: $depositAmount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                    .liquidGlass(cornerRadius: 20)
                    .padding(.horizontal)
                
                Button {
                    if let amount = Double(depositAmount.replacingOccurrences(of: ",", with: ".")), amount > 0 {
                        viewModel.depositToSavingsGoal(goalId: goal.id, amount: amount)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        depositAmount = ""
                        selectedGoal = nil
                    }
                } label: {
                    Text("Confirmer le dépôt")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(goal.color)
                                .shadow(color: goal.color.opacity(0.35), radius: 10, y: 5)
                        )
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 24)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { selectedGoal = nil }
                }
            }
        }
        .presentationDetents([.height(340)])
    }
}
