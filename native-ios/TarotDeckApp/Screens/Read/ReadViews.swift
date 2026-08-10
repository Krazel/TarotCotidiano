#if DEBUG
import SwiftUI
import TarotDeckCore

struct ReadRootView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
    @ObservedObject var languageStore: AppLanguageStore
    let inspectRevealedCard: (String) -> Void
    @State private var showsSettings = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    var body: some View {
        ZStack {
            Group {
                switch model.surface {
                case .restoring:
                    ReadRestoringView(model: model)

                case .home:
                    ReadHomeView(
                        model: model,
                        openSettings: { showsSettings = true }
                    )

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
            .id(model.surface)
            .transition(
                reduceMotion || voiceOverEnabled
                    ? .opacity
                    : .opacity.combined(with: .scale(scale: 0.985))
            )
        }
        .animation(
            reduceMotion || voiceOverEnabled ? CeremonialMotion.reduced : CeremonialMotion.screen,
            value: model.surface
        )
        .toolbar(
            model.surface == .table || model.surface == .restoring ? .hidden : .visible,
            for: .tabBar
        )
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
                SettingsView(languageStore: languageStore)
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let homeControlClearance: CGFloat = 64

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            emptyHome
        }
        .overlay(alignment: .topTrailing) {
            Button(action: openSettings) {
                Image(systemName: "gearshape")
                    .font(.system(.title2, weight: .medium))
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.trailing, 18)
            .accessibilityLabel("Settings")
            .accessibilityHint("Opens app settings without changing your reading")
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var emptyHome: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height && !dynamicTypeSize.isAccessibilitySize

            if dynamicTypeSize.isAccessibilitySize {
                ScrollView {
                    portraitHomeComposition(
                        size: CGSize(width: proxy.size.width, height: max(proxy.size.height, 900)),
                        compact: true
                    )
                    .padding(.top, homeControlClearance)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            } else if isLandscape {
                landscapeHomeComposition(size: proxy.size)
            } else {
                ViewThatFits(in: .vertical) {
                    portraitHomeComposition(size: proxy.size, compact: false)
                    portraitHomeComposition(size: proxy.size, compact: true)
                }
            }
        }
    }

    private func portraitHomeComposition(size: CGSize, compact: Bool) -> some View {
        let carouselHeight: CGFloat = compact ? 132 : 154
        let deckWidth = min(
            max(size.width - (compact ? 128 : 106), 172),
            compact ? 220 : 272,
            max(size.height - carouselHeight - (compact ? 250 : 270), 230)
                * CeremonialObsidianTheme.deckAspectRatio
        )

        return VStack(spacing: compact ? 8 : 13) {
            homeTitle(compact: compact)

            ReadingPresetCarousel(model: model, compact: compact)
                .frame(height: carouselHeight)

            heroDeck(width: deckWidth, compact: compact)

            beginCue(compact: compact)
        }
        .padding(.top, compact ? homeControlClearance : 48)
        .padding(.bottom, compact ? 12 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func landscapeHomeComposition(size: CGSize) -> some View {
        let deckWidth = min(max(size.width * 0.19, 178), 250, max(size.height - 118, 240) * CeremonialObsidianTheme.deckAspectRatio)

        return HStack(spacing: 22) {
            VStack(spacing: 10) {
                homeTitle(compact: true)
                ReadingPresetCarousel(model: model, compact: true)
                    .frame(height: 156)
            }
            .frame(width: size.width * 0.51)

            VStack(spacing: 8) {
                heroDeck(width: deckWidth, compact: true)
                beginCue(compact: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, 18)
        .padding(.horizontal, 26)
        .padding(.bottom, 12)
    }

    private func homeTitle(compact: Bool) -> some View {
        Text("Tarot Deck")
            .font(.system(compact ? .title : .largeTitle, design: .serif, weight: .semibold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private func heroDeck(width: CGFloat, compact: Bool) -> some View {
        Button {
            model.startSelectedPreset()
        } label: {
            ZStack {
                CeremonialCardBack(spokenLabel: "")
                    .offset(y: 12)
                    .opacity(0.34)
                    .accessibilityHidden(true)
                CeremonialCardBack(spokenLabel: "")
                    .offset(y: 6)
                    .opacity(0.62)
                    .accessibilityHidden(true)
                CeremonialCardBack(spokenLabel: "")
            }
            .frame(width: width, height: width / CeremonialObsidianTheme.deckAspectRatio)
            .shadow(color: CeremonialObsidianTheme.brightGold.opacity(0.23), radius: 18)
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Start a Reading")
        .accessibilityValue(model.selectedPreset.title)
        .accessibilityHint("Complete 78-card tarot deck")
    }

    private func beginCue(compact: Bool) -> some View {
        Text("Tap the deck to begin")
            .font(.system(compact ? .body : .title3, design: .serif, weight: .medium))
            .foregroundStyle(CeremonialObsidianTheme.brightGold)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

}

private struct ReadingPresetCarousel: View {
    @ObservedObject var model: ReadFlowModel
    let compact: Bool
    @State private var dragOffset: CGFloat = 0
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    private var presets: [ReadingPreset] { ReadingPreset.allCases }

    var body: some View {
        GeometryReader { proxy in
            let tileWidth = min(max(proxy.size.width * (compact ? 0.48 : 0.56), 154), compact ? 218 : 238)
            let spacing: CGFloat = compact ? 14 : 16
            let selectedIndex = presets.firstIndex(of: model.selectedPreset) ?? 0
            let centeredOffset = proxy.size.width / 2 - tileWidth / 2
                - CGFloat(selectedIndex) * (tileWidth + spacing)

            HStack(spacing: spacing) {
                ForEach(presets) { preset in
                    presetTile(preset, width: tileWidth)
                }
            }
            .offset(x: centeredOffset + dragOffset)
            .animation(CeremonialMotion.screen, value: model.selectedPreset)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard !voiceOverEnabled else { return }
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        guard !voiceOverEnabled else {
                            dragOffset = 0
                            return
                        }
                        let projected = value.predictedEndTranslation.width
                        let threshold = tileWidth * 0.22
                        let direction = projected < -threshold ? 1 : projected > threshold ? -1 : 0
                        select(index: selectedIndex + direction)
                        withAnimation(CeremonialMotion.screen) {
                            dragOffset = 0
                        }
                    }
            )
        }
        .clipped()
        .overlay(alignment: .bottom) {
            pageIndicator
        }
    }

    private func presetTile(_ preset: ReadingPreset, width: CGFloat) -> some View {
        let selected = preset == model.selectedPreset

        return Button {
            withAnimation(CeremonialMotion.screen) {
                model.selectPreset(preset)
            }
        } label: {
            VStack(spacing: compact ? 7 : 10) {
                presetGlyph(preset)
                    .frame(height: compact ? 52 : 62)
                    .accessibilityHidden(true)

                Text(preset.selectorDetail)
                    .font(.system(compact ? .subheadline : .body, design: .serif, weight: .semibold))
                    .foregroundStyle(selected ? CeremonialObsidianTheme.parchment : CeremonialObsidianTheme.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .frame(width: width, height: compact ? 108 : 126)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(CeremonialObsidianTheme.cardSurface.opacity(selected ? 0.98 : 0.90))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                selected ? CeremonialObsidianTheme.brightGold : CeremonialObsidianTheme.gold.opacity(0.42),
                                lineWidth: selected ? 2 : 1
                            )
                    }
                    .shadow(
                        color: selected ? CeremonialObsidianTheme.brightGold.opacity(0.32) : .clear,
                        radius: 9
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(preset.title)
        .accessibilityHint("Selects this reading preset")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func presetGlyph(_ preset: ReadingPreset) -> some View {
        HStack(spacing: preset == .oneCard ? 0 : -9) {
            ForEach(0..<(preset == .oneCard ? 1 : 3), id: \.self) { index in
                CeremonialCardBack(spokenLabel: "")
                    .frame(width: compact ? 32 : 38)
                    .rotationEffect(
                        preset == .oneCard ? .zero : .degrees(Double(index - 1) * 8)
                    )
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(presets) { preset in
                Circle()
                    .fill(
                        preset == model.selectedPreset
                            ? CeremonialObsidianTheme.brightGold
                            : CeremonialObsidianTheme.secondaryText.opacity(0.48)
                    )
                    .frame(width: 7, height: 7)
            }
        }
        .frame(minWidth: 44, minHeight: 24)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reading preset")
        .accessibilityValue(model.selectedPreset.title)
        .accessibilityHint("Swipe up or down to choose the previous or next preset")
        .accessibilityAdjustableAction { direction in
            guard let index = presets.firstIndex(of: model.selectedPreset) else { return }
            switch direction {
            case .increment: select(index: index + 1)
            case .decrement: select(index: index - 1)
            @unknown default: break
            }
        }
    }

    private func select(index: Int) {
        let boundedIndex = min(max(index, presets.startIndex), presets.index(before: presets.endIndex))
        model.selectPreset(presets[boundedIndex])
    }
}

private struct ReadingTableView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
    let inspectRevealedCard: (TarotCardID) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.scenePhase) private var scenePhase
    @State private var shufflePhase = 0
    @State private var visualBaseline: ReadingVisualState?
    @State private var presentationTask: Task<Void, Never>?
    @State private var presentationToken: UUID?
    @State private var presentationLocked = false
    @State private var dealingPosition: Int?
    @State private var dealProgress: CGFloat = 0
    @State private var flippingPosition: Int?
    @State private var flipProgress: CGFloat = 0
    @State private var flipRevealing = true
    @AccessibilityFocusState private var focusedReadingPosition: Int?

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height && !dynamicTypeSize.isAccessibilitySize

            ZStack {
                CeremonialBackdrop()

                if isLandscape {
                    landscapeContent(size: proxy.size)
                } else {
                    portraitContent(size: proxy.size)
                }
            }
            .overlayPreferenceValue(ReadingMotionAnchorPreferenceKey.self) { anchors in
                GeometryReader { coordinateProxy in
                    dealOverlay(anchors: anchors, proxy: coordinateProxy)
                }
            }
            .onChange(of: isLandscape) { _ in
                cancelTransientMotion(establishing: visualState)
            }
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Restoration and rotation establish a baseline without replaying motion or haptics.
            visualBaseline = visualState
        }
        .onChange(of: visualState) { newState in
            respondToDurableStateChange(newState)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                cancelTransientMotion(establishing: visualState)
            }
        }
        .onChange(of: reduceMotion) { _ in
            cancelTransientMotion(establishing: visualState)
        }
        .onChange(of: voiceOverEnabled) { _ in
            cancelTransientMotion(establishing: visualState)
        }
        .onDisappear {
            cancelTransientMotion(establishing: visualState)
        }
    }

    @ViewBuilder
    private func portraitContent(size: CGSize) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                portraitLayout
                    .frame(height: max(size.height, 820))
            }
            .scrollIndicators(.hidden)
        } else {
            portraitLayout
        }
    }

    private var portraitLayout: some View {
        VStack(spacing: 0) {
            header
                .frame(height: 72)

            readingStage(isLandscape: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            actionArea
                .frame(height: 96)
                .padding(.horizontal, 26)
        }
        .padding(.top, 4)
        .padding(.bottom, 10)
    }

    private func landscapeContent(size: CGSize) -> some View {
        let railWidth = min(max(size.width * 0.22, 154), 200)

        return HStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    backButton
                    Spacer(minLength: 0)
                    resetButton
                }

                VStack(spacing: 3) {
                    Text(model.readingTitle)
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)

                deckControl
                    .frame(maxWidth: 132, maxHeight: 152)
                    .anchorPreference(
                        key: ReadingMotionAnchorPreferenceKey.self,
                        value: .bounds,
                        transform: { [.deck: $0] }
                    )
                    .opacity(shouldShowDeck ? 1 : 0)
                    .allowsHitTesting(shouldShowDeck)

                actionArea
            }
            .frame(width: railWidth)

            readingStage(isLandscape: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var header: some View {
        ZStack {
            backButton
                .frame(maxWidth: .infinity, alignment: .leading)

            resetButton
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(spacing: 4) {
                Text(model.readingTitle)
                    .font(.system(.title, design: .serif, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
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

    private var backButton: some View {
        Button {
            cancelTransientMotion(establishing: visualState)
            model.leaveTable()
        } label: {
            Image(systemName: "chevron.left")
                .font(.title2.weight(.semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy)
        .accessibilityLabel("Back")
        .accessibilityHint("Ends this reading and returns to Read home")
    }

    private var resetButton: some View {
        Button {
            cancelTransientMotion(establishing: visualState)
            model.resetReading()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.title3.weight(.semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy)
        .accessibilityLabel("Reset Reading")
        .accessibilityHint("Clears the cards and keeps this reading preset")
    }

    @ViewBuilder
    private func readingStage(isLandscape: Bool) -> some View {
        if let layout = model.layout {
            GeometryReader { proxy in
                let gap: CGFloat = isLandscape ? 16 : 11
                let count = CGFloat(layout.cardLimit)
                let availableWidth = max(proxy.size.width - (isLandscape ? 24 : 36), 1)
                let widthFromRow = (availableWidth - gap * max(count - 1, 0)) / count
                let heightLimit = isLandscape
                    ? max(proxy.size.height - 34, 1)
                    : max(proxy.size.height * (layout == .threeCards ? 0.45 : 0.52), 1)
                let widthFromHeight = heightLimit * CeremonialObsidianTheme.cardAspectRatio
                let cardWidth = min(
                    widthFromRow,
                    widthFromHeight,
                    layout == .oneCard ? (isLandscape ? 300 : 250) : (isLandscape ? 230 : 118)
                )
                let cardHeight = cardWidth / CeremonialObsidianTheme.cardAspectRatio
                let groupWidth = cardWidth * count + gap * max(count - 1, 0)
                let slotCenterY = isLandscape
                    ? proxy.size.height / 2
                    : max(cardHeight / 2 + 28, proxy.size.height * 0.34)

                HStack(spacing: gap) {
                    ForEach(0..<layout.cardLimit, id: \.self) { index in
                        VStack(spacing: layout == .threeCards ? 4 : 0) {
                            if layout == .threeCards {
                                Text(positionTitle(at: index))
                                    .font(.system(.caption, design: .serif, weight: .semibold))
                                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                                    .frame(height: 20)
                                    .accessibilityHidden(true)
                            }

                            position(at: index, total: layout.cardLimit)
                                .frame(width: cardWidth, height: cardHeight)
                                .anchorPreference(
                                    key: ReadingMotionAnchorPreferenceKey.self,
                                    value: .bounds,
                                    transform: { [.slot(index): $0] }
                                )
                        }
                        .frame(width: cardWidth, height: cardHeight + (layout == .threeCards ? 24 : 0))
                    }
                }
                .frame(width: groupWidth, height: cardHeight + (layout == .threeCards ? 24 : 0))
                .position(x: proxy.size.width / 2, y: slotCenterY)
                .accessibilityElement(children: .contain)

                if !isLandscape {
                    let slotBottom = slotCenterY + cardHeight / 2
                    let availableDeckHeight = max(proxy.size.height - slotBottom - 28, 1)
                    let deckWidth = min(
                        max(proxy.size.width * 0.46, 120),
                        220,
                        availableDeckHeight * CeremonialObsidianTheme.deckAspectRatio
                    )
                    let deckHeight = deckWidth / CeremonialObsidianTheme.deckAspectRatio
                    deckControl
                        .frame(width: deckWidth, height: deckHeight)
                        .anchorPreference(
                            key: ReadingMotionAnchorPreferenceKey.self,
                            value: .bounds,
                            transform: { [.deck: $0] }
                        )
                        .opacity(shouldShowDeck ? 1 : 0)
                        .allowsHitTesting(shouldShowDeck)
                        .position(
                            x: proxy.size.width / 2,
                            y: min(proxy.size.height - deckHeight / 2 - 8,
                                   slotBottom + 20 + deckHeight / 2)
                        )
                }
            }
        }
    }

    private func positionTitle(at index: Int) -> String {
        model.spread?.positionTitle(at: index)
            ?? AppLocalization.format("Card %d", index + 1)
    }

    @ViewBuilder
    private func position(at index: Int, total: Int) -> some View {
        if let drawnCard = model.session?.drawnCards[safe: index],
           baselineContainsCard(at: index) {
            let baselineRevealed = visualBaseline?.revealed[safe: index] ?? drawnCard.isRevealed

            if flippingPosition == index,
               let card = content.card(withID: drawnCard.id.rawValue),
               let meaning = content.meaning(for: card) {
                flippingCard(
                    card: card,
                    meaning: meaning,
                    revealing: flipRevealing,
                    progress: flipProgress
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    flipRevealing
                        ? AppLocalization.format(
                            "%@, %@, face up",
                            positionTitle(at: index),
                            card.name
                        )
                        : AppLocalization.format("%@, face down", positionTitle(at: index))
                )
                .accessibilityValue(
                    flipRevealing ? meaning.artworkAccessibilityDescription(for: card) : ""
                )
                .accessibilityFocused($focusedReadingPosition, equals: index)
            } else if baselineRevealed,
                      let card = content.card(withID: drawnCard.id.rawValue),
                      let meaning = content.meaning(for: card) {
                revealedPosition(
                    drawnCard: drawnCard,
                    card: card,
                    meaning: meaning,
                    index: index
                )
            } else {
                FaceDownReadingPosition(
                    position: index + 1,
                    total: total,
                    positionName: positionTitle(at: index),
                    onReveal: { model.reveal(drawnCard.id) }
                )
                .disabled(interactionLocked)
                .id("face-down-\(drawnCard.id.rawValue)")
                .accessibilityFocused($focusedReadingPosition, equals: index)
            }
        } else {
            EmptyReadingPosition(
                position: index + 1,
                total: total,
                positionName: positionTitle(at: index)
            )
            .transition(.opacity)
            .id("empty-\(index)")
        }
    }

    private var shouldShowDeck: Bool {
        if model.isReadyToShuffle { return true }
        guard let layout = model.layout else { return false }
        if dealingPosition != nil { return true }
        let presentedCount = visualBaseline?.drawnCardIDs.count
            ?? model.session?.drawnCards.count
            ?? layout.cardLimit
        if presentedCount < layout.cardLimit { return true }
        let presentedRevealed = visualBaseline?.revealed
            ?? model.session?.drawnCards.map(\.isRevealed)
            ?? []
        return presentedRevealed.count == layout.cardLimit && presentedReadingIsCompleteAndRevealed
    }

    private var presentedReadingIsCompleteAndRevealed: Bool {
        guard let layout = model.layout else { return false }
        let presentedIDs = visualBaseline?.drawnCardIDs
            ?? model.session?.drawnCards.map { $0.id.rawValue }
            ?? []
        let presentedRevealed = visualBaseline?.revealed
            ?? model.session?.drawnCards.map(\.isRevealed)
            ?? []
        return presentedIDs.count == layout.cardLimit
            && presentedRevealed.count == layout.cardLimit
            && presentedRevealed.allSatisfy { $0 }
    }

    private var canUseDeck: Bool {
        if model.isReadyToShuffle { return true }
        guard let session = model.session, let layout = model.layout else { return false }
        return session.drawnCards.count < layout.cardLimit || model.canPrepareAnotherReading
    }

    private var deckControl: some View {
        let remaining = model.session?.remainingCardCount ?? 78
        return Button {
            if model.isReadyToShuffle {
                model.shuffleDeck()
            } else if model.canPrepareAnotherReading {
                cancelTransientMotion(establishing: visualState)
                model.resetReading()
            } else {
                model.drawCard()
            }
        } label: {
            CeremonialShufflingDeck(
                phase: shufflePhase,
                reduceMotion: usesReducedMotion,
                spokenLabel: model.isReadyToShuffle
                    ? AppLocalization.text("Complete deck, not yet shuffled")
                    : model.canPrepareAnotherReading
                        ? AppLocalization.text("Complete deck, ready for another reading")
                        : AppLocalization.format("Deck with %d cards remaining", remaining)
            )
            .contentShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        }
        .buttonStyle(CeremonialDeckButtonStyle(usesReducedMotion: usesReducedMotion))
        .disabled(interactionLocked || !canUseDeck)
        .accessibilityHint(
            AppLocalization.text(
                model.isReadyToShuffle
                    ? "Shuffles the deck"
                    : model.canPrepareAnotherReading
                        ? "Starts another reading with the same preset"
                        : "Draws the next card"
            )
        )
    }

    private var usesReducedMotion: Bool {
        reduceMotion || voiceOverEnabled
    }

    private var interactionLocked: Bool {
        model.isBusy || presentationLocked
    }

    private var visualState: ReadingVisualState {
        ReadingVisualState(
            sessionID: model.session?.id,
            drawnCardIDs: model.session?.drawnCards.map { $0.id.rawValue } ?? [],
            revealed: model.session?.drawnCards.map(\.isRevealed) ?? []
        )
    }

    @MainActor
    private func respondToDurableStateChange(_ newState: ReadingVisualState) {
        guard let baseline = visualBaseline else {
            visualBaseline = newState
            return
        }

        // A commit may finish after the app becomes inactive. Record its state without replaying
        // presentation or haptics when the user returns.
        guard scenePhase == .active else {
            visualBaseline = newState
            return
        }

        if baseline.sessionID == nil,
           newState.sessionID != nil,
           newState.drawnCardIDs.isEmpty {
            visualBaseline = newState
            runShuffleChoreography()
            return
        }

        if newState.drawnCardIDs.count > baseline.drawnCardIDs.count {
            runDeal(to: newState.drawnCardIDs.count - 1, target: newState)
            return
        }

        for index in newState.revealed.indices where baseline.revealed.indices.contains(index) {
            if !baseline.revealed[index], newState.revealed[index] {
                runFlip(at: index, revealing: true, target: newState)
                return
            }
            if baseline.revealed[index], !newState.revealed[index] {
                runFlip(at: index, revealing: false, target: newState)
                return
            }
        }

        visualBaseline = newState
    }

    @MainActor
    private func moveVoiceOverFocus(to position: Int) {
        guard voiceOverEnabled else { return }
        Task { @MainActor in
            await Task.yield()
            focusedReadingPosition = position
        }
    }

    @MainActor
    private func runShuffleChoreography() {
        startPresentation { token in
            if usesReducedMotion {
                withAnimation(.easeOut(duration: 0.075)) {
                    shufflePhase = 1
                }
                try? await Task.sleep(nanoseconds: 75_000_000)
                guard presentationIsCurrent(token) else { return }
                withAnimation(.easeOut(duration: 0.075)) {
                    shufflePhase = 0
                }
                try? await Task.sleep(nanoseconds: 75_000_000)
                guard presentationIsCurrent(token) else { return }
                finishPresentation(token)
                CeremonialHaptics.shuffled()
                return
            }

            withAnimation(CeremonialMotion.cut) {
                shufflePhase = 1
            }
            try? await Task.sleep(nanoseconds: 180_000_000)
            guard presentationIsCurrent(token) else { return }

            withAnimation(CeremonialMotion.interleave) {
                shufflePhase = 2
            }
            try? await Task.sleep(nanoseconds: 240_000_000)
            guard presentationIsCurrent(token) else { return }

            withAnimation(CeremonialMotion.shuffleSettle) {
                shufflePhase = 3
            }
            try? await Task.sleep(nanoseconds: 200_000_000)
            guard presentationIsCurrent(token) else { return }
            shufflePhase = 0
            finishPresentation(token)
            CeremonialHaptics.shuffled()
        }
    }

    @MainActor
    private func runDeal(to position: Int, target: ReadingVisualState) {
        startPresentation { token in
            dealingPosition = position
            dealProgress = 0
            await Task.yield()
            guard presentationIsCurrent(token) else { return }

            withAnimation(usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.deal) {
                dealProgress = 1
            }
            try? await Task.sleep(nanoseconds: usesReducedMotion ? 150_000_000 : 380_000_000)
            guard presentationIsCurrent(token) else { return }

            visualBaseline = target
            dealingPosition = nil
            dealProgress = 0
            finishPresentation(token)
            CeremonialHaptics.drawn()
            moveVoiceOverFocus(to: position)
        }
    }

    @MainActor
    private func runFlip(at position: Int, revealing: Bool, target: ReadingVisualState) {
        startPresentation { token in
            flippingPosition = position
            flipRevealing = revealing
            flipProgress = 0
            await Task.yield()
            guard presentationIsCurrent(token) else { return }

            withAnimation(usesReducedMotion ? CeremonialMotion.reduced : (revealing ? CeremonialMotion.reveal : CeremonialMotion.conceal)) {
                flipProgress = 1
            }
            try? await Task.sleep(nanoseconds: usesReducedMotion ? 150_000_000 : 320_000_000)
            guard presentationIsCurrent(token) else { return }

            visualBaseline = target
            flippingPosition = nil
            flipProgress = 0
            finishPresentation(token)
            if revealing {
                CeremonialHaptics.revealed()
            } else {
                CeremonialHaptics.concealed()
            }
            moveVoiceOverFocus(to: position)
        }
    }

    @MainActor
    private func startPresentation(
        _ operation: @escaping @MainActor (UUID) async -> Void
    ) {
        presentationTask?.cancel()
        let token = UUID()
        presentationToken = token
        presentationLocked = true
        presentationTask = Task { @MainActor in
            await operation(token)
        }
    }

    @MainActor
    private func presentationIsCurrent(_ token: UUID) -> Bool {
        !Task.isCancelled && presentationToken == token && scenePhase == .active
    }

    @MainActor
    private func finishPresentation(_ token: UUID) {
        guard presentationToken == token else { return }
        presentationToken = nil
        presentationTask = nil
        presentationLocked = false
    }

    @MainActor
    private func cancelTransientMotion(establishing baseline: ReadingVisualState) {
        presentationTask?.cancel()
        presentationTask = nil
        presentationToken = nil
        presentationLocked = false
        shufflePhase = 0
        dealingPosition = nil
        dealProgress = 0
        flippingPosition = nil
        flipProgress = 0
        visualBaseline = baseline
    }

    private var actionArea: some View {
        VStack(spacing: 5) {
            if let meaningInstructionText {
                Text(meaningInstructionText)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
            }
            Text(instructionText)
                .foregroundStyle(
                    presentedReadingIsCompleteAndRevealed
                        ? CeremonialObsidianTheme.brightGold
                        : CeremonialObsidianTheme.secondaryText
                )
        }
        .font(.body)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var statusText: String {
        if model.isReadyToShuffle { return AppLocalization.text("Ready to shuffle") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return AppLocalization.text("Deck shuffled") }
        if layout == .oneCard {
            let presentedRevealed = visualBaseline?.revealed.first
                ?? session.drawnCards[0].isRevealed
            return presentedRevealed
                ? AppLocalization.text("Card revealed")
                : AppLocalization.text("Card drawn")
        }
        if presentedReadingIsCompleteAndRevealed {
            return AppLocalization.text("All cards revealed")
        }
        return AppLocalization.format(
            "%d of %d drawn",
            session.drawnCards.count,
            layout.cardLimit
        )
    }

    private var instructionText: String {
        if model.isReadyToShuffle { return AppLocalization.text("Tap the deck to shuffle.") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return AppLocalization.text("Tap the deck to draw.") }
        if presentedReadingIsCompleteAndRevealed {
            return AppLocalization.text("Tap the deck for another reading.")
        }
        if layout == .oneCard, session.drawnCards.count == 1 {
            return AppLocalization.text("Tap the card to reveal it.")
        }
        return AppLocalization.text("Tap a face-down card to turn it over.")
    }

    private var meaningInstructionText: String? {
        guard let layout = model.layout,
              presentedReadingIsCompleteAndRevealed else { return nil }
        return layout == .oneCard
            ? AppLocalization.text("Tap the card to explore its meaning.")
            : AppLocalization.text("Tap a card to explore its meaning.")
    }

    private func baselineContainsCard(at index: Int) -> Bool {
        visualBaseline?.drawnCardIDs.indices.contains(index) == true
    }

    private func revealedPosition(
        drawnCard: DrawnCard,
        card: TarotCardRecord,
        meaning: TarotCardMeaning,
        index: Int
    ) -> some View {
        let artwork = TarotArtworkView(
            card: card,
            artworkDescription: meaning.artworkDescription
        )
        return Button {
            inspectRevealedCard(drawnCard.id)
        } label: {
            artwork
        }
        .buttonStyle(.plain)
        .disabled(interactionLocked)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AppLocalization.format(
                "%@, %@, face up",
                positionTitle(at: index),
                card.name
            )
        )
        .accessibilityValue(artwork.accessibilitySummary)
        .accessibilityHint("Opens the upright meaning")
        .accessibilityAction(named: Text("Turn face down")) {
            model.conceal(drawnCard.id)
        }
        .id("revealed-\(drawnCard.id.rawValue)")
        .accessibilityFocused($focusedReadingPosition, equals: index)
    }

    private func flippingCard(
        card: TarotCardRecord,
        meaning: TarotCardMeaning,
        revealing: Bool,
        progress: CGFloat
    ) -> some View {
        let artwork = TarotArtworkView(
            card: card,
            artworkDescription: meaning.artworkDescription
        )
        return ZStack {
            CeremonialCardBack(
                presentationAspectRatio: CeremonialObsidianTheme.cardAspectRatio,
                contentMode: .fill,
                spokenLabel: ""
            )
            .modifier(
                CeremonialFlipFaceModifier(
                    progress: progress,
                    face: .back,
                    revealing: revealing,
                    reduceMotion: usesReducedMotion
                )
            )

            artwork
                .modifier(
                    CeremonialFlipFaceModifier(
                        progress: progress,
                        face: .front,
                        revealing: revealing,
                        reduceMotion: usesReducedMotion
                    )
                )
        }
        .clipped()
    }

    @ViewBuilder
    private func dealOverlay(
        anchors: [ReadingMotionAnchor: Anchor<CGRect>],
        proxy: GeometryProxy
    ) -> some View {
        if let position = dealingPosition,
           let sourceAnchor = anchors[.deck],
           let destinationAnchor = anchors[.slot(position)] {
            let source = proxy[sourceAnchor]
            let destination = proxy[destinationAnchor]
            let start = CGPoint(x: source.midX, y: source.midY)
            let end = CGPoint(x: destination.midX, y: destination.midY)
            let dx = end.x - start.x
            let dy = end.y - start.y
            let distance = max(sqrt(dx * dx + dy * dy), 1)
            let motionStart = usesReducedMotion ? end : start

            CeremonialCardBack(
                presentationAspectRatio: CeremonialObsidianTheme.cardAspectRatio,
                contentMode: .fill,
                spokenLabel: ""
            )
            .frame(width: destination.width, height: destination.height)
            .scaleEffect(usesReducedMotion ? 1 : 0.94 + 0.06 * dealProgress)
            .rotationEffect(.degrees(usesReducedMotion ? 0 : 2 * (1 - dealProgress)))
            .opacity(usesReducedMotion ? dealProgress : 1)
            .position(motionStart)
            .modifier(
                CeremonialDealGeometryEffect(
                    progress: dealProgress,
                    start: motionStart,
                    end: end,
                    arcHeight: usesReducedMotion ? 0 : min(42, distance * 0.12)
                )
            )
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

private enum ReadingMotionAnchor: Hashable {
    case deck
    case slot(Int)
}

private struct ReadingMotionAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [ReadingMotionAnchor: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [ReadingMotionAnchor: Anchor<CGRect>],
        nextValue: () -> [ReadingMotionAnchor: Anchor<CGRect>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}

private struct ReadingVisualState: Equatable {
    let sessionID: UUID?
    let drawnCardIDs: [String]
    let revealed: [Bool]
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
#endif
