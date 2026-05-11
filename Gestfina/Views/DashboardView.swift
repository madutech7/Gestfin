//
//  DashboardView.swift
//  SamaXaalis
//
//  Design identique aux apps Apple (Stocks · Santé · Wallet)
//  — AreaMark chart, subtitle date, icônes Réglages-style, swipe actions
//

import SwiftUI
import Charts

struct CustomRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CustomRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings   = false
    @State private var balanceVisible = true
    @State private var animateIn      = false
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .top) {
                    // Fond supérieur (sobre, gris clair Apple)
                    GeometryReader { geo in
                        Color(UIColor.systemGroupedBackground)
                            .frame(height: geo.frame(in: .global).minY > 0 ? geo.frame(in: .global).minY + 300 : 300)
                            .offset(y: geo.frame(in: .global).minY > 0 ? -geo.frame(in: .global).minY : 0)
                    }
                    .frame(height: 300)
                    
                    VStack(spacing: 0) {
                        // ── EN-TÊTE ──
                        HStack {
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.primary)
                            }
                            
                            Spacer()
                            
                            // Titre sobre au lieu du bouton fake
                            Text("SamaXaalis")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                            }) {
                                Image(systemName: balanceVisible ? "eye" : "eye.slash")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // ── INDICATEURS (Style discret Apple) ──
                        HStack(spacing: 8) {
                            Circle().fill(Color.primary).frame(width: 6, height: 6)
                            Circle().fill(Color.primary.opacity(0.2)).frame(width: 6, height: 6)
                            Circle().fill(Color.primary.opacity(0.2)).frame(width: 6, height: 6)
                        }
                        .padding(.vertical, 25)
                        
                        // ── CARTE PRINCIPALE (Vraies infos) ──
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Solde total")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(UIColor.systemBackground).opacity(0.8))
                                    
                                    Text(balanceVisible
                                         ? viewModel.formatAmount(viewModel.totalBalance)
                                         : "••••••••")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color(UIColor.systemBackground))
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                }
                                Spacer()
                                
                                // Symbole Apple Pay / Wallet style
                                Image(systemName: "applelogo")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color(UIColor.systemBackground).opacity(0.8))
                            }
                            
                            let rate = viewModel.savingsRate
                            let positive = rate >= 0
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: positive ? "arrow.up.right" : "arrow.down.right")
                                    Text("\(positive ? "+" : "")\(viewModel.formatPercentage(rate))")
                                }
                                .font(.footnote.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(UIColor.systemBackground).opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(Color(UIColor.systemBackground))
                                
                                Spacer()
                                
                                Text(viewModel.formatAmount(viewModel.totalIncome - viewModel.totalExpenses))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color(UIColor.systemBackground).opacity(0.9))
                            }
                        }
                        .padding(24)
                        // Fond sombre ou clair inversé (très élégant, type Apple Card)
                        .background(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, -40) // Chevauchement
                        .zIndex(1)
                        
                        // ── FEUILLE BLANCHE DU BAS (Contenant vos VRAIES DONNÉES) ──
                        VStack(spacing: 0) {
                            Spacer().frame(height: 60) // Espace pour le chevauchement
                            
                            VStack(spacing: 30) {
                                // 1. Revenus / Dépenses (Vraies infos)
                                HStack(spacing: 15) {
                                    cashCard(title: "Revenus", amount: viewModel.formatAmount(viewModel.totalIncome), icon: "arrow.down.left", color: .green)
                                    cashCard(title: "Dépenses", amount: viewModel.formatAmount(viewModel.totalExpenses), icon: "arrow.up.right", color: .red)
                                }
                                .padding(.horizontal, 20)
                                
                                // 2. Catégories de l'utilisateur (Vraies infos)
                                if !viewModel.expensesByCategory.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Dépenses par catégorie")
                                            .font(.headline)
                                            .padding(.horizontal, 20)
                                        
                                        VStack(spacing: 12) {
                                            ForEach(viewModel.expensesByCategory.prefix(4), id: \.category) { item in
                                                categoryRow(item: item)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                                
                                // 3. Graphique (Activité)
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Activité")
                                        .font(.headline)
                                        .padding(.horizontal, 20)
                                    
                                    Chart(viewModel.dailyExpenses, id: \.day) { item in
                                        AreaMark(
                                            x: .value("Jour", item.day),
                                            y: .value("Montant", item.amount)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        LineMark(
                                            x: .value("Jour", item.day),
                                            y: .value("Montant", item.amount)
                                        )
                                        .foregroundStyle(Color.blue)
                                        .lineStyle(StrokeStyle(lineWidth: 2))
                                        .interpolationMethod(.catmullRom)
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) {
                                            AxisValueLabel().font(.system(size: 10)).foregroundStyle(Color.secondary)
                                        }
                                    }
                                    .chartYAxis(.hidden)
                                    .frame(height: 120)
                                    .padding(.horizontal, 20)
                                }
                                
                                // 4. Transactions Récentes
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Récentes")
                                        .font(.headline)
                                        .padding(.horizontal, 20)
                                    
                                    if viewModel.recentTransactions.isEmpty {
                                        Text("Aucune transaction")
                                            .foregroundStyle(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                    } else {
                                        ForEach(viewModel.recentTransactions) { t in
                                            TransactionRow(transaction: t)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 4)
                                                .contextMenu {
                                                    Button(role: .destructive) {
                                                        withAnimation { viewModel.deleteTransaction(t) }
                                                    } label: {
                                                        Label("Supprimer", systemImage: "trash")
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 40)
                        }
                        .background(
                            Color(UIColor.systemBackground)
                                .clipShape(CustomRoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                        )
                    }
                }
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView(authManager: authManager, notifManager: notifManager)
                        .environmentObject(viewModel)
                }
            }
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // MARK: – Helpers
    // ──────────────────────────────────────────────────────────────────

    private func cashCard(title: String, amount: String, icon: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(color)
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(amount)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func settingsIcon(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func categoryRow(item: (category: TransactionCategory, amount: Double, percentage: Double)) -> some View {
        HStack(spacing: 12) {
            settingsIcon(systemName: item.category.icon, color: item.category.color)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.category.rawValue)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.subheadline.weight(.semibold))
                        .fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemFill))
                            .frame(height: 3)
                        Capsule()
                            .fill(item.category.color)
                            .frame(
                                width: geo.size.width * CGFloat(min(item.percentage / 100, 1)),
                                height: 3
                            )
                            .animation(.spring(response: 0.6), value: item.percentage)
                    }
                }
                .frame(height: 3)
            }
        }
        .padding(.vertical, 8)
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassBarChart (encore utilisé par StatisticsView)
// ─────────────────────────────────────────────────────────────────────

