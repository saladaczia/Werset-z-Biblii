import Foundation
import SwiftUI
import Testing
@testable import Werset_z_Biblii

@MainActor
struct WidgetTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Warsaw")!
        return calendar
    }
    private func date(_ day: Int, month: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
    }

    @Test func widgetMatchesReaderOnEveryAvailableDay() throws {
        let verses = WidgetVerse.load()
        #expect(!verses.isEmpty)
        let suite = "WidgetTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        let vm = VersesViewModel(favoritesStore: store, backgroundStore: store, now: { self.date(29) })
        for index in 0...vm.latestAvailableIndex {
            vm.selectVerse(at: index)
            let actual = WidgetVerse.on(vm.selectedDate, verses: verses)
            #expect(actual?.verse == vm.currentVerse?.verse)
            #expect(actual?.reference == vm.currentVerse?.reference)
        }
        #expect(WidgetVerse.on(.distantPast, verses: verses) == nil)
        #expect(WidgetVerse.on(date(29), verses: []) == nil)
    }

    @Test(arguments: BackgroundRotationScope.allCases)
    func widgetRotatesLikeAppWithoutOpeningIt(scope: BackgroundRotationScope) throws {
        let suite = "WidgetTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        var clock = date(24)
        let vm = VersesViewModel(favoritesStore: store, backgroundStore: store, now: { clock })
        vm.backgroundRotationScope = scope
        vm.dailyBackgroundEnabled = true
        let snapshot = vm.widgetPreferences
        for day in 25...31 {
            clock = date(day)
            vm.refreshBackgroundForCurrentDay()
            #expect(snapshot.background(on: clock) == vm.selectedBackground)
        }
        vm.chooseBackground("nature04")
        #expect(vm.widgetPreferences.background(on: date(5, month: 11)) == "nature04")
    }

    @Test func midnightTimelineHandlesDaylightSavingAndFallback() {
        let dates = WidgetPreferences.timelineDates(from: date(24), calendar: calendar)
        #expect(dates.count == 8)
        #expect(calendar.component(.hour, from: dates[1]) == 0)
        #expect(dates[2].timeIntervalSince(dates[1]) == 25 * 3600)
        #expect(WidgetPreferences(background: "removed").background(on: date(29)) == "jesus01")
    }

    @Test func artworkFitsWidgetArchiveLimitForEveryTheme() throws {
        for theme in WidgetPreferences.allThemes {
            let image = try #require(WidgetArtwork.image(named: theme).cgImage)
            #expect(image.width > 0 && image.height > 0)
            #expect(max(image.width, image.height) <= 720)
            #expect(image.width * image.height <= 720 * 720)
        }
    }

    @Test func rendersBothSizesAndLongestVerse() throws {
        let verses = WidgetVerse.load()
        let longest = try #require(verses.max(by: { $0.verse.count < $1.verse.count }))
        let current = WidgetVerse.on(date(29), verses: verses)
        let output = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for (name, verse, medium, width) in [("small", current, false, 170.0),
                                           ("medium", current, true, 364.0),
                                           ("long-small", Optional(longest), false, 158.0),
                                           ("long-medium", Optional(longest), true, 338.0)] {
            let card = VerseWidgetCard(verse: verse, date: date(29), background: "jesus04", medium: medium)
                .frame(width: width, height: 170)
                .background(VerseWidgetCard.paper)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            let renderer = ImageRenderer(content: card)
            renderer.scale = 3
            let image = try #require(renderer.uiImage)
            try #require(image.pngData()).write(to: output.appendingPathComponent("widget-\(name).png"))
        }
    }
}
