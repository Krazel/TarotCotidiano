#if DEBUG
import SwiftUI
import TarotDeckCore

struct ReadRootView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
    let inspectRevealedCard: (String) -> Void
    @State private var showsSettings = false

    var body: some View {
        Group {
            switch model.surface {
            case .restoring:
                ReadRestoringView(model: model)

            case .home:
                ReadHomeView(
                    model: model,
                    openSettings: { showsSettings = true }
                )

            case .layoutChoice:
                LayoutChoiceView(model: model)

            case .table:
                ReadingTableView(
                    model: model,
                    content: content,
                    inspectRevealedCard: { cardID in
                        guard model.canInspect(cardID) else { return }
                        inspectRevealedCard(cardID.rawValue)
                    }
                )
            }
        }
        .toolbar(
            model.surface == .table || model.surface == .restoring ? .hidden : .visible,
            for: .tabBar
        )
        .alert("Start a new reading?", isPresented: $model.showsReplaceReadingAlert) {
            Button("Start New Reading", role: .destructive) {
                model.confirmReplaceReading()
            }
            Button("Keep Current Reading", role: .cancel) {
                model.cancelReplaceReading()
            }
        } message: {
            Text("Your current reading will be cleared.")
        }
        .alert("End this reading?", isPresented: $model.showsEndReadingAlert) {
            Button("End Reading", role: .destructive) {
                model.confirmEndReading()
            }
            Button("Keep Reading", role: .cancel) {
                model.cancelEndReading()
            }
        } message: {
            Text("The cards will return to the deck. This reading won't be saved.")
        }
        .alert(model.issueTitle, isPresented: $model.showsIssueAlert) {
            if model.canRetryIssue {
                Button("Try Again") {
                    model.retryIssue()
                }
            }
            Button("Dismiss", role: .cancel) {
                model.dismissIssue()
            }
        } message: {
            Text(model.issueMessage)
        }
        .sheet(isPresented: $showsSettings) {
            NavigationStack {
                SettingsView()
            }
            .presentationDragIndicator(.visible)
        }
        .task {
            await model.restoreIfNeeded()
        }
    }
}

private struct ReadRestoringView: View {
    @ObservedObject var model: ReadFlowModel

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            VStack(spacing: 18) {
                if model.showsRestorationProgress {
                    ProgressView()
                        .tint(CeremonialObsidianTheme.brightGold)
                        .accessibilityLabel("Restoring reading")
                } else {
                    Text("Reading unavailable")
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .accessibilityAddTraits(.isHeader)

                    Button("Try Again") {
                        model.retryRestoration()
                    }
                    .buttonStyle(CeremonialPrimaryButtonStyle())
                }
            }
            .padding(28)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct ReadHomeView: View {
    @ObservedObject var model: ReadFlowModel
    let openSettings: () -> Void

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Spacer()
                        Button(action: openSettings) {
                            Image(systemName: "gearshape")
                                .font(.system(.title2, weight: .medium))
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Settings")
                        .accessibilityHint("Opens app settings without changing your reading")
                    }

                    VStack(spacing: 7) {
                        Text("Tarot Deck")
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)

                        Text("Your deck, always with you.")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    }

                    CeremonialCardBack(spokenLabel: "Complete 78-card tarot deck")
                        .frame(maxWidth: model.hasActiveReading ? 260 : 320)
                        .padding(.vertical, 4)

