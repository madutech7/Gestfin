//
//  PaywallView.swift
//  Gestfina
//
//  Created by Madu - 2026
//  Écran de vente Premium (Paywall) — Design Apple Ultra-Premium & 3D Interactive
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: FinanceViewModel
    @StateObject private var subManager = SubscriptionManager.shared
    
    @State private var selectedProductID = "com.samaxaalis.gestfina.premium.yearly"
    @State private var isPurchasing = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // États d'animation
    @State private var animateItems = false
    @State private var tiltAngle: Double = -4
    @State private var animateCard = false
    @State private var pulseRate: CGFloat = 1.0
    
    @Environment(\.colorScheme) var colorScheme
    
    private func getMockPriceInfo(productID: String) -> (price: String, description: String) {
        let symbol = viewModel.currencySymbol
        let code = viewModel.currency
        
        // Adapt pricing based on currency code
        if code == "XOF" || code == "XAF" {
            if productID.contains("monthly") {
                return ("1 300 F", "Accès complet sans engagement, résiliable à tout moment")
            } else if productID.contains("yearly") {
                return ("9 900 F", "7 jours d'essai gratuit, puis 9 900 F/an")
            } else {
                return ("19 900 F", "Payez une fois, profitez à vie de toutes les nouveautés")
            }
        } else if code == "USD" {
            if productID.contains("monthly") {
                return ("$1.99", "Accès complet sans engagement, résiliable à tout moment")
            } else if productID.contains("yearly") {
                return ("$14.99", "7 jours d'essai gratuit, puis $14.99/an")
            } else {
                return ("$29.99", "Payez une fois, profitez à vie de toutes les nouveautés")
            }
        } else if code == "GBP" {
            if productID.contains("monthly") {
                return ("£1.49", "Accès complet sans engagement, résiliable à tout moment")
            } else if productID.contains("yearly") {
                return ("£11.99", "7 jours d'essai gratuit, puis £11.99/an")
            } else {
                return ("£24.99", "Payez une fois, profitez à vie de toutes les nouveautés")
            }
        } else {
            // Default EUR / others fallback
            if productID.contains("monthly") {
                return ("1,99 \(symbol)", "Accès complet sans engagement, résiliable à tout moment")
            } else if productID.contains("yearly") {
                return ("14,99 \(symbol)", "7 jours d'essai gratuit, puis 14,99 \(symbol)/an")
            } else {
                return ("29,99 \(symbol)", "Payez une fois, profitez à vie de toutes les nouveautés")
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background sobre avec lueur bleue signature profil
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
                
                RadialGradient(
                    colors: [Color.appBlue.opacity(0.08), Color.appCyan.opacity(0.04), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 550
                )
                .ignoresSafeArea()
            } else {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                RadialGradient(
                    colors: [Color.appBlue.opacity(0.05), Color.appCyan.opacity(0.02), Color.clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 550
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header (Bouton Fermer ultra-discret)
                HStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.secondary.opacity(0.4))
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                    }
                    .buttonStyle(.plain)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // ── 1. CARTE PREMIUM 3D FLOTTANTE (Apple Card Premium) ──
                        ZStack {
                            // Ombre de fond dynamique sobre
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.black.opacity(colorScheme == .dark ? 0.65 : 0.18))
                                .frame(width: 290, height: 160)
                                .blur(radius: 12)
                                .offset(y: 10)
                            
                            // Corps de la carte (Deep Sapphire Liquid Glass)
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "0F172A"),
                                            Color(hex: "1E293B"),
                                            Color(hex: "0F172A")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    // Touch de bleu liquide
                                    LinearGradient(
                                        colors: [Color.appBlue.opacity(0.15), Color.appCyan.opacity(0.08), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                )
                                .overlay(
                                    // Bords fins en métal brossé argenté
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    .white.opacity(colorScheme == .dark ? 0.25 : 0.15),
                                                    .white.opacity(0.05),
                                                    .white.opacity(colorScheme == .dark ? 0.15 : 0.05)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .overlay(
                                    // Reflet métallique discret
                                    LinearGradient(
                                        colors: [.white.opacity(0.12), .clear, .white.opacity(0.03)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                )
                            
                            // Infos textuelles & Éléments graphiques sur la carte
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("SamaXaalis")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .tracking(-0.5)
                                        Text("Pro Card")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white.opacity(0.7))
                                            .tracking(1)
                                    }
                                    Spacer()
                                    // Logo couronne bleue brillante
                                    ZStack {
                                        Circle()
                                            .fill(.white.opacity(0.25))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [Color.appBlue, Color.appCyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    }
                                }
                                
                                Spacer()
                                
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("MEMBRE EXCLUSIF")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white.opacity(0.6))
                                            .tracking(2)
                                        Text("Accès Illimité Actif")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    // Puce de paiement métallique
                                    Image(systemName: "wave.3.right")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .rotationEffect(.degrees(-90))
                                }
                            }
                            .padding(20)
                        }
                        .frame(width: 310, height: 180)
                        // Effet 3D Apple Card de Xcode/Apple Pay
                        .rotation3DEffect(
                            .degrees(tiltAngle),
                            axis: (x: 0.6, y: -0.8, z: 0.0)
                        )
                        .scaleEffect(animateCard ? 1.0 : 0.85)
                        .opacity(animateCard ? 1.0 : 0.0)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                        
                        // ── 2. TITRES ET CONTENU HERO ──
                        VStack(spacing: 8) {
                            Text("SamaXaalis Pro")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.appBlue, Color.appCyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .tracking(-0.8)
                            
                            Text("Débloquez tout le potentiel de vos finances")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .opacity(animateItems ? 1.0 : 0.0)
                        .offset(y: animateItems ? 0 : 15)
                        
                        // ── 3. LISTE DES BÉNÉFICES (Apple Style Rows) ──
                        VStack(alignment: .leading, spacing: 14) {
                            AppleFeatureRow(icon: "infinity", title: "Transactions illimitées", desc: "Suivez chaque dépense, sans restriction de nombre.")
                            AppleFeatureRow(icon: "chart.bar.fill", title: "Analyses & Tendances avancées", desc: "Visualisez l'évolution mensuelle et votre taux d'épargne précis.")
                            AppleFeatureRow(icon: "icloud.fill", title: "Synchronisation multi-appareils", desc: "Vos données sécurisées et accessibles partout sur SamaXaalis Cloud.")
                            AppleFeatureRow(icon: "nosign", title: "Expérience épurée sans publicité", desc: "Concentrez-vous sur vos finances, sans aucune distraction.")
                            AppleFeatureRow(icon: "square.and.arrow.up.fill", title: "Export CSV / PDF pro", desc: "Exportez et partagez vos rapports en quelques secondes.")
                        }
                        .padding(.horizontal, 28)
                        .opacity(animateItems ? 1.0 : 0.0)
                        .offset(y: animateItems ? 0 : 20)
                        
                        // ── 4. STACK VERTICAL D'OFFRES PREMIUM (iCloud+ Style) ──
                        VStack(spacing: 12) {
                            if subManager.products.isEmpty {
                                // Fallback mock pour l'affichage local si StoreKit n'a pas fini de s'initier
                                let yearlyInfo = getMockPriceInfo(productID: "com.samaxaalis.gestfina.premium.yearly")
                                let monthlyInfo = getMockPriceInfo(productID: "com.samaxaalis.gestfina.premium.monthly")
                                let lifetimeInfo = getMockPriceInfo(productID: "com.samaxaalis.gestfina.premium.lifetime")
                                
                                PricingRow(
                                    id: "com.samaxaalis.gestfina.premium.yearly",
                                    title: "Pro Annuel",
                                    price: yearlyInfo.price,
                                    period: "/ an",
                                    description: yearlyInfo.description,
                                    badge: "Économisez 37%",
                                    selectedID: $selectedProductID
                                )
                                
                                PricingRow(
                                    id: "com.samaxaalis.gestfina.premium.monthly",
                                    title: "Pro Mensuel",
                                    price: monthlyInfo.price,
                                    period: "/ mois",
                                    description: monthlyInfo.description,
                                    selectedID: $selectedProductID
                                )
                                
                                PricingRow(
                                    id: "com.samaxaalis.gestfina.premium.lifetime",
                                    title: "Pro à vie",
                                    price: lifetimeInfo.price,
                                    period: "Unique",
                                    description: lifetimeInfo.description,
                                    badge: "Meilleur choix",
                                    selectedID: $selectedProductID
                                )
                            } else {
                                // Rendu dynamique des offres StoreKit réelles
                                ForEach(subManager.products, id: \.id) { product in
                                    let isYearly = product.id.contains("yearly")
                                    let isLifetime = product.id.contains("lifetime")
                                    let periodText = isLifetime ? "Unique" : (isYearly ? "/ an" : "/ mois")
                                    let descText = isYearly ? "7 jours d'essai gratuit, puis \(product.displayPrice)/an" : (isLifetime ? "Accès à vie sans limites ni abonnements" : "Accès mensuel complet, sans engagement")
                                    let badgeText = isYearly ? "Économisez 37%" : (isLifetime ? "À vie" : nil)
                                    
                                    PricingRow(
                                        id: product.id,
                                        title: product.displayName.replacingOccurrences(of: "Premium", with: "Pro"),
                                        price: product.displayPrice,
                                        period: periodText,
                                        description: descText,
                                        badge: badgeText,
                                        selectedID: $selectedProductID
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .opacity(animateItems ? 1.0 : 0.0)
                        .offset(y: animateItems ? 0 : 25)
                        
                        // ── 5. BOUTONS DE COMMANDE ET RESTAURATION ──
                        VStack(spacing: 14) {
                            Button {
                                triggerPurchase()
                            } label: {
                                HStack {
                                    if isPurchasing {
                                        ProgressView()
                                            .tint(.white)
                                            .padding(.trailing, 8)
                                    }
                                    Text(selectedProductID.contains("yearly") ? "Commencer les 7 jours gratuits" : "S'abonner maintenant")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.appBlue, Color.appCyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .shadow(color: Color.appBlue.opacity(0.35), radius: 12, y: 6)
                            }
                            .disabled(isPurchasing)
                            .padding(.horizontal, 20)
                            
                            // Restaurer / CGU
                            HStack(spacing: 20) {
                                Button {
                                    triggerRestore()
                                } label: {
                                    Text("Restaurer l'achat")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text("•")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary.opacity(0.5))
                                
                                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                                    Text("Conditions (EULA)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .opacity(animateItems ? 1.0 : 0.0)
                        .offset(y: animateItems ? 0 : 30)
                        
                        // CGU Mentions Légales
                        VStack(spacing: 4) {
                            Text("Les abonnements sont prélevés via votre compte Apple et renouvelés automatiquement.")
                                .font(.system(size: 10))
                            Text("Modifiable et annulable à tout moment depuis les réglages de votre compte Apple Store.")
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                        .opacity(animateItems ? 1.0 : 0.0)
                    }
                }
            }
        }
        .onAppear {
            // Animation 3D de la carte Apple
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateCard = true
            }
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                tiltAngle = 4
            }
            
            // Animation des éléments de la vue
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) {
                animateItems = true
            }
        }
        .alert("SamaXaalis Pro", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Actions
    
    private func triggerPurchase() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isPurchasing = true
        
        Task {
            do {
                let productToBuy = subManager.products.first(where: { $0.id == selectedProductID })
                
                if let product = productToBuy {
                    let success = try await subManager.purchase(product)
                    isPurchasing = false
                    if success {
                        alertMessage = "Bienvenue dans SamaXaalis Pro ! Votre abonnement est actif."
                        showAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                } else {
                    // Mode Simulation locale en mode Debug si StoreKit n'est pas configuré sur App Store Connect
                    #if DEBUG
                    print("Simulation de l'achat local debug pour : \(selectedProductID)")
                    try await Task.sleep(nanoseconds: 1_200_000_000)
                    UserDefaults.standard.set(true, forKey: "gestfina_is_premium")
                    subManager.updatePurchasedProductsMock(selectedProductID)
                    isPurchasing = false
                    alertMessage = "Félicitations ! SamaXaalis Pro a été débloqué (Simulation)."
                    showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                    #else
                    isPurchasing = false
                    alertMessage = "Abonnement temporairement indisponible. Veuillez réessayer plus tard."
                    showAlert = true
                    #endif
                }
            } catch {
                isPurchasing = false
                alertMessage = "Erreur lors du paiement : \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    private func triggerRestore() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isPurchasing = true
        
        Task {
            await subManager.restorePurchases()
            isPurchasing = false
            
            if subManager.isPremium {
                alertMessage = "Vos achats précédents ont été restaurés avec succès !"
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                alertMessage = "Aucun abonnement actif trouvé à restaurer."
                showAlert = true
            }
        }
    }
}

// MARK: - Apple Feature Row (Design Premium iOS)

struct AppleFeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appBlue.opacity(colorScheme == .dark ? 0.15 : 0.08))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.appBlue)
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
    }
}

// MARK: - Pricing Row (iCloud+ Style Selection Row)

struct PricingRow: View {
    let id: String
    let title: String
    let price: String
    let period: String
    let description: String
    var badge: String? = nil
    @Binding var selectedID: String
    
    @Environment(\.colorScheme) var colorScheme
    private var isSelected: Bool { selectedID == id }
    
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedID = id
            }
        } label: {
            HStack(spacing: 16) {
                // Selecteur radio premium
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.appBlue : Color.secondary.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.appBlue)
                            .frame(width: 12, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let badgeText = badge {
                            Text(badgeText)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    LinearGradient(
                                        colors: [Color.appBlue, Color.appCyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(description)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    Text(price)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(period)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        isSelected
                        ? (colorScheme == .dark ? Color.appBlue.opacity(0.08) : Color.appBlue.opacity(0.03))
                        : (colorScheme == .dark ? Color.white.opacity(0.03) : Color.black.opacity(0.015))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? Color.appBlue.opacity(0.8) : Color.secondary.opacity(0.12),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.015 : 0.985)
            .shadow(color: isSelected ? Color.appBlue.opacity(colorScheme == .dark ? 0.12 : 0.06) : Color.clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
        .environmentObject(FinanceViewModel())
}
