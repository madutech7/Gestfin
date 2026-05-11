//
//  TransactionRow.swift
//  Gestfina
//
//  Ligne de transaction — Adaptive Light/Dark
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    var body: some View {
        HStack(spacing: 16) {
            // Icône catégorie
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(transaction.category.color.opacity(0.15))
                    .frame(width: 42, height: 42)
                
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(transaction.category.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(transaction.category.rawValue)
                    Text("·")
                    Text(transaction.date.relativeFormatted)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.headline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(transaction.type == .income ? .appGreen : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
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
        TransactionRow(transaction: Transaction.sampleData[0])
        TransactionRow(transaction: Transaction.sampleData[1])
        TransactionRow(transaction: Transaction.sampleData[2])
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
