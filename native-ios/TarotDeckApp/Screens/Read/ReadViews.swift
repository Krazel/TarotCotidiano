#if DEBUG
import SwiftUI
import TarotDeckCore

struct ReadRootView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
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

                case .layoutChoice:
                    LayoutChoiceView(model: model)

                case .spreadChoice:
                    ThreeCardSpreadChoiceView(model: model)

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

                if let spread = model.spread {
                    Text(spread.title)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }

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
                .accessibilityLabel(
                    AppLocalization.format(
                        "%d of %d cards drawn",
                        session.drawnCards.count,
                        layout.cardLimit
                    )
                )
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

                        Text("Choose one card, a guided spread, or your own positions.")
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
                        summary: "Choose position meanings or use an open reading."
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
                    Text(AppLocalization.text(summary))
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
        .accessibilityLabel("\(layout.title). \(AppLocalization.text(summary))")
        .accessibilityHint("Starts this reading layout")
    }
}

private struct ThreeCardSpreadChoiceView: View {
    @ObservedObject var model: ReadFlowModel

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Button {
                            model.cancelSpreadChoice()
                        } label: {
                            Label("Reading", systemImage: "chevron.left")
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        Spacer()
                    }

                    VStack(spacing: 7) {
                        Text("Choose a Spread")
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text("Each position has a purpose.")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            .multilineTextAlignment(.center)
                    }

                    ForEach(ThreeCardSpread.namedCases, id: \.self) { spread in
                        spreadButton(spread)
                    }

