//
//  SavingsGoal.swift
//  Gestfina
//
//  Modèle représentant un objectif d'épargne ou une cagnotte
//

import Foundation
import SwiftUI

struct SavingsGoal: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date?
    var hexColor: String
    var iconName: String
    var note: String
    
    var color: Color {
        Color(hex: hexColor) ?? .blue
    }
    
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min((currentAmount / targetAmount) * 100, 100)
    }
    
    var remainingAmount: Double {
        max(targetAmount - currentAmount, 0)
    }
    
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
    
    static var sampleGoals: [SavingsGoal] {
        [
            SavingsGoal(
                id: UUID(),
                title: "Fonds d'Urgence",
                targetAmount: 1000,
                currentAmount: 650,
                targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                hexColor: "#34C759",
                iconName: "shield.fill",
                note: "Épargne de sécurité pour les impondérables"
            ),
            SavingsGoal(
                id: UUID(),
                title: "Voyage Vacances",
                targetAmount: 2500,
                currentAmount: 1200,
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                hexColor: "#FF9500",
                iconName: "airplane",
                note: "Budget vacances d'été"
            )
        ]
    }
}
