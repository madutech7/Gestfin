//
//  Budget.swift
//  Gestfina
//
//  Modèle de budget par catégorie
//

import Foundation
import SwiftUI

/// Période de budget
enum BudgetPeriod: String, Codable, CaseIterable {
    case weekly = "Hebdomadaire"
    case monthly = "Mensuel"
    case yearly = "Annuel"
    
    var icon: String {
        switch self {
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .yearly: return "calendar.badge.plus"
        }
    }
}

/// Modèle de budget
struct Budget: Identifiable, Codable, Equatable {
    let id: UUID
    var category: TransactionCategory
    var limit: Double
    var period: BudgetPeriod
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        category: TransactionCategory,
        limit: Double,
        period: BudgetPeriod = .monthly,
        isActive: Bool = true
    ) {
        self.id = id
        self.category = category
        self.limit = limit
        self.period = period
        self.isActive = isActive
    }
    
    /// Limite formatée pour l'affichage
    var formattedLimit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: NSNumber(value: limit)) ?? "0,00 €"
    }
}

// MARK: - Données d'exemple
extension Budget {
    static let sampleData: [Budget] = [
        Budget(category: .food, limit: 400.00),
        Budget(category: .transport, limit: 150.00),
        Budget(category: .entertainment, limit: 100.00),
        Budget(category: .shopping, limit: 200.00),
        Budget(category: .utilities, limit: 200.00),
        Budget(category: .health, limit: 100.00),
    ]
}
