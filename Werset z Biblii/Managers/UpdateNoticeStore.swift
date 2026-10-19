import Foundation
import Combine

@MainActor
final class UpdateNoticeStore: ObservableObject {
    @Published var isPresented: Bool
    let version: String
    private let defaults: UserDefaults

    // Initialize before other stores write default preferences, to distinguish an existing install.
    init(defaults: UserDefaults = .standard,
         version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0") {
        self.defaults = defaults
        self.version = version
        let previous = defaults.string(forKey: "updates.installedVersion")
        let legacyKeys = ["selectedBackground", "reminderToogle", "dateTimestamp", "notificationDailyIsOn",
                          "reflectionFavorites.v1", "dailyBackgroundEnabled", "dailyReminderEnabled.v2"]
        let existingInstall = previous != nil || legacyKeys.contains { defaults.object(forKey: $0) != nil }
        let alreadySeen = defaults.string(forKey: "updates.seenVersion") == version
        if previous != version {
            if existingInstall && !alreadySeen {
                defaults.set(version, forKey: "updates.pendingVersion")
            } else {
                defaults.removeObject(forKey: "updates.pendingVersion")
            }
        }
        defaults.set(version, forKey: "updates.installedVersion")
        isPresented = !alreadySeen && defaults.string(forKey: "updates.pendingVersion") == version
    }

    // Record actual presentation, not merely app launch. Even a forced close won't repeat it.
    func markPresented() {
        defaults.set(version, forKey: "updates.seenVersion")
        defaults.removeObject(forKey: "updates.pendingVersion")
    }

    func dismiss() { isPresented = false }
}
