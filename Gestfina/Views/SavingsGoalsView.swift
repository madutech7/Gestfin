//
//  SavingsGoalsView.swift
//  Gestfina
//
//  Design Ultra-Premium Apple Wallet × Glassmorphic iOS — Cagnottes & Objectifs d'Épargne
//

import SwiftUI

struct SavingsGoalsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddGoalSheet = false
    @State private var selectedGoalForDeposit: SavingsGoal?
    @State private var goalToDelete: SavingsGoal?
    @State private var showingDeleteAlert = false
    
    // Champs pour nouvel objectif
    @State private var newTitle: String = ""
    @State private var newTargetAmount: String = ""
    @State private var newCurrentAmount: String = ""
    @State private var newSelectedColor: String = "#6366F1"
    @State private var newSelectedIcon: String = "target"
    @FocusState private var isAmountFocused: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    // Templates de cagnottes rapides
    private struct GoalTemplate: Identifiable {
        let id = UUID()
        let title: String
        let defaultTarget: Double
        let icon: String
        let colorHex: String
    }
    
    private let templates: [GoalTemplate] = [
        GoalTemplate(title: "Fonds de Sécurité", defaultTarget: 500000, icon: "shield.fill", colorHex: "#10B981"),
        GoalTemplate(title: "Vacances & Voyages", defaultTarget: 300000, icon: "airplane", colorHex: "#06B6D4"),
        GoalTemplate(title: "Projet High-Tech", defaultTarget: 450000, icon: "desktopcomputer", colorHex: "#6366F1"),
        GoalTemplate(title: "Auto / Véhicule", defaultTarget: 1500000, icon: "car.fill", colorHex: "#F59E0B"),
        GoalTemplate(title: "Immobilier & Maison", defaultTarget: 2000000, icon: "house.fill", colorHex: "#8B5CF6"),
        GoalTemplate(title: "Cadeaux & Événements", defaultTarget: 100000, icon: "gift.fill", colorHex: "#EC4899")
    ]
    
    private let availableIcons = ["target", "shield.fill", "airplane", "car.fill", "house.fill", "desktopcomputer", "bag.fill", "gift.fill", "cart.fill", "briefcase.fill", "heart.fill", "gamecontroller.fill"]
    private let availableColors = ["#6366F1", "#10B981", "#F59E0B", "#F43F5E", "#8B5CF6", "#06B6D4", "#EC4899", "#3B82F6"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond immersif avec Orbs lumineux
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    Circle()
                        .fill(Color.appGreen.opacity(colorScheme == .dark ? 0.08 : 0.05))
                        .frame(width: geo.size.width * 0.9)
                        .offset(x: -geo.size.width * 0.3, y: -geo.size.height * 0.1)
                        .blur(radius: 90)
                    
                    Circle()
                        .fill(Color.appBlue.opacity(colorScheme == .dark ? 0.08 : 0.04))
                        .frame(width: geo.size.width * 0.8)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.5)
                        .blur(radius: 90)
                }
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Global Hero
                        savingsHeaderHero
                        
                        // Liste des Cagnottes ou État Vide
                        if viewModel.savingsGoals.isEmpty {
                            emptyStateView
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(LinearGradient.gradientGreen)
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Mes Cagnottes")
                                            .font(.system(size: 19, weight: .bold, design: .rounded))
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.savingsGoals.count) objectif\(viewModel.savingsGoals.count > 1 ? "s" : "")")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
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
                    .padding(.bottom, 40)
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
                        resetAddGoalFields()
                        showingAddGoalSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Ajouter")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(LinearGradient.gradientGreen)
                                .shadow(color: Color.appGreen.opacity(0.3), radius: 8, y: 3)
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAddGoalSheet) {
                addGoalSheet
            }
            .sheet(item: $selectedGoalForDeposit) { goal in
                DepositSheetView(goal: goal, viewModel: viewModel)
            }
            .alert("Supprimer cette cagnotte ?", isPresented: $showingDeleteAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    if let goal = goalToDelete {
                        withAnimation(.spring(response: 0.35)) {
                            viewModel.deleteSavingsGoal(goal)
                        }
                    }
                }
            } message: {
                if let goal = goalToDelete {
                    Text("Voulez-vous vraiment supprimer la cagnotte « \(goal.title) » ? Cette action est irréversible.")
                }
            }
        }
    }
    
    // MARK: - Header Hero Card
    
    private var savingsHeaderHero: some View {
        let totalSaved = viewModel.savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let totalTarget = viewModel.savingsGoals.reduce(0) { $0 + $1.targetAmount }
        let globalProgress = totalTarget > 0 ? min((totalSaved / totalTarget) * 100, 100) : 0
        let remainingGlobal = max(0, totalTarget - totalSaved)
        
        return VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.text.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("TOTAL ÉPARGNÉ")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                    }
                    .foregroundStyle(Color.white.opacity(0.7))
                    
                    Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalSaved) : "••••••")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Ring de progression global
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 8)
                        .frame(width: 64, height: 64)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(globalProgress / 100))
                        .stroke(
                            LinearGradient(colors: [Color(hex: "#34D399"), Color(hex: "#38BDF8")], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: globalProgress)
                    
                    VStack(spacing: 0) {
                        Text("\(Int(globalProgress))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
            
            // Jauge dynamique avec détails
            VStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(colors: [Color(hex: "#34D399"), Color(hex: "#38BDF8")], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(globalProgress / 100), height: 8)
                            .animation(.spring(response: 0.8), value: globalProgress)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    HStack(spacing: 4) {
                        Text("Cible :")
                            .foregroundStyle(Color.white.opacity(0.6))
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(totalTarget) : "••••")
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Reste :")
                            .foregroundStyle(Color.white.opacity(0.6))
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(remainingGlobal) : "••••")
                            .foregroundStyle(Color(hex: "#34D399"))
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                }
            }
        }
        .padding(22)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#0F172A"),
                        Color(hex: "#1E293B"),
                        Color(hex: "#064E3B").opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                RadialGradient(
                    colors: [Color(hex: "#10B981").opacity(0.25), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 220
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color(hex: "#10B981").opacity(colorScheme == .dark ? 0.25 : 0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Carte d'objectif d’épargne Ultra-Premium
    
    private func savingsGoalCard(_ goal: SavingsGoal) -> some View {
        let isCompleted = goal.isCompleted
        
        return VStack(spacing: 16) {
            HStack(spacing: 14) {
                // Icône avec Halo de couleur d'accentuation
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(goal.color.opacity(0.16))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: goal.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(goal.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(goal.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        if isCompleted {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.appGreen)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(goal.currentAmount) : "••••")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(goal.color)
                        Text("/")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isBalanceVisible ? viewModel.formatAmount(goal.targetAmount) : "••••")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Bouton "Déposer" / Statut
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedGoalForDeposit = goal
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: isCompleted ? "sparkles" : "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(isCompleted ? "Complété" : "Déposer")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(isCompleted ? goal.color : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isCompleted ? goal.color.opacity(0.15) : goal.color)
                            .shadow(color: isCompleted ? .clear : goal.color.opacity(0.35), radius: 8, y: 4)
                    )
                }
            }
            
            // Jauge de progression stylisée
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                            .frame(height: 9)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [goal.color, goal.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(goal.progressPercentage / 100), height: 9)
                            .animation(.spring(response: 0.6), value: goal.progressPercentage)
                    }
                }
                .frame(height: 9)
                
                HStack {
                    if isCompleted {
                        Text("🏆 Objectif atteint avec succès !")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appGreen)
                    } else {
                        Text("\(Int(goal.progressPercentage))% atteint")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Reste \(viewModel.isBalanceVisible ? viewModel.formatAmount(goal.remainingAmount) : "••••")")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 12, x: 0, y: 4)
        .contextMenu {
            Button {
                selectedGoalForDeposit = goal
            } label: {
                Label("Ajouter des fonds", systemImage: "plus.circle")
            }
            
            Button(role: .destructive) {
                goalToDelete = goal
                showingDeleteAlert = true
            } label: {
                Label("Supprimer la cagnotte", systemImage: "trash")
            }
        }
    }
    
    // MARK: - État Vide Interactif avec Templates
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appGreen.opacity(0.18), Color.appBlue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "target")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(LinearGradient.gradientGreen)
                }
                
                Text("Aucune cagnotte pour le moment")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Fixez-vous des objectifs financiers pour réaliser vos projets : voyage, épargne de précaution, achat important...")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            // Recommandations 1-Click Templates
            VStack(alignment: .leading, spacing: 12) {
                Text("Idées de cagnottes populaires :")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(templates) { template in
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                newTitle = template.title
                                newTargetAmount = String(format: "%.0f", template.defaultTarget)
                                newSelectedIcon = template.icon
                                newSelectedColor = template.colorHex
                                showingAddGoalSheet = true
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: template.colorHex).opacity(0.15))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: template.icon)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(Color(hex: template.colorHex))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(template.title)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.primary)
                                        Text(viewModel.formatAmount(template.defaultTarget))
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                resetAddGoalFields()
                showingAddGoalSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Créer une cagnotte personnalisée")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(LinearGradient.gradientGreen)
                        .shadow(color: Color.appGreen.opacity(0.35), radius: 12, y: 6)
                )
            }
            .padding(.top, 4)
        }
        .padding(26)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
    
    // MARK: - Modale de Création d'Objectif Modernisée
    
    private var addGoalSheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Visuel
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: newSelectedColor).opacity(0.15))
                                .frame(width: 72, height: 72)
                            Image(systemName: newSelectedIcon)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(Color(hex: newSelectedColor))
                        }
                        
                        Text(newTitle.isEmpty ? "Nouvelle Cagnotte" : newTitle)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 12)
                    
                    // Champs Saisie
                    VStack(spacing: 16) {
                        // Titre
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOM DE LA CAGNOTTE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(Color(hex: newSelectedColor))
                                    .frame(width: 24)
                                TextField("Ex: Voyage au Japon, Moto, Fonds d'urgence", text: $newTitle)
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .padding(14)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        
                        // Montant Cible
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MONTANT CIBLE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text(viewModel.currencySymbol)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.appGreen)
                                    .frame(width: 24)
                                TextField("0,00", text: $newTargetAmount)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .focused($isAmountFocused)
                            }
                            .padding(14)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        
                        // Somme Initiale (Optionnelle)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SOMME ACTUELLE DÉJÀ ÉPARGNÉE (OPTIONNEL)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: "banknote.fill")
                                    .foregroundColor(.appPurple)
                                    .frame(width: 24)
                                TextField("0,00", text: $newCurrentAmount)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .keyboardType(.decimalPad)
                            }
                            .padding(14)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    
                    // Sélecteur d'icône
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ICÔNE DE LA CAGNOTTE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    newSelectedIcon = icon
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(newSelectedIcon == icon ? Color(hex: newSelectedColor).opacity(0.2) : Color(UIColor.secondarySystemGroupedBackground))
                                            .frame(height: 48)
                                        Image(systemName: icon)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(newSelectedIcon == icon ? Color(hex: newSelectedColor) : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Sélecteur de couleur
                    VStack(alignment: .leading, spacing: 10) {
                        Text("COULEUR D'ACCENTUATION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 14) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: newSelectedColor == colorHex ? 3 : 0)
                                    )
                                    .scaleEffect(newSelectedColor == colorHex ? 1.15 : 1.0)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation(.spring(response: 0.25)) {
                                            newSelectedColor = colorHex
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    
                    // Bouton Valider
                    Button {
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
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showingAddGoalSheet = false
                            resetAddGoalFields()
                        }
                    } label: {
                        Text("Créer la cagnotte")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color(hex: newSelectedColor))
                                    .shadow(color: Color(hex: newSelectedColor).opacity(0.4), radius: 10, y: 5)
                            )
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty || (Double(newTargetAmount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0)
                    .opacity(newTitle.trimmingCharacters(in: .whitespaces).isEmpty || (Double(newTargetAmount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0 ? 0.5 : 1.0)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Nouvelle Cagnotte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { showingAddGoalSheet = false }
                }
            }
        }
    }
    
    private func resetAddGoalFields() {
        newTitle = ""
        newTargetAmount = ""
        newCurrentAmount = ""
        newSelectedColor = "#6366F1"
        newSelectedIcon = "target"
    }
}