struct GlassBarChart: View {
    let data: [(day: String, amount: Double)]
    private var maxAmount: Double { data.map(\.amount).max() ?? 1 }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                let isLast = index == data.count - 1
                let ratio  = maxAmount > 0 ? CGFloat(item.amount / maxAmount) : 0.05
                VStack(spacing: 5) {
                    GeometryReader { geo in
                        VStack { Spacer()
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(isLast ? Color(UIColor.systemBlue) : Color(UIColor.systemBlue).opacity(0.18))
                                .frame(height: max(geo.size.height * ratio, 5))
                        }
                    }
                    Text(item.day)
                        .font(.system(size: 10, weight: isLast ? .bold : .regular))
                        .foregroundStyle(isLast ? Color(UIColor.systemBlue) : Color.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – GlassCategoryRow (utilisé par BudgetView / StatisticsView)
// ─────────────────────────────────────────────────────────────────────

struct GlassCategoryRow: View {
    let category: TransactionCategory; let amount: String; let percentage: Double
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(category.color).frame(width: 30, height: 30)
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue).font(.subheadline.weight(.medium))
                    Spacer()
                    Text(amount).font(.subheadline.weight(.semibold)).fontDesign(.rounded)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(UIColor.systemFill)).frame(height: 3)
                        Capsule().fill(category.color)
                            .frame(width: geo.size.width * CGFloat(min(percentage / 100, 1)), height: 3)
                    }
                }.frame(height: 3)
            }
        }.padding(.vertical, 3)
    }
}

#Preview {
    DashboardView(authManager: AuthenticationManager(), notifManager: NotificationManager())
        .environmentObject(FinanceViewModel())
}
