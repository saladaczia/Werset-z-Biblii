import Foundation
import Testing
@testable import Werset_z_Biblii

@MainActor
struct UpdateNoticeTests {
    @Test func freshInstallDoesNotPretendItWasUpdated() throws {
        let name = "UpdateNoticeTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        #expect(!UpdateNoticeStore(defaults: defaults, version: "1.3.0").isPresented)
        defaults.set("jesus01", forKey: "selectedBackground")
        #expect(!UpdateNoticeStore(defaults: defaults, version: "1.3.0").isPresented)
        #expect(UpdateNoticeStore(defaults: defaults, version: "1.4.0").isPresented)
    }

    @Test func existingUsersSeeNoticeOnceEvenIfAppIsForceClosed() throws {
        let name = "UpdateNoticeTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set("bg7", forKey: "selectedBackground")
        let notice = UpdateNoticeStore(defaults: defaults, version: "1.3.0")
        #expect(notice.isPresented)
        notice.markPresented()
        #expect(notice.isPresented) // Recording exposure must not instantly dismiss the screen.
        #expect(!UpdateNoticeStore(defaults: defaults, version: "1.3.0").isPresented)
        notice.dismiss()
        #expect(!notice.isPresented)
        let nextUpdate = UpdateNoticeStore(defaults: defaults, version: "1.4.0")
        #expect(nextUpdate.isPresented)
        nextUpdate.markPresented()
        #expect(!UpdateNoticeStore(defaults: defaults, version: "1.4.0").isPresented)
    }

    @Test func launchWithoutPresentationKeepsNoticePending() throws {
        let name = "UpdateNoticeTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set("1.2.9", forKey: "updates.installedVersion")
        #expect(UpdateNoticeStore(defaults: defaults, version: "1.3.0").isPresented)
        let relaunched = UpdateNoticeStore(defaults: defaults, version: "1.3.0")
        #expect(relaunched.isPresented)
        relaunched.markPresented()
        #expect(!UpdateNoticeStore(defaults: defaults, version: "1.3.0").isPresented)
    }
}