                    if let session = model.session, let layout = model.layout {
                        activeReading(layout: layout, session: session)
                    } else {
                        emptyReading
                    }
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, 26)
                .padding(.top, 26)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var emptyReading: some View {
        VStack(spacing: 18) {
            Text("78 cards")
                .font(.system(.body, design: .serif, weight: .medium))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .padding(.horizontal, 18)
                .frame(minHeight: 44)
                .background(Capsule().stroke(CeremonialObsidianTheme.gold.opacity(0.55)))

            Text("Shuffle, draw, and read in your own way.")
                .font(.system(.title3, design: .serif))
                .multilineTextAlignment(.center)

            Button("New Reading") {
                model.requestNewReading()
            }
            .buttonStyle(CeremonialPrimaryButtonStyle())
            .disabled(model.isBusy)
        }
    }

    private func activeReading(layout: ReadingLayout, session: DeckSession) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                Text("Reading in progress")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)

                Text(layout.title)
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))

                HStack(spacing: 12) {
                    ForEach(0..<layout.cardLimit, id: \.self) { index in
                        Circle()
                            .fill(index < session.drawnCards.count
                                  ? CeremonialObsidianTheme.brightGold
                                  : CeremonialObsidianTheme.cardEdge)
                            .frame(width: 12, height: 12)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(session.drawnCards.count) of \(layout.cardLimit) cards drawn")
            }

            Button("Resume Reading") {
                model.resumeReading()
            }
            .buttonStyle(CeremonialPrimaryButtonStyle())
            .disabled(model.isBusy)

            Button("New Reading") {
                model.requestNewReading()
            }
            .font(.system(.body, design: .serif, weight: .medium))
            .foregroundStyle(CeremonialObsidianTheme.parchment)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Capsule().stroke(CeremonialObsidianTheme.gold.opacity(0.55)))
            .buttonStyle(.plain)
            .disabled(model.isBusy)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(CeremonialObsidianTheme.cardSurface.opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(CeremonialObsidianTheme.gold.opacity(0.6), lineWidth: 1)
                }
        }
    }
}

private struct LayoutChoiceView: View {
    @ObservedObject var model: ReadFlowModel

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        Button {
                            model.cancelLayoutChoice()
                        } label: {
                            Label("Cancel", systemImage: "chevron.left")
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        Spacer()
                    }

                    VStack(spacing: 7) {
                        Text("Choose a Reading")
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("You decide what each position means.")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            .multilineTextAlignment(.center)
                    }

