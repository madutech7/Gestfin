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
                            
                            googleSignInSection
                                
                            skipButton
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
                
                Image("SamaXaalisLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
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
    
    private var skipButton: some View {
        Button {
            hapticFeedback.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                BackendAuthManager.shared.skipAuthentication()
            }
        } label: {
            Text("Continuer sans compte")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .disabled(isLoading)
    }
    
    private var googleSignInSection: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                
                Text("OU")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
            }
            .padding(.horizontal, 40)
            
            Button {
                hapticFeedback.impactOccurred()
                startNativeGoogleLogin()
            } label: {
                HStack(spacing: 12) {
                    // Icône Google Réelle depuis les Assets
                    Image("google_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Continuer avec Google")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
            }
            .padding(.horizontal, 24)
        }
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
                    
                    // Récupérer immédiatement les transactions et budgets depuis le cloud NestJS
                    viewModel.fetchCloudData()
                }
            case .failure(let error):
                self.setError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Native Google Login (ASWebAuthenticationSession)
    
    private func startNativeGoogleLogin() {
        // ⚠️ INSTRUCTIONS POUR LE DEV (WINDOWS) ⚠️
        // Puisque tu utilises Firebase, Firebase a automatiquement créé ces identifiants pour ton app iOS !
        // 1. Va sur la Console Firebase > Paramètres du projet > Général > Tes applications (iOS)
        // 2. Télécharge ou ouvre le fichier "GoogleService-Info.plist" avec un éditeur de texte (Bloc-notes).
        // 3. Copie la valeur de "CLIENT_ID" et colle-la ci-dessous :
        let clientId = "659116637496-pvv58d9882vmmgtgm4b3ld6lkrlssu7q.apps.googleusercontent.com" 
        
        // 4. Copie la valeur de "REVERSED_CLIENT_ID" et colle-la ci-dessous :
        let reversedClientId = "com.googleusercontent.apps.659116637496-pvv58d9882vmmgtgm4b3ld6lkrlssu7q"
        
        if clientId == "REMPLACE_PAR_TON_CLIENT_ID_IOS" {
            setError("Google SignIn : Remplis le CLIENT_ID et REVERSED_CLIENT_ID dans AuthView.swift (ligne 399).")
            return
        }
        
        isLoading = true
        
        // Le flux OAuth2 natif pour iOS requiert le flux d'autorisation par code ('response_type=code')
        // pour des raisons de sécurité imposées par Google.
        let redirectUri = "\(reversedClientId):/oauth2redirect"
        let authUrlString = "https://accounts.google.com/o/oauth2/v2/auth?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=code&scope=email%20profile"
        
        guard let authUrl = URL(string: authUrlString) else {
            setError("Erreur de configuration URL Google")
            return
        }
        
        let scheme = reversedClientId
        
        let session = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: scheme) { callbackURL, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self.setError("Connexion annulée ou erreur : \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let url = callbackURL else {
                    self.isLoading = false
                    self.setError("Impossible de récupérer la réponse de Google")
                    return
                }
                
                // Extraire le code d'autorisation depuis la query ou le fragment
                let queryString = url.query ?? url.fragment ?? ""
                let parameters = queryString.components(separatedBy: "&")
                var authCode: String? = nil
                
                for param in parameters {
                    let pairs = param.components(separatedBy: "=")
                    let key = pairs[0].replacingOccurrences(of: "?", with: "")
                    if pairs.count == 2 && key == "code" {
                        authCode = pairs[1]
                        break
                    }
                }
                
                if let code = authCode {
                    // Échanger le code contre un id_token Google en toute sécurité
                    self.exchangeCodeForToken(code: code, clientId: clientId, redirectUri: redirectUri) { idToken in
                        DispatchQueue.main.async {
                            if let token = idToken {
                                // Envoyer le VRAI jeton Google au backend NestJS
                                APIManager.shared.googleLogin(idToken: token) { result in
                                    self.handleAuthResult(result)
                                }
                            } else {
                                self.isLoading = false
                                self.setError("Échec de l'échange du code d'autorisation Google")
                            }
                        }
                    }
                } else {
                    self.isLoading = false
                    self.setError("Impossible d'extraire le code de connexion Google")
                }
            }
        }
        
        session.presentationContextProvider = WindowContextProvider.shared
        session.start()
    }
    
    /// Échange le code d'autorisation Google contre des jetons d'accès et d'identité (id_token)
    private func exchangeCodeForToken(code: String, clientId: String, redirectUri: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyComponents = [
            "code": code,
            "client_id": clientId,
            "redirect_uri": redirectUri,
            "grant_type": "authorization_code"
        ]
        
        let bodyString = bodyComponents.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ [GoogleAuth] Erreur lors de l'échange de code : \(error?.localizedDescription ?? "inconnue")")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let idToken = json["id_token"] as? String {
                    completion(idToken)
                } else {
                    let errorDesc = json["error_description"] as? String ?? "Pas de description"
                    print("❌ [GoogleAuth] Token absent du JSON. Erreur: \(json["error"] ?? "inconnue") — \(errorDesc)")
                    completion(nil)
                }
            } else {
                print("❌ [GoogleAuth] Réponse Google illisible")
                completion(nil)
            }
        }.resume()
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

// Classe requise pour présenter la fenêtre web OAuth sur iOS
import AuthenticationServices

class WindowContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WindowContextProvider()
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first { $0.isKeyWindow }
        return window ?? ASPresentationAnchor()
    }
}

#Preview {
    AuthView()
        .environmentObject(FinanceViewModel())
}
