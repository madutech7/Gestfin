//
//  Account.swift
//  Gestfina
//
//  Modèle représentant un compte ou portefeuille financier (Espèces, Banque, Wave, Orange Money, etc.)
//

import Foundation
import SwiftUI

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case cash = "Espèces"
    case bank = "Compte Bancaire"
    case wave = "Wave"
    case orangeMoney = "Orange Money"
    case creditCard = "Carte de Crédit"
    case crypto = "Cryptomonnaie"
    case other = "Autre"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .cash: return "banknote.fill"
        case .bank: return "building.columns.fill"
        case .wave: return "wave.3.right.circle.fill"
        case .orangeMoney: return "phone.bubble.left.fill"
        case .creditCard: return "creditcard.fill"
        case .crypto: return "bitcoinsign.circle.fill"
        case .other: return "wallet.pass.fill"
        }
    }
    
    var defaultHexColor: String {
        switch self {
        case .cash: return "#10B981"
        case .bank: return "#6366F1"
        case .wave: return "#06B6D4"
        case .orangeMoney: return "#F59E0B"
        case .creditCard: return "#8B5CF6"
        case .crypto: return "#F43F5E"
        case .other: return "#64748B"
        }
    }
}

struct Account: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: AccountType
    var initialBalance: Double
    var hexColor: String
    var iconName: String
    var isDefault: Bool = false
    
    var color: Color {
        Color(hex: hexColor)
    }
    
    static var defaultAccounts: [Account] {
        [
            Account(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Espèces", type: .cash, initialBalance: 0, hexColor: AccountType.cash.defaultHexColor, iconName: AccountType.cash.iconName, isDefault: true),
            Account(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Compte Bancaire", type: .bank, initialBalance: 0, hexColor: AccountType.bank.defaultHexColor, iconName: AccountType.bank.iconName, isDefault: false),
            Account(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, name: "Wave", type: .wave, initialBalance: 0, hexColor: AccountType.wave.defaultHexColor, iconName: AccountType.wave.iconName, isDefault: false),
            Account(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, name: "Orange Money", type: .orangeMoney, initialBalance: 0, hexColor: AccountType.orangeMoney.defaultHexColor, iconName: AccountType.orangeMoney.iconName, isDefault: false)
        ]
    }
}
