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
    @State private var isRecurring = false
    @State private var selectedFrequency: RecurringFrequency = .monthly
    @State private var selectedAccountId: UUID?
    @State private var showingScanner = false
    @FocusState private var amountFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Type Revenu / Dépense
                Section {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            let title = type == .income ? L10n.incomeType : L10n.expenseType
                            Label(title, systemImage: type.icon).tag(type)
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

                        // Type badge
                        HStack(spacing: 5) {
                            Image(systemName: selectedType == .income ? "arrow.down.left" : "arrow.up.right")
                                .font(.system(.caption2, weight: .bold))
                                .accessibilityHidden(true)
                            Text(selectedType == .income ? L10n.incomeType : L10n.expenseType)
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
                    Text(L10n.amount)
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
                        TextField(L10n.transactionTitle, text: $title)
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
                        TextField(L10n.noteOptional, text: $note, axis: .vertical)
                            .lineLimit(3, reservesSpace: false)
                    }

                    // MARK: - Récurrence
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $isRecurring.animation(.spring())) {
                            Label(L10n.recurringTransaction, systemImage: "repeat")
                                .foregroundStyle(isRecurring ? Color.appBlue : .primary)
                        }
                        .tint(.appBlue)
                        
                        if isRecurring {
                            Picker(L10n.frequency, selection: $selectedFrequency) {
                                ForEach(RecurringFrequency.allCases) { freq in
                                    Text(L10n.frequencyName(freq)).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(L10n.information)
                }

                // MARK: - Compte / Portefeuille
                Section {
                    Picker("Compte", selection: $selectedAccountId) {
                        Text("Aucun (Par défaut)").tag(UUID?.none)
                        ForEach(viewModel.accounts) { acc in
                            HStack {
                                Image(systemName: acc.iconName)
                                Text(acc.name)
                            }
                            .tag(UUID?.some(acc.id))
                        }
                    }
                } header: {
                    Text("Compte / Portefeuille")
                }
                
                // MARK: - Scan OCR
                Section {
                    Button(action: { showingScanner = true }) {
                        HStack {
                            Image(systemName: "doc.viewfinder")
                                .font(.headline)
                                .foregroundColor(.appBlue)
                            Text("Scanner un reçu / facture (OCR)")
                                .font(.subheadline)
                                .foregroundColor(.appBlue)
                                .bold()
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
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

                                    Text(L10n.categoryName(category))
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
                    Text(L10n.category)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .navigationTitle(L10n.newTransaction)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveTransaction()
                    } label: {
                        Text(L10n.addButton)
                            .font(.headline)
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { amountFocused = false }
                        .font(.subheadline)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    amountFocused = true
                }
            }
            .sheet(isPresented: $showingScanner) {
                ReceiptScannerView { detectedAmount, detectedMerchant in
                    if let amount = detectedAmount {
                        self.amountText = String(format: "%.2f", amount)
                    }
                    if let merchant = detectedMerchant, !merchant.isEmpty {
                        self.title = merchant
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !amountText.isEmpty
        && (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
        && (Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 999_999_999
    }

    private func saveTransaction() {
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let transaction = AppTransaction(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            date: date,
            category: selectedCategory,
            type: selectedType,
            note: note,
            isRecurring: isRecurring,
            recurringFrequency: isRecurring ? selectedFrequency : nil,
            accountId: selectedAccountId
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
