//
//  MainTabView.swift
//  Gestfina
//
//  Navigation premium avec Tab Bar natif — Design Apple-tier
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
        case budget       = "Budget"
        case add          = "Ajouter"
    }

    init(authManager: AuthenticationManager, notifManager: NotificationManager) {
        self.authManager  = authManager
        self.notifManager = notifManager

        // Premium tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: Binding(
            get: { selectedTab },
            set: { newTab in
                if newTab == .add {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showAddTransaction = true
                } else {
                    if newTab != selectedTab {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    selectedTab = newTab
                }
            }
        )) {
            DashboardView(authManager: authManager, notifManager: notifManager)
                .tabItem {
                    Label("Accueil", systemImage: selectedTab == .dashboard ? "house.fill" : "house")
                }
                .tag(AppTab.dashboard)

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "arrow.left.arrow.right")
                }
                .tag(AppTab.transactions)

            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: selectedTab == .budget ? "chart.pie.fill" : "chart.pie")
                }
                .tag(AppTab.budget)

            // "+" trigger tab (last position)
            Color.clear
                .tabItem {
                    Label("Ajouter", systemImage: "plus.circle.fill")
                }
                .tag(AppTab.add)
        }
        .tint(.appBlue)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
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
//  Paramètres — Design premium Apple Settings native
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
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                Circle().fill(Color.appBlue.opacity(0.12)).frame(width: 300).blur(radius: 60).offset(x: -100, y: -200)
                Circle().fill(Color.appPurple.opacity(0.1)).frame(width: 300).blur(radius: 60).offset(x: 150, y: 300)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        
                        // MARK: - Profil
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PROFIL").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).padding(.leading, 8)
                            profileRow
                                .padding(16)
                                .liquidGlass(cornerRadius: 24, opacity: colorScheme == .dark ? 0.1 : 0.03)
                        }
                        
                        // MARK: - Général
                        VStack(alignment: .leading, spacing: 8) {
                            Text("GÉNÉRAL").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).padding(.leading, 8)
                            VStack(spacing: 0) {
                                currencyRow.padding(16)
                                Divider().padding(.leading, 56)
                                securitySection.padding(16)
                            }
                            .liquidGlass(cornerRadius: 24, opacity: colorScheme == .dark ? 0.1 : 0.03)
                        }
                        
                        // MARK: - Notifications
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTIFICATIONS").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).padding(.leading, 8)
                            VStack(spacing: 0) {
                                notificationsSection
                            }
                            .liquidGlass(cornerRadius: 24, opacity: colorScheme == .dark ? 0.1 : 0.03)
                        }
                        
                        // MARK: - Données
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DONNÉES").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).padding(.leading, 8)
                            VStack(spacing: 0) {
                                dataSection
                            }
                            .liquidGlass(cornerRadius: 24, opacity: colorScheme == .dark ? 0.1 : 0.03)
                        }
                        
                        // MARK: - À Propos
                        VStack(alignment: .leading, spacing: 8) {
                            Text("À PROPOS").font(.system(size: 12, weight: .bold)).foregroundColor(.secondary).padding(.leading, 8)
                            VStack(spacing: 0) {
                                aboutSection
                            }
                            .liquidGlass(cornerRadius: 24, opacity: colorScheme == .dark ? 0.1 : 0.03)
                        }
                        
                        // MARK: - Déconnexion
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            BackendAuthManager.shared.logout()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Se déconnecter")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(Color.appRed)
                            .clipShape(Capsule())
                            .shadow(color: Color.appRed.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.top, 10)
                        
                        Text("SamaXaalis Cloud Sync est actif.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .alert("Réinitialiser toutes les données ?", isPresented: $showResetAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Réinitialiser", role: .destructive) {
                    viewModel.resetAllData()
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                }
            } message: {
                Text("Toutes vos transactions et budgets locaux seront supprimés définitivement. Cette action est irréversible.")
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
                                colors: [Color.appBlue, Color.appCyan],
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
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(Color.appBlue)
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 22))
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(viewModel.currencySymbol)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appBlue)
                    Text(viewModel.currency)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(Color.appBlue)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { authManager.isAuthEnabled },
                    set: { newValue in
                        withAnimation(.spring(response: 0.3)) {
                            authManager.isAuthEnabled = newValue
                            if !newValue { authManager.isUnlocked = true }
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                .font(.system(size: 13, weight: .semibold))
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
                Label("Activer les notifications", systemImage: "bell.badge.fill")
                    .foregroundColor(.appBlue)
            }
            .padding(16)
        } else if notifManager.authorizationStatus == .denied {
            Button {
                notifManager.openSettings()
            } label: {
                Label("Ouvrir les Réglages système", systemImage: "gear")
                    .foregroundColor(.appBlue)
            }
            .padding(16)
        } else {
            Toggle(isOn: $notifManager.budgetAlertEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alertes budget")
                            .foregroundColor(.primary)
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
            .padding(16)

            Divider().padding(.leading, 56)

            Toggle(isOn: $notifManager.dailyReminderEnabled) {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rappel quotidien")
                            .foregroundColor(.primary)
                        Text("Saisir vos dépenses du jour")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.appBlue)
                }
            }
            .tint(.appBlue)
            .padding(16)

            if notifManager.dailyReminderEnabled {
                Divider().padding(.leading, 56)
                HStack {
                    Label("Heure du rappel", systemImage: "clock")
                        .foregroundColor(.primary)
                    Spacer()
                    Stepper("", value: $notifManager.reminderHour, in: 6...23)
                        .labelsHidden()
                    Text("\(notifManager.reminderHour)h00")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.appBlue)
                        .frame(width: 52, alignment: .trailing)
                }
                .padding(16)
            }
        }
    }

    // MARK: - Données

    @ViewBuilder
    private var dataSection: some View {
        HStack {
            Label("Transactions enregistrées", systemImage: "arrow.left.arrow.right")
                .foregroundColor(.primary)
            Spacer()
            Text("\(viewModel.transactions.count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appBlue)
        }
        .padding(16)

        Divider().padding(.leading, 56)

        HStack {
            Label("Budgets actifs", systemImage: "chart.pie")
                .foregroundColor(.primary)
            Spacer()
            Text("\(viewModel.budgets.count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appBlue)
        }
        .padding(16)

        Divider().padding(.leading, 56)

        Button {
            showResetAlert = true
        } label: {
            Label("Réinitialiser l'appareil (Local)", systemImage: "trash")
                .foregroundColor(.appRed)
        }
        .padding(16)
    }

    // MARK: - À propos

    @ViewBuilder
    private var aboutSection: some View {
        HStack {
            Label("Version", systemImage: "info.circle")
                .foregroundColor(.primary)
            Spacer()
            Text("1.0.0")
                .foregroundColor(.secondary)
        }
        .padding(16)
        
        Divider().padding(.leading, 56)
        
        HStack {
            Label("Développeur", systemImage: "hammer.fill")
                .foregroundColor(.primary)
            Spacer()
            Text("Madu")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.appBlue)
        }
        .padding(16)
        
        Divider().padding(.leading, 56)
        
        HStack {
            Label("Synchronisation Cloud", systemImage: "cloud.fill")
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.appGreen)
        }
        .padding(16)
    }

    // MARK: - Éditeur de nom

    private var nameEditorSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Votre prénom")) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.appBlue.opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: "person.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.appBlue)
                        }
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
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .font(.system(size: 16, weight: .bold))
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Currency Picker

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
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
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
