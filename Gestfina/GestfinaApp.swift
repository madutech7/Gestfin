//
//  GestfinaApp.swift
//  Gestfina
//
//  Created by Madu - 2026
//  Application de gestion financière personnelle
//

import SwiftUI

@main
struct GestfinaApp: App {
    @StateObject private var viewModel = FinanceViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
        }
    }
}
