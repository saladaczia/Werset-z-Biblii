import SwiftUI

struct WhatsNewView: View {
    @ObservedObject var updates: UpdateNoticeStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.accentColor)
                        .padding(16)
                        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
                    Text("Co nowego\nw Wersecie z Biblii")
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Twój spokojny czas z refleksją pozostaje. Oto nowe możliwości i sposób, w jaki z nich skorzystasz.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 24) {
                    feature("Werset na ekranie głównym", icon: "square.grid.2x2", text: "Dodaj mały lub średni widżet, aby mieć dzisiejszy werset pod ręką. Dotknij go, aby otworzyć refleksję. Instrukcję znajdziesz w Ustawieniach → Werset na ekranie głównym.")
                    feature("Wygodniejsze ulubione", icon: "heart", text: "Lista zapisanych refleksji jest czytelniejsza. Przesuń wybraną pozycję w lewo, aby usunąć ją bez otwierania danego dnia.")
                    feature("Lepsze zdjęcia refleksji", icon: "square.and.arrow.up", text: "Wybierz Udostępnij zdjęcie → TikTok 9:16. Czcionka samej refleksji dopasuje się do wybranego tła, zachowując stałe marginesy, datę i werset.")
                    feature("Codziennie inne tło", icon: "photo.on.rectangle.angled", text: "Poprawiliśmy zmianę motywu po ponownym uruchomieniu aplikacji. Widżety również korzystają z wybranych teł i ustawionej kategorii.")
                }
                Text("Wersja \(updates.version)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(24)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: updates.dismiss) {
                Text("Przejdź do refleksji")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentColor)
            .foregroundStyle(.black)
            .padding(20)
            .background(.regularMaterial)
        }
        .onAppear { updates.markPresented() }
    }

    private func feature(_ title: String, icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 23))
                .foregroundStyle(Color.accentColor)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(text).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
