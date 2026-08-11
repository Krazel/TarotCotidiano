import SwiftUI
import TarotDeckCore
import UIKit

struct ReadRootView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
    @ObservedObject var languageStore: AppLanguageStore
    let inspectRevealedCard: (String) -> Void
    let openReadingTutorial: (String?, Bool) -> Void
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
                        openSettings: { showsSettings = true },
                        openReadingTutorial: { articleID in
                            openReadingTutorial(articleID, false)
                        }
                    )

                case .table:
                    ReadingTableView(
                        model: model,
                        content: content,
                        openReadingTutorial: { articleID in
                            openReadingTutorial(articleID, true)
                        },
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

private enum ReadingChoiceStage: Equatable {
    case count
    case style
}

private struct ReadHomeView: View {
    @ObservedObject var model: ReadFlowModel
    let openSettings: () -> Void
    let openReadingTutorial: (String?) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var choiceStage: ReadingChoiceStage?
    @State private var stagedPreset: ReadingPreset?
    @AccessibilityFocusState private var selectorFocused: Bool

    var body: some View {
        ZStack {
            CeremonialBackdrop()
            emptyHome
                .accessibilityHidden(choiceStage != nil)

            if let choiceStage {
                ReadingChoiceOverlay(
                    stage: choiceStage,
                    stagedPreset: stagedPreset,
                    chooseCount: chooseCount,
                    chooseStyle: chooseStyle,
                    showCountInformation: showCountInformation,
                    showStyleInformation: showStyleInformation,
                    goBack: { present(.count) },
                    cancel: cancelChoices
                )
                .transition(
                    reduceMotion
                        ? .opacity
                        : .opacity.combined(with: .scale(scale: 0.98, anchor: .bottom))
                )
                .zIndex(2)
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
            .padding(.top, 8)
            .padding(.trailing, 14)
            .disabled(choiceStage != nil)
            .opacity(choiceStage == nil ? 1 : 0.38)
            .accessibilityHidden(choiceStage != nil)
            .accessibilityLabel("Settings")
            .accessibilityHint("Opens app settings without changing your reading")
        }
        .animation(reduceMotion ? CeremonialMotion.reduced : CeremonialMotion.screen, value: choiceStage)
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var emptyHome: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height && !dynamicTypeSize.isAccessibilitySize
            let isSmallPortrait = proxy.size.height < 620
            let needsSmallPortraitScroll = !isLandscape && isSmallPortrait &&
                (dynamicTypeSize == .xxLarge || dynamicTypeSize == .xxxLarge)

            if dynamicTypeSize.isAccessibilitySize || needsSmallPortraitScroll {
                ScrollView {
                    portraitHomeComposition(
                        size: CGSize(
                            width: proxy.size.width,
                            height: max(proxy.size.height, dynamicTypeSize.isAccessibilitySize ? 860 : 640)
                        ),
                        compact: true
                    )
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            } else if isLandscape {
                landscapeHomeComposition(size: proxy.size)
            } else {
                portraitHomeComposition(size: proxy.size, compact: isSmallPortrait)
            }
        }
    }

    private func portraitHomeComposition(size: CGSize, compact: Bool) -> some View {
        let verticalReservation: CGFloat = compact ? 164 : 208
        let availableDeckHeight = max(size.height - verticalReservation, 0)
        let horizontalDeckLimit = max(size.width - 48, 0)
        let deckWidth = min(
            horizontalDeckLimit,
            compact ? 292 : 330,
            availableDeckHeight * CeremonialObsidianTheme.deckAspectRatio
        )

        return VStack(spacing: compact ? 10 : 15) {
            homeTitle(compact: compact, protectsGear: true)
            compactSelectorButton(compact: compact)
            heroDeck(width: deckWidth)
            beginCue(compact: compact)
        }
        .padding(.top, compact ? 8 : 18)
        .padding(.horizontal, 24)
        .padding(.bottom, compact ? 12 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func landscapeHomeComposition(size: CGSize) -> some View {
        let landscapeVerticalReservation: CGFloat = 76
        let availableDeckHeight = max(size.height - landscapeVerticalReservation, 0)
        let deckWidth = min(
            max(size.width * 0.32, 0),
            276,
            availableDeckHeight * CeremonialObsidianTheme.deckAspectRatio
        )

        return HStack(spacing: 20) {
            VStack(spacing: 18) {
                homeTitle(compact: false, protectsGear: false)
                compactSelectorButton(compact: true)
            }
            .frame(width: size.width * 0.48)

            VStack(spacing: 7) {
                heroDeck(width: deckWidth)
                beginCue(compact: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.trailing, 36)
        }
        .padding(.top, 8)
        .padding(.leading, 24)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func homeTitle(compact: Bool, protectsGear: Bool) -> some View {
        Text("Tarot Deck")
            .font(.system(compact ? .title : .largeTitle, design: .serif, weight: .semibold))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, protectsGear ? 48 : 0)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private func compactSelectorButton(compact: Bool) -> some View {
        Button(action: openChoices) {
            HStack(spacing: 12) {
                ReadingCountGlyph(
                    count: model.selectedPreset == .oneCard ? 1 : 3,
                    cardWidth: compact ? 20 : 23
                )
                .frame(width: compact ? 32 : 38, height: compact ? 34 : 40)
                .accessibilityHidden(true)

                Text(model.selectedPreset.title)
                    .font(.system(compact ? .body : .title3, design: .serif, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.down")
                    .font(.system(.body, weight: .semibold))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, compact ? 16 : 20)
            .frame(width: compact ? 250 : 292, height: compact ? 50 : 56)
            .background {
                Capsule()
                    .fill(CeremonialObsidianTheme.cardSurface.opacity(0.96))
                    .overlay {
                        Capsule()
                            .stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1.5)
                    }
                    .shadow(color: CeremonialObsidianTheme.brightGold.opacity(0.18), radius: 10)
            }
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy || choiceStage != nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reading preset")
        .accessibilityValue(model.selectedPreset.title)
        .accessibilityHint("Opens visual reading choices")
        .accessibilityFocused($selectorFocused)
    }

    private func heroDeck(width: CGFloat) -> some View {
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
            .shadow(color: CeremonialObsidianTheme.brightGold.opacity(0.28), radius: 20)
        }
        .buttonStyle(.plain)
        .disabled(model.isBusy || choiceStage != nil)
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

    private func openChoices() {
        selectorFocused = false
        stagedPreset = model.selectedPreset
        present(.count)
    }

    private func chooseCount(_ count: Int) {
        if count == 1 {
            model.selectPreset(.oneCard)
            dismissChoicesAndRestoreFocus()
        } else {
            if stagedPreset == .oneCard { stagedPreset = nil }
            present(.style)
        }
    }

    private func chooseStyle(_ preset: ReadingPreset) {
        guard preset != .oneCard else { return }
        stagedPreset = preset
        model.selectPreset(preset)
        dismissChoicesAndRestoreFocus()
    }

    private func showCountInformation(_ count: Int) {
        choiceStage = nil
        openReadingTutorial(count == 1 ? "one-card-focus" : nil)
    }

    private func showStyleInformation(_ preset: ReadingPreset) {
        choiceStage = nil
        openReadingTutorial(preset.tutorialArticleID)
    }

    private func cancelChoices() {
        stagedPreset = model.selectedPreset
        dismissChoicesAndRestoreFocus()
    }

    private func dismissChoicesAndRestoreFocus() {
        choiceStage = nil
        Task { @MainActor in
            selectorFocused = true
        }
    }

    private func present(_ stage: ReadingChoiceStage) {
        withAnimation(reduceMotion ? CeremonialMotion.reduced : CeremonialMotion.screen) {
            choiceStage = stage
        }
    }
}

private struct ReadingChoiceOverlay: View {
    let stage: ReadingChoiceStage
    let stagedPreset: ReadingPreset?
    let chooseCount: (Int) -> Void
    let chooseStyle: (ReadingPreset) -> Void
    let showCountInformation: (Int) -> Void
    let showStyleInformation: (ReadingPreset) -> Void
    let goBack: () -> Void
    let cancel: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var headingFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height && !dynamicTypeSize.isAccessibilitySize
            let portraitPanelHeight = max(
                proxy.size.height * (stage == .count ? 0.54 : 0.82),
                0
            )
            let landscapePanelHeight = max(
                min(proxy.size.height - 16, stage == .count ? 310 : 350),
                0
            )

            ZStack {
                Color.black.opacity(0.58)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: cancel)
                    .accessibilityHidden(true)

                if isLandscape {
                    selectorPanel(compact: true)
                        .frame(
                            width: min(proxy.size.width * (stage == .count ? 0.56 : 0.72), stage == .count ? 620 : 820),
                            height: landscapePanelHeight
                        )
                } else {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        selectorPanel(compact: false)
                            .frame(maxWidth: .infinity)
                            .frame(height: portraitPanelHeight)
                    }
                }
            }
        }
        .onAppear {
            Task { @MainActor in headingFocused = true }
        }
        .onChange(of: stage) { _ in
            Task { @MainActor in headingFocused = true }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private func selectorPanel(compact: Bool) -> some View {
        VStack(spacing: compact ? 10 : 16) {
            selectorHeader(compact: compact)

            Group {
                if stage == .count {
                    countChoices(compact: compact)
                } else {
                    styleChoices(compact: compact)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, compact ? 18 : 20)
        .padding(.top, compact ? 12 : 16)
        .padding(.bottom, compact ? 14 : 22)
        .background {
            RoundedRectangle(cornerRadius: compact ? 24 : 30)
                .fill(CeremonialObsidianTheme.cardSurface.opacity(0.995))
                .overlay {
                    RoundedRectangle(cornerRadius: compact ? 24 : 30)
                        .stroke(CeremonialObsidianTheme.gold.opacity(0.72), lineWidth: 1.5)
                }
                .shadow(color: .black.opacity(0.72), radius: 24, y: 10)
        }
        .padding(.horizontal, compact ? 0 : 8)
    }

    private func selectorHeader(compact: Bool) -> some View {
        HStack(spacing: 10) {
            if stage == .style {
                selectorIconButton(systemName: "chevron.left", action: goBack)
                    .accessibilityLabel("Back")
                    .accessibilityHint("Returns to one or three card choices")
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
            }

            Text(AppLocalization.text(stage == .count ? "Choose Your Reading" : "Choose the Style"))
                .font(.system(compact ? .title2 : .title, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.76)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($headingFocused)

            selectorIconButton(systemName: "xmark", action: cancel)
                .accessibilityLabel("Close")
                .accessibilityHint("Closes reading choices without changing the selection")
        }
    }

    private func selectorIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(.title3, weight: .semibold))
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .overlay {
                            Circle().stroke(CeremonialObsidianTheme.gold.opacity(0.42), lineWidth: 1)
                        }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func countChoices(compact: Bool) -> some View {
        HStack(spacing: compact ? 12 : 14) {
            countChoice(count: 1, compact: compact)
            countChoice(count: 3, compact: compact)
        }
    }

    private func countChoice(count: Int, compact: Bool) -> some View {
        let selected = count == 1
            ? stagedPreset == .oneCard
            : stagedPreset.map { $0 != .oneCard } ?? false

        return ZStack {
            choiceTileBackground(selected: selected, cornerRadius: 22)

            Button {
                chooseCount(count)
            } label: {
                VStack(spacing: compact ? 6 : 12) {
                    ReadingCountGlyph(count: count, cardWidth: compact ? 52 : 70)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityHidden(true)

                    Text(AppLocalization.text(count == 1 ? "One Card" : "Three Cards"))
                        .font(.system(compact ? .body : .title3, design: .serif, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
                .padding(compact ? 10 : 14)
                .padding(.top, 22)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(AppLocalization.text(count == 1 ? "One Card" : "Three Cards")))
            .accessibilityHint(Text(AppLocalization.text(count == 1 ? "Selects one card" : "Opens five visual three-card styles")))
            .accessibilityAddTraits(selected ? .isSelected : [])

            VStack {
                HStack {
                    informationButton {
                        showCountInformation(count)
                    }
                    .accessibilityLabel(AppLocalization.format(
                        "Learn how to use %@",
                        AppLocalization.text(count == 1 ? "One Card" : "Three Cards")
                    ))
                    Spacer()
                    selectionMark(selected: selected)
                }
                Spacer()
            }
            .padding(8)
        }
    }

    private func styleChoices(compact: Bool) -> some View {
        let pairedPresets: [ReadingPreset] = [
            .pastPresentFuture,
            .situationChallengeAdvice,
            .relationship,
            .open
        ]

        return Group {
            if compact {
                HStack(spacing: 10) {
                    ForEach(pairedPresets + [.freeform]) { preset in
                        styleChoice(preset, compact: true)
                    }
                }
            } else if dynamicTypeSize.isAccessibilitySize {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(pairedPresets + [.freeform]) { preset in
                            styleChoice(preset, compact: false)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        styleChoice(.pastPresentFuture, compact: false)
                        styleChoice(.situationChallengeAdvice, compact: false)
                    }
                    HStack(spacing: 10) {
                        styleChoice(.relationship, compact: false)
                        styleChoice(.open, compact: false)
                    }
                    styleChoice(.freeform, compact: false)
                }
            }
        }
    }

    private func styleChoice(_ preset: ReadingPreset, compact: Bool) -> some View {
        let selected = preset == stagedPreset

        return ZStack {
            choiceTileBackground(selected: selected, cornerRadius: 20)

            Button {
                chooseStyle(preset)
            } label: {
                VStack(spacing: compact ? 5 : 9) {
                    ThreeCardStyleGlyph(preset: preset, cardWidth: compact ? 36 : 34)
                        .frame(height: compact ? 60 : 58)
                        .accessibilityHidden(true)

                    Text(preset.title)
                        .font(.system(compact ? .subheadline : .body, design: .serif, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        .minimumScaleFactor(0.70)
                        .frame(maxWidth: .infinity)

                    if preset == .open {
                        Text(preset.selectorDetail)
                            .font(.caption)
                            .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    } else if preset == .freeform {
                        Text(AppLocalization.text("No assigned positions"))
                            .font(.caption)
                            .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                    }
                }
                .padding(.horizontal, compact ? 8 : 10)
                .padding(.vertical, compact ? 7 : 10)
                .padding(.top, 18)
                .frame(maxWidth: .infinity, minHeight: compact ? 108 : 116, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(preset.title)
            .accessibilityValue(preset == .open ? preset.selectorDetail : "")
            .accessibilityHint("Selects this reading preset")
            .accessibilityAddTraits(selected ? .isSelected : [])

            VStack {
                HStack {
                    Spacer()
                    informationButton {
                        showStyleInformation(preset)
                    }
                    .accessibilityLabel(AppLocalization.format("Learn how to use %@", preset.title))
                }
                Spacer()
            }
            .padding(8)

            if selected {
                VStack {
                    HStack {
                        selectionMark(selected: true)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
    }

    private func informationButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "info")
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 28, height: 28)
                .background {
                    Circle()
                        .fill(Color.black.opacity(0.28))
                        .overlay {
                            Circle().stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1)
                        }
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the matching reading tutorial without changing your selection")
    }

    private func choiceTileBackground(selected: Bool, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.black.opacity(selected ? 0.28 : 0.18))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        selected ? CeremonialObsidianTheme.brightGold : CeremonialObsidianTheme.gold.opacity(0.36),
                        lineWidth: selected ? 1.8 : 1
                    )
            }
            .shadow(color: selected ? CeremonialObsidianTheme.brightGold.opacity(0.18) : .clear, radius: 8)
    }

    private func selectionMark(selected: Bool) -> some View {
        Image(systemName: "checkmark")
            .font(.system(.body, weight: .bold))
            .foregroundStyle(CeremonialObsidianTheme.background)
            .frame(width: 34, height: 34)
            .background(Circle().fill(CeremonialObsidianTheme.brightGold))
            .opacity(selected ? 1 : 0)
            .accessibilityHidden(true)
    }
}

private struct ReadingCountGlyph: View {
    let count: Int
    let cardWidth: CGFloat

    var body: some View {
        HStack(spacing: count == 1 ? 0 : -cardWidth * 0.28) {
            ForEach(0..<count, id: \.self) { index in
                CeremonialCardBack(spokenLabel: "")
                    .frame(width: cardWidth)
                    .rotationEffect(count == 1 ? .zero : .degrees(Double(index - 1) * 9))
            }
        }
    }
}

private struct ThreeCardStyleGlyph: View {
    let preset: ReadingPreset
    let cardWidth: CGFloat

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<3, id: \.self) { index in
                CeremonialCardBack(spokenLabel: "")
                    .frame(width: cardWidth)
                    .rotationEffect(rotation(for: index))
                    .offset(y: verticalOffset(for: index))
            }
        }
    }

    private var spacing: CGFloat {
        preset == .open ? -cardWidth * 0.28 : cardWidth * 0.20
    }

    private func rotation(for index: Int) -> Angle {
        switch preset {
        case .relationship, .open:
            return .degrees(Double(index - 1) * (preset == .open ? 10 : 7))
        default:
            return .zero
        }
    }

    private func verticalOffset(for index: Int) -> CGFloat {
        switch preset {
        case .situationChallengeAdvice:
            return index == 1 ? -8 : 4
        case .relationship:
            return index == 1 ? -5 : 3
        case .open:
            return index == 1 ? -4 : 3
        default:
            return 0
        }
    }
}

private struct ReadingTableView: View {
    @ObservedObject var model: ReadFlowModel
    let content: TarotContent
    let openReadingTutorial: (String?) -> Void
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
                    readingInfoButton
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
                    .accessibilityHidden(!shouldShowDeck)

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

            readingInfoButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 44)

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
            .padding(.horizontal, 96)
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

    private var readingInfoButton: some View {
        Button {
            guard let layout = model.layout else { return }
            let articleID = ReadingPreset.resolved(
                layout: layout,
                spread: model.spread
            ).tutorialArticleID
            openReadingTutorial(articleID)
        } label: {
            Image(systemName: "info")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 28, height: 28)
                .overlay {
                    Circle().stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1)
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(interactionLocked)
        .accessibilityLabel("About This Reading")
        .accessibilityHint(
            AppLocalization.format(
                "Opens the %@ tutorial without changing your reading.",
                model.readingTitle
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
                        .accessibilityHidden(!shouldShowDeck)
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
        if model.canShuffleDeck { return true }
        if dealingPosition != nil { return true }
        return false
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
        model.canShuffleDeck
    }

    private var deckControl: some View {
        return Button {
            model.shuffleDeck()
        } label: {
            CeremonialShufflingDeck(
                phase: shufflePhase,
                reduceMotion: usesReducedMotion,
                spokenLabel: model.isReadyToShuffle
                    ? AppLocalization.text("Unshuffled tarot deck")
                    : AppLocalization.text("Shuffled tarot deck")
            )
            .contentShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        }
        .buttonStyle(CeremonialDeckButtonStyle(usesReducedMotion: usesReducedMotion))
        .disabled(interactionLocked || !canUseDeck)
        .accessibilityHint(
            AppLocalization.text(
                model.isReadyToShuffle
                    ? "Shuffles all 78 cards"
                    : "Shuffles all 78 cards again"
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

        if newState.sessionID != nil,
           baseline.sessionID != newState.sessionID,
           baseline.drawnCardIDs.isEmpty,
           newState.drawnCardIDs.isEmpty {
            visualBaseline = newState
            runShuffleChoreography()
            return
        }

        if newState.drawnCardIDs.count > baseline.drawnCardIDs.count {
            runDealSequence(
                from: baseline.drawnCardIDs.count,
                to: newState.drawnCardIDs.count,
                target: newState
            )
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
            try? await Task.sleep(nanoseconds: 110_000_000)
            guard presentationIsCurrent(token) else { return }

            withAnimation(CeremonialMotion.cut) {
                shufflePhase = 2
            }
            try? await Task.sleep(nanoseconds: 170_000_000)
            guard presentationIsCurrent(token) else { return }

            withAnimation(CeremonialMotion.interleave) {
                shufflePhase = 3
            }
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard presentationIsCurrent(token) else { return }

            withAnimation(CeremonialMotion.riffle) {
                shufflePhase = 4
            }
            try? await Task.sleep(nanoseconds: 210_000_000)
            guard presentationIsCurrent(token) else { return }

            withAnimation(CeremonialMotion.shuffleSettle) {
                shufflePhase = 5
            }
            try? await Task.sleep(nanoseconds: 190_000_000)
            guard presentationIsCurrent(token) else { return }
            shufflePhase = 0
            finishPresentation(token)
            CeremonialHaptics.shuffled()
        }
    }

    @MainActor
    private func runDealSequence(from start: Int, to end: Int, target: ReadingVisualState) {
        startPresentation { token in
            for position in start..<end {
                dealingPosition = position
                dealProgress = 0
                await Task.yield()
                guard presentationIsCurrent(token) else { return }

                withAnimation(usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.deal) {
                    dealProgress = 1
                }
                try? await Task.sleep(
                    nanoseconds: usesReducedMotion ? 120_000_000 : 310_000_000
                )
                guard presentationIsCurrent(token) else { return }

                visualBaseline = ReadingVisualState(
                    sessionID: target.sessionID,
                    drawnCardIDs: Array(target.drawnCardIDs.prefix(position + 1)),
                    revealed: Array(target.revealed.prefix(position + 1))
                )
                CeremonialHaptics.drawn()
            }
            dealingPosition = nil
            dealProgress = 0
            visualBaseline = target
            finishPresentation(token)
            if voiceOverEnabled {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: AppLocalization.text(
                        end == 1
                            ? "One card dealt face down"
                            : "Three cards dealt face down"
                    )
                )
            }
            moveVoiceOverFocus(to: max(end - 1, 0))
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

            if model.isReadyToShuffle || model.isReadyToDeal {
                Button("Deal") {
                    model.dealCards()
                }
                .buttonStyle(CeremonialPrimaryButtonStyle())
                .disabled(interactionLocked || !model.isReadyToDeal)
                .accessibilityHint(
                    AppLocalization.text(
                        model.isReadyToDeal
                            ? (model.layout == .oneCard
                                ? "Deals one card face down"
                                : "Deals three cards face down")
                            : "Shuffle before dealing."
                    )
                )
            }
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
        if session.drawnCards.isEmpty {
            return AppLocalization.text("Tap again to shuffle, or deal when ready.")
        }
        if presentedReadingIsCompleteAndRevealed {
            return ""
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
