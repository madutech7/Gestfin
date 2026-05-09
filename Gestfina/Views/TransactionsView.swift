//
//  TransactionsView.swift
//  Gestfina
//
//  Liste des transactions Liquid Glass
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                searchBar
                filterChips
                transactionsList
            }
            .background(Color.clear)
            .navigationBarHidden(true)
        }
        .alert("Supprimer ?", isPresented: $showDeleteAlert) {
            Button("Annuler", role: .cancel) { }
            Button("Supprimer", role: .destructive) {
                if let t = transactionToDelete { viewModel.deleteTransaction(t) }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Transactions")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Text("\(viewModel.filteredTransactions.count) opérations")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20).padding(.top, 16)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textTertiary)
            
            TextField("Rechercher une transaction...", text: $viewModel.searchText)
                .font(.system(size: 15))
                .foregroundColor(.textPrimary)
                .autocorrectionDisabled()
            
            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(14)
        .liquidGlass(cornerRadius: 16, opacity: 0.05)
        .padding(.horizontal, 20).padding(.top, 14)
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                GlassChip(title: "Tout", isSelected: viewModel.selectedFilter == nil) { viewModel.selectedFilter = nil }
                GlassChip(title: "Revenus", isSelected: viewModel.selectedFilter == .income, color: .appGreen) { viewModel.selectedFilter = .income }
                GlassChip(title: "Dépenses", isSelected: viewModel.selectedFilter == .expense, color: .appRed) { viewModel.selectedFilter = .expense }
                
                Divider().frame(height: 20).opacity(0.3)
                
                ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                    GlassChip(title: period.rawValue, isSelected: viewModel.selectedPeriod == period, color: .appPurple) {
                        viewModel.selectedPeriod = period
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
    }
    
    private var transactionsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 8) {
                if viewModel.filteredTransactions.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.filteredTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                            .contextMenu {
                                Button(role: .destructive) {
                                    transactionToDelete = transaction
                                    showDeleteAlert = true
                                } label: { Label("Supprimer", systemImage: "trash") }
                            }
                    }
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.glassBorder, lineWidth: 0.5))
                
                Image(systemName: "tray")
                    .font(.system(size: 32))
                    .foregroundColor(.textTertiary)
            }
            
            Text("Aucune transaction")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textSecondary)
            
            Text("Ajoutez votre première transaction\navec le bouton +")
                .font(.system(size: 13))
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
}

// MARK: - Glass Filter Chip

struct GlassChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .appBlue
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { action() }
        }) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(color.opacity(0.3))
                                .overlay(Capsule().fill(.ultraThinMaterial).opacity(0.3))
                                .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 0.5))
                                .shadow(color: color.opacity(0.2), radius: 8, y: 2)
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.04))
                                .overlay(Capsule().stroke(Color.white.opacity(0.06), lineWidth: 0.4))
                        }
                    }
                )
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        TransactionsView()
    }
    .environmentObject(FinanceViewModel())
    .preferredColorScheme(.dark)
}
