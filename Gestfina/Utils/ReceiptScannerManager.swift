//
//  ReceiptScannerManager.swift
//  Gestfina
//
//  Gestionnaire OCR utilisant le framework natif Apple Vision pour analyser les factures et reçus
//

import Foundation
import UIKit
import Vision

struct ScannedReceiptResult {
    var detectedAmount: Double?
    var detectedDate: Date?
    var detectedMerchant: String?
    var rawText: String
}

class ReceiptScannerManager {
    static let shared = ReceiptScannerManager()
    
    private init() {}
    
    /// Analyse une image de reçu avec Vision OCR pour en extraire le montant, la date et le commerçant
    func scanReceipt(image: UIImage, completion: @escaping (Result<ScannedReceiptResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "ReceiptScanner", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image non valide"])))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success(ScannedReceiptResult(rawText: "")))
                return
            }
            
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            let fullText = recognizedStrings.joined(separator: "\n")
            
            let parsed = self.parseReceiptText(recognizedStrings: recognizedStrings, fullText: fullText)
            completion(.success(parsed))
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["fr-FR", "en-US"]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Algorithme de Parsing du Reçu
    
    private func parseReceiptText(recognizedStrings: [String], fullText: String) -> ScannedReceiptResult {
        var detectedAmount: Double?
        var detectedMerchant: String?
        var detectedDate: Date?
        
        // 1. Détection du commerçant (souvent dans les 3 premières lignes)
        for line in recognizedStrings.prefix(3) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && trimmed.count > 2 && !trimmed.contains("TOTAL") && !trimmed.contains("EUR") {
                detectedMerchant = trimmed
                break
            }
        }
        
        // 2. Détection du montant (recherche de "TOTAL", "NET", "PAYER", ou du plus grand montant numérique)
        var possibleAmounts: [Double] = []
        
        let numberRegex = try? NSRegularExpression(pattern: #"(\d+[\.,]\d{2})"#)
        
        for line in recognizedStrings {
            let uppercaseLine = line.uppercased()
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if let matches = numberRegex?.matches(in: line, options: [], range: range) {
                for match in matches {
                    if let substringRange = Range(match.range(at: 1), in: line) {
                        let rawNumStr = String(line[substringRange]).replacingOccurrences(of: ",", with: ".")
                        if let val = Double(rawNumStr), val > 0 {
                            if uppercaseLine.contains("TOTAL") || uppercaseLine.contains("NET") || uppercaseLine.contains("PAYER") {
                                detectedAmount = val
                                break
                            }
                            possibleAmounts.append(val)
                        }
                    }
                }
            }
            if detectedAmount != nil { break }
        }
        
        if detectedAmount == nil {
            detectedAmount = possibleAmounts.max()
        }
        
        // 3. Détection basique de la date (Format DD/MM/YYYY ou YYYY-MM-DD)
        let dateRegex = try? NSRegularExpression(pattern: #"(\d{2}[\/\.-]\d{2}[\/\.-]\d{2,4})"#)
        let range = NSRange(location: 0, length: fullText.utf16.count)
        if let match = dateRegex?.firstMatch(in: fullText, options: [], range: range),
           let substringRange = Range(match.range(at: 1), in: fullText) {
            let dateStr = String(fullText[substringRange])
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            detectedDate = formatter.date(from: dateStr)
        }
        
        return ScannedReceiptResult(
            detectedAmount: detectedAmount,
            detectedDate: detectedDate,
            detectedMerchant: detectedMerchant,
            rawText: fullText
        )
    }
}
