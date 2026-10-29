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

    /// The top 55% of gallery assets is reserved for text. Account for both
    /// the reader's centered aspect-fill crop and the TikTok crop from the top.
    static func portraitTextHeight(assetSize: CGSize, readerSize: CGSize) -> CGFloat {
        let scale = max(readerSize.width / assetSize.width, readerSize.height / assetSize.height)
        let scaledHeight = assetSize.height * scale
        let portraitHeight = readerSize.width * 16 / 9
        return min(portraitHeight * 0.5,
                   (readerSize.height - scaledHeight) / 2 + scaledHeight * 0.55
                   - (readerSize.height - portraitHeight) - readerSize.width * 0.04)
    }

    static func portraitTextImage(vm: VersesViewModel, width: CGFloat, maxHeight: CGFloat) -> UIImage? {
        // Start large and use the largest complete layout that fits above the artwork.
        for step in 0...42 {
            let scale = (1.30 - CGFloat(step) * 0.025) * width / 402
            let candidate: UIImage? = autoreleasepool {
                let renderer = ImageRenderer(content: PortraitReflectionText(fontScale: scale)
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
        let textHeight = portraitTextHeight(assetSize: asset.size, readerSize: size)
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

/// Compact export typography; the on-screen reader keeps its existing font sizes.
private struct PortraitReflectionText: View {
    let fontScale: CGFloat
    @EnvironmentObject private var vm: VersesViewModel

    var body: some View {
        VStack(spacing: 7 * fontScale) {
            Text(vm.currentVerse?.date ?? "")
                .font(.custom("Times New Roman", size: 25 * fontScale)).bold()
            Text(vm.currentVerse?.verse ?? "")
                .font(.custom("Times New Roman", size: 22 * fontScale)).italic()
            Text(vm.currentVerse?.reference ?? "")
                .font(.custom("Times New Roman", size: 16 * fontScale)).bold()
                .frame(maxWidth: .infinity, alignment: .center)
            Divider().overlay(Color.gray.opacity(0.3))
                .padding(.horizontal, 40 * fontScale)
                .padding(.vertical, 3 * fontScale)
            Text(vm.currentVerse?.message ?? "")
                .font(.custom("Times New Roman", size: 20 * fontScale))
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.black)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 26 * fontScale)
        .padding(.top, 30 * fontScale)
        .padding(.bottom, 8 * fontScale)
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
                         : "Format 9:16 zachowuje dół tła. Rozmiar tekstu dopasowuje się do wolnej przestrzeni u góry.")
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
