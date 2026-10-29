import WidgetKit
import SwiftUI

struct VerseEntry: TimelineEntry {
    let date: Date
    let verse: WidgetVerse?
    let background: String
}

struct VerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(date: Date(), verse: .placeholder, background: "jesus01")
    }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        let date = Date()
        completion(VerseEntry(date: date, verse: WidgetVerse.on(date, verses: WidgetVerse.load()),
                              background: WidgetPreferences.read().background(on: date)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        let verses = WidgetVerse.load()
        let preferences = WidgetPreferences.read()
        let entries = WidgetPreferences.timelineDates(from: Date()).map { date in
            VerseEntry(date: date, verse: WidgetVerse.on(date, verses: verses),
                       background: preferences.background(on: date))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct DailyVerseView: View {
    let entry: VerseEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.showsWidgetContainerBackground) private var showsBackground

    var body: some View {
        VerseWidgetCard(verse: entry.verse, date: entry.date, background: entry.background,
                        medium: family == .systemMedium, showsArtwork: showsBackground)
            .containerBackground(for: .widget) { VerseWidgetCard.paper }
            .widgetURL(URL(string: "werset://today"))
    }
}

@main
struct DailyVerseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetPreferences.kind, provider: VerseProvider()) { entry in
            DailyVerseView(entry: entry)
        }
        .configurationDisplayName("Werset na dziś")
        .description("Codzienny werset z motywem wybranym w aplikacji. Dotknij, aby przeczytać refleksję.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    DailyVerseWidget()
} timeline: {
    VerseEntry(date: .now, verse: .placeholder, background: "jesus01")
}

#Preview(as: .systemMedium) {
    DailyVerseWidget()
} timeline: {
    VerseEntry(date: .now, verse: .placeholder, background: "jesus04")
}
