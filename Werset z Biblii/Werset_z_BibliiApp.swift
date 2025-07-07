//
//  Werset_z_BibliiApp.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 23/06/2025.
//

import SwiftUI
import UserNotifications

@main
struct Werset_z_BibliiApp: App {
    
    // ViewModel
    @StateObject var vm = VersesViewModel()
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
                .environmentObject(vm)
                .preferredColorScheme(.light)
                .onAppear {
                    // Play music in background
                    AudioManager.shared.playBackgroundMusic()
                    // Request user to Notification Permission
                    vm.requestNotificationPermission()
                }
        }
        
    }
}
