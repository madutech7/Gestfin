//
//  AccountBadgeView.swift
//  Gestfina
//
//  Composant visuel affichant le logo/badge officiel pour chaque type de compte (Wave, Orange Money, Espèces, Banque, etc.)
//

import SwiftUI

struct AccountBadgeView: View {
    let type: AccountType
    var size: CGFloat = 36
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: type.defaultHexColor), Color(hex: type.defaultHexColor).opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color(hex: type.defaultHexColor).opacity(0.35), radius: size * 0.18, x: 0, y: size * 0.08)
            
            badgeIcon
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var badgeIcon: some View {
        switch type {
        case .wave:
            // Badge Logo Wave (Onde et Cercle)
            Image(systemName: "wave.3.right")
                .font(.system(size: size * 0.45, weight: .bold))
        case .orangeMoney:
            // Badge Logo Orange Money (Mobile & Transfert)
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: size * 0.42, weight: .bold))
        case .cash:
            // Badge Logo Espèces (Billet)
            Image(systemName: "banknote.fill")
                .font(.system(size: size * 0.44, weight: .bold))
        case .bank:
            // Badge Logo Banque (Piliers)
            Image(systemName: "building.columns.fill")
                .font(.system(size: size * 0.42, weight: .bold))
        case .creditCard:
            // Badge Logo Carte Bleue
            Image(systemName: "creditcard.fill")
                .font(.system(size: size * 0.42, weight: .bold))
        case .crypto:
            // Badge Logo Cryptomonnaie
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: size * 0.48, weight: .bold))
        case .other:
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: size * 0.44, weight: .bold))
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        AccountBadgeView(type: .wave)
        AccountBadgeView(type: .orangeMoney)
        AccountBadgeView(type: .cash)
        AccountBadgeView(type: .bank)
        AccountBadgeView(type: .creditCard)
    }
    .padding()
}
