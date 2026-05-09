//
//  Category.swift
//  Gestfina
//
//  Catégories de transactions
//

import Foundation
import SwiftUI

/// Catégories prédéfinies pour les transactions
enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case salary = "Salaire"
    case freelance = "Freelance"
    case investment = "Investissement"
    case food = "Alimentation"
    case housing = "Logement"
    case transport = "Transport"
    case utilities = "Factures"
    case entertainment = "Loisirs"
    case shopping = "Shopping"
    case health = "Santé"
    case education = "Éducation"
    case savings = "Épargne"
    case other = "Autre"
    
    var id: String { rawValue }
    
    /// Icône SF Symbol pour chaque catégorie
    var icon: String {
        switch self {
        case .salary: return "briefcase.fill"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .food: return "cart.fill"
        case .housing: return "house.fill"
        case .transport: return "car.fill"
        case .utilities: return "bolt.fill"
        case .entertainment: return "gamecontroller.fill"
        case .shopping: return "bag.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .savings: return "banknote.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    /// Couleur associée à chaque catégorie
    var color: Color {
        switch self {
        case .salary: return Color(hex: "4CAF50")
        case .freelance: return Color(hex: "8BC34A")
        case .investment: return Color(hex: "00BCD4")
        case .food: return Color(hex: "FF9800")
        case .housing: return Color(hex: "795548")
        case .transport: return Color(hex: "2196F3")
        case .utilities: return Color(hex: "FFC107")
        case .entertainment: return Color(hex: "E91E63")
        case .shopping: return Color(hex: "9C27B0")
        case .health: return Color(hex: "F44336")
        case .education: return Color(hex: "3F51B5")
        case .savings: return Color(hex: "009688")
        case .other: return Color(hex: "607D8B")
        }
    }
    
    /// Gradient pour les cartes
    var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Catégories de type revenu
    static var incomeCategories: [TransactionCategory] {
        [.salary, .freelance, .investment, .other]
    }
    
    /// Catégories de type dépense
    static var expenseCategories: [TransactionCategory] {
        [.food, .housing, .transport, .utilities, .entertainment, .shopping, .health, .education, .savings, .other]
    }
}
