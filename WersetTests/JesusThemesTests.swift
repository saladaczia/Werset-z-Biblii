import Testing
import SwiftUI
import UIKit
@testable import Werset_z_Biblii

@MainActor
struct JesusThemesTests {
    @Test func allThemesLoadAndRenderWithLongReflection() throws {
        let vm = VersesViewModel()
        let previousBackground = vm.selectedBackground
        defer { vm.selectedBackground = previousBackground }
        #expect(vm.jesusThemes.count == 12)
        #expect(Set(vm.jesusThemes.map(\.name)).count == 12)
        let available = vm.verses
        let longest = try #require(available.indices.max(by: {
            available[$0].message.count + available[$0].verse.count < available[$1].message.count + available[$1].verse.count
        }))
        vm.currentVerse = available[longest]
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var previews: [UIImage] = []
        for theme in vm.jesusThemes {
            let asset = try #require(UIImage(named: theme.name))
            #expect(asset.size.height > asset.size.width)
            vm.selectedBackground = theme.name
            #expect(!vm.isDarkBackground)
            let image = try #require(ReflectionExporter.image(vm: vm, size: CGSize(width: 375, height: 812)))
            previews.append(image)
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let sheet = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 2040), format: format).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1200, height: 2040))
            for (index, image) in previews.enumerated() {
                let x = CGFloat(index % 4) * 300
                let y = CGFloat(index / 4) * 680
                image.draw(in: CGRect(x: x + 6, y: y + 6, width: 288, height: 624))
                (vm.jesusThemes[index].title as NSString).draw(in: CGRect(x: x + 10, y: y + 638, width: 280, height: 40),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
            }
        }
        try sheet.pngData()?.write(to: folder.appendingPathComponent("jesus-themes-proof.png"))
    }
}
