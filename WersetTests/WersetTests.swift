//
//  WersetTests.swift
//  WersetTests
//
//  Created by Maciej Sołoducha on 26/07/2025.
//

import Testing
@testable import Werset_z_Biblii

@MainActor
struct WersetTests {

    @Test func testLoadingVersesFromJSON() async throws {
            let vm = VersesViewModel()
            #expect(vm.verses.isEmpty == false, "The JSON file should be loaded and contain some verses.")
        }

        @Test func testSelectVerseForToday() async throws {
            let vm = VersesViewModel()
            let verse = vm.currentVerse
            #expect(verse != nil, "The verse for today should be selected after the ViewModel is initialized.")
        }

        @Test func testIsDarkBackgroundFlag() {
            let vm = VersesViewModel()
            vm.selectedBackground = "bg1-dark"
            #expect(vm.isDarkBackground == true, "The background should be recognized as dark.")

            vm.selectedBackground = "bg4"
            #expect(vm.isDarkBackground == false, "The background should be recognized as light.")
        }

}

