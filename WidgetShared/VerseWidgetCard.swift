import SwiftUI
import UIKit

/// The same card is used by WidgetKit and layout previews in the app's tests.
struct VerseWidgetCard: View {
    let verse: WidgetVerse?
    let date: Date
    let background: String
    let medium: Bool
    var showsArtwork = true

    private var ink: Color { showsArtwork ? Color(red: 0.23, green: 0.21, blue: 0.17) : .primary }
    static let paper = Color(red: 0.97, green: 0.95, blue: 0.90)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                if showsArtwork {
                    Image(uiImage: WidgetArtwork.image(named: background))
                        .resizable()
                        .scaledToFill()
                        .frame(width: medium ? geometry.size.width * 0.48 : geometry.size.width,
                               height: geometry.size.height, alignment: .bottom)
                        .clipped()
                        .overlay {
                            if !medium { Self.paper.opacity(0.88) }
                        }
                        .mask {
                            if medium {
                                // Fade into the actual system-rendered container background.
                                // A paper-colored overlay can show a seam when iOS adjusts that background.
                                LinearGradient(stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .clear, location: 0.10),
                                    .init(color: .black.opacity(0.08), location: 0.25),
                                    .init(color: .black.opacity(0.32), location: 0.43),
                                    .init(color: .black.opacity(0.68), location: 0.63),
                                    .init(color: .black.opacity(0.92), location: 0.82),
                                    .init(color: .black, location: 1)
                                ], startPoint: .leading, endPoint: .trailing)
                            } else {
                                Rectangle()
                            }
                        }
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        Image(systemName: "sun.max")
                        Text(date.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "pl_PL"))))
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ink.opacity(0.7))
                    Spacer(minLength: 0)
                    Text(verse?.verse ?? "Otwórz aplikację, aby przeczytać dzisiejszy werset.")
                        .font(.system(size: medium ? 19 : 17, weight: .medium, design: .serif))
                        .minimumScaleFactor(0.70)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                    Spacer(minLength: 0)
                    Text(verse?.reference ?? "Werset z Biblii")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(ink.opacity(0.7))
                }
                .padding(16)
                .frame(width: medium && showsArtwork ? geometry.size.width * 0.70 : geometry.size.width,
                       height: geometry.size.height)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .foregroundStyle(ink)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Otwiera dzisiejszą refleksję")
    }
}

/// SwiftUI scaling changes layout, but WidgetKit still archives the original pixels.
/// Bound the actual bitmap before passing it to the widget archiver.
@MainActor
enum WidgetArtwork {
    static func image(named name: String) -> UIImage {
        guard let original = UIImage(named: name) else { return UIImage() }
        let ratio = min(1, 720 / max(original.size.width, original.size.height))
        let size = CGSize(width: original.size.width * ratio, height: original.size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            original.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
