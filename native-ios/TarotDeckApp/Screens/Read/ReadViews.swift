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

            if let session = model.session, let layout = model.layout {
                activeHome(layout: layout, session: session)
            } else {
                emptyHome
            }
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
            let usableHeight = max(proxy.size.height - homeControlClearance, 1)
            let regularDeckWidth = min(
                max(proxy.size.width - 64, 220),
                320,
                max(usableHeight - 180, 260) * CeremonialObsidianTheme.deckAspectRatio
            )
            let compactDeckWidth = min(
                max(proxy.size.width - 80, 180),
                238,
                max(usableHeight - 150, 220) * CeremonialObsidianTheme.deckAspectRatio
            )

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Color.clear
                        .frame(
                            width: homeControlClearance,
                            height: homeControlClearance
                        )
                        .accessibilityHidden(true)
                }

                Group {
                    if dynamicTypeSize.isAccessibilitySize {
                        ScrollView {
                            emptyHomeComposition(
                                deckWidth: min(compactDeckWidth, 210),
                                compact: true
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        ViewThatFits(in: .vertical) {
                            emptyHomeComposition(deckWidth: regularDeckWidth, compact: false)
                            emptyHomeComposition(deckWidth: compactDeckWidth, compact: true)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func emptyHomeComposition(deckWidth: CGFloat, compact: Bool) -> some View {
        VStack(spacing: compact ? 10 : 16) {
            Text("Tarot Deck")
                .font(.system(compact ? .title : .largeTitle, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Button {
                model.requestNewReading()
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
                .frame(width: deckWidth, height: deckWidth / CeremonialObsidianTheme.deckAspectRatio)
                .shadow(color: CeremonialObsidianTheme.brightGold.opacity(0.23), radius: 18)
            }
            .buttonStyle(.plain)
            .disabled(model.isBusy)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Start a Reading")
            .accessibilityHint("Complete 78-card tarot deck")

            Text("Tap the deck to begin")
                .font(.system(compact ? .body : .title3, design: .serif, weight: .medium))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, compact ? 24 : 38)
        .padding(.bottom, compact ? 18 : 22)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func activeHome(layout: ReadingLayout, session: DeckSession) -> some View {
        ScrollView {
            VStack(spacing: 18) {
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
                    .frame(maxWidth: 260)
                    .padding(.vertical, 4)

                activeReading(layout: layout, session: session)
            }
            .frame(maxWidth: 680)
            .padding(.horizontal, 26)
            .padding(.top, 70)
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
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
        return presentedCount < layout.cardLimit
    }

    private var canUseDeck: Bool {
        if model.isReadyToShuffle { return true }
        guard let session = model.session, let layout = model.layout else { return false }
        return session.drawnCards.count < layout.cardLimit
    }

    private var deckControl: some View {
        let remaining = model.session?.remainingCardCount ?? 78
        return Button {
            if model.isReadyToShuffle {
                model.shuffleDeck()
            } else {
                model.drawCard()
            }
        } label: {
            CeremonialShufflingDeck(
                phase: shufflePhase,
                reduceMotion: usesReducedMotion,
                spokenLabel: model.isReadyToShuffle
                    ? AppLocalization.text("Complete deck, not yet shuffled")
                    : AppLocalization.format("Deck with %d cards remaining", remaining)
            )
            .contentShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        }
        .buttonStyle(CeremonialDeckButtonStyle(usesReducedMotion: usesReducedMotion))
        .disabled(interactionLocked || !canUseDeck)
        .accessibilityHint(
            AppLocalization.text(
                model.isReadyToShuffle ? "Shuffles the deck" : "Draws the next card"
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
        VStack(spacing: 12) {
            Text(instructionText)
                .font(.body)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("End Reading") {
                model.requestEndReading()
            }
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(CeremonialObsidianTheme.brightGold)
            .frame(minWidth: 44, minHeight: 44)
            .buttonStyle(.plain)
            .disabled(interactionLocked)
        }
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
        if model.isReadyToShuffle { return AppLocalization.text("Tap the deck to shuffle.") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return AppLocalization.text("Tap the deck to draw.") }
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