                    layoutButton(
                        layout: .oneCard,
                        summary: "A single card for one clear focus."
                    )
                    layoutButton(
                        layout: .threeCards,
                        summary: "Read three cards together in your own way."
                    )
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func layoutButton(layout: ReadingLayout, summary: String) -> some View {
        Button {
            model.selectLayout(layout)
        } label: {
            HStack(spacing: 22) {
                HStack(spacing: -22) {
                    ForEach(0..<layout.cardLimit, id: \.self) { _ in
                        CeremonialCardBack(spokenLabel: "")
                            .frame(width: layout == .oneCard ? 96 : 68)
                    }
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 9) {
                    Text(layout.title)
                        .font(.system(.title, design: .serif, weight: .semibold))
                    Text(summary)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
            }
            .padding(20)
            .frame(minHeight: 188)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(CeremonialObsidianTheme.cardSurface.opacity(0.96))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(CeremonialObsidianTheme.gold.opacity(0.58), lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(layout.title). \(summary)")
        .accessibilityHint("Starts this reading layout")
    }
}

private struct ReadingTableView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
    let inspectRevealedCard: (TarotCardID) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height && !dynamicTypeSize.isAccessibilitySize

            ZStack {
                CeremonialBackdrop()

                if isLandscape {
                    landscapeContent
                } else {
                    portraitContent
                }
            }
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var portraitContent: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                positions
                    .frame(maxWidth: model.layout == .oneCard ? 360 : 620)
                    .padding(.horizontal, model.layout == .oneCard ? 52 : 18)

                if shouldShowDeck {
                    deck
                        .frame(maxWidth: 220)
                }

                actionArea
                    .frame(maxWidth: 420)
                    .padding(.horizontal, 26)
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
    }

    private var landscapeContent: some View {
        VStack(spacing: 4) {
            header

            HStack(spacing: 36) {
                VStack(spacing: 12) {
                    if shouldShowDeck {
                        deck
                            .frame(maxWidth: 190)
                    }
                    actionArea
                        .frame(maxWidth: 440)
                }
                .frame(maxWidth: .infinity)

                positions
                    .frame(maxWidth: model.layout == .oneCard ? 320 : 720, maxHeight: 360)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 12)
        }
    }

    private var header: some View {
        ZStack(alignment: .leading) {
            Button {
                model.leaveTable()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.semibold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(model.isBusy)
            .accessibilityLabel("Back")
            .accessibilityHint(model.hasActiveReading ? "Returns to Read home" : "Returns to layout choice")

            VStack(spacing: 4) {
                Text(model.layout?.title ?? "Reading")
                    .font(.system(.title, design: .serif, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Text(statusText)
                    .font(.body)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 54)
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 64)
    }

    @ViewBuilder
    private var positions: some View {
        if let layout = model.layout {
            HStack(spacing: layout == .oneCard ? 0 : 14) {
                ForEach(0..<layout.cardLimit, id: \.self) { index in
                    position(at: index, total: layout.cardLimit)
                }
            }
            .accessibilityElement(children: .contain)
        }
    }

    @ViewBuilder
    private func position(at index: Int, total: Int) -> some View {
        if let drawnCard = model.session?.drawnCards[safe: index] {
            if drawnCard.isRevealed,
               let card = content.card(withID: drawnCard.id.rawValue),
               let meaning = content.meaning(for: card) {
                let artwork = TarotArtworkView(
                    card: card,
                    artworkDescription: meaning.artworkDescription
                )
                Button {
                    inspectRevealedCard(drawnCard.id)
                } label: {
                    artwork
                }
                .buttonStyle(.plain)
                .disabled(model.isBusy)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(card.name), card position \(index + 1) of \(total), face up")
                .accessibilityValue(artwork.accessibilitySummary)
                .accessibilityHint("Opens the upright meaning")
                .accessibilityAction(named: Text("Turn face down")) {
                    model.conceal(drawnCard.id)
                }
            } else {
                FaceDownReadingPosition(
                    position: index + 1,
                    total: total,
                    onReveal: { model.reveal(drawnCard.id) }
                )
                .disabled(model.isBusy)
            }
        } else {
            EmptyReadingPosition(position: index + 1, total: total)
        }
    }

    private var shouldShowDeck: Bool {
        if model.isReadyToShuffle { return true }
        guard let session = model.session, let layout = model.layout else { return false }
        return session.drawnCards.count < layout.cardLimit
    }

    private var deck: some View {
        let remaining = model.session?.remainingCardCount ?? 78
        return CeremonialCardBack(
            spokenLabel: model.isReadyToShuffle
                ? "Complete deck, not yet shuffled"
                : "Deck with \(remaining) cards remaining"
        )
    }

    private var actionArea: some View {
        VStack(spacing: 12) {
            Text(instructionText)
                .font(.body)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                .multilineTextAlignment(.center)

            if let primaryTitle {
                Button(primaryTitle) {
                    if model.isReadyToShuffle {
                        model.shuffleDeck()
                    } else {
                        model.drawCard()
                    }
                }
                .buttonStyle(CeremonialPrimaryButtonStyle())
                .disabled(model.isBusy)
            }

            Button("End Reading") {
                model.requestEndReading()
            }
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(CeremonialObsidianTheme.brightGold)
            .frame(minWidth: 44, minHeight: 44)
            .buttonStyle(.plain)
            .disabled(model.isBusy)
        }
    }

    private var primaryTitle: String? {
        if model.isReadyToShuffle { return "Shuffle Deck" }
        guard let session = model.session, let layout = model.layout,
              session.drawnCards.count < layout.cardLimit else { return nil }
        if session.drawnCards.isEmpty { return "Draw Card" }
        return session.drawnCards.count + 1 == layout.cardLimit
            ? "Draw Final Card"
            : "Draw Next Card"
    }

    private var statusText: String {
        if model.isReadyToShuffle { return "Ready to shuffle" }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return "Deck shuffled" }
        if layout == .oneCard {
            return session.drawnCards[0].isRevealed ? "Card revealed" : "Card drawn"
        }
        if session.drawnCards.count == layout.cardLimit,
           session.drawnCards.allSatisfy(\.isRevealed) {
            return "All cards revealed"
        }
        return "\(session.drawnCards.count) of \(layout.cardLimit) drawn"
    }

    private var instructionText: String {
        if model.isReadyToShuffle { return "Shuffle before drawing." }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return "Draw when you're ready." }
        if session.drawnCards.count == layout.cardLimit,
           session.drawnCards.allSatisfy(\.isRevealed) {
            return layout == .oneCard
                ? "Tap the card to explore its meaning."
                : "Tap a card to explore its meaning."
        }
        if layout == .oneCard, session.drawnCards.count == 1 {
            return "Tap the card to reveal it."
        }
        return "Tap a face-down card to turn it over."
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
#endif
