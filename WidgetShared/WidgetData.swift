import Foundation

nonisolated struct WidgetVerse: Codable, Equatable {
    let verse: String
    let reference: String

    static let placeholder = WidgetVerse(verse: "Pan jest moim pasterzem, nie brak mi niczego.", reference: "Ps 23,1")

    static func load(bundle: Bundle = .main) -> [WidgetVerse] {
        guard let url = bundle.url(forResource: "versesList", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let verses = try? JSONDecoder().decode([WidgetVerse].self, from: data) else { return [] }
        return verses
    }

    static func on(_ date: Date, verses: [WidgetVerse], calendar: Calendar = .current) -> WidgetVerse? {
        guard let first = calendar.date(from: DateComponents(year: 2025, month: 7, day: 14)) else { return nil }
        let index = calendar.dateComponents([.day], from: first, to: calendar.startOfDay(for: date)).day ?? -1
        guard index >= 0, !verses.isEmpty else { return nil }
        return verses[min(index, verses.count - 1)]
    }
}

nonisolated struct WidgetPreferences: Codable, Equatable {
    static let group = "group.pl.goldenapp.Werset-z-Biblii"
    static let key = "verseWidget.preferences.v1"
    static let kind = "DailyVerseWidget"
    static let allThemes = (1...12).map { String(format: "jesus%02d", $0) }
        + (1...9).map { String(format: "nature%02d", $0) }

    var background = "jesus01"
    var rotates = false
    var themes = allThemes
    var anchor = Date()

    static func read(store: UserDefaults? = UserDefaults(suiteName: group)) -> Self {
        guard let data = store?.data(forKey: key),
              let value = try? JSONDecoder().decode(Self.self, from: data) else { return Self() }
        return value
    }

    func background(on date: Date, calendar: Calendar = .current) -> String {
        guard Self.allThemes.contains(background) else { return Self.allThemes[0] }
        let valid = themes.filter { Self.allThemes.contains($0) }
        guard rotates, !valid.isEmpty else { return background }
        let days = max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: anchor),
                                                to: calendar.startOfDay(for: date)).day ?? 0)
        // Keep today's saved background even after migrating a removed theme.
        guard days > 0 else { return background }
        let index = valid.firstIndex(of: background) ?? -1
        return valid[(index + days % valid.count + valid.count) % valid.count]
    }

    static func timelineDates(from date: Date, calendar: Calendar = .current) -> [Date] {
        [date] + (1...7).compactMap { calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: date)) }
    }
}
