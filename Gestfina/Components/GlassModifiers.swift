//
//  GlassModifiers.swift
//  Gestfina
//
//  Effets visuels professionnels - Style iOS 17/18
//

import SwiftUI

// MARK: - Professional Card Modifier

struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    var opacity: Double = 0.08
    var borderOpacity: Double = 0.15
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Floating Modifier (pour le tab bar - gardé si utilisé ailleurs)

struct LiquidGlassFloating: ViewModifier {
    var cornerRadius: CGFloat = 32
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
    }
}

// MARK: - Professional Button

struct LiquidGlassButton: ViewModifier {
    var isActive: Bool = false
    var activeColor: Color = .appBlue
    
    func body(content: Content) -> some View {
        content
            .background(
                Capsule()
                    .fill(isActive ? activeColor.opacity(0.15) : Color(UIColor.tertiarySystemGroupedBackground))
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? activeColor.opacity(0.3) : Color.black.opacity(0.05), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

// MARK: - Squishy Premium Button Style

struct SquishyPremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Holographic Angular Gradient Border

struct AnimatedGlassBorder: ViewModifier {
    @State private var rotation: Double = 0
    var cornerRadius: CGFloat = 24
    var colors: [Color] = [.appBlue, .appCyan, .appPurple, .appBlue]
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        AngularGradient(
                            colors: colors,
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: 1.5
                    )
            )
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.4),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: -geo.size.width * 0.3 + (geo.size.width * 1.6) * phase)
                    .clipped()
                }
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Floating Animation

struct FloatingAnimation: ViewModifier {
    @State private var offset: CGFloat = 0
    var amplitude: CGFloat = 4
    var duration: Double = 3
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = amplitude
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    
    /// Applique un style de carte professionnel
    func liquidGlass(cornerRadius: CGFloat = 24, opacity: Double = 0.08) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    /// Applique un effet flottant matériel
    func liquidGlassFloating(cornerRadius: CGFloat = 32) -> some View {
        modifier(LiquidGlassFloating(cornerRadius: cornerRadius))
    }
    
    /// Bouton professionnel
    func liquidGlassButton(isActive: Bool = false, activeColor: Color = .appBlue) -> some View {
        modifier(LiquidGlassButton(isActive: isActive, activeColor: activeColor))
    }
    
    /// Bordure gradient subtile
    func animatedGlassBorder(cornerRadius: CGFloat = 24, colors: [Color] = [.appBlue, .appBlue, .appGreen, .appBlue]) -> some View {
        modifier(AnimatedGlassBorder(cornerRadius: cornerRadius, colors: colors))
    }
    
    /// Effet de brillance animé
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
    
    /// Animation de flottement subtil
    func floating(amplitude: CGFloat = 4, duration: Double = 3) -> some View {
        modifier(FloatingAnimation(amplitude: amplitude, duration: duration))
    }
}
