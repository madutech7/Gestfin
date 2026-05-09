//
//  GlassModifiers.swift
//  Gestfina
//
//  Effets Liquid Glass inspirés d'iOS 26
//

import SwiftUI

// MARK: - Liquid Glass Card Modifier

struct LiquidGlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    var opacity: Double = 0.08
    var borderOpacity: Double = 0.15
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Base glass fill
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(0.85)
                    
                    // Subtle color tint
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(opacity),
                                    Color.white.opacity(opacity * 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Top highlight reflection
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.12), location: 0),
                                    .init(color: Color.white.opacity(0.04), location: 0.3),
                                    .init(color: Color.clear, location: 0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(borderOpacity),
                                Color.white.opacity(borderOpacity * 0.3),
                                Color.white.opacity(borderOpacity * 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Liquid Glass Floating Modifier (pour le tab bar)

struct LiquidGlassFloating: ViewModifier {
    var cornerRadius: CGFloat = 32
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Frosted blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    // Glass shimmer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Internal glow
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.06), Color.clear],
                                center: .top,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.6
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Liquid Glass Button

struct LiquidGlassButton: ViewModifier {
    var isActive: Bool = false
    var activeColor: Color = .appBlue
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if isActive {
                        Capsule()
                            .fill(activeColor.opacity(0.25))
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.4)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(
                        isActive
                        ? activeColor.opacity(0.4)
                        : Color.white.opacity(0.1),
                        lineWidth: 0.6
                    )
            )
            .clipShape(Capsule())
    }
}

// MARK: - Animated Gradient Border

struct AnimatedGlassBorder: ViewModifier {
    @State private var rotation: Double = 0
    var cornerRadius: CGFloat = 24
    var colors: [Color] = [.appBlue, .appPurple, .appGreen, .appBlue]
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(
                            colors: colors,
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: 1.5
                    )
                    .opacity(0.5)
                    .blur(radius: 0.5)
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
                            Color.white.opacity(0.08),
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
    
    /// Applique l'effet Liquid Glass à une carte
    func liquidGlass(cornerRadius: CGFloat = 24, opacity: Double = 0.08) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    /// Applique l'effet Liquid Glass flottant (tab bar, bottom sheets)
    func liquidGlassFloating(cornerRadius: CGFloat = 32) -> some View {
        modifier(LiquidGlassFloating(cornerRadius: cornerRadius))
    }
    
    /// Bouton en Liquid Glass
    func liquidGlassButton(isActive: Bool = false, activeColor: Color = .appBlue) -> some View {
        modifier(LiquidGlassButton(isActive: isActive, activeColor: activeColor))
    }
    
    /// Bordure animée avec gradient rotatif
    func animatedGlassBorder(cornerRadius: CGFloat = 24, colors: [Color] = [.appBlue, .appPurple, .appGreen, .appBlue]) -> some View {
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
