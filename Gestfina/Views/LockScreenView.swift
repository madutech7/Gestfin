//
//  LockScreenView.swift
//  Gestfina
//
//  Écran de verrouillage premium — Face ID / Touch ID / Code
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var shakeOffset: CGFloat = 0
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Premium background
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
                // Subtle radial accent
                RadialGradient(
                    colors: [Color.appBlue.opacity(0.08), Color.clear],
                    center: .center,
                    startRadius: 50,
                    endRadius: 300
                )
                .ignoresSafeArea()
            } else {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            }

            VStack(spacing: 28) {
                Spacer()

                // Lock icon with pulse ring
                ZStack {
                    Circle()
                        .stroke(Color.appBlue.opacity(0.15), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                        .opacity(Double(2 - pulseScale))

                    Circle()
                        .fill(Color.appBlue.opacity(0.08))
                        .frame(width: 90, height: 90)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 38, weight: .light))
                        .foregroundStyle(.primary)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("SamaXaalis")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("est verrouillé")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .opacity(logoOpacity)

                if let error = authManager.authError {
                    Text(error)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.appRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .offset(x: shakeOffset)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Spacer()

                // Biometric button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    authManager.authenticate()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: authManager.biometricIcon)
                            .font(.system(size: 20))
                        Text("Utiliser \(authManager.biometricName)")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(Color.appBlue)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .opacity(logoOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                logoScale = 1
                logoOpacity = 1
            }
            // Pulse animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                pulseScale = 1.3
            }
            // Auto-trigger biometric
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                authManager.authenticate()
            }
        }
        .onChange(of: authManager.authError) {
            if authManager.authError != nil {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.3).repeatCount(3, autoreverses: true)) {
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
