import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var vm: VersesViewModel
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if vm.favoriteVerses.isEmpty {
                    ContentUnavailableView("Twoje ulubione", systemImage: "heart",
                        description: Text("Dotknij serca przy refleksji, do której chcesz wracać."))
                } else {
                    List {
                        Section {
                            ForEach(vm.favoriteVerses) { verse in
                                HStack(alignment: .top, spacing: 12) {
                                    Button {
                                        if let index = vm.verses.firstIndex(where: { $0.favoriteKey == verse.favoriteKey }) {
                                            vm.selectVerse(at: index)
                                            onClose()
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 10) {
                                            Label(verse.date, systemImage: "calendar")
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(.secondary)
                                            Text(verse.verse)
                                                .font(.system(.body, design: .serif))
                                                .foregroundStyle(.primary)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            HStack {
                                                Text(verse.reference).font(.caption.weight(.semibold))
                                                Spacer()
                                                Image(systemName: "chevron.right").font(.caption2.weight(.semibold))
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityHint("Otwiera zapisaną refleksję")


                                }
                                .padding(.vertical, 8)
                                .listRowBackground(Color(.secondarySystemGroupedBackground))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Usuń", systemImage: "trash", role: .destructive) {
                                        withAnimation { vm.removeFavorite(verse) }
                                    }
                                }
                            }
                        } header: {
                            Text("Zapisane refleksje · \(vm.favoriteVerses.count)")
                        } footer: {
                            Text("Dotknij refleksji, aby ją otworzyć. Przesuń w lewo, aby usunąć ją z ulubionych.")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ulubione")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe", action: onClose).foregroundStyle(.primary)
                }
            }
        }
        .tint(.primary)
    }
}
