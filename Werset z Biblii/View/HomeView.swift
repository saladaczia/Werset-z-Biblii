//
//  HomeView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 27/06/2025.
//

import SwiftUI
import Combine

struct HomeView: View {
    
    @ObservedObject private var reminderNavigation = ReminderNavigation.shared
    @EnvironmentObject private var updates: UpdateNoticeStore
    // ViewModel
    @EnvironmentObject private var vm: VersesViewModel
    @Environment(\.scenePhase) var scenePhase
    
    // Screen size area
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    // Show buttons
    @State private var showButtonsView: Bool = false
    @State private var lastActiveDate = Date()
    private let dayCheck = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    // Animate verse text
    @State private var animateShowVerseText: Bool = false
    
    
    
    var body: some View {
    
        // Main ZStack
        ZStack {
            ReflectionCanvas(size: CGSize(width: screenWidth, height: screenHeight),
                             textOpacity: animateShowVerseText ? 1 : 0)
                .animation(.easeInOut(duration: 4), value: animateShowVerseText)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { showButtonsView.toggle() } }

            // Buttons View
                ButtonsView(onClickedSettings: $vm.onClickedSettings, screenSize: CGSize(width: screenWidth, height: screenHeight))
                    .allowsHitTesting(showButtonsView)
                    .opacity(showButtonsView ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: showButtonsView)
                
                // Settings View sheet
                    .sheet(isPresented: $vm.onClickedSettings) {
                        SettingView()
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .presentationBackground(Color(.systemGroupedBackground))
                    }
            
        }.statusBarHidden()
        .sheet(isPresented: $updates.isPresented) {
            WhatsNewView(updates: updates)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(.systemGroupedBackground))
        }
        .onAppear {
            // Animate for showing text
                withAnimation {
                    animateShowVerseText = true
                }
        }
        .onReceive(reminderNavigation.$openToday) { requested in
            if requested {
                vm.selectVerseForToday()
                vm.onClickedSettings = false
                reminderNavigation.openToday = false
            }
        }
        .onReceive(dayCheck) { _ in
            if scenePhase == .active { vm.refreshBackgroundForCurrentDay() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            vm.refreshBackgroundForCurrentDay()
        }
        // if app is running from background verse must be reload
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                vm.refreshBackgroundForCurrentDay()
                // Keep the day being read when returning from sharing or Photos.
                if Calendar.current.isDateInToday(lastActiveDate) == false {
                    vm.selectVerseForToday()
                }
                lastActiveDate = Date()
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(VersesViewModel())
        .environmentObject(UpdateNoticeStore())
        .environmentObject(ReminderStore())
}

