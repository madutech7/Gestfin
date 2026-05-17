//
//  AuthView.swift
//  Gestfina
//
//  Écran d'authentification ultra-premium (Design Native Apple / iOS 17)
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var isLoginMode = true
    
    // Form fields
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    // UI state
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var isPasswordVisible = false
    
    // Focus state for elegant input behavior
    @FocusState private var focusedField: Field?
    enum Field {
        case name, email, password
    }
    
    // Animations state
    @State private var appearAnimation = false
    @State private var showGoogleAlert = false
    @State private var googleEmailInput = ""
    
    // Dégradé Premium (Mesh-like)
    private let meshGradient = LinearGradient(
        colors: [
            Color(red: 0.15, green: 0.1, blue: 0.25),
            Color(red: 0.08, green: 0.08, blue: 0.15),
            Color(red: 0.05, green: 0.05, blue: 0.1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // ── FOND DYNAMIQUE APPLE-LIKE ──
            meshGradient
                .ignoresSafeArea()
            
            // Orbes lumineuses ultra-fluides (style Siri / iOS 17 Backgrounds)
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.4))
                        .frame(width: proxy.size.width * 1.2)
                        .offset(x: appearAnimation ? -proxy.size.width * 0.2 : proxy.size.width * 0.2,
                                y: appearAnimation ? -proxy.size.height * 0.2 : proxy.size.height * 0.1)
                        .blur(radius: 120)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: proxy.size.width)
                        .offset(x: appearAnimation ? proxy.size.width * 0.4 : -proxy.size.width * 0.1,
                                y: appearAnimation ? proxy.size.height * 0.4 : proxy.size.height * 0.6)
                        .blur(radius: 100)
                }
            }
            .ignoresSafeArea()
            
            // Couche de verre subtile (Ultra Thin Material) pour unifier le fond
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .ignoresSafeArea()
            
            // ── CONTENU PRINCIPAL ──
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // En-tête (Logo + Textes)
                    headerSection
                        .padding(.top, 40)
                    
                    // Carte Principale (Formulaire)
                    VStack(spacing: 0) {
                        modeSelector
                        
                        if showError, let msg = errorMessage {
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                            VStack { Divider().background(.white.opacity(0.12)) }
                        }
                        .padding(.vertical, 8)
                        
                        // ── BOUTON GOOGLE ULTRA-PREMIUM ──
                        Button {
                            handleGoogleLogin()
                        } label: {
                            HStack(spacing: 12) {
                                // Logo Google stylisé multicolore en SwiftUI natif
                                HStack(spacing: 2) {
                                    Circle().fill(.red).frame(width: 6, height: 6)
                                    Circle().fill(.blue).frame(width: 6, height: 6)
                                    Circle().fill(.yellow).frame(width: 6, height: 6)
                                    Circle().fill(.green).frame(width: 6, height: 6)
                                }
                                
                                Text("Continuer avec Google")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.12), lineWidth: 1)
                            )
                        }
                        .disabled(isLoading)
                        
                    }
                    .padding(24)
                    .background(.white.opacity(0.03))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.2), radius: 30, y: 15)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Connexion Google", isPresented: $showGoogleAlert) {
            TextField("Adresse Email Google", text: $googleEmailInput)
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
            
            Button("Annuler", role: .cancel) { }
            Button("Se connecter") {
                executeGoogleLogin(email: googleEmailInput)
            }
        } message: {
            Text("Entrez votre adresse email Google pour simuler l'authentification OAuth2 Firebase de manière sécurisée.")
        }
    }
    
    // MARK: - Éléments personnalisés SwiftUI
    
    @ViewBuilder
    private func customTextField(
        value: Binding<String>,
        placeholder: String,
        icon: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            TextField("", text: value, prompt: Text(placeholder).foregroundColor(.white.opacity(0.35)))
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding(14)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func customPasswordField() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            ZStack(alignment: .leading) {
                if isPasswordVisible {
                    TextField("", text: $password, prompt: Text("Mot de passe").foregroundColor(.white.opacity(0.35)))
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    SecureField("", text: $password, prompt: Text("Mot de passe").foregroundColor(.white.opacity(0.35)))
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        guard !email.isEmpty, !password.isEmpty else {
            setError("Veuillez remplir tous les champs obligatoires.")
            return
        }
        
        if !isLoginMode && name.isEmpty {
            setError("Veuillez entrer votre nom complet.")
            return
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation {
            isLoading = true
            showError = false
            errorMessage = nil
        }
        
        if isLoginMode {
            APIManager.shared.login(email: email, password: password) { result in
                handleAuthResult(result)
            }
        } else {
            APIManager.shared.register(email: email, password: password, name: name) { result in
                handleAuthResult(result)
            }
        }
    }
    
    private func handleAuthResult(_ result: Result<[String: Any], Error>) {
        DispatchQueue.main.async {
            isLoading = false
            switch result {
            case .success:
                print("🔑 Authentification réussie ! Téléchargement des données cloud...")
                // Mettre à jour le nom de l'utilisateur dans l'application
                if let name = UserDefaults.standard.string(forKey: "gestfina_user_name") {
                    viewModel.userName = name
                    viewModel.saveUserName()
                }
                
                // Charger les transactions et budgets cloud de cet utilisateur
                viewModel.fetchCloudData()
                
            case .failure(let error):
                setError(error.localizedDescription)
            }
        }
    }
    
    private func handleGoogleLogin() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        googleEmailInput = ""
        showGoogleAlert = true
    }
    
    private func executeGoogleLogin(email: String) {
        guard !email.isEmpty && email.contains("@") else {
            setError("Veuillez entrer une adresse email Google valide.")
            return
        }
        
        withAnimation {
            isLoading = true
            showError = false
            errorMessage = nil
        }
        
        // Simuler le jeton ID Firebase avec le préfixe de simulation du backend
        let mockToken = "mock-google-token-\(email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))"
        
        APIManager.shared.googleLogin(idToken: mockToken) { result in
            handleAuthResult(result)
        }
    }
    
    private func setError(_ message: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            errorMessage = message
            showError = true
            isLoading = false
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(FinanceViewModel())
}
