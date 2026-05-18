//
//  SubscriptionManager.swift
//  Gestfina
//
//  Created by Madu - 2026
//  Gestionnaire natif d'abonnements et achats In-App — StoreKit 2
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    
    static let shared = SubscriptionManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    // MARK: - État Premium Synchrone
    
    var isPremium: Bool {
        #if DEBUG
        // Possibilité de forcer le mode Premium pour le debug local
        if UserDefaults.standard.bool(forKey: "debug_premium_bypass") {
            return true
        }
        #endif
        return !purchasedProductIDs.isEmpty
    }
    
    // MARK: - Identifiants des produits (doivent correspondre au fichier .storekit et App Store Connect)
    
    private let productIDs = [
        "com.samaxaalis.gestfina.premium.monthly",
        "com.samaxaalis.gestfina.premium.yearly",
        "com.samaxaalis.gestfina.premium.lifetime"
    ]
    
    private var transactionListener: Task<Void, Error>?
    
    // MARK: - Init
    
    init() {
        // Mettre à jour l'état immédiatement depuis le cache UserDefaults
        let cachedPremium = UserDefaults.standard.bool(forKey: "gestfina_is_premium")
        if cachedPremium {
            // Remplir avec un ID générique pour refléter le statut Premium au lancement rapide
            purchasedProductIDs.insert("com.samaxaalis.gestfina.premium.cached")
        }
        
        // Démarrer l'écouteur de transactions Apple (achats effectués en dehors de l'app, remboursements, etc.)
        transactionListener = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransaction(result: result)
            }
        }
        
        // Charger les produits et vérifier les droits actifs en arrière-plan
        Task {
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Récupérer les produits
    
    func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            // Trier par prix croissant
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("❌ Erreur lors de la récupération des produits StoreKit : \(error)")
        }
    }
    
    // MARK: - Acheter un produit
    
    /// Effectue l'achat et retourne vrai si validé
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            switch verificationResult {
            case .verified(let transaction):
                // Mettre à jour l'état des achats
                await updatePurchasedProducts()
                // Toujours finaliser la transaction avec Apple
                await transaction.finish()
                
                // Déclencher un feedback haptique de succès
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
                return true
                
            case .unverified(_, let error):
                print("⚠️ Transaction non vérifiée par Apple : \(error)")
                return false
            }
            
        case .userCancelled:
            print("👤 Achat annulé par l'utilisateur.")
            return false
            
        case .pending:
            print("⏳ Achat en attente d'approbation (ex: Contrôle Parental).")
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Restaurer les achats
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        } catch {
            print("❌ Échec de la synchronisation AppStore : \(error)")
        }
    }
    
    // MARK: - Vérifier et mettre à jour les droits d'accès
    
    func updatePurchasedProducts() async {
        var activePurchasedIDs = Set<String>()
        
        // Parcourir toutes les transactions en cours d'autorisation / abonnements actifs
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Vérifier si la transaction est révoquée
                if transaction.revocationDate == nil {
                    if let expirationDate = transaction.expirationDate {
                        // Pour les abonnements : vérifier s'ils n'ont pas expiré
                        if expirationDate > Date() {
                            activePurchasedIDs.insert(transaction.productID)
                        }
                    } else {
                        // Pour l'achat à vie (Non-Consumable)
                        activePurchasedIDs.insert(transaction.productID)
                    }
                }
            case .unverified(_, let error):
                print("⚠️ Droit non vérifié : \(error)")
            }
        }
        
        // Mettre à jour la propriété publiée
        self.purchasedProductIDs = activePurchasedIDs
        
        // Sauvegarder dans UserDefaults pour un accès synchrone ultra rapide au lancement de l'app
        let isNowPremium = !activePurchasedIDs.isEmpty
        UserDefaults.standard.set(isNowPremium, forKey: "gestfina_is_premium")
        
        // Poster une notification globale au cas où d'autres composants doivent réagir
        NotificationCenter.default.post(name: NSNotification.Name("GestfinaPremiumStatusChanged"), object: nil)
    }
    
    // MARK: - Gestionnaire de mise à jour des transactions
    
    private func handleTransaction(result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            await updatePurchasedProducts()
            await transaction.finish()
        case .unverified(_, let error):
            print("⚠️ Échec de vérification lors de la mise à jour de transaction : \(error)")
        }
    }
}
