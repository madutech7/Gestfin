//
//  PrivacyBlurOverlay.swift
//  Gestfina
//
//  Composant de sécurité affiché lorsque l'application passe en arrière-plan
//

import SwiftUI

struct PrivacyBlurOverlay: View {
    var body: some View {
        ZStack {
            // Arrière-plan sombre flouté
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 6) {
                    Text("Gestfina")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Données sécurisées")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

/// Helper pour l'effet de flou natif UIKit
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

#Preview {
    PrivacyBlurOverlay()
}
