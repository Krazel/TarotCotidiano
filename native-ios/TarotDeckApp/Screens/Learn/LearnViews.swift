import SwiftUI

struct LearnIndexView: View {
    let content: TarotContent
    let openArticle: (String) -> Void
    let openTutorials: () -> Void

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                LazyVStack(spacing: 14) {
                    titleBlock

                    ForEach(content.foundationArticles) { article in
                        Button {
                            openArticle(article.id)
                        } label: {
                            FoundationArticleRow(
                                article: article,
                                featured: article.id == "how-to-read-tarot"
                            )
                        }
                        .buttonStyle(.plain)

                        if article.id == "shuffle-and-draw" {
                            Button(action: openTutorials) {
                                TutorialsPortalRow()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: 720)
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
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

private struct FoundationArticleRow: View {
    let article: TarotGuideArticle
    let featured: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: featured ? 32 : 26, weight: .light))
                .foregroundStyle(featured ? CeremonialObsidianTheme.background : CeremonialObsidianTheme.brightGold)
                .frame(width: 46)

            VStack(alignment: .leading, spacing: 7) {
                if featured {
                    Text("BEGIN HERE")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .tracking(1.1)
                        .foregroundStyle(CeremonialObsidianTheme.background.opacity(0.82))
                }

                Text(article.title)
                    .font(.system(featured ? .title2 : .title3, design: .serif, weight: .semibold))
                    .foregroundStyle(featured ? CeremonialObsidianTheme.background : CeremonialObsidianTheme.parchment)

                Text(article.summary)
                    .font(.subheadline)
                    .foregroundStyle(featured ? CeremonialObsidianTheme.background.opacity(0.78) : CeremonialObsidianTheme.secondaryText)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundStyle(featured ? CeremonialObsidianTheme.background : CeremonialObsidianTheme.parchment)
        }
        .padding(18)
        .frame(minHeight: featured ? 132 : 94)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(featured ? CeremonialObsidianTheme.parchment : CeremonialObsidianTheme.cardSurface.opacity(0.96))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(CeremonialObsidianTheme.gold.opacity(featured ? 0.92 : 0.35), lineWidth: featured ? 2 : 1)
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title). \(article.summary)")
        .accessibilityHint("Opens this guide article")
    }

    private var iconName: String {
        switch article.id {
        case "how-to-read-tarot": return "sun.max"
        case "shuffle-and-draw": return "rectangle.stack"
        case "symbols-and-patterns": return "eye"
        case "build-your-interpretation": return "text.book.closed"
        default: return "sparkles"
        }
    }
}

private struct TutorialsPortalRow: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .frame(width: 46)

            VStack(alignment: .leading, spacing: 7) {
                Text("Reading Tutorials")
                    .font(.system(.title2, design: .serif, weight: .semibold))

                Text("One card, yes or no, and more practical methods.")
                    .font(.subheadline)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.headline)
        }
        .padding(18)
        .frame(minHeight: 104)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(CeremonialObsidianTheme.cardSurface.opacity(0.98))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1.5)
                }
                .shadow(color: CeremonialObsidianTheme.brightGold.opacity(0.22), radius: 10)
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens six reading tutorials")
    }
}

struct ReadingTutorialsView: View {
    let articles: [TarotGuideArticle]
    let openArticle: (String) -> Void

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                LazyVStack(spacing: 12) {
                    VStack(spacing: 8) {
                        Text("Reading Tutorials")
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("Choose a practical way to read the cards.")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 22)

                    ForEach(articles) { article in
                        Button {
                            openArticle(article.id)
                        } label: {
                            TutorialMethodRow(article: article)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: 720)
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 28)
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
}

private struct TutorialMethodRow: View {
    let article: TarotGuideArticle
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .frame(width: 46)

            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .multilineTextAlignment(.leading)

