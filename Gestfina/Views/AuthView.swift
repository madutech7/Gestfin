//
//  AuthView.swift
//  Gestfina
//
//  Écran d'authentification ultra-premium (Liquid Glass)
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
    
    // Google Sign-In Simulator
    @State private var showGoogleAlert = false
    @State private var googleEmailInput = ""
    
    // Animations state
    @State private var startAnimation = false
    
    var body: some View {
        ZStack {
            // ── FOND DYNAMIQUE AVEC DÉGRADÉ PREMIUM ──
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.10, blue: 0.20),
                    Color(red: 0.05, green: 0.05, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Éléments lumineux d'ambiance
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.18))
                    .frame(width: 300, height: 300)
                    .offset(x: startAnimation ? -80 : -150, y: startAnimation ? -100 : -200)
                    .blur(radius: 80)
                
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .offset(x: startAnimation ? 120 : 200, y: startAnimation ? 200 : 300)
                    .blur(radius: 70)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    startAnimation = true
                }
            }
            
            // ── CONTENU PRINCIPAL ──
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // Logo & Titre
                    VStack(spacing: 12) {
                        Image("SamaXaalisLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .shadow(color: .purple.opacity(0.3), radius: 10)
                        
                        Text("SamaXaalis")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(isLoginMode ? "Suivez vos finances en toute sécurité" : "Rejoignez SamaXaalis aujourd'hui")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    // ── PANNEAU D'AUTHENTIFICATION (GLASSMORPHIC) ──
                    VStack(spacing: 20) {
                        
                        // Sélecteur Mode
                        HStack(spacing: 0) {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    isLoginMode = true
                                    errorMessage = nil
                                }
                            } label: {
                                Text("Connexion")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(isLoginMode ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isLoginMode ? .white.opacity(0.08) : .clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    isLoginMode = false
                                    errorMessage = nil
                                }
                            } label: {
                                Text("Inscription")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(!isLoginMode ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isLoginMode ? .white.opacity(0.08) : .clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(4)
                        .background(.white.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Erreur Banner
                        if showError, let msg = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.red)
                                Text(msg)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.9))
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.red.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Formulaire
                        VStack(spacing: 16) {
                            
                            // Champ Nom (Inscription uniquement)
                            if !isLoginMode {
                                customTextField(
                                    value: $name,
                                    placeholder: "Nom complet",
                                    icon: "person.fill"
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // Champ Email
                            customTextField(
                                value: $email,
                                placeholder: "Adresse Email",
                                icon: "envelope.fill",
                                keyboardType: .emailAddress
                            )
                            
                            // Champ Mot de passe
                            customPasswordField()
                        }
                        
                        // Bouton d'action
                        Button {
                            handleSubmit()
                        } label: {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isLoginMode ? "Se connecter" : "S'inscrire")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(isLoading)
                        .padding(.top, 10)
                        
                        // ── SÉPARATEUR ──
                        HStack {
                            VStack { Divider().background(.white.opacity(0.12)) }
                            Text("ou continuer avec")
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
