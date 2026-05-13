//
//  AdMobBannerView.swift
//  Gestfina
//
//  Composant SwiftUI pour afficher les bannières publicitaires AdMob
//

import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: View {
    let adUnitID: String
    
    var body: some View {
        BannerViewControllerRepresentable(adUnitID: adUnitID)
            .frame(height: 50) // Hauteur standard pour les bannières sur iPhone
    }
}

private struct BannerViewControllerRepresentable: UIViewControllerRepresentable {
    let adUnitID: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        
        // Centrer la bannière
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
        ])
        
        bannerView.load(GADRequest())
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AdMobBannerView_Previews: PreviewProvider {
    static var previews: some View {
        // ID de test Google pour les bannières
        AdMobBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
            .previewLayout(.sizeThatFits)
    }
}
