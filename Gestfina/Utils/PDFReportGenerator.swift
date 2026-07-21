//
//  PDFReportGenerator.swift
//  Gestfina
//
//  Générateur de rapports financiers mensuels au format PDF natif
//

import Foundation
import UIKit
import PDFKit

class PDFReportGenerator {
    static let shared = PDFReportGenerator()
    
    private init() {}
    
    /// Génère un document PDF contenant le rapport financier mensuel
    func generateMonthlyReport(
        transactions: [AppTransaction],
        budgets: [Budget],
        periodTitle: String,
        userName: String,
        currencySymbol: String
    ) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Gestfina",
            kCGPDFContextAuthor: userName,
            kCGPDFContextTitle: "Rapport Financier - \(periodTitle)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let pdfURL = tempDir.appendingPathComponent("Rapport_Financier_Gestfina.pdf")
        
        do {
            try renderer.writePDF(to: pdfURL) { context in
                context.beginPage()
                
                let margin: CGFloat = 40.0
                var currentY: CGFloat = margin
                
                // En-tête du document
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                    .foregroundColor: UIColor.systemBlue
                ]
                let titleString = NSAttributedString(string: "Gestfina — Rapport Financier", attributes: titleAttributes)
                titleString.draw(at: CGPoint(x: margin, y: currentY))
                currentY += 32.0
                
                // Informations utilisateur et période
                let subtitleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.darkGray
                ]
                let subtitleString = NSAttributedString(string: "Titulaire : \(userName)  |  Période : \(periodTitle)  |  Généré le : \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))", attributes: subtitleAttributes)
                subtitleString.draw(at: CGPoint(x: margin, y: currentY))
                currentY += 24.0
                
                // Ligne de séparation
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: currentY))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
                path.lineWidth = 1.5
                UIColor.systemGray4.setStroke()
                path.stroke()
                currentY += 20.0
                
                // Synthèse Financière
                let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
                let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
                let netBalance = totalIncome - totalExpense
                
                let summaryAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: UIColor.black
                ]
                let summaryText = "Revenus : \(String(format: "%.2f", totalIncome)) \(currencySymbol)  |  Dépenses : \(String(format: "%.2f", totalExpense)) \(currencySymbol)  |  Solde Net : \(String(format: "%.2f", netBalance)) \(currencySymbol)"
                let summaryString = NSAttributedString(string: summaryText, attributes: summaryAttributes)
                summaryString.draw(at: CGPoint(x: margin, y: currentY))
                currentY += 30.0
                
                // Titre de la table
                let tableHeaderAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.black
                ]
                let tableHeaderString = NSAttributedString(string: "Historique des Transactions", attributes: tableHeaderAttributes)
                tableHeaderString.draw(at: CGPoint(x: margin, y: currentY))
                currentY += 20.0
                
                // En-tête des colonnes
                let colDateX = margin
                let colTitleX = margin + 80
                let colCategoryX = margin + 280
                let colAmountX = pageWidth - margin - 80
                
                let colHeaderAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                    .foregroundColor: UIColor.gray
                ]
                
                NSAttributedString(string: "Date", attributes: colHeaderAttributes).draw(at: CGPoint(x: colDateX, y: currentY))
                NSAttributedString(string: "Titre", attributes: colHeaderAttributes).draw(at: CGPoint(x: colTitleX, y: currentY))
                NSAttributedString(string: "Catégorie", attributes: colHeaderAttributes).draw(at: CGPoint(x: colCategoryX, y: currentY))
                NSAttributedString(string: "Montant", attributes: colHeaderAttributes).draw(at: CGPoint(x: colAmountX, y: currentY))
                currentY += 16.0
                
                let rowAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                
                // Parcourir et dessiner les transactions (max 30 par page)
                for tx in transactions.prefix(30) {
                    if currentY > pageHeight - margin - 40 {
                        context.beginPage()
                        currentY = margin
                    }
                    
                    let dateStr = dateFormatter.string(from: tx.date)
                    let amountStr = "\(tx.type == .expense ? "-" : "+")\(String(format: "%.2f", tx.amount)) \(currencySymbol)"
                    
                    NSAttributedString(string: dateStr, attributes: rowAttributes).draw(at: CGPoint(x: colDateX, y: currentY))
                    NSAttributedString(string: String(tx.title.prefix(25)), attributes: rowAttributes).draw(at: CGPoint(x: colTitleX, y: currentY))
                    NSAttributedString(string: tx.category.rawValue, attributes: rowAttributes).draw(at: CGPoint(x: colCategoryX, y: currentY))
                    
                    let amountColor: UIColor = tx.type == .income ? .systemGreen : .black
                    let amountAttr: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                        .foregroundColor: amountColor
                    ]
                    NSAttributedString(string: amountStr, attributes: amountAttr).draw(at: CGPoint(x: colAmountX, y: currentY))
                    
                    currentY += 16.0
                }
            }
            return pdfURL
        } catch {
            return nil
        }
    }
}
