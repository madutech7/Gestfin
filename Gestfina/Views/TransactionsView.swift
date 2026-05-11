//
//  TransactionsView.swift
//  Gestfina
//
//  Liste des transactions — Style iOS natif professionnel
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                // Filtres période
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Tout", isSelected: viewModel.selectedFilter == nil, color: .appBlue) {
                                viewModel.selectedFilter = nil
                            }
                            FilterChip(title: "Revenus", isSelected: viewModel.selectedFilter == .income, color: .appGreen) {
                                viewModel.selectedFilter = .income
                            }
                            FilterChip(title: "Dépenses", isSelected: viewModel.selectedFilter == .expense, color: .appRed) {
                                viewModel.selectedFilter = .expense
                            }
                            
                            Divider().frame(height: 20)
                            
                            ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                                FilterChip(title: period.rawValue, isSelected: viewModel.selectedPeriod == period, color: .appPurple) {
                                    viewModel.selectedPeriod = period
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Résumé rapide
                if !viewModel.filteredTransactions.isEmpty {
                    Section {
                        HStack {
                            Label {
                                Text("\(viewModel.filteredTransactions.count) opérations")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            } icon: {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.appBlue)
                            }
                            Spacer()
                            Text("Solde : \(viewModel.formatAmount(viewModel.filteredTransactions.reduce(0) { $0 + $1.signedAmount }))")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Transactions
                if viewModel.filteredTransactions.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.appPurple.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.appPurple)
                                    .shadow(color: Color.appPurple.opacity(0.5), radius: 10, x: 0, y: 5)
                            }
                            Text("Aucune transaction")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("Ajoutez votre première transaction via le bouton + pour l'afficher ici.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 10, x: 0, y: 4)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    Section {
                        ForEach(viewModel.filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        transactionToDelete = transaction
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
            .background(
                ZStack {
                    Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                    Circle()
                        .fill(Color.appGreen.opacity(colorScheme == .dark ? 0.05 : 0.03))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: 150, y: -200)
                }
            )
            .scrollContentBackground(.hidden)
            .searchable(text: $viewModel.searchText, prompt: "Rechercher une transaction")
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Supprimer cette transaction ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                if let t = transactionToDelete { viewModel.deleteTransaction(t) }
            }
        } message: {
            if let t = transactionToDelete {
                Text("« \(t.title) » sera définitivement supprimée.")
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .appBlue
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) { action() }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isSelected ? color : Color(UIColor.tertiarySystemGroupedBackground))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TransactionsView()
        .environmentObject(FinanceViewModel())
}
