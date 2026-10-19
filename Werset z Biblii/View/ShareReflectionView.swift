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

    static func portrait(vm: VersesViewModel, size: CGSize) -> UIImage? {
        let measure = ImageRenderer(content: VerseTextView(fillsHeight: false)
            .environmentObject(vm).frame(width: size.width).fixedSize(horizontal: false, vertical: true))
        guard let measured = measure.uiImage else { return nil }
        let backgroundRenderer = ImageRenderer(content: ReflectionCanvas(size: size, textOpacity: 0)
            .environmentObject(vm))
        backgroundRenderer.proposedSize = ProposedViewSize(size)
        backgroundRenderer.scale = 3
        guard let background = backgroundRenderer.uiImage,
              let croppedBackground = croppedBackground(background, contentHeight: measured.size.height),
              let text = textImage(vm: vm, size: croppedBackground.size) else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = croppedBackground.scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: croppedBackground.size, format: format).image { _ in
            croppedBackground.draw(at: .zero)
            text.draw(at: .zero)
        }
    }

    // Crop only the background from the top. Text is rendered separately at its original position.
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
                         : "Format 9:16 przycina górę tła. Dół obrazu i cały tekst pozostają.")
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