                    Button {
                        model.selectSpread(.open)
                    } label: {
                        HStack(spacing: 10) {
                            Text("Open reading · No assigned positions")
                                .font(.system(.body, design: .serif, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(CeremonialObsidianTheme.cardSurface.opacity(0.94))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(CeremonialObsidianTheme.gold.opacity(0.7), lineWidth: 1)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    .disabled(model.isBusy)
                    .accessibilityLabel("Open reading. No assigned positions.")
                    .accessibilityHint("Starts a free three-card reading")
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

    private func spreadButton(_ spread: ThreeCardSpread) -> some View {
        Button {
            model.selectSpread(spread)
        } label: {
            HStack(spacing: 18) {
                HStack(spacing: -12) {
                    ForEach(0..<3, id: \.self) { _ in
                        CeremonialCardBack(spokenLabel: "")
                            .frame(width: 56)
                    }
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 7) {
                    Text(spread.title)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(spread.summary)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
            }
            .padding(17)
            .frame(minHeight: 142)
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
        .accessibilityLabel("\(spread.title). \(spread.summary)")
        .accessibilityHint("Selects this three-card spread")
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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var shufflePhase = 0
    @State private var previousVisualState: ReadingVisualState?
    @State private var shuffleTask: Task<Void, Never>?
    @AccessibilityFocusState private var focusedReadingPosition: Int?

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height && !dynamicTypeSize.isAccessibilitySize

            ZStack {
                CeremonialBackdrop()

                if isLandscape {
                    landscapeContent(size: proxy.size)
                } else {
                    portraitContent
                }
            }
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // Restoration and rotation establish a baseline without replaying motion or haptics.
            previousVisualState = visualState
        }
        .onChange(of: visualState) { newState in
            respondToDurableStateChange(newState)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase != .active {
                cancelTransientMotion()
            }
        }
        .onDisappear {
            cancelTransientMotion()
        }
    }

    private var portraitContent: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                positions(showLabels: model.layout == .threeCards)
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

    private func landscapeContent(size: CGSize) -> some View {
        let railWidth = min(max(size.width * 0.21, 148), 190)

        return HStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 10) {
                    HStack {
                        backButton
                        Spacer(minLength: 0)
                    }

                    VStack(spacing: 3) {
                        Text(model.layout?.title ?? AppLocalization.text("Reading"))
                            .font(.system(.title2, design: .serif, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }

                    if shouldShowDeck {
                        deck
                            .frame(maxHeight: model.layout == .oneCard ? 132 : 112)
                    }

                    actionArea
                }
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .frame(width: railWidth)

            positions(showLabels: model.layout == .threeCards)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var header: some View {
        ZStack(alignment: .leading) {
            backButton

            VStack(spacing: 4) {
                Text(model.layout?.title ?? AppLocalization.text("Reading"))
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

    private var backButton: some View {
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
        .accessibilityHint(
            AppLocalization.text(
                model.hasActiveReading ? "Returns to Read home" : "Returns to layout choice"
            )
        )
    }

    @ViewBuilder
    private func positions(showLabels: Bool) -> some View {
        if let layout = model.layout {
            HStack(spacing: layout == .oneCard ? 0 : 11) {
                ForEach(0..<layout.cardLimit, id: \.self) { index in
                    VStack(spacing: showLabels ? 4 : 0) {
                        if showLabels {
                            Text(positionTitle(at: index))
                                .font(.system(.caption, design: .serif, weight: .semibold))
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .frame(minHeight: 20)
                                .accessibilityHidden(true)
                        }
                        position(at: index, total: layout.cardLimit)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .accessibilityElement(children: .contain)
            .animation(
                usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.draw,
                value: model.session?.drawnCards.count ?? 0
            )
            .animation(
                usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.reveal,
                value: model.session?.drawnCards.map(\.isRevealed) ?? []
            )
        }
    }

    private func positionTitle(at index: Int) -> String {
        model.spread?.positionTitle(at: index)
            ?? AppLocalization.format("Card %d", index + 1)
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
                .transition(usesReducedMotion ? .opacity : .ceremonialCardReveal)
                .id("revealed-\(drawnCard.id.rawValue)")
                .accessibilityFocused($focusedReadingPosition, equals: index)
            } else {
                FaceDownReadingPosition(
                    position: index + 1,
                    total: total,
                    positionName: positionTitle(at: index),
                    onReveal: { model.reveal(drawnCard.id) }
                )
                .disabled(model.isBusy)
                .transition(drawTransition)
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
        guard let session = model.session, let layout = model.layout else { return false }
        return session.drawnCards.count < layout.cardLimit
    }

    private var deck: some View {
        let remaining = model.session?.remainingCardCount ?? 78
        return CeremonialShufflingDeck(
            phase: shufflePhase,
            reduceMotion: usesReducedMotion,
            spokenLabel: model.isReadyToShuffle
                ? AppLocalization.text("Complete deck, not yet shuffled")
                : AppLocalization.format("Deck with %d cards remaining", remaining)
        )
    }

    private var drawTransition: AnyTransition {
        if usesReducedMotion { return .opacity }
        let comesFromSide = verticalSizeClass == .compact
        return .asymmetric(
            insertion: .offset(
                x: comesFromSide ? -80 : 0,
                y: comesFromSide ? 0 : 70
            )
            .combined(with: .scale(scale: 0.92))
            .combined(with: .opacity),
            removal: .opacity
        )
    }

    private var usesReducedMotion: Bool {
        reduceMotion || voiceOverEnabled
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
        guard let previousVisualState else {
            self.previousVisualState = newState
            return
        }
        self.previousVisualState = newState

        // A commit may finish after the app becomes inactive. Record its state without replaying
        // presentation or haptics when the user returns.
        guard scenePhase == .active else { return }

        if previousVisualState.sessionID == nil,
           newState.sessionID != nil,
           newState.drawnCardIDs.isEmpty {
            CeremonialHaptics.shuffled()
            runShuffleSettle()
            return
        }

        if newState.drawnCardIDs.count > previousVisualState.drawnCardIDs.count {
            CeremonialHaptics.drawn()
            moveVoiceOverFocus(to: newState.drawnCardIDs.count - 1)
            return
        }

        for index in newState.revealed.indices where previousVisualState.revealed.indices.contains(index) {
            if !previousVisualState.revealed[index], newState.revealed[index] {
                CeremonialHaptics.revealed()
                moveVoiceOverFocus(to: index)
                return
            }
            if previousVisualState.revealed[index], !newState.revealed[index] {
                CeremonialHaptics.concealed()
                moveVoiceOverFocus(to: index)
                return
            }
        }
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
    private func runShuffleSettle() {
        shuffleTask?.cancel()
        shuffleTask = Task { @MainActor in
            withAnimation(usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.shuffle) {
                shufflePhase = 1
            }
            try? await Task.sleep(nanoseconds: usesReducedMotion ? 120_000_000 : 160_000_000)
            guard !Task.isCancelled else { return }

            if !usesReducedMotion {
                withAnimation(CeremonialMotion.shuffle) {
                    shufflePhase = 2
                }
                try? await Task.sleep(nanoseconds: 160_000_000)
                guard !Task.isCancelled else { return }
            }

            withAnimation(usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.shuffle) {
                shufflePhase = 0
            }
        }
    }

    @MainActor
    private func cancelTransientMotion() {
        shuffleTask?.cancel()
        shuffleTask = nil
        shufflePhase = 0
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
        if model.isReadyToShuffle { return AppLocalization.text("Shuffle Deck") }
        guard let session = model.session, let layout = model.layout,
              session.drawnCards.count < layout.cardLimit else { return nil }
        if session.drawnCards.isEmpty { return AppLocalization.text("Draw Card") }
        return session.drawnCards.count + 1 == layout.cardLimit
            ? AppLocalization.text("Draw Final Card")
            : AppLocalization.text("Draw Next Card")
    }

    private var statusText: String {
        if model.isReadyToShuffle { return AppLocalization.text("Ready to shuffle") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return AppLocalization.text("Deck shuffled") }
        if layout == .oneCard {
            return session.drawnCards[0].isRevealed
                ? AppLocalization.text("Card revealed")
                : AppLocalization.text("Card drawn")
        }
        if session.drawnCards.count == layout.cardLimit,
           session.drawnCards.allSatisfy(\.isRevealed) {
            return AppLocalization.text("All cards revealed")
        }
        return AppLocalization.format(
            "%d of %d drawn",
            session.drawnCards.count,
            layout.cardLimit
        )
    }

    private var instructionText: String {
        if model.isReadyToShuffle { return AppLocalization.text("Shuffle before drawing.") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return AppLocalization.text("Draw when you're ready.") }
        if session.drawnCards.count == layout.cardLimit,
           session.drawnCards.allSatisfy(\.isRevealed) {
            return layout == .oneCard
                ? AppLocalization.text("Tap the card to explore its meaning.")
                : AppLocalization.text("Tap a card to explore its meaning.")
        }
        if layout == .oneCard, session.drawnCards.count == 1 {
            return AppLocalization.text("Tap the card to reveal it.")
        }
        return AppLocalization.text("Tap a face-down card to turn it over.")
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
