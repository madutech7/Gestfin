//
//  AdService.swift
//  Gestfina
//
//  Service centralisé pour gérer les publicités plein écran (Interstitiels)
//

import Foundation
import GoogleMobileAds
import UIKit

class AdService: NSObject, FullScreenContentDelegate {
    static let shared = AdService()
    
    private var interstitial: InterstitialAd?
    
    // ID de test Google pour les interstitiels
    private let interstitialID = "ca-app-pub-3940256099942544/4411468910"
    
    override init() {
        super.init()
        loadInterstitial()
    }
    
    func loadInterstitial() {
        let request = Request()
        InterstitialAd.load(with: interstitialID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Erreur chargement pub interstitielle: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    func showInterstitial() {
        guard let interstitial = interstitial else {
            print("Pub non prête, chargement en cours...")
            loadInterstitial()
            return
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            interstitial.present(from: rootVC)
        }
    }
    
    // MARK: - FullScreenContentDelegate
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Pub fermée")
        interstitial = nil
        loadInterstitial() // Préparer la suivante
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Erreur affichage pub: \(error.localizedDescription)")
        interstitial = nil
        loadInterstitial()
    }
}
