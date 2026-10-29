import SwiftUI
import UIKit

/// The reader and export share their layout, including the background's original crop.
struct ReflectionCanvas: View {
    let size: CGSize
    var textOpacity: Double = 1
    @EnvironmentObject private var vm: VersesViewModel

    var body: some View {
        ZStack {
            Image(vm.selectedBackground)
                .resizable().scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
            VStack {
                VerseTextView().opacity(textOpacity)
                Spacer()
            }
            .frame(width: size.width, height: size.height)
        }
        .frame(width: size.width, height: size.height)
        .ignoresSafeArea()
    }
}

@MainActor
enum ReflectionExporter {
    static func image(vm: VersesViewModel, size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: ReflectionCanvas(size: size).environmentObject(vm))
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = 3
        return renderer.uiImage
    }

    static func textImage(vm: VersesViewModel, size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: VStack {
            VerseTextView()
            Spacer()
        }.frame(width: size.width, height: size.height).environmentObject(vm))
        renderer.proposedSize = ProposedViewSize(size)
        renderer.scale = 3
        return renderer.uiImage
    }

    /// First important artwork, measured from the top of each original asset.
    /// Keep these values with the gallery: replacing an asset requires a visual review.
    static let artworkStartFractions: [String: CGFloat] = [
        "jesus01": 0.67, "jesus02": 0.65, "jesus03": 0.70,
        "jesus04": 0.60, "jesus05": 0.66, "jesus06": 0.72,
        "jesus07": 0.69, "jesus08": 0.65, "jesus09": 0.63,
        "jesus10": 0.68, "jesus11": 0.63, "jesus12": 0.67,
        "nature01": 0.73, "nature02": 0.71, "nature03": 0.74,
        "nature04": 0.65, "nature05": 0.75, "nature06": 0.70,
        "nature07": 0.75, "nature08": 0.61, "nature09": 0.70
    ]

    /// Transform the asset's boundary through both crops, retaining a 2% export-height gap.
    static func portraitTextHeight(assetSize: CGSize, readerSize: CGSize, background: String) -> CGFloat {
        let scale = max(readerSize.width / assetSize.width, readerSize.height / assetSize.height)
        let scaledHeight = assetSize.height * scale
        let portraitHeight = readerSize.width * 16 / 9
        let artworkStart = artworkStartFractions[background] ?? 0.55
        let boundary = (readerSize.height - scaledHeight) / 2 + scaledHeight * artworkStart
            - (readerSize.height - portraitHeight)
        return max(0, min(portraitHeight, boundary) - portraitHeight * 0.02)
    }

    static func portraitTextImage(vm: VersesViewModel, width: CGFloat, maxHeight: CGFloat) -> UIImage? {
        // Keep the reader layout fixed; only shrink the reflection when it overlaps the artwork.
        for step in 0...60 {
            let reflectionFontSize = 20 - CGFloat(step) * 0.25
            let candidate: UIImage? = autoreleasepool {
                let renderer = ImageRenderer(content: VerseTextView(fillsHeight: false, reflectionFontSize: reflectionFontSize)
                    .environmentObject(vm)
                    .environment(\.dynamicTypeSize, .medium)
                    .frame(width: width)
                    .fixedSize(horizontal: false, vertical: true))
                renderer.scale = 3
                guard let image = renderer.uiImage, image.size.height <= maxHeight else { return nil }
                return image
            }
            if let candidate { return candidate }
        }
        return nil
    }

    static func portrait(vm: VersesViewModel, size: CGSize) -> UIImage? {
        guard let asset = UIImage(named: vm.selectedBackground) else { return nil }
        let textHeight = portraitTextHeight(assetSize: asset.size, readerSize: size, background: vm.selectedBackground)
        guard let text = portraitTextImage(vm: vm, width: size.width, maxHeight: textHeight) else { return nil }
        let backgroundRenderer = ImageRenderer(content: ReflectionCanvas(size: size, textOpacity: 0)
            .environmentObject(vm))
        backgroundRenderer.proposedSize = ProposedViewSize(size)
        backgroundRenderer.scale = 3
        guard let background = backgroundRenderer.uiImage,
              let croppedBackground = croppedBackground(background, contentHeight: text.size.height) else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = croppedBackground.scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: croppedBackground.size, format: format).image { _ in
            croppedBackground.draw(at: .zero)
            text.draw(at: .zero)
        }
    }

    // Crop only the background from the top. Text is laid out separately within the clear upper area.
    static func croppedBackground(_ image: UIImage, contentHeight: CGFloat) -> UIImage? {
        let height = image.size.width * 16 / 9
        guard height <= image.size.height, contentHeight + 20 <= height,
              let source = image.cgImage else { return nil }
        let pixelHeight = Int((height * image.scale).rounded())
        guard let crop = source.cropping(to: CGRect(x: 0, y: source.height - pixelHeight,
                                                   width: source.width, height: pixelHeight)) else { return nil }
        return UIImage(cgImage: crop, scale: image.scale, orientation: .up)
    }
}

struct ShareReflectionView: View {
    let size: CGSize
    @EnvironmentObject private var vm: VersesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var original: UIImage?
    @State private var portrait: UIImage?
    @State private var usePortrait = false
    @State private var showActivity = false
    private var selectedImage: UIImage? { usePortrait ? portrait : original }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                if let selectedImage {
                    Image(uiImage: selectedImage).resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
                        .padding(.top, 8)
                    Picker("Format zdjęcia", selection: $usePortrait) {
                        Text("Cały ekran").tag(false)
                        Text("TikTok · 9:16").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .disabled(portrait == nil)
                    Text(portrait == nil
                         ? "Cały ekran zachowuje pełny tekst refleksji."
                         : "Format 9:16 zachowuje dół tła. Tylko czcionka refleksji zmniejsza się, jeśli wymaga tego tło.")
                        .font(.footnote).foregroundStyle(.secondary)
                    Button { showActivity = true } label: {
                        Label("Udostępnij zdjęcie", systemImage: "square.and.arrow.up")
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(colorScheme == .dark ? Color.white : Color.black)
                    Text("W menu udostępniania wybierz „Zachowaj obraz”, aby zapisać w Zdjęciach.")
                        .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                } else {
                    ContentUnavailableView("Nie udało się przygotować zdjęcia", systemImage: "photo", description: Text("Zamknij to okno i spróbuj ponownie."))
                }
            }
            .padding(20)
            .navigationTitle("Zdjęcie refleksji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Gotowe") { dismiss() } } }
            .onAppear {
                original = ReflectionExporter.image(vm: vm, size: size)
                portrait = ReflectionExporter.portrait(vm: vm, size: size)
            }
            .sheet(isPresented: $showActivity) {
                if let selectedImage { ImageActivityView(image: selectedImage) }
            }
        }
    }
}

private struct ImageActivityView: UIViewControllerRepresentable {
    let image: UIImage
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
