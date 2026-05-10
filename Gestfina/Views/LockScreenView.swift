//
//  LockScreenView.swift
//  Gestfina
//
//  Écran de verrouillage — Face ID / Touch ID / Code
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var shakeOffset: CGFloat = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Fond dégradé subtil
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "0F172A"), Color(hex: "1E293B")]
                    : [Color(hex: "F8FAFF"), Color(hex: "EEF2FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Orbes de couleur subtils
            Circle()
                .fill(Color.appBlue.opacity(0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: -80, y: -200)
            
            Circle()
                .fill(Color.appPurple.opacity(0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 100, y: 250)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo + Nom app
                VStack(spacing: 20) {
                    // Icône de l'app
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appBlue, Color.appPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 110, height: 110)
                            .shadow(color: Color.appBlue.opacity(0.35), radius: 30, y: 12)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    VStack(spacing: 8) {
                        Text("Gestfina")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Vos finances en sécurité")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .opacity(logoOpacity)
                }
                
                Spacer()
                
                // Zone d'authentification
                VStack(spacing: 24) {
                    // Message d'erreur
                    if let error = authManager.authError {
                        Text(error)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appRed)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            .offset(x: shakeOffset)
                    }
                    
                    // Bouton principal biométrie
                    Button {
                        authManager.authenticate()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: authManager.biometricIcon)
                                .font(.system(size: 22, weight: .medium))
                            
                            Text("Déverrouiller avec \(authManager.biometricName)")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appBlue, Color.appPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.appBlue.opacity(0.4), radius: 16, y: 6)
                        .scaleEffect(authManager.isAuthenticating ? 0.97 : 1)
                        .animation(.spring(response: 0.2), value: authManager.isAuthenticating)
                    }
                    .padding(.horizontal, 32)
                    
                    // Sous-texte fallback
                    Button {
                        authManager.authenticate()
                    } label: {
                        Text("Utiliser le code de l'appareil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1
                logoOpacity = 1
            }
            // Déclenchement automatique de Face ID à l'ouverture
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                authManager.authenticate()
            }
        }
        .onChange(of: authManager.authError) { error in
            if error != nil {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3).repeatCount(4, autoreverses: true)) {
                    shakeOffset = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    shakeOffset = 0
                }
            }
        }
    }
}

#Preview {
    LockScreenView(authManager: AuthenticationManager())
}
