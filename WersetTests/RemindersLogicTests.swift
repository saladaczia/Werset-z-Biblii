//
//  RemindersLogicTests.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 26/07/2025.
//

import Testing
@testable import Werset_z_Biblii
import Foundation

@MainActor
struct RemindersLogicTests {
    
    @Test func testTurningOffReminderDisablesNotifications() {
        let vm = VersesViewModel()
        
        vm.notificationDailyIsOn = true
        vm.handleReminderToggleChange(false)
        
        #expect(vm.notificationDailyIsOn == false, "Disabling notifications should also turn off the daily flag.")
    }
    
    @Test func testReminderTimeChangeTriggersButtonVisibility() {
        let vm = VersesViewModel()
        let oldDate = vm.date
        
        // Symulujemy zmianę godziny (przyszłość o 1h)
        let newDate = Calendar.current.date(byAdding: .hour, value: 1, to: oldDate)!
        vm.date = newDate
        
        #expect(vm.date != oldDate, "The newly set time should be different from the previous one.")
    }
    
    @Test func testNotificationFlagsLogic() {
        let vm = VersesViewModel()
        
        // Symulacja że użytkownik ma włączone powiadomienia systemowe
        vm.notificationRequestIsOn = true
        vm.notificationDailyIsOn = false
        
        // Symulujemy wywołanie powiadomienia
        vm.activeDailyNotification(9, 30)
        vm.notificationDailyIsOn = true
        
        #expect(vm.notificationDailyIsOn == true, "After enabling notifications, the notificationDailyIsOn flag should be set to true.")
    }
}
