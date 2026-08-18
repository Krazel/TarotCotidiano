import SwiftUI
import UIKit

struct TarotArtworkView: View {
    let card: TarotCardRecord
    var artworkDescription: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if let image = UIImage(named: card.artworkAsset) {
                Image(uiImage: image)
                    .resizable()
                    .antialiased(true)
                    .scaledToFit()
                    .accessibilityHidden(true)
            } else {
                missingApprovedArtworkFallback
            }
        }
        .aspectRatio(CeremonialObsidianTheme.cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius)
                .stroke(CeremonialObsidianTheme.gold.opacity(0.75), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.65), radius: 10, y: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.accessibilityLabel)
        .accessibilityValue(accessibilitySummary)
    }

    private var missingApprovedArtworkFallback: some View {
        ZStack {
            LinearGradient(
                colors: [CeremonialObsidianTheme.backgroundLifted, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 9)
                .stroke(CeremonialObsidianTheme.gold.opacity(0.55), lineWidth: 1)
                .padding(7)

            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)

                Text(card.name)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundStyle(CeremonialObsidianTheme.parchment)
                    .multilineTextAlignment(.center)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)

                Text("MISSING APPROVED ASSET")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
            }
            .padding(10)
        }
    }

    var accessibilitySummary: String {
        guard UIImage(named: card.artworkAsset) != nil else {
            return AppLocalization.text(
                "Approved artwork is missing from this build."
            )
        }

        let description = artworkDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if description.isEmpty {
            return AppLocalization.text(
                "Historical Rider–Waite–Smith artwork."
            )
        }
        return AppLocalization.format(
            "Historical Rider–Waite–Smith artwork. %@",
            description
        )
    }
}
