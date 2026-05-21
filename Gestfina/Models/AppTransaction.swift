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

/// Type de fréquence pour les transactions récurrentes
enum RecurringFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Quotidien"
    case weekly = "Hebdomadaire"
    case monthly = "Mensuel"
    case yearly = "Annuel"
    
    var id: String { self.rawValue }
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        case .yearly: return .year
        }
    }
}

/// Modèle principal de transaction
struct AppTransaction: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var category: TransactionCategory
    var type: TransactionType
    var note: String
    
    // Récurrence
    var isRecurring: Bool
    var recurringFrequency: RecurringFrequency?
    var lastRecurrenceDate: Date? // Date de la dernière fois qu'elle a été générée
    
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date = Date(),
        category: TransactionCategory,
        type: TransactionType,
        note: String = "",
        isRecurring: Bool = false,
        recurringFrequency: RecurringFrequency? = nil,
        lastRecurrenceDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.type = type
        self.note = note
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.lastRecurrenceDate = lastRecurrenceDate
    }
    
    /// Montant signé (négatif pour les dépenses)
    var signedAmount: Double {
        type == .expense ? -amount : amount
    }
    
    /// Montant formaté pour l'affichage
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let currencyCode = UserDefaults.standard.string(forKey: "gestfina_currency") ?? "EUR"
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: "fr_FR")
        let prefix = type == .income ? "+" : "-"
        let symbol = AppCurrency.all.first(where: { $0.code == currencyCode })?.symbol ?? "€"
        return "\(prefix)\(formatter.string(from: NSNumber(value: amount)) ?? "0,00 \(symbol)")"
    }
}

// MARK: - Données d'exemple
extension AppTransaction {
    static let sampleData: [AppTransaction] = [
        AppTransaction(title: "Salaire", amount: 2800.00, date: Date(), category: .salary, type: .income),
        AppTransaction(title: "Loyer", amount: 750.00, date: Date().addingTimeInterval(-86400), category: .housing, type: .expense),
        AppTransaction(title: "Courses Carrefour", amount: 85.40, date: Date().addingTimeInterval(-172800), category: .food, type: .expense),
        AppTransaction(title: "Netflix", amount: 13.49, date: Date().addingTimeInterval(-259200), category: .entertainment, type: .expense),
        AppTransaction(title: "Freelance Design", amount: 450.00, date: Date().addingTimeInterval(-345600), category: .freelance, type: .income),
        AppTransaction(title: "Électricité", amount: 65.00, date: Date().addingTimeInterval(-432000), category: .utilities, type: .expense),
        AppTransaction(title: "Restaurant", amount: 42.50, date: Date().addingTimeInterval(-518400), category: .food, type: .expense),
        AppTransaction(title: "Transport", amount: 75.00, date: Date().addingTimeInterval(-604800), category: .transport, type: .expense),
        AppTransaction(title: "Vêtements", amount: 120.00, date: Date().addingTimeInterval(-691200), category: .shopping, type: .expense),
        AppTransaction(title: "Prime", amount: 500.00, date: Date().addingTimeInterval(-777600), category: .salary, type: .income),
    ]
}