// MARK: - Modale de Dépôt Interactive Ultra-Stylisée

struct DepositSheetView: View {
    let goal: SavingsGoal
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var depositAmount: String = ""
    @FocusState private var isFieldFocused: Bool
    
    private var quickChips: [Double] {
        let remaining = goal.remainingAmount
        if remaining <= 50000 {
            return [5000, 10000, 25000, remaining]
        } else {
            return [10000, 25000, 50000, 100000]
        }
    }
    
    private var enteredAmount: Double {
        Double(depositAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    
    private var projectedTotal: Double {
        goal.currentAmount + enteredAmount
    }
    
    private var projectedProgress: Double {
        goal.targetAmount > 0 ? min((projectedTotal / goal.targetAmount) * 100, 100) : 0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Entête Objectif
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: goal.iconName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(goal.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("Solde actuel : \(viewModel.formatAmount(goal.currentAmount)) / Cible : \(viewModel.formatAmount(goal.targetAmount))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Hero Field Montant
                VStack(spacing: 6) {
                    Text("MONTANT DU DÉPÔT")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(viewModel.currencySymbol)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(goal.color)
                        
                        TextField("0", text: $depositAmount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .focused($isFieldFocused)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 8)
                }
                
                // Quick Chips
                HStack(spacing: 8) {
                    ForEach(quickChips, id: \.self) { amount in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            depositAmount = String(format: "%.0f", amount)
                        } label: {
                            Text("+\(viewModel.formatAmount(amount))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(enteredAmount == amount ? .white : goal.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(enteredAmount == amount ? goal.color : goal.color.opacity(0.12))
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                // Prévisualisation de la jauge avec le dépôt
                VStack(spacing: 6) {
                    HStack {
                        Text("Progression après versement")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(projectedProgress))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(goal.color)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.12))
                                .frame(height: 8)
                            
                            // Progression actuelle
                            Capsule()
                                .fill(goal.color.opacity(0.4))
                                .frame(width: geo.size.width * CGFloat(goal.progressPercentage / 100), height: 8)
                            
                            // Projection avec nouveau versement
                            Capsule()
                                .fill(goal.color)
                                .frame(width: geo.size.width * CGFloat(projectedProgress / 100), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Bouton de confirmation
                Button {
                    if enteredAmount > 0 {
                        viewModel.depositToSavingsGoal(goalId: goal.id, amount: enteredAmount)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    }
                } label: {
                    Text("Confirmer le versement")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(enteredAmount > 0 ? goal.color : Color.gray.opacity(0.4))
                                .shadow(color: enteredAmount > 0 ? goal.color.opacity(0.35) : .clear, radius: 10, y: 5)
                        )
                        .padding(.horizontal, 20)
                }
                .disabled(enteredAmount <= 0)
            }
            .padding(.bottom, 20)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Verser à la cagnotte")
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
        .presentationDetents([.height(440)])
    }
}

#Preview {
    SavingsGoalsView()
        .environmentObject(FinanceViewModel())
}
