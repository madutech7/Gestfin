//
//  TransactionsView.swift
//  Gestfina
//
//  Liste des transactions — Design premium Apple-native
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var viewModel: FinanceViewModel
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: AppTransaction?
    @State private var transactionToEdit: AppTransaction?
    @Environment(\.colorScheme) var colorScheme
    
    // Nouveaux états Premium
    @State private var showPaywall = false
    @State private var exportURL: IdentifiableURL? = nil
    @ObservedObject private var subManager = SubscriptionManager.shared

    private var netBalance: Double {
        viewModel.filteredTransactions.reduce(0) { $0 + $1.signedAmount }
    }

    var body: some View {
        NavigationView {
            List {
                // Filtres période
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Group {
                                PremiumFilterChip(title: L10n.all, isSelected: viewModel.selectedFilter == nil, color: Color.appBlue) {
                                    viewModel.selectedFilter = nil
                                }
                                PremiumFilterChip(title: L10n.income, isSelected: viewModel.selectedFilter == .income, color: Color.appGreen) {
                                    viewModel.selectedFilter = .income
                                }
                                PremiumFilterChip(title: L10n.expenses, isSelected: viewModel.selectedFilter == .expense, color: Color.appRed) {
                                    viewModel.selectedFilter = .expense
                                }
                            }

                            Rectangle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 1, height: 20)
                                .padding(.horizontal, 4)

                            ForEach(FinanceViewModel.TimePeriod.allCases, id: \.self) { period in
                                PremiumFilterChip(title: L10n.periodName(period), isSelected: viewModel.selectedPeriod == period, color: Color.appBlue) {
                                    viewModel.selectedPeriod = period
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                // Summary bar
                if !viewModel.filteredTransactions.isEmpty {
                    Section {
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "number")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.appBlue)
                                Text(L10n.operationsCount(viewModel.filteredTransactions.count))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: netBalance >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    .font(.system(size: 10, weight: .bold))
                                Text(viewModel.isBalanceVisible ? viewModel.formatAmount(netBalance) : "••••")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(netBalance >= 0 ? Color.appGreen : Color.appRed)
                        }
                    }
                }

                // Transactions list
                if viewModel.filteredTransactions.isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appBlue.opacity(0.12), Color.appCyan.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                Image(systemName: "tray")
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundStyle(Color.appBlue)
                            }
                            VStack(spacing: 6) {
                                Text(L10n.noTransaction)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                Text(L10n.addFirstViaPlus)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    // Group by date
                    let grouped = Dictionary(grouping: viewModel.filteredTransactions) { transaction in
                        Calendar.current.startOfDay(for: transaction.date)
                    }
                    let sortedKeys = grouped.keys.sorted(by: >)

                    ForEach(sortedKeys, id: \.self) { date in
                        Section(header: Text(date.localizedRelativeFormatted).textCase(nil)) {
                            ForEach(grouped[date]!) { transaction in
                                TransactionRow(transaction: transaction)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        transactionToEdit = transaction
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            transactionToEdit = transaction
                                        } label: {
                                            Label(L10n.edit, systemImage: "pencil")
                                        }
                                        .tint(.appBlue)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            transactionToDelete = transaction
                                            showDeleteAlert = true
                                        } label: {
                                            Label(L10n.delete, systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(UIColor.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .searchable(text: $viewModel.searchText, prompt: L10n.searchTransaction)
            .refreshable {
                SyncManager.shared.triggerSynchronization()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            .navigationTitle(L10n.tabTransactions)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            if subManager.isPremium {
                                exportToCSV()
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Label(L10n.exportCSV, systemImage: "tablecells")
                        }
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            if subManager.isPremium {
                                exportToPDF()
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Label(L10n.exportPDF, systemImage: "doc.richtext")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .bold))
                            Text(L10n.export)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(Color.appBlue)
                    }
                }
            }
        }
        .alert(L10n.deleteTransactionConfirm, isPresented: $showDeleteAlert) {
            Button(L10n.cancel, role: .cancel) { }
            Button(L10n.delete, role: .destructive) {
                if let t = transactionToDelete {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.deleteTransaction(t)
                    }
                }
            }
        } message: {
            if let t = transactionToDelete {
                Text(L10n.willBeDeleted(t.title))
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(item: $exportURL) { item in
            ShareSheet(activityItems: [item.url])
        }
        .sheet(item: $transactionToEdit) { transaction in
            EditTransactionView(transaction: transaction)
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Générateur d'Exportation CSV Premium
    
    private func exportToCSV() {
        var csvString = "Date;Titre;Type;Categorie;Montant;Note\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for tx in viewModel.filteredTransactions {
            let dateStr = formatter.string(from: tx.date)
            let typeStr = tx.type == .income ? L10n.incomeType : L10n.expenseType
            let amountStr = String(format: "%.2f", tx.amount)
            
            // Nettoyer les caractères spéciaux et les séparateurs point-virgule
            let titleCleaned = tx.title.replacingOccurrences(of: ";", with: ",").replacingOccurrences(of: "\"", with: "'")
            let noteCleaned = tx.note.replacingOccurrences(of: ";", with: ",").replacingOccurrences(of: "\"", with: "'")
            
            csvString += "\(dateStr);\"\(titleCleaned)\";\(typeStr);\(L10n.categoryName(tx.category));\(amountStr);\"\(noteCleaned)\"\n"
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let filename = "SamaXaalis_Export_\(Int(Date().timeIntervalSince1970)).csv"
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                self.exportURL = IdentifiableURL(url: fileURL)
            }
        } catch {
            print("Erreur d'écriture du fichier CSV : \(error)")
        }
    }
    
    // MARK: - Générateur d'Exportation PDF Premium
    
    private func exportToPDF() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: L10n.dateLocaleIdentifier)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "SamaXaalis",
            kCGPDFContextAuthor: viewModel.userName,
            kCGPDFContextTitle: "Rapport Financier SamaXaalis"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2   // A4
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 40
        _ = pageWidth - margin * 2
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            var yPos: CGFloat = margin
            
            // Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let titleAttr: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.label]
            let title = "Rapport Financier" as NSString
            title.draw(at: CGPoint(x: margin, y: yPos), withAttributes: titleAttr)
            yPos += 36
            
            // Subtitle
            let subFont = UIFont.systemFont(ofSize: 12, weight: .medium)
            let subAttr: [NSAttributedString.Key: Any] = [.font: subFont, .foregroundColor: UIColor.secondaryLabel]
            let dateStr = formatter.string(from: Date())
            let subtitle = "Généré le \(dateStr) — \(viewModel.filteredTransactions.count) opérations" as NSString
            subtitle.draw(at: CGPoint(x: margin, y: yPos), withAttributes: subAttr)
            yPos += 30
            
            // Summary
            let totalInc = viewModel.filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let totalExp = viewModel.filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            let summaryFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
            let summaryAttr: [NSAttributedString.Key: Any] = [.font: summaryFont, .foregroundColor: UIColor.label]
            let summary = "\(L10n.income): \(viewModel.formatAmount(totalInc))  |  \(L10n.expenses): \(viewModel.formatAmount(totalExp))  |  \(L10n.totalBalance): \(viewModel.formatAmount(totalInc - totalExp))" as NSString
            summary.draw(at: CGPoint(x: margin, y: yPos), withAttributes: summaryAttr)
            yPos += 34
            
            // Separator
            let separatorPath = UIBezierPath()
            separatorPath.move(to: CGPoint(x: margin, y: yPos))
            separatorPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPos))
            UIColor.separator.setStroke()
            separatorPath.lineWidth = 0.5
            separatorPath.stroke()
            yPos += 16
            
            // Table header
            let headerFont = UIFont.systemFont(ofSize: 10, weight: .bold)
            let headerAttr: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.secondaryLabel]
            let columns: [(String, CGFloat)] = [("Date", margin), ("Titre", margin + 70), (L10n.category, margin + 230), (L10n.amount, margin + 360)]
            for (text, x) in columns {
                (text as NSString).draw(at: CGPoint(x: x, y: yPos), withAttributes: headerAttr)
            }
            yPos += 22
            
            // Rows
            let rowFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let rowAmountFont = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .semibold)
            
            for tx in viewModel.filteredTransactions {
                if yPos > pageHeight - 60 {
                    context.beginPage()
                    yPos = margin
                }
                
                let rowAttr: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.label]
                let amountColor: UIColor = tx.type == .income ? .systemGreen : .label
                let amountAttr: [NSAttributedString.Key: Any] = [.font: rowAmountFont, .foregroundColor: amountColor]
                
                (formatter.string(from: tx.date) as NSString).draw(at: CGPoint(x: margin, y: yPos), withAttributes: rowAttr)
                
                let titleRect = CGRect(x: margin + 70, y: yPos, width: 155, height: 14)
                (tx.title as NSString).draw(in: titleRect, withAttributes: rowAttr)
                
                (L10n.categoryName(tx.category) as NSString).draw(at: CGPoint(x: margin + 230, y: yPos), withAttributes: rowAttr)
                
                let prefix = tx.type == .income ? "+" : "-"
                let amountStr = "\(prefix)\(viewModel.formatAmount(tx.amount))" as NSString
                amountStr.draw(at: CGPoint(x: margin + 360, y: yPos), withAttributes: amountAttr)
                
                yPos += 20
            }
            
            // Footer
            let footerFont = UIFont.systemFont(ofSize: 8, weight: .medium)
            let footerAttr: [NSAttributedString.Key: Any] = [.font: footerFont, .foregroundColor: UIColor.tertiaryLabel]
            let footer = "SamaXaalis — Rapport généré automatiquement" as NSString
            footer.draw(at: CGPoint(x: margin, y: pageHeight - 30), withAttributes: footerAttr)
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "SamaXaalis_Rapport_\(Int(Date().timeIntervalSince1970)).pdf"
        let fileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            DispatchQueue.main.async {
                self.exportURL = IdentifiableURL(url: fileURL)
            }
        } catch {
            print("Erreur PDF: \(error)")
        }
    }
}

// MARK: - Premium Filter Chip

struct PremiumFilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .appBlue
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { action() }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color(UIColor.tertiarySystemGroupedBackground))
                )
        }
        .buttonStyle(.plain)
    }
}

// Keep FilterChip as alias for backward compat
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .appBlue
    let action: () -> Void

    var body: some View {
        PremiumFilterChip(title: title, isSelected: isSelected, color: color, action: action)
    }
}

// MARK: - Premium Export Models & UI Activity View Controller

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    TransactionsView()
        .environmentObject(FinanceViewModel())
}
