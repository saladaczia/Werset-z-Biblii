//
//  HomeViewModel.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import Foundation
import Combine
import SwiftUI

enum BackgroundRotationScope: String, CaseIterable, Identifiable {
    case all, nature, jesus
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return "Wszystkie"
        case .nature: return "Natura"
        case .jesus: return "Jezus"
        }
    }
}

class VersesViewModel: ObservableObject {
    
    // Verses model
    @Published var verses: [VersesModel] = []
    // Current Verse for today
    @Published var currentVerse: VersesModel?
    @Published private(set) var selectedIndex = 0
    @Published private(set) var favoriteKeys: Set<String> = []
    private let backgroundStore: UserDefaults
    private let favoritesStore: UserDefaults
    private let now: () -> Date
    private var restoringBackgroundSettings = true

    var latestAvailableIndex: Int {
        let days = Calendar.current.dateComponents([.day], from: firstDate,
            to: Calendar.current.startOfDay(for: now())).day ?? 0
        return min(days, verses.count - 1)
    }

    var isShowingToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: now())
    }

    var isCurrentFavorite: Bool {
        currentVerse.map { favoriteKeys.contains($0.favoriteKey) } ?? false
    }

    var favoriteVerses: [VersesModel] {
        verses.prefix(max(0, latestAvailableIndex + 1)).filter { favoriteKeys.contains($0.favoriteKey) }
    }

    func toggleFavorite() {
        guard let verse = currentVerse else { return }
        if !favoriteKeys.insert(verse.favoriteKey).inserted {
            favoriteKeys.remove(verse.favoriteKey)
        }
        favoritesStore.set(Array(favoriteKeys), forKey: "reflectionFavorites.v1")
    }

    func removeFavorite(_ verse: VersesModel) {
        favoriteKeys.remove(verse.favoriteKey)
        favoritesStore.set(Array(favoriteKeys), forKey: "reflectionFavorites.v1")
    }

    func selectVerse(at index: Int) {
        guard verses.indices.contains(index), index <= latestAvailableIndex else { return }
        selectedIndex = index
        currentVerse = verses[index]
    }

    func moveDay(by offset: Int) { selectVerse(at: selectedIndex + offset) }

    var firstDate: Date {
        Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 14))!
    }

    var selectedDate: Date {
        Calendar.current.date(byAdding: .day, value: selectedIndex, to: firstDate)!
    }

    var lastDate: Date {
        Calendar.current.date(byAdding: .day, value: max(0, latestAvailableIndex), to: firstDate)!
    }

    func selectDate(_ date: Date) {
        let index = Calendar.current.dateComponents([.day], from: firstDate,
            to: Calendar.current.startOfDay(for: date)).day ?? 0
        selectVerse(at: index)
    }

    // Open/Close settings
    @Published var onClickedSettings: Bool = false
    // User selected theme
    @Published var selectedTheme: Int = 0
    
    let natureThemes: [(name: String, title: String)] = [
        ("nature01", "Poranna mgła"),
        ("nature02", "Spokojne morze"),
        ("nature03", "Złota łąka"),
        ("nature04", "Oliwny gaj"),
        ("nature05", "Pustynna cisza"),
        ("nature06", "Górski strumień"),
        ("nature07", "Lawendowy poranek"),
        ("nature08", "Jesienny spokój"),
        ("nature09", "Wiosenny sad")
    ]
    let jesusThemes: [(name: String, title: String)] = [
        ("jesus01", "Dobry Pasterz"),
        ("jesus02", "Nad Jeziorem Galilejskim"),
        ("jesus03", "Droga do Emaus"),
        ("jesus04", "Modlitwa w Getsemani"),
        ("jesus05", "Światło zmartwychwstania"),
        ("jesus06", "Krzyż na wzgórzu"),
        ("jesus07", "Jezus na pustyni"),
        ("jesus08", "Łódź na jeziorze"),
        ("jesus09", "Jezus i dzieci"),
        ("jesus10", "Chleb życia"),
        ("jesus11", "Jezus błogosławi"),
        ("jesus12", "Pokój nad wodą")
    ]
    var allThemeNames: [String] { (jesusThemes + natureThemes).map(\.name) }
    var firstGalleryBackground: String { jesusThemes[0].name }
    @Published private var backgroundName = "jesus01"

    var selectedBackground: String {
        get { backgroundName }
        set {
            backgroundName = allThemeNames.contains(newValue) ? newValue : firstGalleryBackground
            backgroundStore.set(backgroundName, forKey: "selectedBackground")
        }
    }

    @Published var backgroundRotationScope: BackgroundRotationScope = .all {
        didSet {
            guard !restoringBackgroundSettings, backgroundRotationScope != oldValue else { return }
            backgroundStore.set(backgroundRotationScope.rawValue, forKey: "backgroundRotationScope")
            if dailyBackgroundEnabled {
                ensureBackgroundInRotationScope()
                markBackgroundDay()
            }
        }
    }

    var rotatingThemeNames: [String] {
        switch backgroundRotationScope {
        case .all: return allThemeNames
        case .nature: return natureThemes.map(\.name)
        case .jesus: return jesusThemes.map(\.name)
        }
    }

    private func ensureBackgroundInRotationScope() {
        if !rotatingThemeNames.contains(selectedBackground), let first = rotatingThemeNames.first {
            selectedBackground = first
        }
    }

    @Published var dailyBackgroundEnabled = false {
        didSet {
            guard !restoringBackgroundSettings, dailyBackgroundEnabled != oldValue else { return }
            backgroundStore.set(dailyBackgroundEnabled, forKey: "dailyBackgroundEnabled")
            if dailyBackgroundEnabled {
                ensureBackgroundInRotationScope()
                markBackgroundDay()
            }
        }
    }

    private func markBackgroundDay() {
        backgroundStore.set(Calendar.current.startOfDay(for: now()).timeIntervalSince1970,
                            forKey: "backgroundRotationDate")
    }

    func chooseBackground(_ name: String) {
        dailyBackgroundEnabled = false
        selectedBackground = name
    }

    func refreshBackgroundForCurrentDay() {
        guard dailyBackgroundEnabled else { return }
        let timestamp = backgroundStore.double(forKey: "backgroundRotationDate")
        guard timestamp != 0 else { markBackgroundDay(); return }
        let calendar = Calendar.current
        let previous = calendar.startOfDay(for: Date(timeIntervalSince1970: timestamp))
        let today = calendar.startOfDay(for: now())
        let days = calendar.dateComponents([.day], from: previous, to: today).day ?? 0
        guard days != 0 else { return }
        if days > 0 {
            let names = rotatingThemeNames
            let index = names.firstIndex(of: selectedBackground) ?? -1
            selectedBackground = names[(index + days % names.count + names.count) % names.count]
        }
        markBackgroundDay()
    }
    
    var widgetPreferences: WidgetPreferences {
        let timestamp = backgroundStore.double(forKey: "backgroundRotationDate")
        return WidgetPreferences(background: selectedBackground, rotates: dailyBackgroundEnabled,
                                 themes: rotatingThemeNames,
                                 anchor: timestamp == 0 ? Calendar.current.startOfDay(for: now()) : Date(timeIntervalSince1970: timestamp))
    }

    // User theme is dark or light
    var isDarkBackground: Bool {
        selectedBackground.lowercased().contains("dark")
    }
    
    
    init(favoritesStore: UserDefaults = .standard, backgroundStore: UserDefaults = .standard, now: @escaping () -> Date = Date.init) {
        self.now = now
        self.favoritesStore = favoritesStore
        self.backgroundStore = backgroundStore
        let storedBackground = backgroundStore.string(forKey: "selectedBackground") ?? firstGalleryBackground
        selectedBackground = storedBackground
        backgroundRotationScope = BackgroundRotationScope(rawValue: backgroundStore.string(forKey: "backgroundRotationScope") ?? "all") ?? .all
        dailyBackgroundEnabled = backgroundStore.bool(forKey: "dailyBackgroundEnabled")
        // Restoring the toggle must not overwrite yesterday's rotation date.
        restoringBackgroundSettings = false
        if !allThemeNames.contains(storedBackground) {
            // Removed/unknown themes always migrate to the first visible gallery item.
            markBackgroundDay()
        } else if dailyBackgroundEnabled {
            ensureBackgroundInRotationScope()
        }
        refreshBackgroundForCurrentDay()
        favoriteKeys = Set(favoritesStore.stringArray(forKey: "reflectionFavorites.v1") ?? [])
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
    func selectVerseForToday() {
        guard !verses.isEmpty else { return }

        selectVerse(at: latestAvailableIndex)
    }
    
}
