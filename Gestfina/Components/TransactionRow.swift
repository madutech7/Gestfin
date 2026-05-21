//
//  TransactionRow.swift
//  Gestfina
//
//  Ligne de transaction — Design premium Apple-native
//

import SwiftUI

struct TransactionRow: View {
    let transaction: AppTransaction
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            // Category icon with subtle gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                transaction.category.color.opacity(0.18),
                                transaction.category.color.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(transaction.category.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(transaction.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    if transaction.isRecurring {
                        Image(systemName: "repeat")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.appBlue)
                            .padding(3)
                            .background(Color.appBlue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }

                HStack(spacing: 5) {
                    Text(transaction.category.rawValue)
                        .font(.system(size: 13, weight: .medium))
                    Text("·")
                        .font(.system(size: 13, weight: .bold))
                    Text(transaction.date.relativeFormatted)
                        .font(.system(size: 13))
                }
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.isBalanceVisible ? transaction.formattedAmount : "••••")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(transaction.type == .income ? Color.appGreen : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                // Subtle type indicator
                Text(transaction.type == .income ? "Revenu" : "Dépense")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(transaction.type == .income ? Color.appGreen.opacity(0.7) : Color.secondary.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: {
                Haptics.play(.light)
                UIPasteboard.general.string = transaction.formattedAmount
            }) {
                Label("Copier le montant", systemImage: "doc.on.doc")
            }
            Button(action: {
                Haptics.play(.light)
                UIPasteboard.general.string = transaction.title
            }) {
                Label("Copier le titre", systemImage: "text.cursor")
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        TransactionRow(transaction: AppTransaction.sampleData[0])
        TransactionRow(transaction: AppTransaction.sampleData[1])
        TransactionRow(transaction: AppTransaction.sampleData[2])
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
    .environmentObject(FinanceViewModel())
}
