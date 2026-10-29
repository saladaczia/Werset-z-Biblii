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
    
    @UIApplicationDelegateAdaptor(ReminderAppDelegate.self) private var appDelegate
    @StateObject private var reminders: ReminderStore
    @StateObject private var updates: UpdateNoticeStore
    @Environment(\.scenePhase) private var scenePhase
    // ViewModel
    @StateObject var vm: VersesViewModel

    init() {
        // Check legacy install evidence before the view model initializes saved defaults.
        let notice = UpdateNoticeStore()
        _updates = StateObject(wrappedValue: notice)
        _reminders = StateObject(wrappedValue: ReminderStore())
        _vm = StateObject(wrappedValue: VersesViewModel())
    }
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
                .environmentObject(vm)
                .environmentObject(reminders)
                .environmentObject(updates)
                .preferredColorScheme(.dark)
                .task { vm.syncWidget(); await reminders.refresh() }
                .onChange(of: vm.widgetPreferences) { _, _ in vm.syncWidget() }
                .onOpenURL { url in
                    guard url.scheme == "werset", url.host == "today" else { return }
                    updates.isPresented = false
                    vm.selectVerseForToday()
                    vm.onClickedSettings = false
                    ReminderNavigation.shared.openToday = true
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        vm.refreshBackgroundForCurrentDay()
                        vm.syncWidget()
                        Task { await reminders.refresh() }
                    }
                }
                .onAppear {
                    // Play music in background
                    AudioManager.shared.playBackgroundMusic()

                }
        }
        
    }
}
