//
//  SettingsView.swift
//  Gestfina
//
//  Paramètres complets — Profil, Sécurité, Notifications, Données
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @ObservedObject var authManager: AuthenticationManager
    @ObservedObject var notifManager: NotificationManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showResetAlert = false
    @State private var showNameEditor = false
    @State private var tempName = ""
    @State private var showDeleteSuccess = false
    
    var body: some View {
        NavigationView {
            List {
                
                // MARK: - Profil
                Section {
                    profileRow
                } header: {
                    Text("Profil")
                }
                
                // MARK: - Sécurité
                Section {
                    securitySection
                } header: {
                    Text("Sécurité")
                } footer: {
                    Text(authManager.isAuthEnabled
                         ? "L'application sera verrouillée à chaque fois que vous la mettez en arrière-plan."
                         : "Activez \(authManager.biometricName) pour protéger l'accès à vos données financières.")
                }
                
                // MARK: - Notifications
                Section {
                    notificationsSection
                } header: {
                    Text("Notifications")
                } footer: {
                    if notifManager.authorizationStatus == .denied {
                        Text("Les notifications sont désactivées. Activez-les dans Réglages > Gestfina.")
                    }
                }
                
                // MARK: - Devise
                Section {
                    HStack {
                        Label("Devise", systemImage: "eurosign")
                            .foregroundColor(.primary)
                        Spacer()
                        Text("EUR (€)")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                } header: {
                    Text("Préférences")
                }
                
                // MARK: - Données
                Section {
                    dataSection
                } header: {
                    Text("Données")
                } footer: {
                    Text("Toutes vos données sont stockées uniquement sur votre appareil et ne sont jamais partagées.")
                }
                
                // MARK: - À propos
                Section {
                    aboutSection
                } header: {
                    Text("À propos")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .alert("Réinitialiser toutes les données ?", isPresented: $showResetAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Réinitialiser", role: .destructive) {
                    viewModel.resetAllData()
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.warning)
                }
            } message: {
                Text("Toutes vos transactions et budgets seront supprimés définitivement. Cette action est irréversible.")
            }
            .sheet(isPresented: $showNameEditor) {
                nameEditorSheet
            }
        }
    }
    
    // MARK: - Profil Row
    
    private var profileRow: some View {
        Button {
            tempName = viewModel.userName
            showNameEditor = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appBlue, Color.appPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Text(String(viewModel.userName.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.userName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Appuyer pour modifier")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Section Sécurité
    
    @ViewBuilder
    private var securitySection: some View {
        if authManager.isBiometricAvailable {
            HStack {
                Label {
                    Text(authManager.biometricName)
                } icon: {
                    Image(systemName: authManager.biometricIcon)
                        .foregroundColor(.appBlue)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { authManager.isAuthEnabled },
                    set: { newValue in
                        withAnimation(.spring(response: 0.3)) {
                            authManager.isAuthEnabled = newValue
                            if !newValue { authManager.isUnlocked = true }
                        }
                        let feedback = UIImpactFeedbackGenerator(style: .light)
                        feedback.impactOccurred()
                    }
                ))
                .tint(.appBlue)
            }
        } else {
            HStack {
                Label("Biométrie non disponible", systemImage: "exclamationmark.shield")
                    .foregroundColor(.secondary)
            }
        }
        
        HStack {
            Label("Protection des données", systemImage: "lock.shield.fill")
                .foregroundColor(.primary)
            Spacer()
            Label("Activée", systemImage: "checkmark.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(.appGreen)
        }
    }
    
    // MARK: - Section Notifications
    
    @ViewBuilder
    private var notificationsSection: some View {
        if notifManager.authorizationStatus == .notDetermined {
            Button {
                notifManager.requestAuthorization()
            } label: {
                Label("Activer les notifications", systemImage: "bell.badge")
                    .foregroundColor(.appBlue)
            }
        } else if notifManager.authorizationStatus == .denied {
            Button {
                notifManager.openSettings()
            } label: {
                Label("Ouvrir les Réglages", systemImage: "gear")
                    .foregroundColor(.appBlue)
            }
        } else {
            // Alertes budget
            Toggle(isOn: $notifManager.budgetAlertEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alertes budget")
                        Text("Quand 80% ou 100% est atteint")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.appOrange)
                }
            }
            .tint(.appBlue)
            
            // Rappel quotidien
            Toggle(isOn: $notifManager.dailyReminderEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rappel quotidien")
                        Text("Saisir vos dépenses du jour")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.appPurple)
                }
            }
            .tint(.appBlue)
            
            if notifManager.dailyReminderEnabled {
                HStack {
                    Label("Heure du rappel", systemImage: "clock")
                        .foregroundColor(.primary)
                    Spacer()
                    Stepper("\(notifManager.reminderHour)h00", value: $notifManager.reminderHour, in: 6...23)
                        .labelsHidden()
                    Text("\(notifManager.reminderHour)h00")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.appBlue)
                        .frame(width: 52, alignment: .trailing)
                }
            }
        }
    }
    
    // MARK: - Section Données
    
    @ViewBuilder
    private var dataSection: some View {
        HStack {
            Label("Transactions", systemImage: "arrow.left.arrow.right")
                .foregroundColor(.primary)
            Spacer()
            Text("\(viewModel.transactions.count)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        
        HStack {
            Label("Budgets", systemImage: "chart.pie")
                .foregroundColor(.primary)
            Spacer()
            Text("\(viewModel.budgets.count)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        
        Button {
            showResetAlert = true
        } label: {
            Label("Réinitialiser toutes les données", systemImage: "trash")
                .foregroundColor(.appRed)
        }
    }
    
    // MARK: - Section À propos
    
    @ViewBuilder
    private var aboutSection: some View {
        HStack {
            Label("Version", systemImage: "info.circle")
                .foregroundColor(.primary)
            Spacer()
            Text("1.0.0")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
        }
        
        HStack {
            Label("Développeur", systemImage: "hammer")
                .foregroundColor(.primary)
            Spacer()
            Text("Madu")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
        }
        
        HStack {
            Label("Stockage", systemImage: "internaldrive")
                .foregroundColor(.primary)
            Spacer()
            Label("100% local", systemImage: "checkmark.shield.fill")
                .font(.system(size: 13))
                .foregroundColor(.appGreen)
        }
    }
    
    // MARK: - Éditeur de nom
    
    private var nameEditorSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Votre prénom")) {
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(.appBlue)
                        TextField("Prénom", text: $tempName)
                    }
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { showNameEditor = false }
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        viewModel.userName = tempName.isEmpty ? "Madu" : tempName
                        viewModel.saveUserName()
                        showNameEditor = false
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    SettingsView(
        authManager: AuthenticationManager(),
        notifManager: NotificationManager()
    )
    .environmentObject(FinanceViewModel())
}
