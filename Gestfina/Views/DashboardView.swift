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

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings   = false
    @State private var balanceVisible = true
    @State private var animateIn      = false
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager

    let topBgColor = Color(red: 82/255, green: 82/255, blue: 235/255)
    let cardGradient = LinearGradient(
        colors: [Color(red: 20/255, green: 200/255, blue: 255/255), Color(red: 0/255, green: 160/255, blue: 255/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .top) {
                    // Fond bleu qui s'étire vers le haut si on bounce
                    GeometryReader { geo in
                        topBgColor
                            .frame(height: geo.frame(in: .global).minY > 0 ? geo.frame(in: .global).minY + 350 : 350)
                            .offset(y: geo.frame(in: .global).minY > 0 ? -geo.frame(in: .global).minY : 0)
                    }
                    .frame(height: 350)
                    
                    VStack(spacing: 0) {
                        // ── EN-TÊTE ──
                        HStack {
                            Button(action: { showSettings = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "archivebox.fill")
                                    .font(.system(size: 12))
                                Text("\(Int(viewModel.totalIncome))")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundStyle(topBgColor)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // ── INDICATEURS + OEIL ──
                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Circle().fill(Color.white).frame(width: 8, height: 8)
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                                Circle().fill(Color.white.opacity(0.5)).frame(width: 8, height: 8)
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) { balanceVisible.toggle() }
                            }) {
                                Image(systemName: balanceVisible ? "eye.fill" : "eye.slash.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.vertical, 20)
                        
                        // ── CARTE PRINCIPALE (Vraies infos au lieu du QR) ──
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Solde total")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.9))
                                    
                                    Text(balanceVisible
                                         ? viewModel.formatAmount(viewModel.totalBalance)
                                         : "••••••••")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.4), value: viewModel.totalBalance)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                }
                                Spacer()
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
                                .background(Color.white.opacity(0.2))
                                .clipShape(Capsule())
                                .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Text(viewModel.formatAmount(viewModel.totalIncome - viewModel.totalExpenses))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(24)
                        .background(cardGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                        .padding(.bottom, -50)
                        .zIndex(1)
                        
                        // ── FEUILLE BLANCHE DU BAS ──
                        VStack(spacing: 0) {
                            Spacer().frame(height: 70) // Espace pour le chevauchement
                            
                            // ── GRILLE DES ACTIONS DE L'IMAGE ──
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 24) {
                                actionIcon(icon: "person.fill", title: "Transfert", bgColor: Color.blue.opacity(0.15), iconColor: .blue)
                                actionIcon(icon: "basket.fill", title: "Paiements", bgColor: Color.orange.opacity(0.15), iconColor: .orange)
                                actionIcon(icon: "iphone", title: "Crédit", bgColor: Color.cyan.opacity(0.15), iconColor: .cyan)
                                actionIcon(icon: "building.columns.fill", title: "Banque", bgColor: Color.red.opacity(0.15), iconColor: .red)
                                
                                actionIcon(icon: "creditcard.fill", title: "Carte", bgColor: Color.purple.opacity(0.15), iconColor: .purple)
                                actionIcon(icon: "gift.fill", title: "Cadeaux", bgColor: Color.green.opacity(0.15), iconColor: .green)
                                actionIcon(icon: "vault.fill", title: "Coffre", bgColor: Color.pink.opacity(0.15), iconColor: .pink)
                                actionIcon(icon: "bus.fill", title: "Transport", bgColor: Color.orange.opacity(0.15), iconColor: .orange)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            
                            // ── SUITE DES INFORMATIONS DE L'APP ──
                            VStack(spacing: 24) {
                                HStack(spacing: 15) {
                                    cashCard(title: "Revenus", amount: viewModel.formatAmount(viewModel.totalIncome), icon: "arrow.down.left", color: .green)
                                    cashCard(title: "Dépenses", amount: viewModel.formatAmount(viewModel.totalExpenses), icon: "arrow.up.right", color: .red)
                                }
                                .padding(.horizontal, 20)
                                
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
                                                colors: [topBgColor.opacity(0.3), topBgColor.opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        LineMark(
                                            x: .value("Jour", item.day),
                                            y: .value("Montant", item.amount)
                                        )
                                        .foregroundStyle(topBgColor)
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

    private func actionIcon(icon: String, title: String, bgColor: Color, iconColor: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
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
