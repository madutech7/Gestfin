//
//  ReceiptScannerView.swift
//  Gestfina
//
//  Vue d'analyse OCR de tickets de caisse et factures avec prévisualisation
//

import SwiftUI
import PhotosUI

struct ReceiptScannerView: View {
    @Environment(\.dismiss) var dismiss
    
    var onScanCompleted: (Double?, String?) -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isScanning = false
    @State private var detectedAmount: Double?
    @State private var detectedMerchant: String?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        // Zone d'aperçu de l'image
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 320)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.3), radius: 10)
                            
                            if isScanning {
                                ZStack {
                                    Color.black.opacity(0.6)
                                        .cornerRadius(16)
                                    
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.3)
                                        
                                        Text("Analyse du reçu en cours...")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Résultats détectés
                        if !isScanning {
                            VStack(spacing: 12) {
                                Text("Résultats de la détection")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Commerçant / Titre")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(detectedMerchant ?? "Non détecté")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Montant détecté")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(detectedAmount != nil ? String(format: "%.2f", detectedAmount!) : "Non détecté")
                                            .font(.headline)
                                            .foregroundColor(.appGreen)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.appCardBackground))
                                .padding(.horizontal)
                                
                                Button(action: {
                                    onScanCompleted(detectedAmount, detectedMerchant)
                                    dismiss()
                                }) {
                                    Text("Utiliser ces données")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Capsule().fill(Color.appBlue))
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else {
                        // État initial : invitation à importer une photo
                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(Color.appBlue.opacity(0.15))
                                    .frame(width: 90, height: 90)
                                
                                Image(systemName: "doc.viewfinder")
                                    .font(.system(size: 44))
                                    .foregroundColor(.appBlue)
                            }
                            
                            VStack(spacing: 6) {
                                Text("Scanner une facture / reçu")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text("Sélectionnez une photo de votre ticket de caisse pour extraire automatiquement le montant et le commerçant.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text("Choisir une photo")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(Color.appBlue))
                            }
                        }
                        .padding(.vertical, 40)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Scan de Reçu OCR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.selectedImage = uiImage
                            self.processImage(uiImage)
                        }
                    }
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        isScanning = true
        ReceiptScannerManager.shared.scanReceipt(image: image) { result in
            DispatchQueue.main.async {
                isScanning = false
                switch result {
                case .success(let parsed):
                    self.detectedAmount = parsed.detectedAmount
                    self.detectedMerchant = parsed.detectedMerchant
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
