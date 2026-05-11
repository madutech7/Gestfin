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
        case add          = "Ajouter"
        case budget       = "Budget"
    }

    @Namespace private var animation

    init(authManager: AuthenticationManager, notifManager: NotificationManager) {
        self.authManager  = authManager
        self.notifManager = notifManager
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView(authManager: authManager, notifManager: notifManager)
                case .transactions:
                    TransactionsView()
                case .add:
                    EmptyView() // Ignored
                case .budget:
                    BudgetView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Detached Floating Tab Bar
            HStack(spacing: 12) {
                // Main Navigation Pill
                HStack(spacing: 8) {
                    TabBarButton(tab: .dashboard, selectedTab: $selectedTab, icon: "house", selectedIcon: "house.fill", title: "Accueil", animation: animation)
                    TabBarButton(tab: .transactions, selectedTab: $selectedTab, icon: "arrow.left.arrow.right", selectedIcon: "arrow.left.arrow.right", title: "Transactions", animation: animation)
                    TabBarButton(tab: .budget, selectedTab: $selectedTab, icon: "chart.pie", selectedIcon: "chart.pie.fill", title: "Budget", animation: animation)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 12, y: 6)
                )

                // Detached Add Action Button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.appBlue)
                        .clipShape(Circle())
                        .shadow(color: Color.appBlue.opacity(0.3), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }
}

// MARK: - TabBarButton Component
struct TabBarButton: View {
    let tab: MainTabView.AppTab
    @Binding var selectedTab: MainTabView.AppTab
    let icon: String
    let selectedIcon: String
    let title: String
    let animation: Namespace.ID
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button {
            if !isSelected {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tab
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .semibold))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.horizontal, isSelected ? 14 : 10)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.appBlue)
                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: animation)
                    }
                }
            )
        }
        .buttonStyle(.plain)
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
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appBlue)
        }

        HStack {
            Label("Budgets actifs", systemImage: "chart.pie")
            Spacer()
            Text("\(viewModel.budgets.count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appBlue)
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
            Label("Développeur", systemImage: "hammer.fill")
            Spacer()
            Text("Madu")
                .font(.system(size: 15, weight: .semibold))
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
