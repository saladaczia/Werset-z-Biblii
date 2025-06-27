//
//  Werset_z_BibliiApp.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 23/06/2025.
//

import SwiftUI

@main
struct Werset_z_BibliiApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
                .onAppear {
                    AudioManager.shared.playBackgroundMusic()
                }
        }
        
    }
}
