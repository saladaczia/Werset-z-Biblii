import SwiftUI

struct ButtonsView: View {
    @EnvironmentObject private var vm: VersesViewModel
    @Binding var onClickedSettings: Bool
    var screenSize: CGSize
    @State private var showCalendar = false
    @State private var showFavorites = false
    @State private var showShare = false

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                if !vm.isShowingToday {
                    Button { vm.selectVerseForToday() } label: {
                        Label("Wróć do dzisiaj", systemImage: "arrow.uturn.backward")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(.primary.opacity(0.06), in: Capsule())
                    }
                    .accessibilityLabel("Wróć do dzisiejszej refleksji")
                }
                HStack {
                    Button { vm.moveDay(by: -1) } label: {
                        Image(systemName: "chevron.left").frame(width: 44, height: 44)
                    }
                    .disabled(vm.selectedIndex == 0)
                    .accessibilityLabel("Poprzedni dzień")
                    Spacer(minLength: 0)
                    Button { showCalendar = true } label: {
                        VStack(spacing: 3) {
                            Text(vm.selectedDate, format: .dateTime.day().month(.wide).year())
                                .font(.subheadline.weight(.semibold))
                            Text("Wybierz dzień").font(.caption2).foregroundStyle(.secondary)
                        }
                        .frame(minHeight: 44)
                    }
                    Spacer(minLength: 0)
                    Button { vm.moveDay(by: 1) } label: {
                        Image(systemName: "chevron.right").frame(width: 44, height: 44)
                    }
                    .disabled(vm.selectedIndex >= vm.latestAvailableIndex)
                    .accessibilityLabel("Następny dzień")
                }
                Divider()
                HStack(spacing: 0) {
                    action(vm.isCurrentFavorite ? "Zapisano" : "Zapisz", icon: vm.isCurrentFavorite ? "heart.fill" : "heart") {
                        vm.toggleFavorite()
                    }
                    .foregroundStyle(vm.isCurrentFavorite ? Color.pink : Color.primary)
                    action("Ulubione", icon: "heart.text.clipboard") { showFavorites = true }
                    action("Udostępnij", icon: "square.and.arrow.up") { showShare = true }
                    action("Ustawienia", icon: "gearshape") { onClickedSettings = true }
                }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(.primary.opacity(0.08)))
            .shadow(color: .black.opacity(0.12), radius: 20, y: 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .buttonStyle(.plain)
        .onReceive(ReminderNavigation.shared.$openToday) { requested in
            if requested {
                showCalendar = false
                showFavorites = false
                showShare = false
            }
        }
        .sheet(isPresented: $showCalendar) {
            NavigationStack {
                DatePicker("Dzień refleksji", selection: Binding(get: { vm.selectedDate }, set: {
                    vm.selectDate($0)
                    showCalendar = false
                }), in: vm.firstDate...vm.lastDate, displayedComponents: .date)
                .datePickerStyle(.graphical).padding()
                .navigationTitle("Wybierz dzień")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Zamknij") { showCalendar = false } }
                    ToolbarItem(placement: .confirmationAction) { Button("Dzisiaj") { vm.selectVerseForToday(); showCalendar = false } }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showFavorites) {
            NavigationStack {
                Group {
                    if vm.favoriteVerses.isEmpty {
                        ContentUnavailableView("Twoje ulubione", systemImage: "heart", description: Text("Dotknij serca przy refleksji, do której chcesz wracać."))
                    } else {
                        List(vm.favoriteVerses) { verse in
                            Button {
                                if let index = vm.verses.firstIndex(where: { $0.favoriteKey == verse.favoriteKey }) {
                                    vm.selectVerse(at: index)
                                }
                                showFavorites = false
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(verse.date).font(.caption).foregroundStyle(.secondary)
                                    Text(verse.verse).font(.body).foregroundStyle(.primary)
                                    Text(verse.reference).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                                }.padding(.vertical, 5)
                            }
                        }
                    }
                }
                .navigationTitle("Ulubione")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Gotowe") { showFavorites = false } } }
            }
        }
        .sheet(isPresented: $showShare) { ShareReflectionView(size: screenSize) }
    }

    private func action(_ title: String, icon: String, perform: @escaping () -> Void) -> some View {
        Button(action: perform) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 21))
                Text(title).font(.system(size: 10, weight: .medium))
            }.frame(maxWidth: .infinity, minHeight: 52)
        }
        .accessibilityLabel(title)
    }
}
