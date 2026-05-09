//
//  TransactionRow.swift
//  Gestfina
//
//  Ligne de transaction Liquid Glass
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 14) {
            // Icône glass
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(transaction.category.color.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(transaction.category.color.opacity(0.12), lineWidth: 0.5)
                    )
                    .frame(width: 46, height: 46)
                
                Image(systemName: transaction.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(transaction.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(transaction.category.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(transaction.category.color)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(transaction.category.color.opacity(0.10))
                                .overlay(
                                    Capsule()
                                        .stroke(transaction.category.color.opacity(0.12), lineWidth: 0.4)
                                )
                        )
                    
                    Text("·")
                        .foregroundColor(.textTertiary)
                    
                    Text(transaction.date.relativeFormatted)
                        .font(.system(size: 11))
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(transaction.type == .income ? .appGreen : .appRed)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.4)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
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
    .background(Color.backgroundPrimary)
    .preferredColorScheme(.dark)
}
