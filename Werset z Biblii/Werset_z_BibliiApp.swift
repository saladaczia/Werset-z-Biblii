//
//  Werset_z_BibliiApp.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 23/06/2025.
//

import SwiftUI

@main
struct Werset_z_BibliiApp: App {
    
    @StateObject var viewModel = VersesViewModel()
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .preferredColorScheme(.light)
                .onAppear {
                    AudioManager.shared.playBackgroundMusic()
                }
        }
        
    }
}
