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
}
