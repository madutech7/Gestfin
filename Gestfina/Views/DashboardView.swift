//
//  DashboardView.swift
//  SamaXaalis
//
//  Design ultra-premium inspiré Apple Wallet × Stocks × Health
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showSettings   = false
    @State private var balanceVisible = true
    @State private var greetingScale: CGFloat = 0.95
    @State private var greetingOpacity: Double = 0
    @State private var cardAppeared = false
    @Environment(\.colorScheme) var colorScheme

    let authManager:  AuthenticationManager
    let notifManager: NotificationManager



    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {

                    // ── GREETING ──
                    HStack {
                        Image("SamaXaalisLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 4)
                        
                        Spacer()
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showSettings = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .scaleEffect(greetingScale)
                    .opacity(greetingOpacity)

                    // ── 1. BALANCE CARD — APPLE WALLET PREMIUM ──
                    BalanceCardView(viewModel: viewModel, balanceVisible: $balanceVisible)
                        .padding(.horizontal, 20)
                        .opacity(cardAppeared ? 1 : 0)
                        .offset(y: cardAppeared ? 0 : 20)

                    // ── 2. QUICK METRICS ──
                    QuickMetricsRow(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // ── 3. SPARKLINE ACTIVITY ──
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Activité", systemImage: "chart.xyaxis.line")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("7 jours")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)

                        SparklineChartCard(viewModel: viewModel)
                            .padding(.horizontal, 20)
                    }

                    // ── 4. CATEGORIES — APPLE HEALTH STYLE ──
                    if !viewModel.expensesByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("Dépenses", systemImage: "chart.pie.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(viewModel.expensesByCategory.count) catégories")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.expensesByCategory.prefix(5).enumerated()), id: \.element.category) { index, item in
                                    PremiumCategoryRow(item: item, viewModel: viewModel)
                                    if index < min(viewModel.expensesByCategory.count, 5) - 1 {
                                        Divider()
                                            .padding(.leading, 68)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }

                    // ── 5. RECENT TRANSACTIONS ──
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Récentes", systemImage: "clock.arrow.circlepath")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.primary)
                            Spacer()
                            if !viewModel.recentTransactions.isEmpty {
                                Text("\(viewModel.recentTransactions.count)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.appBlue)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 24)

                        if viewModel.recentTransactions.isEmpty {
                            EmptyStateCard(
                                icon: "tray",
                                title: "Aucune transaction",
                                subtitle: "Ajoutez votre première opération"
                            )
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.recentTransactions.enumerated()), id: \.element.id) { index, t in
                                    TransactionRow(transaction: t)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                withAnimation(.spring(response: 0.35)) {
                                                    viewModel.deleteTransaction(t)
                                                }
                                            } label: {
                                                Label("Supprimer", systemImage: "trash")
                                            }
                                        }

                                    if index < viewModel.recentTransactions.count - 1 {
                                        Divider().padding(.leading, 68)
                                    }
                                }
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView(authManager: authManager, notifManager: notifManager)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    greetingScale = 1
                    greetingOpacity = 1
                }
                withAnimation(.spring(response: 0.7, dampingFraction: 0.78).delay(0.2)) {
                    cardAppeared = true
                }
            }
        }
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: – Balance Card (Apple Wallet × Apple Card Premium)
// ──────────────────────────────────────────────────────────────────

struct BalanceCardView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Binding var balanceVisible: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var gradientPhase: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Solde total")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.white.opacity(0.7))

                    Text(balanceVisible
                         ? viewModel.formatAmount(viewModel.totalBalance)
                         : "••••••")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        balanceVisible.toggle()
                    }
                } label: {
                    Image(systemName: balanceVisible ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(10)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }

            Spacer(minLength: 24)

            // Bottom metrics
            let rate = viewModel.savingsRate
            let positive = rate >= 0
            HStack(alignment: .bottom) {
                HStack(spacing: 6) {
                    Image(systemName: positive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11, weight: .bold))
                    Text("\(positive ? "+" : "")\(viewModel.formatPercentage(rate))")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(positive ? Color.white.opacity(0.2) : Color.red.opacity(0.3))
                )

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 12))
                    Text("SamaXaalis")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(Color.white.opacity(0.5))
            }
        }
        .padding(24)
        .frame(height: 200)
        .background(
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.08, blue: 0.12),
                        Color(red: 0.15, green: 0.12, blue: 0.22),
                        Color(red: 0.08, green: 0.10, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Subtle animated accent
                EllipticalGradient(
                    colors: [
                        Color.purple.opacity(0.25),
                        Color.blue.opacity(0.15),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.8 + sin(gradientPhase) * 0.15,
                                     y: 0.2 + cos(gradientPhase) * 0.15)
                )

                // Top-left light reflection
                RadialGradient(
                    colors: [Color.white.opacity(0.08), Color.clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.purple.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 30, x: 0, y: 15)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                gradientPhase = .pi * 2
            }
        }
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: – Quick Metrics (Revenue / Expense pills)
// ──────────────────────────────────────────────────────────────────

struct QuickMetricsRow: View {
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        HStack(spacing: 12) {
            MetricPill(
                title: "Revenus",
                amount: viewModel.formatAmount(viewModel.totalIncome),
                icon: "arrow.down.left",
                color: .appGreen
            )
            MetricPill(
                title: "Dépenses",
                amount: viewModel.formatAmount(viewModel.totalExpenses),
                icon: "arrow.up.right",
                color: .appRed
            )
        }
    }
}

struct MetricPill: View {
    let title: String
    let amount: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(amount)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: – Sparkline Chart (Apple Stocks style)
// ──────────────────────────────────────────────────────────────────

struct SparklineChartCard: View {
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Total for period
            let total = viewModel.dailyExpenses.reduce(0) { $0 + $1.amount }
            if total > 0 {
                Text(viewModel.formatAmount(total))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Chart(viewModel.dailyExpenses, id: \.day) { item in
                AreaMark(
                    x: .value("Jour", item.day),
                    y: .value("Montant", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appBlue.opacity(0.2), Color.appBlue.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Jour", item.day),
                    y: .value("Montant", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.appBlue, .appCyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 140)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: – Category Row (Apple Health style)
// ──────────────────────────────────────────────────────────────────

struct PremiumCategoryRow: View {
    let item: (category: TransactionCategory, amount: Double, percentage: Double)
    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.category.color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: item.category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(item.category.color)
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(item.category.rawValue)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                    Text(viewModel.formatAmount(item.amount))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.tertiarySystemFill))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [item.category.color, item.category.color.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(min(item.percentage / 100, 1)))
                    }
                }
                .frame(height: 5)
                .clipShape(Capsule())
            }

            Text("\(Int(item.percentage))%")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// ──────────────────────────────────────────────────────────────────
// MARK: – Empty State Card
// ──────────────────────────────────────────────────────────────────

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.tertiary)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// ─────────────────────────────────────────────────────────────────────
// MARK: – Legacy components kept for StatisticsView / BudgetView
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
