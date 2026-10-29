import Testing
import SwiftUI
import UIKit
@testable import Werset_z_Biblii

@MainActor
struct ReflectionTests {
    @Test func removingFavoriteFromListPersistsWithoutChangingSelectedDay() throws {
        let suite = "ReflectionTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        let vm = VersesViewModel(favoritesStore: store, backgroundStore: store)
        vm.selectVerse(at: 0)
        vm.toggleFavorite()
        let first = try #require(vm.currentVerse)
        vm.selectVerse(at: 1)
        vm.toggleFavorite()
        let second = try #require(vm.currentVerse)
        vm.removeFavorite(first)
        vm.removeFavorite(first)
        #expect(vm.selectedIndex == 1)
        #expect(vm.isCurrentFavorite)
        #expect(vm.favoriteVerses.map(\.favoriteKey) == [second.favoriteKey])
        let restored = VersesViewModel(favoritesStore: store, backgroundStore: store)
        #expect(restored.favoriteVerses.map(\.favoriteKey) == [second.favoriteKey])
        vm.removeFavorite(second)
        #expect(vm.favoriteVerses.isEmpty)
        #expect(!vm.isCurrentFavorite)
        #expect(vm.selectedIndex == 1)
        #expect(VersesViewModel(favoritesStore: store, backgroundStore: store).favoriteVerses.isEmpty)
    }

    @Test func navigationAndPersistentFavorites() throws {
        let name = "ReflectionTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: name))
        defer { store.removePersistentDomain(forName: name) }
        let vm = VersesViewModel(favoritesStore: store)
        vm.selectVerse(at: 0)
        vm.moveDay(by: -1)
        #expect(vm.selectedIndex == 0)
        vm.moveDay(by: 1)
        #expect(vm.selectedIndex == 1)
        vm.toggleFavorite()
        let key = try #require(vm.currentVerse?.favoriteKey)
        let reloaded = VersesViewModel(favoritesStore: store)
        #expect(reloaded.favoriteVerses.map(\.favoriteKey) == [key])
        reloaded.selectVerse(at: 1)
        reloaded.toggleFavorite()
        #expect(VersesViewModel(favoritesStore: store).favoriteVerses.isEmpty)
        vm.selectDate(vm.lastDate)
        #expect(vm.selectedIndex == vm.latestAvailableIndex)
        vm.moveDay(by: 1)
        #expect(vm.selectedIndex == vm.latestAvailableIndex)
        vm.selectDate(vm.firstDate)
        #expect(vm.selectedIndex == 0)
    }

    @Test func futureDaysAreBlockedIncludingSavedFavorites() throws {
        let name = "ReflectionTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: name))
        defer { store.removePersistentDomain(forName: name) }
        let today = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 19))!
        let vm = VersesViewModel(favoritesStore: store, now: { today })
        let todayIndex = vm.selectedIndex
        let future = vm.verses[todayIndex + 1]
        store.set([future.favoriteKey], forKey: "reflectionFavorites.v1")
        let reloaded = VersesViewModel(favoritesStore: store, now: { today })
        #expect(reloaded.favoriteVerses.isEmpty)
        vm.moveDay(by: 1)
        #expect(vm.selectedIndex == todayIndex)
        vm.selectDate(Calendar.current.date(byAdding: .day, value: 1, to: today)!)
        #expect(vm.selectedIndex == todayIndex)
        vm.selectVerse(at: vm.verses.count - 1)
        #expect(vm.selectedIndex == todayIndex)
        #expect(vm.lastDate == today)
        vm.moveDay(by: -4)
        #expect(!vm.isShowingToday)
        vm.selectVerseForToday()
        #expect(vm.isShowingToday)
        #expect(vm.selectedIndex == todayIndex)
    }

    @Test func exportPreservesBottomBackgroundAndTextPosition() throws {
        let vm = VersesViewModel()
        let size = CGSize(width: 402, height: 874)
        let full = try #require(ReflectionExporter.image(vm: vm, size: size))
        #expect(full.cgImage?.width == 1206)
        #expect(full.cgImage?.height == 2622)
        let crop = try #require(ReflectionExporter.croppedBackground(full, contentHeight: 500))
        #expect(crop.cgImage?.height == 2144)
        let expected = try #require(full.cgImage?.cropping(to: CGRect(x: 0, y: 478, width: 1206, height: 2144)))
        #expect(UIImage(cgImage: expected, scale: 3, orientation: .up).pngData() == crop.pngData())
        #expect(ReflectionExporter.croppedBackground(full, contentHeight: 720) == nil)
        let portrait = try #require(ReflectionExporter.portrait(vm: vm, size: size))
        #expect(portrait.cgImage?.width == 1206)
        #expect(portrait.cgImage?.height == 2144)
        // Text pixels must stay at the same top coordinates, independent of background crop.
        let fullText = try #require(ReflectionExporter.textImage(vm: vm, size: size))
        let portraitText = try #require(ReflectionExporter.textImage(vm: vm, size: portrait.size))
        let textArea = CGRect(x: 0, y: 0, width: 1206, height: 1900)
        let expectedText = try #require(fullText.cgImage?.cropping(to: textArea))
        let actualText = try #require(portraitText.cgImage?.cropping(to: textArea))
        #expect(UIImage(cgImage: expectedText).pngData() == UIImage(cgImage: actualText).pngData())
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try full.pngData()?.write(to: folder.appendingPathComponent("reflection-full.png"))
        try portrait.pngData()?.write(to: folder.appendingPathComponent("reflection-portrait.png"))
        let panel = ImageRenderer(content: ZStack {
            ReflectionCanvas(size: size)
            ButtonsView(onClickedSettings: .constant(false), screenSize: size).padding(.bottom, 34)
        }.environmentObject(vm).environment(\.locale, Locale(identifier: "pl_PL")).frame(width: size.width, height: size.height))
        panel.scale = 2
        try panel.uiImage?.pngData()?.write(to: folder.appendingPathComponent("reflection-controls.png"))
        vm.moveDay(by: -1)
        let previousPanel = ImageRenderer(content: ZStack {
            ReflectionCanvas(size: size)
            ButtonsView(onClickedSettings: .constant(false), screenSize: size).padding(.bottom, 34)
        }.environmentObject(vm).environment(\.locale, Locale(identifier: "pl_PL")).frame(width: size.width, height: size.height))
        previousPanel.scale = 2
        try previousPanel.uiImage?.pngData()?.write(to: folder.appendingPathComponent("reflection-controls-previous.png"))
    }
}
