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
    @State private var showPaywall = false
    @EnvironmentObject var viewModel: FinanceViewModel
    @ObservedObject private var subManager = SubscriptionManager.shared

    let authManager: AuthenticationManager
    let notifManager: NotificationManager

    enum AppTab: String, CaseIterable {
        case dashboard    = "Accueil"
        case transactions = "Transactions"
        case coach        = "Coach IA"
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
                    if viewModel.transactions.count >= 25 && !subManager.isPremium {
                        showPaywall = true
                    } else {
                        showAddTransaction = true
                    }
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

            CoachView()
                .tabItem {
                    Label("SamaCoach", systemImage: "sparkles")
                }
                .tag(AppTab.coach)

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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
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
    @State private var showPaywall        = false
    @State private var tempName          = ""
    @ObservedObject private var subManager = SubscriptionManager.shared
    @AppStorage("gestfina_appearance") private var appearanceMode: Int = 0 // 0=system, 1=light, 2=dark

    var body: some View {
        NavigationView {
            List {
                // MARK: - Premium
                Section {
                    premiumRow
                } header: {
                    Text("Mon abonnement")
                }

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

                // MARK: - Apparence
                Section {
                    Picker(selection: $appearanceMode) {
                        Text("Système").tag(0)
                        Text("Clair").tag(1)
                        Text("Sombre").tag(2)
                    } label: {
                        Label("Apparence", systemImage: "moon.circle.fill")
                    }
                    .pickerStyle(.menu)
                    .tint(.appBlue)
                } header: {
                    Text("Affichage")
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
                    Text("Vos données sont stockées localement et synchronisées de manière sécurisée sur votre compte SamaXaalis Cloud.")
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
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Premium Row

    private var premiumRow: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showPaywall = true
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
                        .frame(width: 40, height: 40)
                    Image(systemName: "crown.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("SamaXaalis Pro")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subManager.isPremium ? "Abonnement actif — Merci pour votre soutien !" : "Débloquez les transactions illimitées & stats")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
                
                if subManager.isPremium {
                    Text("Actif")
                        .font(.system(.caption, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appGreen)
                        .clipShape(Capsule())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(.footnote, weight: .semibold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.userName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Appuyer pour modifier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(.footnote, weight: .semibold))
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
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } icon: {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(Color.appBlue)
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(viewModel.currencySymbol)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.appBlue)
                    Text(viewModel.currency)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.system(.footnote, weight: .semibold))
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
                            .font(.caption2)
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
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.appBlue)
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
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Color.appBlue)
        }

        HStack {
            Label("Budgets actifs", systemImage: "chart.pie")
            Spacer()
            Text("\(viewModel.budgets.count)")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Color.appBlue)
        }

        Button {
            viewModel.resetAllData()
        } label: {
            Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                .foregroundColor(.orange)
        }

        Button {
            showResetAlert = true
        } label: {
            Label("Réinitialiser l'appareil (Local)", systemImage: "trash")
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
            Label("Développeur", systemImage: "hammer.fill")
            Spacer()
            Text("Madu")
                .font(.system(.subheadline, weight: .semibold))
                .foregroundColor(.secondary)
        }
        HStack {
            Label("Données 100% locales", systemImage: "internaldrive")
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.appGreen)
        }
        
        Link(destination: URL(string: "https://samaxaalis.com/privacy")!) {
            Label("Politique de confidentialité", systemImage: "hand.raised.fill")
                .foregroundColor(.appBlue)
        }
        
        Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
            Label("Conditions d'utilisation (EULA)", systemImage: "doc.text.fill")
                .foregroundColor(.appBlue)
        }
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
                                .font(.system(.footnote, weight: .semibold))
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
                    .font(.headline)
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
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                            .foregroundColor(.appBlue)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(currency.name)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Text(currency.code)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if selectedCode == currency.code {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.appBlue)
                                            .font(.title3)
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
