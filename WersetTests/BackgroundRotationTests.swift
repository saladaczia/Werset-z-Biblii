import Foundation
import Testing
@testable import Werset_z_Biblii

@MainActor
struct BackgroundRotationTests {
    @Test func removedAndUnknownThemesMigrateToFirstGalleryItem() throws {
        let suite = "BackgroundTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        for old in ["bg1-dark", "bg2-dark", "bg3", "bg4", "bg7", "bg18", "missing-theme", ""] {
            store.set(old, forKey: "selectedBackground")
            let vm = VersesViewModel(backgroundStore: store)
            #expect(vm.selectedBackground == vm.firstGalleryBackground)
            #expect(store.string(forKey: "selectedBackground") == "jesus01")
        }
        store.set("jesus09", forKey: "selectedBackground")
        #expect(VersesViewModel(backgroundStore: store).selectedBackground == "jesus09")
    }

    @Test func dailyRotationPersistsAndChangesOnlyOnNewDay() throws {
        let suite = "BackgroundTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        let calendar = Calendar.current
        var clock = calendar.date(from: DateComponents(year: 2026, month: 10, day: 19, hour: 12))!
        let vm = VersesViewModel(backgroundStore: store, now: { clock })
        vm.chooseBackground("jesus12")
        vm.dailyBackgroundEnabled = true
        vm.refreshBackgroundForCurrentDay()
        #expect(vm.selectedBackground == "jesus12")
        let relaunched = VersesViewModel(backgroundStore: store, now: { clock })
        #expect(relaunched.dailyBackgroundEnabled)
        #expect(relaunched.selectedBackground == "jesus12")
        clock = calendar.date(byAdding: .day, value: 1, to: clock)!
        relaunched.refreshBackgroundForCurrentDay()
        #expect(relaunched.selectedBackground == "nature01")
        relaunched.refreshBackgroundForCurrentDay()
        #expect(relaunched.selectedBackground == "nature01")
        let nextLaunch = VersesViewModel(backgroundStore: store, now: { clock })
        #expect(nextLaunch.selectedBackground == "nature01")
        clock = calendar.date(byAdding: .day, value: 8, to: clock)!
        nextLaunch.refreshBackgroundForCurrentDay()
        #expect(nextLaunch.selectedBackground == "nature09")
        clock = calendar.date(byAdding: .day, value: 1, to: clock)!
        nextLaunch.refreshBackgroundForCurrentDay()
        #expect(nextLaunch.selectedBackground == "jesus01")
        nextLaunch.chooseBackground("nature05")
        #expect(!nextLaunch.dailyBackgroundEnabled)
        clock = calendar.date(byAdding: .day, value: 1, to: clock)!
        nextLaunch.refreshBackgroundForCurrentDay()
        #expect(nextLaunch.selectedBackground == "nature05")
    }

    @Test(arguments: [BackgroundRotationScope.nature, .jesus])
    func categoryRotationStaysInCategoryAndSurvivesRestart(scope: BackgroundRotationScope) throws {
        let suite = "BackgroundTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        let calendar = Calendar.current
        var clock = calendar.date(from: DateComponents(year: 2026, month: 10, day: 19, hour: 12))!
        let vm = VersesViewModel(backgroundStore: store, now: { clock })
        vm.chooseBackground(scope == .nature ? "jesus05" : "nature05")
        vm.backgroundRotationScope = scope
        vm.dailyBackgroundEnabled = true
        #expect(vm.rotatingThemeNames.contains(vm.selectedBackground))
        let names = vm.rotatingThemeNames
        let restarted = VersesViewModel(backgroundStore: store, now: { clock })
        #expect(restarted.backgroundRotationScope == scope)
        for _ in 0..<(names.count + 1) {
            let previous = restarted.selectedBackground
            clock = calendar.date(byAdding: .day, value: 1, to: clock)!
            restarted.refreshBackgroundForCurrentDay()
            #expect(names.contains(restarted.selectedBackground))
            #expect(restarted.selectedBackground != previous)
        }
        restarted.backgroundRotationScope = scope == .nature ? .jesus : .nature
        #expect(restarted.rotatingThemeNames.contains(restarted.selectedBackground))
        let selected = restarted.selectedBackground
        restarted.refreshBackgroundForCurrentDay()
        #expect(restarted.selectedBackground == selected)
    }

    @Test func missingThemeWithRotationEnabledStillStartsAtFirstItem() throws {
        let suite = "BackgroundTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        store.set("removed", forKey: "selectedBackground")
        store.set(true, forKey: "dailyBackgroundEnabled")
        store.set(Date.distantPast.timeIntervalSince1970, forKey: "backgroundRotationDate")
        let vm = VersesViewModel(backgroundStore: store)
        #expect(vm.selectedBackground == "jesus01")
        #expect(vm.dailyBackgroundEnabled)
    }
}
