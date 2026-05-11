//
//  MainTabView.swift
//  Gestfina
//
//  Navigation native avec Tab Bar — 5 onglets + Réglages
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showAddTransaction = false
    @EnvironmentObject var viewModel: FinanceViewModel
    
    let authManager: AuthenticationManager
    let notifManager: NotificationManager
    
    enum AppTab: String, CaseIterable {
        case dashboard    = "Accueil"
        case transactions = "Transactions"
        case add          = "Ajouter"
        case budget       = "Budget"
        case statistics   = "Stats"
    }
    
    init(authManager: AuthenticationManager, notifManager: NotificationManager) {
        self.authManager  = authManager
        self.notifManager = notifManager
        
        // Tab Bar apparence native (translucide avec flou iOS)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(AppTab.dashboard)
                .toolbar(.hidden, for: .tabBar)
            
            TransactionsView()
                .tag(AppTab.transactions)
                .toolbar(.hidden, for: .tabBar)
            
            Color.clear
                .tag(AppTab.add)
                .toolbar(.hidden, for: .tabBar)
            
            BudgetView()
                .tag(AppTab.budget)
                .toolbar(.hidden, for: .tabBar)
            
            SettingsView(authManager: authManager, notifManager: notifManager)
                .tag(AppTab.statistics)
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom) {
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 12) {
            // Pill Container for main tabs
            HStack(spacing: 0) {
                tabButton(tab: .dashboard, icon: "house.fill")
                tabButton(tab: .transactions, icon: "arrow.left.arrow.right")
                
                // Add Button
                Button {
                    Haptics.play(.medium)
                    showAddTransaction = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                        Text("Ajouter")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                }
                
                tabButton(tab: .budget, icon: "chart.pie.fill")
            }
            .padding(.horizontal, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
            )
            
            // Separated Settings Button
            Button {
                Haptics.play(.light)
                selectedTab = .statistics
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24))
                    Text("Réglages")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(selectedTab == .statistics ? .appBlue : .secondary)
                .frame(width: 70, height: 60)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8) // Safe area padding is usually handled by ZStack, but a bit extra looks nice
    }
    
    private func tabButton(tab: AppTab, icon: String) -> some View {
        Button {
            Haptics.play(.light)
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selectedTab == tab ? .appBlue : .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
    }
}

#Preview {
    MainTabView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}


//
//  SettingsView.swift
//  Gestfina
//
//  Paramètres complets — Profil, Devise, Sécurité, Notifications, Données
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @ObservedObject var authManager: AuthenticationManager
    @ObservedObject var notifManager: NotificationManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showResetAlert    = false
    @State private var showNameEditor    = false
    @State private var showCurrencyPicker = false
    @State private var tempName          = ""
    
    var body: some View {
        NavigationView {
            List {
                
                // MARK: - Profil
                Section {
                    profileRow
                } header: {
                    Text("Profil")
                }
                
                // MARK: - Devise
                Section {
                    currencyRow
                } header: {
                    Text("Devise")
                } footer: {
                    Text("La devise sélectionnée sera utilisée pour toutes les transactions et les budgets.")
                }
                
                // MARK: - Sécurité
                Section {
                    securitySection
                } header: {
                    Text("Sécurité")
                } footer: {
                    Text(authManager.isAuthEnabled
                         ? "L'application se verrouille automatiquement en arrière-plan."
                         : "Activez \(authManager.biometricName) pour protéger vos données financières.")
                }
                
                // MARK: - Notifications
                Section {
                    notificationsSection
                } header: {
                    Text("Notifications")
                } footer: {
                    if notifManager.authorizationStatus == .denied {
                        Text("Notifications désactivées. Activez-les dans Réglages > SamaXaalis.")
                    }
                }
                
                // MARK: - Données
                Section {
                    dataSection
                } header: {
                    Text("Données")
                } footer: {
                    Text("Toutes vos données sont stockées uniquement sur votre appareil.")
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
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerSheet(selectedCode: $viewModel.currency)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
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
    
    // MARK: - Devise Row
    
    private var currencyRow: some View {
        Button {
            showCurrencyPicker = true
        } label: {
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Devise")
                            .foregroundColor(.primary)
                        if let currency = AppCurrency.all.first(where: { $0.code == viewModel.currency }) {
                            Text(currency.name)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                } icon: {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.appBlue)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(viewModel.currencySymbol)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.appBlue)
                    Text(viewModel.currency)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Sécurité
    
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
            Label("Biométrie non disponible", systemImage: "exclamationmark.shield")
                .foregroundColor(.secondary)
        }
        
        HStack {
            Label("Stockage chiffré local", systemImage: "lock.shield.fill")
                .foregroundColor(.primary)
            Spacer()
            Label("Actif", systemImage: "checkmark.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(.appGreen)
        }
    }
    
    // MARK: - Notifications
    
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
                Label("Ouvrir les Réglages système", systemImage: "gear")
                    .foregroundColor(.appBlue)
            }
        } else {
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
                    Spacer()
                    Stepper("", value: $notifManager.reminderHour, in: 6...23)
                        .labelsHidden()
                    Text("\(notifManager.reminderHour)h00")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.appBlue)
                        .frame(width: 52, alignment: .trailing)
                }
            }
        }
    }
    
    // MARK: - Données
    
    @ViewBuilder
    private var dataSection: some View {
        HStack {
            Label("Transactions enregistrées", systemImage: "arrow.left.arrow.right")
            Spacer()
            Text("\(viewModel.transactions.count)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        
        HStack {
            Label("Budgets actifs", systemImage: "chart.pie")
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
    
    // MARK: - À propos
    
    @ViewBuilder
    private var aboutSection: some View {
        HStack {
            Label("Version", systemImage: "info.circle")
            Spacer()
            Text("1.0.0")
                .foregroundColor(.secondary)
        }
        HStack {
            Label("Développeur", systemImage: "hammer")
            Spacer()
            Text("Madu")
                .foregroundColor(.secondary)
        }
        HStack {
            Label("Données 100% locales", systemImage: "internaldrive")
            Spacer()
            Image(systemName: "checkmark.shield.fill")
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

// MARK: - Sélecteur de devise

struct CurrencyPickerSheet: View {
    @Binding var selectedCode: String
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    private var filteredGroups: [(region: String, currencies: [AppCurrency])] {
        if searchText.isEmpty { return AppCurrency.grouped }
        let q = searchText.lowercased()
        return AppCurrency.grouped.compactMap { group in
            let filtered = group.currencies.filter {
                $0.name.lowercased().contains(q) ||
                $0.code.lowercased().contains(q) ||
                $0.symbol.lowercased().contains(q)
            }
            return filtered.isEmpty ? nil : (group.region, filtered)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredGroups, id: \.region) { group in
                    Section(header: Text(group.region)) {
                        ForEach(group.currencies) { currency in
                            Button {
                                selectedCode = currency.code
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    // Symbole de devise dans un cercle
                                    ZStack {
                                        Circle()
                                            .fill(Color.appBlue.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        Text(currency.symbol)
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(.appBlue)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(currency.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.primary)
                                        Text(currency.code)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedCode == currency.code {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.appBlue)
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher une devise")
            .navigationTitle("Choisir une devise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    SettingsView(
        authManager: AuthenticationManager(),
        notifManager: NotificationManager()
    )
    .environmentObject(FinanceViewModel())
}

