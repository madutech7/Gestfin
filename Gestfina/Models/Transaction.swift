//
//  Transaction.swift
//  Gestfina
//
//  Modèle représentant une transaction financière
//

import Foundation
import SwiftUI

/// Type de transaction : revenu ou dépense
enum TransactionType: String, Codable, CaseIterable {
    case income = "Revenu"
    case expense = "Dépense"
    
    var color: Color {
        switch self {
        case .income: return Color.appGreen
        case .expense: return Color.appRed
        }
    }
    
    var icon: String {
        switch self {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        }
    }
}

/// Modèle principal de transaction
struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: TransactionCategory
    var type: TransactionType
    var note: String
    
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        category: TransactionCategory,
        type: TransactionType,
        note: String = ""
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.note = note
    }
    
    /// Montant signé (négatif pour les dépenses)
    var signedAmount: Double {
        type == .expense ? -amount : amount
    }
    
    /// Montant formaté pour l'affichage
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "fr_FR")
        let prefix = type == .income ? "+" : "-"
        return "\(prefix)\(formatter.string(from: NSNumber(value: amount)) ?? "0,00 €")"
    }
}

// MARK: - Données d'exemple
extension Transaction {
    static let sampleData: [Transaction] = [
        Transaction(title: "Salaire", amount: 2800.00, date: Date(), category: .salary, type: .income),
        Transaction(title: "Loyer", amount: 750.00, date: Date().addingTimeInterval(-86400), category: .housing, type: .expense),
        Transaction(title: "Courses Carrefour", amount: 85.40, date: Date().addingTimeInterval(-172800), category: .food, type: .expense),
        Transaction(title: "Netflix", amount: 13.49, date: Date().addingTimeInterval(-259200), category: .entertainment, type: .expense),
        Transaction(title: "Freelance Design", amount: 450.00, date: Date().addingTimeInterval(-345600), category: .freelance, type: .income),
        Transaction(title: "Électricité", amount: 65.00, date: Date().addingTimeInterval(-432000), category: .utilities, type: .expense),
        Transaction(title: "Restaurant", amount: 42.50, date: Date().addingTimeInterval(-518400), category: .food, type: .expense),
        Transaction(title: "Transport", amount: 75.00, date: Date().addingTimeInterval(-604800), category: .transport, type: .expense),
        Transaction(title: "Vêtements", amount: 120.00, date: Date().addingTimeInterval(-691200), category: .shopping, type: .expense),
        Transaction(title: "Prime", amount: 500.00, date: Date().addingTimeInterval(-777600), category: .salary, type: .income),
    ]
}
