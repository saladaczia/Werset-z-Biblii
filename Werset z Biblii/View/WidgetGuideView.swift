import SwiftUI

struct WidgetGuideView: View {
    @EnvironmentObject private var vm: VersesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VerseWidgetCard(verse: WidgetVerse.on(Date(), verses: WidgetVerse.load()), date: Date(),
                                background: vm.selectedBackground, medium: true)
                    .frame(height: 170)
                    .background(VerseWidgetCard.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .accessibilityLabel("Podgląd średniego widgetu")
                Text("Codzienna chwila ze Słowem")
                    .font(.title2.bold())
                Text("Wybierz mały lub średni widget. Każdego dnia pokaże werset oraz tło zgodne z ustawieniami aplikacji, również przy automatycznej zmianie motywów.")
                VStack(alignment: .leading, spacing: 16) {
                    step("1", "Przytrzymaj puste miejsce na ekranie głównym iPhone’a.")
                    step("2", "Wybierz Edytuj, a następnie Dodaj widget.")
                    step("3", "Wyszukaj Werset z Biblii, wybierz rozmiar i dotknij Dodaj widget.")
                }
                Text("Dotknij widgetu, aby otworzyć dzisiejszą refleksję. Dłuższy cytat może być skrócony na małym ekranie — całość przeczytasz w aplikacji.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .navigationTitle("Werset na dziś")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func step(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number).font(.subheadline.bold())
                .frame(width: 28, height: 28)
                .background(.quaternary, in: Circle())
            Text(text).frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
