import Testing
import UIKit
import SwiftUI
@testable import Werset_z_Biblii

@MainActor
struct PortraitLayoutTests {
    @Test func october29UsesAvailableSpaceAboveGethsemane() throws {
        let suite = "PortraitTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        let vm = VersesViewModel(favoritesStore: store, backgroundStore: store)
        vm.currentVerse = try #require(vm.verses.last { $0.date == "29 października" })
        vm.selectedBackground = "jesus04"
        let size = CGSize(width: 402, height: 874)
        let asset = try #require(UIImage(named: vm.selectedBackground))
        let limit = ReflectionExporter.portraitTextHeight(assetSize: asset.size, readerSize: size)
        let text = try #require(ReflectionExporter.portraitTextImage(vm: vm, width: size.width, maxHeight: limit))
        #expect(text.size.height > limit * 0.90)
        #expect(text.size.height <= limit)
        let output = try #require(ReflectionExporter.portrait(vm: vm, size: size))
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try output.pngData()?.write(to: folder.appendingPathComponent("tiktok-october29-larger.png"))
    }

    @Test func completeReflectionsFitAboveArtworkOnAllThemes() throws {
        let suite = "PortraitTests.\(UUID().uuidString)"
        let store = try #require(UserDefaults(suiteName: suite))
        defer { store.removePersistentDomain(forName: suite) }
        let vm = VersesViewModel(favoritesStore: store, backgroundStore: store)
        let sizes = [CGSize(width: 375, height: 667), CGSize(width: 402, height: 874), CGSize(width: 440, height: 956)]
        var longest: VersesModel?
        var greatestHeight: CGFloat = 0
        for size in sizes {
            let asset = try #require(UIImage(named: "jesus01"))
            let limit = ReflectionExporter.portraitTextHeight(assetSize: asset.size, readerSize: size)
            for verse in vm.verses {
                try autoreleasepool {
                vm.currentVerse = verse
                let text = try #require(ReflectionExporter.portraitTextImage(vm: vm, width: size.width, maxHeight: limit))
                #expect(text.size.height <= limit)
                if size.width == 402, text.size.height > greatestHeight {
                    longest = verse
                    greatestHeight = text.size.height
                }
                }
            }
        }
        vm.currentVerse = try #require(longest)
        var previews: [UIImage] = []
        let size = sizes[1]
        for theme in vm.allThemeNames {
            vm.selectedBackground = theme
            let asset = try #require(UIImage(named: theme))
            let limit = ReflectionExporter.portraitTextHeight(assetSize: asset.size, readerSize: size)
            let text = try #require(ReflectionExporter.portraitTextImage(vm: vm, width: size.width, maxHeight: limit))
            #expect(text.size.height <= limit)
            let output = try #require(ReflectionExporter.portrait(vm: vm, size: size))
            #expect(abs(output.size.height / output.size.width - 16.0 / 9.0) < 0.001)
            // Below the reserved upper area, exported pixels must match the untouched background.
            let backgroundRenderer = SwiftUI.ImageRenderer(content: ReflectionCanvas(size: size, textOpacity: 0).environmentObject(vm))
            backgroundRenderer.scale = 3
            let background = try #require(backgroundRenderer.uiImage)
            let crop = try #require(ReflectionExporter.croppedBackground(background, contentHeight: 0))
            let y = Int(ceil(limit * 3))
            let rect = CGRect(x: 0, y: y, width: output.cgImage!.width, height: output.cgImage!.height - y)
            let actual = try #require(output.cgImage?.cropping(to: rect))
            let expected = try #require(crop.cgImage?.cropping(to: rect))
            #expect(UIImage(cgImage: actual).pngData() == UIImage(cgImage: expected).pngData())
            previews.append(output)
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let sheet = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 2730), format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1200, height: 2730))
            for (i, image) in previews.enumerated() {
                let x = CGFloat(i % 4) * 300
                let y = CGFloat(i / 4) * 455
                image.draw(in: CGRect(x: x + 6, y: y + 6, width: 240, height: 426.67))
                (vm.allThemeNames[i] as NSString).draw(at: CGPoint(x: x + 8, y: y + 435), withAttributes: [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.black])
            }
        }
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try sheet.pngData()?.write(to: folder.appendingPathComponent("tiktok-all-themes.png"))
        try previews[10].pngData()?.write(to: folder.appendingPathComponent("tiktok-example.png"))
    }
}
