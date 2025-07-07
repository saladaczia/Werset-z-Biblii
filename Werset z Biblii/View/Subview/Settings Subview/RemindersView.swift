//
//  RemindersView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 02/07/2025.
//

import SwiftUI

struct RemindersView: View {
    
    // ViewModel
    @EnvironmentObject private var vm: VersesViewModel
    
    // Dismiss screen
    @Environment(\.dismiss) private var dismiss
    
    // Temp date for Picker
    @State private var tempTime: Date = Date()
    
    // Show set button
    @State var showSetButton = false
    
    // Show set button
    @State var showPicker = false
    
        
    
    var body: some View {
        NavigationStack {
            // Main VStack
            VStack {
                // MARK: - Reminder toogle
                Toggle(isOn: $vm.reminderToogle) {
                    Text("Codzienne powiadomienia")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)
                    Text("Codziennie otrzymujesz powiadomienia o nowych wersach")
                        .font(.caption)
                        .frame(maxWidth: 250, alignment: .leading)
                }
                .onChange(of: vm.reminderToogle, { oldValue, newValue in
                    if vm.reminderToogle && vm.notificationRequestIsOn {
                        // User can see reminder settings
                        showSetButton = true
                        showPicker = true
                    } else if vm.reminderToogle && !vm.notificationRequestIsOn{
                        // user must notificaction On in system
                        vm.reminderToogle = false
                        // -> Alert for user must change notification settings in iOS system
                        if let appSettings = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    } else {
                        // user set daily notification on off
                        vm.removeDailyNotification()
                        vm.notificationDailyIsOn = false
                    }
                })
                .tint(.accentColor)
                
                // MARK: - Reminder Settings
                // Choose time for reminders
                if vm.reminderToogle {
                    DatePicker(
                            "Godzina powiadomienia:",
                            selection: $tempTime,
                            displayedComponents: [.hourAndMinute]
                        )
                    .onChange(of: tempTime, { oldValue, newValue in
                        // When time is changed then button is showing
                        if tempTime != vm.date {
                            showSetButton = true
                        }
                    })
                    .padding(.top, 10)
                    
                    // Set reminders settings
                    if showSetButton {
                        Button(action: {
                            vm.date = tempTime // Set a reminders time
                            // Time logic from Date()
                            let calendar = Calendar.current
                            let hour = calendar.component(.hour, from: vm.date)
                            let minute = calendar.component(.minute, from: vm.date)
                            // Set notifications according to user settings
                            if !vm.notificationDailyIsOn { // If notification is Off
                                    vm.activeDailyNotification(hour, minute)
                                } else { // If notifications is On - We must first remove previous notifications
                                    vm.removeDailyNotification()
                                    vm.activeDailyNotification(hour, minute)
                                }
                            vm.notificationDailyIsOn = true // Daily notifications is ON
                            dismiss() // Hidden screen
                        }) {
                            Text("Ustaw")
                                .frame(maxWidth: 100)
                                .frame(height: 30)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 20)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .navigationTitle("Powiadomienia")
        .onAppear {
            tempTime = vm.date // Set current time to picker
        }
        .onDisappear() {
            if !vm.notificationDailyIsOn { // If the user forgot to install the device -> hidden a reminders settings and set toogle to off
                vm.reminderToogle = false
            }
        }
    }
}

#Preview {
    RemindersView()
        .environmentObject(VersesViewModel())
}
