import SwiftUI

struct LearnIndexView: View {
    let content: TarotContent
    let startReading: (String) -> Void

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                LazyVStack(spacing: 14) {
                    titleBlock

                    ForEach(content.guideArticles) { article in
                        NavigationLink {
                            LearnArticleView(
                                article: article,
                                startReading: startReading
                            )
                        } label: {
                            LearnArticleRow(
                                article: article,
                                isFirst: article.order == 1
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
        .navigationTitle("Learn")
    }

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text("Learn")
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text("A simple way to read for yourself")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 22)
    }
}

private struct LearnArticleRow: View {
    let article: TarotGuideArticle
    let isFirst: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(isFirst ? Color.black.opacity(0.78) : CeremonialObsidianTheme.brightGold)
                .frame(width: 42)

            VStack(alignment: .leading, spacing: 7) {
                if isFirst {
                    Text("BEGIN HERE")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .tracking(1.2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(CeremonialObsidianTheme.gold.opacity(0.42))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }

                Text(article.title)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(isFirst ? Color.black.opacity(0.86) : CeremonialObsidianTheme.parchment)

                Text(article.summary)
                    .font(.subheadline)
                    .foregroundStyle(isFirst ? Color.black.opacity(0.72) : CeremonialObsidianTheme.secondaryText)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(isFirst ? Color.black.opacity(0.65) : CeremonialObsidianTheme.parchment)
        }
        .padding(18)
        .frame(minHeight: isFirst ? 142 : 94)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(isFirst ? CeremonialObsidianTheme.parchment : CeremonialObsidianTheme.cardSurface.opacity(0.96))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(CeremonialObsidianTheme.gold.opacity(isFirst ? 0.9 : 0.35), lineWidth: 1)
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title). \(article.summary)")
        .accessibilityHint("Opens this guide article")
    }

    private var iconName: String {
        switch article.id {
        case "prepare-a-reading": return "sun.max"
        case "one-card-focus": return "rectangle.portrait"
        case "past-present-possible-direction": return "arrow.right"
        case "situation-challenge-guidance": return "scope"
        case "you-other-person-connection": return "person.2"
        case "yes-or-no-with-context": return "arrow.left.arrow.right"
        case "open-three-cards": return "rectangle.stack.fill"
        case "read-symbols-whole-spread": return "eye"
        default: return "text.book.closed"
        }
    }
}

struct LearnArticleView: View {
    let article: TarotGuideArticle
    let startReading: (String) -> Void

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    if let readingPresetID = article.readingPresetID {
                        readingIllustration(cardCount: readingPresetID == "oneCard" ? 1 : 3)
                    }

                    ForEach(Array(article.sections.enumerated()), id: \.offset) { index, section in
                        articleSection(number: index + 1, section: section)
                    }

                    if let readingPresetID = article.readingPresetID {
                        Button {
                            startReading(readingPresetID)
                        } label: {
                            Label("Try This Reading", systemImage: "chevron.right")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(CeremonialPrimaryButtonStyle())
                        .accessibilityHint("Selects this reading preset or returns to the current reading")
                    }
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(CeremonialObsidianTheme.background.opacity(0.96), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(article.title)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Text(article.summary)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 6)
    }

    private func readingIllustration(cardCount: Int) -> some View {
        HStack(spacing: 14) {
            ForEach(1...cardCount, id: \.self) { position in
                CeremonialCardBack(
                    spokenLabel: AppLocalization.format(
                        "Example card %d of %d, face down",
                        position,
                        cardCount
                    )
                )
                    .frame(maxWidth: 105)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
    }

    private func articleSection(
        number: Int,
        section: TarotGuideArticle.Section
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .frame(width: 44, height: 44)
                .background(Circle().stroke(CeremonialObsidianTheme.gold, lineWidth: 1))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(section.heading)
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)

                Text(section.body)
                    .font(.body)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}
