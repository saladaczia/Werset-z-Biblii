import Testing
import Foundation
import UserNotifications
@testable import Werset_z_Biblii

@MainActor
private final class FakeNotifications: ReminderNotificationService {
    var status: UNAuthorizationStatus = .authorized
    var grant = true
    var shouldFail = false
    var requestedPermission = 0
    var requests: [UNNotificationRequest] = []
    func authorizationStatus() async -> UNAuthorizationStatus { status }
    func requestAuthorization() async throws -> Bool {
        requestedPermission += 1
        status = grant ? .authorized : .denied
        return grant
    }
    func pendingRequests() async -> [UNNotificationRequest] { requests }
    func add(_ request: UNNotificationRequest) async throws {
        if shouldFail { throw NSError(domain: "Test", code: 1) }
        requests.removeAll { $0.identifier == request.identifier }
        requests.append(request)
    }
    func removeReminder() { requests.removeAll { $0.identifier == ReminderStore.identifier } }
}

@MainActor
struct RemindersLogicTests {
    private func time(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 19, hour: hour, minute: minute))!
    }

    @Test func authorizationOnlyOnExplicitEnableAndSingleRepeatingRequest() async throws {
        let suite = "Reminders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let service = FakeNotifications(); service.status = .notDetermined
        let store = ReminderStore(service: service, defaults: defaults)
        await store.refresh()
        #expect(service.requestedPermission == 0)
        await store.setEnabled(true, time: time(9, 30))
        #expect(service.requestedPermission == 1)
        #expect(store.enabled && store.scheduled)
        await store.save(time: time(18, 45))
        #expect(service.requests.count == 1)
        let trigger = try #require(service.requests.first?.trigger as? UNCalendarNotificationTrigger)
        #expect(trigger.repeats)
        #expect(trigger.dateComponents.hour == 18 && trigger.dateComponents.minute == 45)
        #expect(trigger.dateComponents.day == nil && trigger.dateComponents.timeZone == nil)
        let restored = ReminderStore(service: service, defaults: defaults)
        await restored.refresh()
        #expect(restored.enabled && restored.scheduled)
        #expect(restored.hour == 18 && restored.minute == 45)
        await restored.setEnabled(false, time: time(18, 45))
        #expect(!restored.enabled && !restored.scheduled && service.requests.isEmpty)
        #expect(!ReminderStore(service: service, defaults: defaults).enabled)
    }

    @Test func deniedPermissionDoesNotPretendReminderIsEnabled() async throws {
        let suite = "Reminders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let service = FakeNotifications(); service.status = .notDetermined; service.grant = false
        let store = ReminderStore(service: service, defaults: defaults)
        await store.setEnabled(true, time: time(9, 0))
        #expect(store.authorization == .denied)
        #expect(!store.enabled && !store.scheduled && service.requests.isEmpty)
        await store.setEnabled(true, time: time(9, 0))
        #expect(service.requestedPermission == 1)
    }

    @Test func failedReplacementKeepsPreviousTimeAndRequest() async throws {
        let suite = "Reminders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let service = FakeNotifications()
        let store = ReminderStore(service: service, defaults: defaults)
        await store.setEnabled(true, time: time(9, 0))
        service.shouldFail = true
        await store.save(time: time(20, 30))
        #expect(store.hour == 9 && store.minute == 0)
        #expect(store.enabled && store.scheduled && store.errorMessage != nil)
        #expect((service.requests.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents.hour == 9)
    }

    @Test func failedFirstScheduleNeverSetsEnabled() async throws {
        let suite = "Reminders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let service = FakeNotifications(); service.shouldFail = true
        let store = ReminderStore(service: service, defaults: defaults)
        await store.setEnabled(true, time: time(9, 0))
        #expect(!store.enabled && !store.scheduled && store.errorMessage != nil)
    }

    @Test func revokedAndRestoredPermissionAndMissingSchedule() async throws {
        let suite = "Reminders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let service = FakeNotifications()
        let store = ReminderStore(service: service, defaults: defaults)
        await store.setEnabled(true, time: time(8, 15))
        service.status = .denied
        await store.refresh()
        #expect(store.enabled && !store.scheduled && service.requests.isEmpty)
        service.status = .authorized
        await store.refresh()
        #expect(store.scheduled && service.requests.count == 1)
        service.requests = []
        await store.refresh()
        #expect(store.scheduled && service.requests.count == 1)
        #expect(service.requestedPermission == 0)
    }

    @Test func legacySettingsMigrateWithoutTrustingCachedPermission() async throws {
        let suite = "Reminders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: "notificationDailyIsOn")
        defaults.set(true, forKey: "notificationRequestIsOn")
        defaults.set(time(7, 25).timeIntervalSince1970, forKey: "dateTimestamp")
        let service = FakeNotifications(); service.status = .denied
        let store = ReminderStore(service: service, defaults: defaults)
        await store.refresh()
        #expect(store.enabled && store.hour == 7 && store.minute == 25)
        #expect(store.authorization == .denied && !store.scheduled)
    }
}
