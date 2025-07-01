//
//  HomeViewModel.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import Foundation
import Combine

class VersesViewModel: ObservableObject {
    @Published var verses: [VersesModel] = []

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
