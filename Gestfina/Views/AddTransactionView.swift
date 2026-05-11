//
//  AddTransactionView.swift
//  Gestfina
//
//  Formulaire d'ajout — Design premium Apple-native
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
    @FocusState private var amountFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Type Revenu / Dépense
                Section {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) {
                        selectedCategory = selectedType == .income ? .salary : .food
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }

                // MARK: - Montant (Hero)
                Section {
                    VStack(spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(viewModel.currencySymbol)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            TextField("0,00", text: $amountText)
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(selectedType == .income ? Color.appGreen : Color.primary)
                                .keyboardType(.decimalPad)
                                .focused($amountFocused)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)

                        // Type badge
                        HStack(spacing: 5) {
                            Image(systemName: selectedType == .income ? "arrow.down.left" : "arrow.up.right")
                                .font(.system(size: 10, weight: .bold))
                            Text(selectedType.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(selectedType == .income ? Color.appGreen : Color.appRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(selectedType == .income ? Color.appGreen.opacity(0.12) : Color.appRed.opacity(0.12))
                        )
                    }
                } header: {
                    Text("Montant")
                }

                // MARK: - Informations
                Section {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appBlue.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "pencil")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appBlue)
                        }
                        TextField("Titre de la transaction", text: $title)
                    }

                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appPurple.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appPurple)
                        }
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .tint(.appBlue)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appOrange.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "note.text")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appOrange)
                        }
                        .padding(.top, 3)
                        TextField("Note (optionnel)", text: $note, axis: .vertical)
                            .lineLimit(3, reservesSpace: false)
                    }
                } header: {
                    Text("Informations")
                }

                // MARK: - Catégorie
                Section {
                    let categories = selectedType == .income
                        ? TransactionCategory.incomeCategories
                        : TransactionCategory.expenseCategories

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 14) {
                        ForEach(categories) { category in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    selectedCategory = category
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(selectedCategory == category
                                                  ? category.color
                                                  : category.color.opacity(0.1))
                                            .frame(width: 50, height: 50)

                                        Image(systemName: category.icon)
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundStyle(selectedCategory == category ? .white : category.color)
                                    }
                                    .shadow(color: selectedCategory == category ? category.color.opacity(0.35) : .clear, radius: 8, y: 4)

                                    Text(category.rawValue)
                                        .font(.system(size: 10, weight: selectedCategory == category ? .bold : .medium))
                                        .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Catégorie")
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .navigationTitle("Nouvelle transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveTransaction()
                    } label: {
                        Text("Ajouter")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { amountFocused = false }
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    amountFocused = true
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !amountText.isEmpty
        && (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    private func saveTransaction() {
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let transaction = Transaction(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            date: date,
            category: selectedCategory,
            type: selectedType,
            note: note
        )
        viewModel.addTransaction(transaction)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(FinanceViewModel())
}
