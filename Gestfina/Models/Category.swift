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


//
//  AppCurrency.swift
//  Gestfina
//
//  Catalogue complet des devises supportées
//

import Foundation

struct AppCurrency: Identifiable, Equatable {
    let id: String        // code ISO
    let code: String
    let symbol: String
    let name: String
    let flag: String      // drapeau représentatif (texte)
    
    static let all: [AppCurrency] = [
        // Afrique
        AppCurrency(id: "XOF", code: "XOF", symbol: "CFA",  name: "Franc CFA (UEMOA)",        flag: "🌍"),
        AppCurrency(id: "XAF", code: "XAF", symbol: "FCFA", name: "Franc CFA (CEMAC)",         flag: "🌍"),
        AppCurrency(id: "MAD", code: "MAD", symbol: "MAD",  name: "Dirham marocain",            flag: "🇲🇦"),
        AppCurrency(id: "DZD", code: "DZD", symbol: "DZD",  name: "Dinar algérien",             flag: "🇩🇿"),
        AppCurrency(id: "TND", code: "TND", symbol: "TND",  name: "Dinar tunisien",             flag: "🇹🇳"),
        AppCurrency(id: "EGP", code: "EGP", symbol: "EGP",  name: "Livre égyptienne",           flag: "🇪🇬"),
        AppCurrency(id: "NGN", code: "NGN", symbol: "₦",    name: "Naira nigérian",             flag: "🇳🇬"),
        AppCurrency(id: "GHS", code: "GHS", symbol: "GHS",  name: "Cedi ghanéen",               flag: "🇬🇭"),
        AppCurrency(id: "KES", code: "KES", symbol: "KSh",  name: "Shilling kényan",            flag: "🇰🇪"),
        AppCurrency(id: "ZAR", code: "ZAR", symbol: "R",    name: "Rand sud-africain",          flag: "🇿🇦"),
        // Europe
        AppCurrency(id: "EUR", code: "EUR", symbol: "€",    name: "Euro",                       flag: "🇪🇺"),
        AppCurrency(id: "GBP", code: "GBP", symbol: "£",    name: "Livre sterling",             flag: "🇬🇧"),
        AppCurrency(id: "CHF", code: "CHF", symbol: "CHF",  name: "Franc suisse",               flag: "🇨🇭"),
        AppCurrency(id: "NOK", code: "NOK", symbol: "kr",   name: "Couronne norvégienne",        flag: "🇳🇴"),
        AppCurrency(id: "SEK", code: "SEK", symbol: "kr",   name: "Couronne suédoise",          flag: "🇸🇪"),
        AppCurrency(id: "PLN", code: "PLN", symbol: "zł",   name: "Zloty polonais",             flag: "🇵🇱"),
        // Amériques
        AppCurrency(id: "USD", code: "USD", symbol: "$",    name: "Dollar américain",           flag: "🇺🇸"),
        AppCurrency(id: "CAD", code: "CAD", symbol: "CA$",  name: "Dollar canadien",            flag: "🇨🇦"),
        AppCurrency(id: "BRL", code: "BRL", symbol: "R$",   name: "Real brésilien",             flag: "🇧🇷"),
        AppCurrency(id: "MXN", code: "MXN", symbol: "MX$",  name: "Peso mexicain",              flag: "🇲🇽"),
        // Asie / Pacifique
        AppCurrency(id: "JPY", code: "JPY", symbol: "¥",    name: "Yen japonais",               flag: "🇯🇵"),
        AppCurrency(id: "CNY", code: "CNY", symbol: "¥",    name: "Yuan chinois",               flag: "🇨🇳"),
        AppCurrency(id: "INR", code: "INR", symbol: "₹",    name: "Roupie indienne",            flag: "🇮🇳"),
        AppCurrency(id: "AUD", code: "AUD", symbol: "A$",   name: "Dollar australien",          flag: "🇦🇺"),
        AppCurrency(id: "SGD", code: "SGD", symbol: "S$",   name: "Dollar de Singapour",        flag: "🇸🇬"),
        AppCurrency(id: "AED", code: "AED", symbol: "AED",  name: "Dirham des Émirats",         flag: "🇦🇪"),
        AppCurrency(id: "SAR", code: "SAR", symbol: "SAR",  name: "Riyal saoudien",             flag: "🇸🇦"),
    ]
    
    /// Groupes pour l'affichage dans le picker
    static var grouped: [(region: String, currencies: [AppCurrency])] {
        [
            ("Afrique",         all.filter { ["XOF","XAF","MAD","DZD","TND","EGP","NGN","GHS","KES","ZAR"].contains($0.code) }),
            ("Europe",          all.filter { ["EUR","GBP","CHF","NOK","SEK","PLN"].contains($0.code) }),
            ("Amériques",       all.filter { ["USD","CAD","BRL","MXN"].contains($0.code) }),
            ("Asie / Pacifique",all.filter { ["JPY","CNY","INR","AUD","SGD","AED","SAR"].contains($0.code) }),
        ]
    }
}

