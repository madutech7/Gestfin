import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let animationName: String
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentStep = 0
    @State private var isAnimating = false
    
    // SF Haptics pour les transitions
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    let steps = [
        OnboardingStep(
            title: "Bienvenue sur SamaXaalis",
            description: "La façon la plus simple et élégante de gérer votre portefeuille et vos finances personnelles au quotidien.",
            animationName: "wallet"
        ),
        OnboardingStep(
            title: "Suivez vos dépenses",
            description: "Obtenez des statistiques claires, fluides et précises sur vos habitudes de consommation.",
            animationName: "chart"
        ),
        OnboardingStep(
            title: "Sécurité absolue",
            description: "Vos données sont protégées par Face ID et chiffrées en toute sécurité sur votre appareil.",
            animationName: "security"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background dynamique premium (Mesh-like gradient)
            GeometryReader { proxy in
                ZStack {
                    Color(UIColor.systemBackground).ignoresSafeArea()
                    
                    Circle()
                        .fill(Color.appBlue.opacity(0.15))
                        .frame(width: proxy.size.width * 1.5)
                        .blur(radius: 60)
                        .offset(x: currentStep == 0 ? -100 : (currentStep == 1 ? 100 : 0),
                                y: currentStep == 0 ? -150 : (currentStep == 1 ? 100 : -100))
                        .animation(.easeInOut(duration: 1.2), value: currentStep)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.08))
                        .frame(width: proxy.size.width)
                        .blur(radius: 50)
                        .offset(x: currentStep == 0 ? 150 : (currentStep == 1 ? -150 : 100),
                                y: currentStep == 0 ? 200 : (currentStep == 1 ? -100 : 150))
                        .animation(.easeInOut(duration: 1.5), value: currentStep)
                }
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header (Skip Button)
                HStack {
                    Spacer()
                    Button(action: completeOnboarding) {
                        Text("Ignorer")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    }
                    .opacity(currentStep == steps.count - 1 ? 0 : 1)
                    .animation(.easeInOut, value: currentStep)
                }
                
                // Pager
                TabView(selection: Binding(
                    get: { currentStep },
                    set: { newValue in
                        withAnimation { currentStep = newValue }
                        hapticFeedback.impactOccurred()
                    }
                )) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        OnboardingPageView(step: steps[index], isCurrent: currentStep == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Pagination Indicators
                HStack(spacing: 12) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(currentStep == index ? Color.appBlue : Color.gray.opacity(0.3))
                            .frame(width: currentStep == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentStep)
                    }
                }
                .padding(.vertical, 30)
                
                // Main Action Button
                Button(action: {
                    hapticFeedback.impactOccurred()
                    if currentStep < steps.count - 1 {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentStep += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentStep == steps.count - 1 ? "Commencer" : "Continuer")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color.appBlue, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.appBlue.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func completeOnboarding() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
            hasSeenOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let step: OnboardingStep
    let isCurrent: Bool
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Glassmorphism Container for Lottie
            ZStack {
                Circle()
                    .fill(Color.appBlue.opacity(0.05))
                    .frame(width: 280, height: 280)
                
                // Glass effect behind animation
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 240, height: 240)
                    .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                
                LottieView(animationName: step.animationName, loopMode: .loop)
                    .frame(width: 180, height: 180)
                    .scaleEffect(isVisible ? 1 : 0.6)
                    .opacity(isVisible ? 1 : 0)
            }
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                Text(step.title)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 25)
                
                Text(step.description)
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 36)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 25)
                    .lineSpacing(6)
            }
            
            Spacer()
        }
        .onChange(of: isCurrent) {
            if isCurrent {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                    isVisible = true
                }
            } else {
                isVisible = false
            }
        }
        .onAppear {
            if isCurrent {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                    isVisible = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
