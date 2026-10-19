import SwiftUI

struct WhatsNewView: View {
    @ObservedObject var updates: UpdateNoticeStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.mint)
                        .padding(16)
                        .background(.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 20))
                    Text("Co nowego\nw Wersecie z Biblii")
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Twój spokojny czas z refleksją pozostaje. Oto nowe możliwości i sposób, w jaki z nich skorzystasz.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 24) {
                    feature("Sterowanie pod ręką", icon: "hand.tap", text: "Dotknij tła, aby pokazać lub ukryć panel na dole ekranu.")
                    feature("Wracaj do wcześniejszych dni", icon: "calendar", text: "Użyj strzałek albo dotknij daty, aby otworzyć kalendarz. Przycisk „Wróć do dzisiaj” przeniesie Cię do bieżącej refleksji.")
                    feature("Zachowuj ulubione", icon: "heart", text: "Dotknij „Zapisz” przy wybranej refleksji. Znajdziesz ją później w „Ulubionych”.")
                    feature("Udostępniaj jako zdjęcie", icon: "square.and.arrow.up", text: "Wybierz „Udostępnij”, a potem cały ekran lub TikTok 9:16. Zdjęcie zawiera tylko tekst i tło. Opcja „Zachowaj obraz” zapisze je w Zdjęciach.")
                    feature("Nowe tła i codzienna zmiana", icon: "photo.on.rectangle.angled", text: "W Ustawieniach → Wybór motywu znajdziesz galerie Jezus i Natura. Włącz „Codziennie inne tło” i wybierz wszystkie motywy albo jedną kategorię.")
                    feature("Przypomnienie o Twojej porze", icon: "bell", text: "W Ustawieniach → Codzienne powiadomienie wybierz godzinę i włącz przypomnienie. Status pokaże, czy zostało zaplanowane.")
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
            .tint(.mint)
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
                .foregroundStyle(.mint)
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
