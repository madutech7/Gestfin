//
//  ReceiptScannerView.swift
//  Gestfina
//
//  Design Ultra-Premium Apple iOS 26 — Scanner de Reçu OCR
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
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if let image = selectedImage {
                        // Zone d'aperçu de l'image scannée
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
                            
                            if isScanning {
                                ZStack {
                                    Color.black.opacity(0.55)
                                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                    
                                    VStack(spacing: 14) {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.4)
                                        
                                        Text("Analyse OCR intelligente en cours...")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Résultats de l'analyse Vision
                        if !isScanning {
                            VStack(spacing: 16) {
                                HStack {
                                    Label("Résultats de la détection", systemImage: "sparkles")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("COMMERÇANT / LIBELLÉ")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                        Text(detectedMerchant ?? "Non détecté")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("MONTANT DÉTECTÉ")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                        Text(detectedAmount != nil ? String(format: "%.2f", detectedAmount!) : "Non détecté")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.appGreen)
                                    }
                                }
                                .padding(18)
                                .liquidGlass(cornerRadius: 20)
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    onScanCompleted(detectedAmount, detectedMerchant)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Utiliser ces données")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        Capsule()
                                            .fill(LinearGradient.gradientPrimary)
                                            .shadow(color: Color.appBlue.opacity(0.35), radius: 12, y: 6)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    } else {
                        // État d'accueil pour la sélection de la facture
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.appBlue.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "doc.viewfinder")
                                    .font(.system(size: 48, weight: .medium))
                                    .foregroundColor(.appBlue)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Scan Intelligent de Reçu")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Text("Sélectionnez une photo de votre ticket de caisse pour en extraire automatiquement le montant et le commerçant.")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                HStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                    Text("Choisir une photo")
                                }
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient.gradientPrimary)
                                        .shadow(color: Color.appBlue.opacity(0.35), radius: 12, y: 6)
                                )
                            }
                        }
                        .padding(32)
                        .liquidGlass(cornerRadius: 24)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Scanner un Reçu OCR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onChange(of: selectedItem) { newItem in
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
