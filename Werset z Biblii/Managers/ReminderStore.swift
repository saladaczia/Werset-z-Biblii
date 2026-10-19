import UIKit

import Foundation
import Combine
import UserNotifications

@MainActor
protocol ReminderNotificationService {
    func authorizationStatus() async -> UNAuthorizationStatus
    func requestAuthorization() async throws -> Bool
    func pendingRequests() async -> [UNNotificationRequest]
    func add(_ request: UNNotificationRequest) async throws
    func removeReminder()
}

@MainActor
final class SystemReminderNotifications: ReminderNotificationService {
    private let center = UNUserNotificationCenter.current()
    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }
    func pendingRequests() async -> [UNNotificationRequest] { await center.pendingNotificationRequests() }
    func add(_ request: UNNotificationRequest) async throws { try await center.add(request) }
    func removeReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [ReminderStore.identifier])
        center.removeDeliveredNotifications(withIdentifiers: [ReminderStore.identifier])
    }
}

@MainActor
final class ReminderStore: ObservableObject {
    static let identifier = "dailyVerseNotification"
    @Published private(set) var enabled: Bool
    @Published private(set) var hour: Int
    @Published private(set) var minute: Int
    @Published private(set) var authorization: UNAuthorizationStatus = .notDetermined
    @Published private(set) var scheduled = false
    @Published private(set) var busy = false
    @Published var errorMessage: String?
    private let service: ReminderNotificationService
    private let defaults: UserDefaults

    init(service: ReminderNotificationService? = nil, defaults: UserDefaults = .standard) {
        self.service = service ?? SystemReminderNotifications()
        self.defaults = defaults
        // Preserve an existing installed reminder, but never trust cached permission flags.
        enabled = defaults.object(forKey: "dailyReminderEnabled.v2") as? Bool
            ?? defaults.bool(forKey: "notificationDailyIsOn")
        if let savedHour = defaults.object(forKey: "dailyReminderHour") as? Int,
           let savedMinute = defaults.object(forKey: "dailyReminderMinute") as? Int {
            hour = min(23, max(0, savedHour))
            minute = min(59, max(0, savedMinute))
        } else if let timestamp = defaults.object(forKey: "dateTimestamp") as? Double {
            let components = Calendar.current.dateComponents([.hour, .minute], from: Date(timeIntervalSince1970: timestamp))
            hour = components.hour ?? 9
            minute = components.minute ?? 0
        } else {
            hour = 9
            minute = 0
        }
    }

    var time: Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    var hasPermission: Bool {
        authorization == .authorized || authorization == .provisional || authorization == .ephemeral
    }

    static func request(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Werset na dziś"
        content.body = "Zatrzymaj się na chwilę. Dzisiejszy werset i refleksja już czekają."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute), repeats: true)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private func persist() {
        defaults.set(enabled, forKey: "dailyReminderEnabled.v2")
        defaults.set(hour, forKey: "dailyReminderHour")
        defaults.set(minute, forKey: "dailyReminderMinute")
    }

    /// Refresh without prompting. Reconcile revoked permission and repair a missing schedule.
    func refresh() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        authorization = await service.authorizationStatus()
        guard enabled, hasPermission else {
            service.removeReminder()
            scheduled = false
            return
        }
        let requests = await service.pendingRequests()
        let existing = requests.first { $0.identifier == Self.identifier }
        if let trigger = existing?.trigger as? UNCalendarNotificationTrigger,
           trigger.repeats, trigger.dateComponents.hour == hour, trigger.dateComponents.minute == minute {
            scheduled = true
            return
        }
        scheduled = false
        do {
            try await service.add(Self.request(hour: hour, minute: minute))
            scheduled = true
            errorMessage = nil
        } catch {
            errorMessage = "Nie udało się zaplanować przypomnienia. Spróbuj ponownie."
        }
    }

    func setEnabled(_ value: Bool, time: Date) async {
        guard !busy else { return }
        if !value {
            service.removeReminder()
            enabled = false
            scheduled = false
            errorMessage = nil
            persist()
            return
        }
        await save(time: time)
    }

    func save(time: Date) async {
        guard !busy else { return }
        busy = true
        errorMessage = nil
        defer { busy = false }
        do {
            authorization = await service.authorizationStatus()
            if authorization == .notDetermined {
                _ = try await service.requestAuthorization()
                authorization = await service.authorizationStatus()
            }
            guard hasPermission else {
                service.removeReminder()
                scheduled = false
                return
            }
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let newHour = components.hour ?? 9
            let newMinute = components.minute ?? 0
            // Adding the same identifier replaces the old request only after success.
            try await service.add(Self.request(hour: newHour, minute: newMinute))
            hour = newHour
            minute = newMinute
            enabled = true
            scheduled = true
            persist()
        } catch {
            errorMessage = "Nie udało się zapisać przypomnienia. Poprzednie ustawienia zostały zachowane."
        }
    }
}

@MainActor
final class ReminderNavigation: ObservableObject {
    static let shared = ReminderNavigation()
    @Published var openToday = false
}

final class ReminderAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "dailyVerseNotification",
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            Task { @MainActor in ReminderNavigation.shared.openToday = true }
        }
        completionHandler()
    }
}
