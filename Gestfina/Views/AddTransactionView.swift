//
//  AddTransactionView.swift
//  Gestfina
//
//  Formulaire d'ajout Liquid Glass
//

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var amountText = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: TransactionCategory = .food
    @State private var date = Date()
    @State private var note = ""
    @State private var animateIn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond avec orbes
                Color.backgroundPrimary.ignoresSafeArea()
                Circle().fill(selectedType == .income ? Color.appGreen.opacity(0.06) : Color.appRed.opacity(0.06))
                    .frame(width: 300).blur(radius: 80).offset(y: -100)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        typeSelector
                        amountSection
                        glassField(title: "Titre", icon: "pencil.line") {
                            TextField("Ex: Courses, Salaire...", text: $title)
                                .foregroundColor(.textPrimary).font(.system(size: 15))
                        }
                        categorySection
                        glassField(title: "Date", icon: "calendar") {
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact).labelsHidden().tint(.appBlue)
                        }
                        glassField(title: "Note", icon: "note.text") {
                            TextField("Optionnel...", text: $note)
                                .foregroundColor(.textPrimary).font(.system(size: 15))
                        }
                        saveButton
                        Spacer(minLength: 40)
                    }.padding(20)
                }
            }
            .navigationTitle("Nouvelle Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle().fill(.ultraThinMaterial).frame(width: 32, height: 32)
                                .overlay(Circle().stroke(Color.glassBorder, lineWidth: 0.5))
                            Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { animateIn = true }
            }
        }
    }
    
    private var typeSelector: some View {
        HStack(spacing: 10) {
            ForEach(TransactionType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedType = type
                        selectedCategory = type == .income ? .salary : .food
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: type.icon).font(.system(size: 15))
                        Text(type.rawValue).font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(selectedType == type ? .white : .textSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(
                        ZStack {
                            if selectedType == type {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(type.color.opacity(0.25))
                                    .overlay(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial).opacity(0.3))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(type.color.opacity(0.3), lineWidth: 0.6))
                                    .shadow(color: type.color.opacity(0.2), radius: 8, y: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 0.4))
                            }
                        }
                    )
                }
            }
        }
        .scaleEffect(animateIn ? 1 : 0.9).opacity(animateIn ? 1 : 0)
    }
    
    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("Montant").font(.system(size: 12, weight: .medium)).foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                Text("€").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(.textTertiary)
                TextField("0,00", text: $amountText)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .liquidGlass(cornerRadius: 20, opacity: 0.06)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selectedType.color.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Catégorie", systemImage: "tag")
                .font(.system(size: 12, weight: .medium)).foregroundColor(.textSecondary)
            
            let categories = selectedType == .income
                ? TransactionCategory.incomeCategories
                : TransactionCategory.expenseCategories
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedCategory = category }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedCategory == category ? category.color.opacity(0.2) : Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedCategory == category ? category.color.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 0.5)
                                    )
                                    .frame(width: 48, height: 48)
                                    .shadow(color: selectedCategory == category ? category.color.opacity(0.2) : .clear, radius: 6, y: 2)
                                
                                Image(systemName: category.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedCategory == category ? category.color : .textSecondary)
                            }
                            
                            Text(category.rawValue)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(selectedCategory == category ? .textPrimary : .textTertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 20, opacity: 0.05)
    }
    
    private func glassField<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 12, weight: .medium)).foregroundColor(.textSecondary)
            content()
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 0.4))
                )
        }
    }
    
    private var saveButton: some View {
        Button { saveTransaction() } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 18))
                Text("Enregistrer").font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(
                ZStack {
                    if canSave {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(colors: [.appBlue, .appPurple], startPoint: .leading, endPoint: .trailing))
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial).opacity(0.15)
                    } else {
                        RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.06))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(canSave ? Color.appBlue.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 0.5)
            )
            .shadow(color: canSave ? Color.appBlue.opacity(0.25) : .clear, radius: 16, y: 6)
        }
        .disabled(!canSave)
    }
    
    private var canSave: Bool {
        !title.isEmpty && !amountText.isEmpty && (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }
    
    private func saveTransaction() {
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        viewModel.addTransaction(Transaction(title: title, amount: amount, date: date, category: selectedCategory, type: selectedType, note: note))
        dismiss()
    }
}

#Preview {
    AddTransactionView().environmentObject(FinanceViewModel()).preferredColorScheme(.dark)
}
