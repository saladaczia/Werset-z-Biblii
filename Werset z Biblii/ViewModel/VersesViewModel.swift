//
//  HomeViewModel.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications

class VersesViewModel: ObservableObject {
    
    // Verses model
    @Published var verses: [VersesModel] = []
    // Current Verse for today
    @Published var currentVerse: VersesModel?
    // Open/Close settings
    @Published var onClickedSettings: Bool = false
    // User selected theme
    @Published var selectedTheme: Int = 0
    
    // Background name arrays
    let illustrationsBgName = ["bg1-dark", "bg2-dark", "bg3"]
    let natureBgName = ["bg4", "bg5-dark", "bg6", "bg7", "bg8-dark", "bg9-dark", "bg10","bg11", "bg12"]
    // Saved selected theme
    @AppStorage("selectedBackground") var selectedBackground = "bg4"
    
    // Active Reminder Toogle
    @AppStorage("reminderToogle") var reminderToogle: Bool = false
    // Date for Picker Reminder Notification
    @AppStorage("dateTimestamp") private var dateTimestamp: Double = Date().timeIntervalSince1970
    // Notification Request is ON?
    @AppStorage("notificationRequestIsOn") var notificationRequestIsOn: Bool = false
    // Daily notification is ON?
    @AppStorage("notificationDailyIsOn") var notificationDailyIsOn: Bool = false
    
    var date: Date {
        get { Date(timeIntervalSince1970: dateTimestamp) }
        set { dateTimestamp = newValue.timeIntervalSince1970 }
    }
    
    
    // User theme is dark or light
    var isDarkBackground: Bool {
        selectedBackground.lowercased().contains("dark")
    }
    
    
    init() {
        print("load")
        loadVersesFromJSON()
        selectVerseForToday()
    }

    // Decode JSON data
        func loadVersesFromJSON() {
        guard let url = Bundle.main.url(forResource: "versesList", withExtension: "json") else {
            print("File verses.json not found.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedVerses = try JSONDecoder().decode([VersesModel].self, from: data)
            self.verses = decodedVerses
        } catch {
            print("Error loading JSON: \(error)")
        }
    }
    
    
    // Get Verse for today
    private func selectVerseForToday() {
        guard !verses.isEmpty else { return }

        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 7, day: 14))!
        let today = calendar.startOfDay(for: Date())

        let daysPassed = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        let index = daysPassed % verses.count

        currentVerse = verses[index]
    }
    
    // Request Notification
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                
                print("Błąd podczas proszenia o zgodę: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.notificationRequestIsOn = granted
                }
                print("Zgoda na powiadomienia: \(granted)")
            }
        }
    }
    
    // Daily notification ON
    func activeDailyNotification(_ hour: Int, _ minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "📖 Werset na dziś"
        content.body = "Kliknij, aby zobaczyć dzisiejszy fragment z Pisma Świętego."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "dailyVerseNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Błąd przy dodawaniu powiadomienia: \(error)")
            } else {
                print("Powiadomienie zaplanowane ✅")
            }
        }
    }
    
    // Daily notification OFF
    func removeDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyVerseNotification"])
        print("powiadomienia usunięte")
    }
    
    // Toogle function
    func handleReminderToggleChange(_ isOn: Bool) {
        reminderToogle = isOn
        
        if !isOn {
            removeDailyNotification()
            notificationDailyIsOn = false
        }
    }
}
