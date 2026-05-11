//
//  AddTransactionView.swift
//  Gestfina
//
//  Formulaire d'ajout — Style iOS natif professionnel
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
                    }
                }
                
                // MARK: - Montant
                Section {
                    HStack {
                        Text(viewModel.currencySymbol)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        TextField("0,00", text: $amountText)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(selectedType == .income ? .appGreen : .appRed)
                            .keyboardType(.decimalPad)
                            .focused($amountFocused)
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Montant")
                }
                
                // MARK: - Informations
                Section {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(.appBlue)
                            .frame(width: 28)
                        TextField("Titre de la transaction", text: $title)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.appPurple)
                            .frame(width: 28)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .tint(.appBlue)
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "note.text")
                            .foregroundColor(.appOrange)
                            .frame(width: 28)
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
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 14) {
                        ForEach(categories) { category in
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    selectedCategory = category
                                }
                            } label: {
                                VStack(spacing: 7) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(selectedCategory == category
                                                  ? category.color
                                                  : category.color.opacity(0.1))
                                            .frame(width: 52, height: 52)
                                        
                                        Image(systemName: category.icon)
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(selectedCategory == category ? .white : category.color)
                                    }
                                    .shadow(color: selectedCategory == category ? category.color.opacity(0.35) : .clear, radius: 8, y: 4)
                                    
                                    Text(category.rawValue)
                                        .font(.system(size: 10, weight: selectedCategory == category ? .semibold : .regular))
                                        .foregroundColor(selectedCategory == category ? .primary : .secondary)
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
            .background(
                ZStack {
                    Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                    Circle()
                        .fill(Color.appBlue.opacity(0.04))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -150, y: -200)
                }
            )
            .scrollContentBackground(.hidden)
            .navigationTitle("Nouvelle transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveTransaction()
                    } label: {
                        Text("Ajouter")
                            .fontWeight(.semibold)
                    }
                    .disabled(!canSave)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { amountFocused = false }
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
        Haptics.shared.notify(.success)
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(FinanceViewModel())
}
