import Testing
import SwiftUI
import UIKit
@testable import Werset_z_Biblii

@MainActor
struct NatureThemesTests {
    @Test func allThemesLoadAndRenderWithLongReflection() throws {
        let vm = VersesViewModel()
        let previousBackground = vm.selectedBackground
        defer { vm.selectedBackground = previousBackground }
        #expect(vm.natureThemes.count == 9)
        #expect(Set(vm.natureThemes.map(\.name)).count == 9)
        let available = vm.verses
        let longest = try #require(available.indices.max(by: {
            available[$0].message.count + available[$0].verse.count < available[$1].message.count + available[$1].verse.count
        }))
        vm.currentVerse = available[longest]
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var previews: [UIImage] = []
        for theme in vm.natureThemes {
            let asset = try #require(UIImage(named: theme.name))
            #expect(asset.size.height > asset.size.width)
            vm.selectedBackground = theme.name
            #expect(!vm.isDarkBackground)
            let image = try #require(ReflectionExporter.image(vm: vm, size: CGSize(width: 375, height: 812)))
            previews.append(image)
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let sheet = UIGraphicsImageRenderer(size: CGSize(width: 900, height: 2040), format: format).image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 900, height: 2040))
            for (index, image) in previews.enumerated() {
                let x = CGFloat(index % 3) * 300
                let y = CGFloat(index / 3) * 680
                image.draw(in: CGRect(x: x + 6, y: y + 6, width: 288, height: 624))
                (vm.natureThemes[index].title as NSString).draw(in: CGRect(x: x + 10, y: y + 638, width: 280, height: 40),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
            }
        }
        try sheet.pngData()?.write(to: folder.appendingPathComponent("nature-themes-proof.png"))
    }
}
