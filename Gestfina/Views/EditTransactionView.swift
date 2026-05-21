//
//  EditTransactionView.swift
//  Gestfina
//
//  Formulaire de modification de transaction — Design Apple-native
//

import SwiftUI

struct EditTransactionView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @Environment(\.dismiss) var dismiss

    let transaction: AppTransaction

    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: TransactionCategory = .food
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isRecurring: Bool = false
    @State private var selectedFrequency: RecurringFrequency = .monthly
    @FocusState private var amountFocused: Bool

    var body: some View {
        NavigationView {
            SwiftUI.Form {
                // MARK: - Type Revenu / Dépense
                Section {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedType) {
                        if selectedType == .income && TransactionCategory.expenseCategories.contains(where: { $0 == selectedCategory }) {
                            selectedCategory = .salary
                        } else if selectedType == .expense && TransactionCategory.incomeCategories.contains(where: { $0 == selectedCategory }) {
                            selectedCategory = .food
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }

                // MARK: - Montant
                Section {
                    VStack(spacing: 8) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(viewModel.currencySymbol)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(.secondary)
                            TextField("0,00", text: $amountText)
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(selectedType == .income ? Color.appGreen : Color.primary)
                                .keyboardType(.decimalPad)
                                .focused($amountFocused)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)

                        HStack(spacing: 5) {
                            Image(systemName: selectedType == .income ? "arrow.down.left" : "arrow.up.right")
                                .font(.system(.caption2, weight: .bold))
                            Text(selectedType.rawValue)
                                .font(.system(.caption, weight: .semibold))
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

                    // MARK: - Récurrence
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $isRecurring.animation(.spring())) {
                            Label("Transaction récurrente", systemImage: "repeat")
                                .foregroundStyle(isRecurring ? Color.appBlue : .primary)
                        }
                        .tint(.appBlue)
                        
                        if isRecurring {
                            Picker("Fréquence", selection: $selectedFrequency) {
                                ForEach(RecurringFrequency.allCases) { freq in
                                    Text(freq.rawValue).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
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
                                        .font(.system(.caption2, weight: selectedCategory == category ? .bold : .medium))
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

                // MARK: - Supprimer
                Section {
                    Button(role: .destructive) {
                        deleteTransaction()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Supprimer cette transaction")
                                .font(.system(.headline, design: .rounded))
                            Spacer()
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .navigationTitle("Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveChanges()
                    } label: {
                        Text("Enregistrer")
                            .font(.headline)
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                title = transaction.title
                amountText = String(format: "%.2f", transaction.amount).replacingOccurrences(of: ".", with: ",")
                selectedType = transaction.type
                selectedCategory = transaction.category
                date = transaction.date
                note = transaction.note
                isRecurring = transaction.isRecurring
                selectedFrequency = transaction.recurringFrequency ?? .monthly
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !amountText.isEmpty
        && (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    private func deleteTransaction() {
        viewModel.deleteTransaction(transaction)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }

    private func saveChanges() {
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        var updated = transaction
        updated.title = title.trimmingCharacters(in: .whitespaces)
        updated.amount = amount
        updated.date = date
        updated.category = selectedCategory
        updated.type = selectedType
        updated.note = note
        updated.isRecurring = isRecurring
        updated.recurringFrequency = isRecurring ? selectedFrequency : nil
        
        viewModel.updateTransaction(updated)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }
}
