//
//  Color+Extensions.swift
//  Gestfina
//
//  Système de couleurs Liquid Glass — inspiré iOS 26
//

import SwiftUI

extension Color {
    
    // MARK: - Couleurs système Apple exactes
    static let appGreen  = Color(UIColor.systemGreen)   // #34C759
    static let appRed    = Color(UIColor.systemRed)     // #FF3B30
    static let appBlue   = Color(UIColor.systemBlue)    // #007AFF
    static let appPurple = Color(UIColor.systemPurple)  // #AF52DE
    static let appOrange = Color(UIColor.systemOrange)  // #FF9500
    static let appYellow = Color(UIColor.systemYellow)  // #FFCC00
    static let appCyan   = Color(UIColor.systemCyan)    // #32ADE6
    static let appPink   = Color(UIColor.systemPink)    // #FF2D55
    
    // MARK: - Fond clair / Blanc
    
    static let backgroundPrimary = Color.white
    static let backgroundSecondary = Color(hex: "F8FAFC")
    static let backgroundTertiary = Color(hex: "F1F5F9")
    static let surfaceColor = Color.white
    
    // MARK: - App Background & Card
    
    static let appBackground = Color(UIColor.systemBackground)
    static let appCardBackground = Color(UIColor.secondarySystemBackground)
    
    // MARK: - Glass surfaces
    
    static let glassLight = Color.black.opacity(0.02)
    static let glassMedium = Color.black.opacity(0.04)
    static let glassStrong = Color.black.opacity(0.08)
    static let glassBorder = Color.black.opacity(0.06)
    
    // MARK: - Texte
    
    static let textPrimary = Color(hex: "0F172A")
    static let textSecondary = Color(hex: "475569")
    static let textTertiary = Color(hex: "94A3B8")
    
    // MARK: - Gradients premium
    
    static let gradientPrimary = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6"), Color(hex: "A855F7")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let gradientGreen = LinearGradient(
        colors: [Color(hex: "34D399"), Color(hex: "06B6D4")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let gradientRed = LinearGradient(
        colors: [Color(hex: "FB7185"), Color(hex: "F43F5E")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let gradientGold = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let gradientMesh = LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "EC4899"), Color(hex: "F59E0B")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let gradientCard = LinearGradient(
        colors: [Color(hex: "141836"), Color(hex: "0C1022")],
        startPoint: .top, endPoint: .bottom
    )
    
    // MARK: - Initialiseur Hex
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