                Text(article.summary)
                    .font(.subheadline)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.headline)
        }
        .padding(18)
        .frame(minHeight: 94)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(CeremonialObsidianTheme.cardSurface.opacity(0.96))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(CeremonialObsidianTheme.gold.opacity(0.35), lineWidth: 1)
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.title). \(article.summary)")
        .accessibilityHint("Opens this reading tutorial")
    }

    private var iconName: String {
        switch article.readingPresetID {
        case "oneCard": return "rectangle.portrait"
        case "pastPresentFuture": return "arrow.right"
        case "situationChallengeAdvice": return "scope"
        case "relationship": return "person.2"
        case "open": return "arrow.left.arrow.right"
        case "freeform": return "rectangle.on.rectangle"
        default: return "sparkles"
        }
    }
}

struct LearnArticleView: View {
    let article: TarotGuideArticle
    let startReading: (String) -> Void
    let returnToReading: (() -> Void)?
    let previousTutorial: TarotGuideArticle?
    let nextTutorial: TarotGuideArticle?
    let openTutorial: (String) -> Void
    @AccessibilityFocusState private var titleFocused: Bool

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    if let readingPresetID = article.readingPresetID {
                        readingIllustration(labels: positionLabels(for: readingPresetID))
                    }

                    ForEach(Array(article.sections.enumerated()), id: \.offset) { index, section in
                        articleSection(number: index + 1, section: section)
                    }

                    if let readingPresetID = article.readingPresetID,
                       returnToReading == nil {
                        Button {
                            startReading(readingPresetID)
                        } label: {
                            Label("Try This Reading", systemImage: "chevron.right")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(CeremonialPrimaryButtonStyle())
                        .accessibilityHint("Selects this reading preset or returns to the current reading")
                    }

                    if article.readingPresetID != nil {
                        tutorialNavigation
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
        .navigationBarBackButtonHidden(returnToReading != nil)
        .toolbarBackground(CeremonialObsidianTheme.background.opacity(0.96), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if let returnToReading {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: returnToReading) {
                        Label("Back to Reading", systemImage: "chevron.left")
                    }
                    .accessibilityHint("Returns to the unchanged reading.")
                }
            }
        }
        .id(article.id)
        .onAppear {
            Task { @MainActor in titleFocused = true }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(article.title)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)

            Text(article.summary)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 6)
    }

    private var tutorialNavigation: some View {
        HStack(spacing: 14) {
            tutorialNavigationButton(
                article: previousTutorial,
                title: "Previous Tutorial",
                systemName: "chevron.left",
                valuePrefix: "Previous: %@"
            )

            tutorialNavigationButton(
                article: nextTutorial,
                title: "Next Tutorial",
                systemName: "chevron.right",
                valuePrefix: "Next: %@"
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func tutorialNavigationButton(
        article destination: TarotGuideArticle?,
        title: String,
        systemName: String,
        valuePrefix: String
    ) -> some View {
        Button {
            guard let destination else { return }
            openTutorial(destination.id)
        } label: {
            Label(title, systemImage: systemName)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .tint(CeremonialObsidianTheme.brightGold)
        .disabled(destination == nil)
        .opacity(destination == nil ? 0.35 : 1)
        .accessibilityValue(
            destination.map { AppLocalization.format(valuePrefix, $0.title) } ?? ""
        )
    }

    private func readingIllustration(labels: [String]) -> some View {
        HStack(spacing: 14) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                VStack(spacing: 8) {
                    CeremonialCardBack(
                        spokenLabel: AppLocalization.format(
                            "Example card %d of %d, face down",
                            index + 1,
                            labels.count
                        )
                    )
                    .frame(maxWidth: 105)

                    Text(label)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 115)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
    }

    private func positionLabels(for presetID: String) -> [String] {
        switch presetID {
        case "oneCard":
            return [AppLocalization.text("One Card")]
        case "pastPresentFuture":
            return (0..<3).map { ThreeCardSpread.pastPresentFuture.positionTitle(at: $0) }
        case "situationChallengeAdvice":
            return (0..<3).map { ThreeCardSpread.situationChallengeAdvice.positionTitle(at: $0) }
        case "relationship":
            return (0..<3).map { ThreeCardSpread.relationship.positionTitle(at: $0) }
        case "open":
            return (0..<3).map { ThreeCardSpread.open.positionTitle(at: $0) }
        case "freeform":
            return (0..<3).map { ThreeCardSpread.freeform.positionTitle(at: $0) }
        default:
            return []
        }
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
