//
//  HomeViewModel.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import Foundation
import Combine
import SwiftUI

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
    let natureBgName = ["bg4", "bg5-dark", "bg6", "bg7", "bg8-dark", "bg9-dark"]
    // Saved selected theme
    @AppStorage("selectedBackground") var selectedBackground = "bg4"
    
    // User theme is dark or light
    var isDarkBackground: Bool {
        selectedBackground.lowercased().contains("dark")
    }
    
    
    init() {
        loadVersesFromJSON()
        selectVerseForToday()
    }

    // Decode JSON data
    private func loadVersesFromJSON() {
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
    
    // Get selected verse for today
    private func selectVerseForToday() {
        guard !verses.isEmpty else { return }

        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 6, day: 29))!
        let today = calendar.startOfDay(for: Date())

        let daysPassed = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        let index = daysPassed % verses.count

        currentVerse = verses[index]
    }
    
}
