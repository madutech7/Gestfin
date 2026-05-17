//
//  AuthView.swift
//  Gestfina
//
//  Écran d'authentification "iOS 26 Liquid Glass" natif
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
    
    // SF Haptics
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // ── FOND DYNAMIQUE "IOS 26 LIQUID GLASS" ──
            GeometryReader { proxy in
                ZStack {
                    Color(UIColor.systemBackground).ignoresSafeArea()
                    
                    Circle()
                        .fill(Color.appBlue.opacity(0.15))
                        .frame(width: proxy.size.width * 1.5)
                        .blur(radius: 80)
                        .offset(x: appearAnimation ? -100 : 100, y: appearAnimation ? -150 : 100)
                    
                    Circle()
                        .fill(Color.appPurple.opacity(0.12))
                        .frame(width: proxy.size.width)
                        .blur(radius: 60)
                        .offset(x: appearAnimation ? 150 : -100, y: appearAnimation ? 200 : -100)
                }
                .ignoresSafeArea()
            }
            
            // ── CONTENU PRINCIPAL ──
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // En-tête (Icône + Textes)
                    headerSection
                        .padding(.top, 40)
                    
                    // Carte Principale (Formulaire)
                    VStack(spacing: 0) {
                        modeSelector
                        
                        if showError, let msg = errorMessage {
                            errorBanner(message: msg)
                        }
                        
                        VStack(spacing: 20) {
                            formFields
                            
                            actionButton
                                .padding(.top, 12)
                        }
                        .padding(24)
                    }
                    .liquidGlass(cornerRadius: 32, opacity: 0.05)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                appearAnimation = true
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icône premium de l'application (Liquid Glass Style)
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
                
                Circle()
                    .stroke(Color.appBlue.opacity(0.3), lineWidth: 1)
                    .frame(width: 88, height: 88)
                
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.appBlue, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            .padding(.bottom, 8)
            
            Text("SamaXaalis")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
                .tracking(0.5)
            
            Text(isLoginMode ? "Gérez vos finances avec élégance." : "Prenez le contrôle de votre argent.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var modeSelector: some View {
        HStack(spacing: 0) {
            Button {
                hapticFeedback.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isLoginMode = true
                    errorMessage = nil
                    focusedField = nil
                }
            } label: {
                Text("Connexion")
                    .font(.system(size: 15, weight: isLoginMode ? .semibold : .medium))
                    .foregroundColor(isLoginMode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if isLoginMode {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                    .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
                                    .matchedGeometryEffect(id: "MODE_SELECTOR", in: animationNamespace)
                            }
                        }
                    )
            }
            
            Button {
                hapticFeedback.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isLoginMode = false
                    errorMessage = nil
                    focusedField = nil
                }
            } label: {
                Text("Inscription")
                    .font(.system(size: 15, weight: !isLoginMode ? .semibold : .medium))
                    .foregroundColor(!isLoginMode ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if !isLoginMode {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                    .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
                                    .matchedGeometryEffect(id: "MODE_SELECTOR", in: animationNamespace)
                            }
                        }
                    )
            }
        }
        .padding(4)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
    
    @Namespace private var animationNamespace
    
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.appRed)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.appRed.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appRed.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var formFields: some View {
        VStack(spacing: 16) {
            if !isLoginMode {
                inputField(
                    icon: "person.fill",
                    placeholder: "Nom complet",
                    text: $name,
                    field: .name
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            inputField(
                icon: "envelope.fill",
                placeholder: "Adresse e-mail",
                text: $email,
                field: .email,
                isEmail: true
            )
            
            passwordField
        }
    }
    
    private func inputField(icon: String, placeholder: String, text: Binding<String>, field: Field, isEmail: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(focusedField == field ? Color.appBlue : .secondary)
                .frame(width: 24)
            
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .focused($focusedField, equals: field)
                .keyboardType(isEmail ? .emailAddress : .default)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(focusedField == field ? Color.appBlue : Color.black.opacity(0.05), lineWidth: focusedField == field ? 2 : 1)
        )
        .shadow(color: focusedField == field ? Color.appBlue.opacity(0.15) : Color.clear, radius: 8, y: 4)
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }
    
    private var passwordField: some View {
        HStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(focusedField == .password ? Color.appBlue : .secondary)
                .frame(width: 24)
            
            Group {
                if isPasswordVisible {
                    TextField("Mot de passe", text: $password)
                } else {
                    SecureField("Mot de passe", text: $password)
                }
            }
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.primary)
            .focused($focusedField, equals: .password)
            .textInputAutocapitalization(.never)
            
            Button {
                hapticFeedback.impactOccurred()
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(focusedField == .password ? Color.appBlue : Color.black.opacity(0.05), lineWidth: focusedField == .password ? 2 : 1)
        )
        .shadow(color: focusedField == .password ? Color.appBlue.opacity(0.15) : Color.clear, radius: 8, y: 4)
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }
    
    private var actionButton: some View {
        Button {
            focusedField = nil
            handleAuthAction()
        } label: {
            ZStack {
                LinearGradient(colors: [Color.appBlue, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(isLoading ? 0.7 : 1)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(isLoginMode ? "Se connecter" : "Créer mon compte")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 56)
            .clipShape(Capsule())
            .shadow(color: Color.appBlue.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .disabled(isLoading)
    }
    
    
    // MARK: - Actions
    
    private func handleAuthAction() {
        if email.isEmpty || password.isEmpty {
            setError("Veuillez remplir tous les champs.")
            return
        }
        
        if !isLoginMode && name.isEmpty {
            setError("Veuillez entrer votre nom.")
            return
        }
        
        hapticFeedback.impactOccurred()
        isLoading = true
        errorMessage = nil
        showError = false
        
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
            self.isLoading = false
            
            switch result {
            case .success(let data):
                self.notificationFeedback.notificationOccurred(.success)
                if let user = data["user"] as? [String: Any],
                   let token = data["accessToken"] as? String,
                   let userEmail = user["email"] as? String,
                   let userName = user["name"] as? String {
                    
                    BackendAuthManager.shared.setLoginState(
                        token: token,
                        email: userEmail,
                        name: userName
                    )
                }
            case .failure(let error):
                self.setError(error.localizedDescription)
            }
        }
    }
    
    private func setError(_ message: String) {
        notificationFeedback.notificationOccurred(.error)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            errorMessage = message
            showError = true
            isLoading = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                showError = false
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(FinanceViewModel())
}
