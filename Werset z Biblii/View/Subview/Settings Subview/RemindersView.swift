import SwiftUI

struct RemindersView: View {
    @EnvironmentObject private var reminders: ReminderStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var selectedTime = Date()
    @State private var loaded = false

    private var timeChanged: Bool {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        return parts.hour != reminders.hour || parts.minute != reminders.minute
    }

    var body: some View {
        Form {
            Section {
                Toggle("Codzienne przypomnienie", isOn: Binding(
                    get: { reminders.enabled },
                    set: { value in Task { await reminders.setEnabled(value, time: selectedTime) } }
                ))
                .disabled(reminders.busy || !loaded)
                DatePicker("Godzina", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .disabled(reminders.busy || !loaded)
                if reminders.enabled && timeChanged {
                    Button("Zapisz godzinę") { Task { await reminders.save(time: selectedTime) } }
                        .disabled(reminders.busy)
                }
            } footer: {
                Text("Jedno przypomnienie dziennie o wybranej godzinie lokalnej. Dotknięcie powiadomienia otwiera dzisiejszą refleksję.")
            }

            Section("Status") {
                if reminders.busy {
                    HStack { ProgressView(); Text("Sprawdzanie ustawień…") }
                } else if reminders.authorization == .denied {
                    Label("Powiadomienia zablokowane w iOS", systemImage: "bell.slash")
                        .foregroundStyle(.orange)
                    Text("Zezwól na powiadomienia w ustawieniach iPhone’a. Po powrocie aplikacja sprawdzi zgodę ponownie.")
                        .font(.footnote).foregroundStyle(.secondary)
                    Button("Otwórz ustawienia iOS") {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) { openURL(url) }
                    }
                } else if reminders.enabled && reminders.scheduled {
                    Label {
                        Text("Codziennie o \(reminders.time.formatted(date: .omitted, time: .shortened))")
                    } icon: { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                    if reminders.authorization == .provisional {
                        Text("iOS dostarcza te powiadomienia po cichu.").font(.footnote).foregroundStyle(.secondary)
                    }
                } else if reminders.enabled {
                    Label("Przypomnienie nie jest zaplanowane", systemImage: "exclamationmark.circle")
                    Button("Spróbuj ponownie") { Task { await reminders.refresh() } }
                } else {
                    Label("Przypomnienia wyłączone", systemImage: "bell.slash")
                        .foregroundStyle(.secondary)
                }
                if let error = reminders.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(.red)
                }
            }
            Section {
                Label("Chwila na refleksję", systemImage: "book.closed")
                    .font(.headline)
                Text("Werset na dziś\nZatrzymaj się na chwilę. Dzisiejszy werset i refleksja już czekają.")
                    .font(.subheadline).foregroundStyle(.secondary)
            } header: { Text("Treść przypomnienia") }
        }
        .navigationTitle("Powiadomienia")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !loaded { selectedTime = reminders.time; loaded = true }
            await reminders.refresh()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await reminders.refresh() } }
        }
    }
}

#Preview {
    NavigationStack { RemindersView().environmentObject(ReminderStore()) }
}
