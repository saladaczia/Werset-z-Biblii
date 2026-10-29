import SwiftUI

struct ThemesView: View {
    @EnvironmentObject private var vm: VersesViewModel
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Codziennie inne tło", isOn: $vm.dailyBackgroundEnabled)
                            .font(.headline)
                        Picker("Zmieniaj tła", selection: $vm.backgroundRotationScope) {
                            ForEach(BackgroundRotationScope.allCases) { scope in
                                Text(scope.title).tag(scope)
                            }
                        }
                        .pickerStyle(.segmented)
                        Text("Każdego dnia kolejny motyw z wybranej kategorii. Ręczny wybór tła wyłącza tę opcję.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    themeSection("Jezus", themes: vm.jesusThemes)
                    themeSection("Natura", themes: vm.natureThemes)
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Motywy")
        }
    }

    private func themeSection(_ title: String, themes: [(name: String, title: String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title2.bold()).foregroundStyle(.secondary)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(themes, id: \.name) { theme in
                    Button { vm.chooseBackground(theme.name) } label: {
                        VStack(spacing: 8) {
                            Image(theme.name)
                                .resizable()
                                .aspectRatio(4.0 / 9.0, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(vm.selectedBackground == theme.name ? Color.accentColor : Color.clear, lineWidth: 3)
                                }
                            Text(theme.title)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .frame(minHeight: 32, alignment: .top)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(theme.title)
                    .accessibilityAddTraits(vm.selectedBackground == theme.name ? .isSelected : [])
                }
            }
        }
    }
}

#Preview {
    ThemesView().environmentObject(VersesViewModel())
}
