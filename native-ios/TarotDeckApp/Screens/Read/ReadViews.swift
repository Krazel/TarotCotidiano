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
        .onChange(of: model.customLibraryRequestCount) { _ in
            guard model.surface == .home else { return }
            showsSettings = false
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
    @State private var stagedCustomSelected = false
    @State private var showsCustomSpreads = false
    @State private var handledCustomLibraryRequestCount = 0
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
                    stagedCustomSelected: stagedCustomSelected,
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
        .sheet(isPresented: $showsCustomSpreads) {
            NavigationStack {
                CustomSpreadLibraryView(model: model) { definition in
                    model.selectCustomSpread(definition)
                    showsCustomSpreads = false
                    dismissChoicesAndRestoreFocus()
                }
            }
            .presentationDragIndicator(.visible)
        }
        .onChange(of: model.customLibraryRequestCount) { _ in
            presentRequestedCustomLibraryIfNeeded()
        }
        .onAppear {
            presentRequestedCustomLibraryIfNeeded()
        }
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
                ReadingKindGlyph(
                    kindCount: model.selectedCustomSpreadID == nil
                        ? model.selectedReadingCardCount
                        : 0,
                    cardWidth: compact ? 20 : 23
                )
                .frame(width: compact ? 32 : 38, height: compact ? 34 : 40)
                .accessibilityHidden(true)

                Text(model.selectedReadingTitle)
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
        .accessibilityValue(model.selectedReadingTitle)
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
        .accessibilityValue(model.selectedReadingTitle)
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
        stagedCustomSelected = model.selectedCustomSpreadID != nil
        stagedPreset = stagedCustomSelected ? nil : model.selectedPreset
        present(.count)
    }

    private func chooseCount(_ count: Int) {
        if count == 1 {
            model.selectPreset(.oneCard)
            dismissChoicesAndRestoreFocus()
        } else if count == 3 {
            if stagedPreset == .oneCard { stagedPreset = nil }
            stagedCustomSelected = false
            present(.style)
        } else if count == 6 {
            model.selectPreset(.sixCardGuidance)
            dismissChoicesAndRestoreFocus()
        } else {
            choiceStage = nil
            stagedCustomSelected = true
            showsCustomSpreads = true
        }
    }

    private func chooseStyle(_ preset: ReadingPreset) {
        guard preset != .oneCard else { return }
        stagedPreset = preset
        stagedCustomSelected = false
        model.selectPreset(preset)
        dismissChoicesAndRestoreFocus()
    }

    private func showCountInformation(_ count: Int) {
        choiceStage = nil
        if count == 0 {
            openReadingTutorial("create-custom-spread")
        } else {
            openReadingTutorial(count == 1 ? "one-card-focus" : (count == 6 ? "six-card-guidance" : nil))
        }
    }

    private func showStyleInformation(_ preset: ReadingPreset) {
        choiceStage = nil
        openReadingTutorial(preset.tutorialArticleID)
    }

    private func cancelChoices() {
        stagedCustomSelected = model.selectedCustomSpreadID != nil
        stagedPreset = stagedCustomSelected ? nil : model.selectedPreset
        dismissChoicesAndRestoreFocus()
    }

    private func dismissChoicesAndRestoreFocus() {
        choiceStage = nil
        Task { @MainActor in
            selectorFocused = true
        }
    }

    private func presentRequestedCustomLibraryIfNeeded() {
        guard model.customLibraryRequestCount > handledCustomLibraryRequestCount else { return }
        handledCustomLibraryRequestCount = model.customLibraryRequestCount
        choiceStage = nil
        showsCustomSpreads = true
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
    let stagedCustomSelected: Bool
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
                proxy.size.height * (stage == .count ? 0.68 : 0.82),
                0
            )
            let landscapePanelHeight = max(
                min(proxy.size.height - 16, 350),
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
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: compact ? 10 : 12), count: 2),
            spacing: compact ? 10 : 12
        ) {
            ForEach([1, 3, 6, 0], id: \.self) { count in
                countChoice(count: count, compact: compact)
            }
        }
    }

    private func countChoice(count: Int, compact: Bool) -> some View {
        let selected: Bool
        switch count {
        case 1: selected = stagedPreset == .oneCard
        case 3: selected = stagedPreset?.layout == .threeCards
        case 6: selected = stagedPreset == .sixCardGuidance
        default: selected = stagedCustomSelected
        }
        let title: String = {
            switch count {
            case 1: return AppLocalization.text("One Card")
            case 3: return AppLocalization.text("Three Cards")
            case 6: return AppLocalization.text("Six Cards")
            default: return AppLocalization.text("Custom")
            }
        }()

        return ZStack {
            choiceTileBackground(selected: selected, cornerRadius: 22)

            Button {
                chooseCount(count)
            } label: {
                VStack(spacing: compact ? 6 : 12) {
                    ReadingKindGlyph(kindCount: count, cardWidth: compact ? 38 : 48)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityHidden(true)

                    Text(title)
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
            .accessibilityLabel(Text(title))
            .accessibilityHint(Text(AppLocalization.text(count == 3 ? "Opens five visual three-card styles" : "Selects this reading type")))
            .accessibilityAddTraits(selected ? .isSelected : [])

            VStack {
                HStack {
                    informationButton {
                        showCountInformation(count)
                    }
                    .accessibilityLabel(AppLocalization.format(
                        "Learn how to use %@",
                        title
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
                    informationButton {
                        showStyleInformation(preset)
                    }
                    .accessibilityLabel(AppLocalization.format("Learn how to use %@", preset.title))
                    Spacer()
                    selectionMark(selected: selected)
                }
                Spacer()
            }
            .padding(8)
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

private struct CustomSpreadLibraryView: View {
    @ObservedObject var model: ReadFlowModel
    let choose: (SpreadDefinition) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var editingDraft: SpreadDefinition?
    @State private var pendingDeletion: SpreadDefinition?

    var body: some View {
        ZStack {
            CeremonialBackdrop()
            ScrollView {
                LazyVStack(spacing: 14) {
                    if let draft = model.recoveredCustomDraft {
                        Button {
                            editingDraft = draft
                        } label: {
                            Label("Continue Draft", systemImage: "clock.arrow.circlepath")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(tileBackground(selected: false))
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Returns to the last saved custom spread draft")
                    }

                    if !model.customLibraryAvailable {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            Text("Custom spreads unavailable")
                                .font(.system(.title2, design: .serif, weight: .semibold))
                            Text("The saved custom spread file couldn't be read. Built-in readings are still available.")
                                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                                .multilineTextAlignment(.center)
                            Button("Try Again") { model.retryCustomSpreadLibrary() }
                                .buttonStyle(CeremonialPrimaryButtonStyle())
                        }
                        .padding(.vertical, 44)
                    } else if model.customSpreads.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "rectangle.stack.badge.plus")
                                .font(.system(size: 42, weight: .light))
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            Text("No Custom Spreads Yet")
                                .font(.system(.title2, design: .serif, weight: .semibold))
                            Text("Create a layout with 1 to 12 cards, your own position labels, and the arrangement you prefer.")
                                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 44)
                    } else {
                        ForEach(model.customSpreads) { definition in
                            customSpreadRow(definition)
                        }
                    }
                }
                .padding(20)
            }
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .navigationTitle("Custom Spreads")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editingDraft = model.makeCustomDraft()
                } label: {
                    Label("New Spread", systemImage: "plus")
                }
                .disabled(!model.customLibraryAvailable)
            }
        }
        .sheet(item: $editingDraft) { draft in
            NavigationStack {
                CustomSpreadEditorView(model: model, initialDraft: draft) { saved in
                    editingDraft = nil
                    choose(saved)
                }
            }
        }
        .alert(
            AppLocalization.text("Delete Custom Spread?"),
            isPresented: Binding(
                get: { pendingDeletion != nil },
                set: { if !$0 { pendingDeletion = nil } }
            ),
            presenting: pendingDeletion
        ) { definition in
            Button("Delete", role: .destructive) {
                model.deleteCustomSpread(definition.id)
                pendingDeletion = nil
            }
            Button("Cancel", role: .cancel) { pendingDeletion = nil }
        } message: { definition in
            Text(AppLocalization.format("Delete %@? This cannot be undone.", definition.name))
        }
    }

    private func customSpreadRow(_ definition: SpreadDefinition) -> some View {
        let selected = model.selectedCustomSpreadID == definition.id
        return ZStack {
            tileBackground(selected: selected)
            Button {
                choose(definition)
            } label: {
                VStack(spacing: 8) {
                    CustomSpreadMiniMap(positions: definition.positions)
                        .frame(height: 78)
                        .accessibilityHidden(true)
                    Text(definition.name)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                    Text(AppLocalization.format("%d cards", definition.cardCount))
                        .font(.subheadline)
                        .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                }
                .padding(.horizontal, 52)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(definition.name)
            .accessibilityValue(AppLocalization.format("%d cards", definition.cardCount))
            .accessibilityAddTraits(selected ? .isSelected : [])

            VStack {
                HStack {
                    Menu {
                        Button("Edit", systemImage: "pencil") {
                            editingDraft = model.beginEditingCustomSpread(definition.id)
                        }
                        Button("Duplicate", systemImage: "plus.square.on.square") {
                            _ = model.duplicateCustomSpread(definition.id)
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            pendingDeletion = definition
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(AppLocalization.format("Options for %@", definition.name))
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.body.bold())
                        .foregroundStyle(CeremonialObsidianTheme.background)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(CeremonialObsidianTheme.brightGold))
                        .opacity(selected ? 1 : 0)
                        .accessibilityHidden(true)
                }
                Spacer()
            }
            .padding(8)
        }
    }

    private func tileBackground(selected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(CeremonialObsidianTheme.cardSurface.opacity(0.96))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(selected ? CeremonialObsidianTheme.brightGold : CeremonialObsidianTheme.gold.opacity(0.38), lineWidth: selected ? 1.8 : 1)
            }
    }
}

private struct CustomSpreadEditorView: View {
    @ObservedObject var model: ReadFlowModel
    let onSaved: (SpreadDefinition) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var draft: SpreadDefinition
    @State private var originalDraft: SpreadDefinition
    @State private var undoStack: [SpreadDefinition] = []
    @State private var dragBaseline: SpreadDefinition?
    @State private var showsArrangeSheet = false
    @State private var confirmsDiscard = false

    init(
        model: ReadFlowModel,
        initialDraft: SpreadDefinition,
        onSaved: @escaping (SpreadDefinition) -> Void
    ) {
        self.model = model
        self.onSaved = onSaved
        _draft = State(initialValue: initialDraft)
        _originalDraft = State(initialValue: initialDraft)
    }

    var body: some View {
        ZStack {
            CeremonialBackdrop()
            ScrollView {
                VStack(spacing: 18) {
                    TextField("Spread Name", text: nameBinding)
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .textInputAutocapitalization(.words)
                        .padding(14)
                        .background(editorField)
                        .accessibilityLabel("Spread Name")

                    HStack {
                        Text("Cards")
                            .font(.headline)
                        Spacer()
                        Button { changeCardCount(by: -1) } label: {
                            Image(systemName: "minus").frame(width: 44, height: 44)
                        }
                        .disabled(draft.cardCount <= SpreadDefinition.minimumCardCount)
                        Text("\(draft.cardCount)")
                            .font(.title3.monospacedDigit().bold())
                            .frame(minWidth: 32)
                            .accessibilityLabel(AppLocalization.format("%d cards", draft.cardCount))
                        Button { changeCardCount(by: 1) } label: {
                            Image(systemName: "plus").frame(width: 44, height: 44)
                        }
                        .disabled(draft.cardCount >= SpreadDefinition.maximumCardCount)
                    }

                    spreadCanvas
                        .frame(height: 330)

                    HStack {
                        Button { showsArrangeSheet = true } label: {
                            Label("Arrange", systemImage: "square.grid.3x3")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(CeremonialObsidianTheme.brightGold)

                        Button {
                            undo()
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(CeremonialObsidianTheme.brightGold)
                        .disabled(undoStack.isEmpty)
                    }

                    VStack(spacing: 10) {
                        ForEach(draft.positions.sorted(by: { $0.order < $1.order })) { position in
                            if let index = draft.positions.firstIndex(where: { $0.id == position.id }) {
                                HStack(spacing: 10) {
                                    Text("\(index + 1)")
                                        .font(.caption.bold())
                                        .frame(width: 24, height: 24)
                                        .background(Circle().fill(CeremonialObsidianTheme.gold.opacity(0.35)))
                                    TextField("Position label", text: labelBinding(at: index))
                                        .textInputAutocapitalization(.sentences)
                                    Button { movePosition(from: index, by: -1) } label: {
                                        Image(systemName: "chevron.up").frame(width: 44, height: 44)
                                    }
                                    .disabled(index == 0)
                                    .accessibilityLabel("Move Position Earlier")
                                    Button { movePosition(from: index, by: 1) } label: {
                                        Image(systemName: "chevron.down").frame(width: 44, height: 44)
                                    }
                                    .disabled(index == draft.cardCount - 1)
                                    .accessibilityLabel("Move Position Later")
                                }
                                .padding(12)
                                .background(editorField)
                                .accessibilityElement(children: .contain)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .navigationTitle("Edit Spread")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    if draft == originalDraft { dismiss() } else { confirmsDiscard = true }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    normalizeOrder()
                    if model.saveCustomSpread(draft) { onSaved(draft) }
                }
                .disabled(!model.canSaveCustomSpread(draft))
            }
        }
        .sheet(isPresented: $showsArrangeSheet) {
            ArrangeSpreadSheet(cardCount: draft.cardCount) { columns in
                arrange(columns: columns)
                showsArrangeSheet = false
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Discard Changes?", isPresented: $confirmsDiscard) {
            Button("Discard", role: .destructive) {
                model.discardCustomDraft()
                dismiss()
            }
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("This custom spread has unsaved changes.")
        }
    }

    private var spreadCanvas: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.30))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(CeremonialObsidianTheme.gold.opacity(0.50), lineWidth: 1))

                ForEach(draft.positions) { position in
                    if let index = draft.positions.firstIndex(where: { $0.id == position.id }) {
                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(CeremonialObsidianTheme.cardSurface)
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1))
                                .frame(width: 44, height: 70)
                            Text("\(index + 1)")
                                .font(.caption2.bold())
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        }
                        .position(
                            x: CGFloat(position.point.x) * proxy.size.width,
                            y: CGFloat(position.point.y) * proxy.size.height
                        )
                        .gesture(
                            DragGesture(minimumDistance: 2)
                                .onChanged { value in
                                    if dragBaseline == nil {
                                        dragBaseline = draft
                                        pushUndo()
                                    }
                                    let candidate = SpreadPoint(
                                        x: min(max(Double(value.location.x / proxy.size.width), 0.08), 0.92),
                                        y: min(max(Double(value.location.y / proxy.size.height), 0.12), 0.88)
                                    )
                                    if pointIsAvailable(candidate, excluding: position.id) {
                                        draft.positions[index].point = candidate
                                    }
                                }
                                .onEnded { _ in
                                    dragBaseline = nil
                                    touchAndPersist()
                                }
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(
                            AppLocalization.format(
                                "Position %d, %@",
                                index + 1,
                                position.label.isEmpty ? AppLocalization.format("Card %d", index + 1) : position.label
                            )
                        )
                        .accessibilityHint("Drag or use the movement actions to reposition this card")
                        .accessibilityAction(named: Text("Move Left")) { moveCanvasPosition(id: position.id, dx: -0.05, dy: 0) }
                        .accessibilityAction(named: Text("Move Right")) { moveCanvasPosition(id: position.id, dx: 0.05, dy: 0) }
                        .accessibilityAction(named: Text("Move Up")) { moveCanvasPosition(id: position.id, dx: 0, dy: -0.05) }
                        .accessibilityAction(named: Text("Move Down")) { moveCanvasPosition(id: position.id, dx: 0, dy: 0.05) }
                    }
                }
            }
        }
    }

    private var editorField: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(CeremonialObsidianTheme.cardSurface.opacity(0.92))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(CeremonialObsidianTheme.gold.opacity(0.36), lineWidth: 1))
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: { draft.name },
            set: { value in
                pushUndo()
                draft.name = String(value.prefix(40))
                touchAndPersist()
            }
        )
    }

    private func labelBinding(at index: Int) -> Binding<String> {
        Binding(
            get: { draft.positions[index].label },
            set: { value in
                pushUndo()
                draft.positions[index].label = String(value.prefix(32))
                touchAndPersist()
            }
        )
    }

    private func changeCardCount(by delta: Int) {
        let newCount = min(max(draft.cardCount + delta, 1), 12)
        guard newCount != draft.cardCount else { return }
        pushUndo()
        var ordered = draft.positions.sorted { $0.order < $1.order }
        if delta > 0 {
            let point = nextAvailablePoint(for: newCount)
            ordered.append(SpreadPosition(order: ordered.count, label: "", point: point))
        } else {
            ordered.removeLast()
        }
        draft.positions = ordered.enumerated().map { index, position in
            var updated = position
            updated.order = index
            return updated
        }
        touchAndPersist()
    }

    private func arrange(columns: Int?) {
        pushUndo()
        let ordered = draft.positions.sorted { $0.order < $1.order }
        let arranged = SpreadDefinition.arrangedPositions(count: draft.cardCount, columns: columns)
        draft.positions = ordered.enumerated().map { index, position in
            var updated = position
            updated.order = index
            updated.point = arranged[index].point
            return updated
        }
        touchAndPersist()
    }

    private func movePosition(from index: Int, by offset: Int) {
        let destination = index + offset
        guard draft.positions.indices.contains(index), draft.positions.indices.contains(destination) else { return }
        pushUndo()
        var ordered = draft.positions.sorted { $0.order < $1.order }
        ordered.swapAt(index, destination)
        draft.positions = ordered.enumerated().map { newIndex, position in
            var updated = position
            updated.order = newIndex
            return updated
        }
        draft.updatedAt = Date()
        persistDraft()
    }

    private func pushUndo() {
        guard undoStack.last != draft else { return }
        undoStack.append(draft)
        if undoStack.count > 30 { undoStack.removeFirst() }
    }

    private func undo() {
        guard let previous = undoStack.popLast() else { return }
        withAnimation(reduceMotion ? CeremonialMotion.reduced : CeremonialMotion.screen) {
            draft = previous
        }
        persistDraft()
    }

    private func normalizeOrder() {
        let sorted = draft.positions.sorted { $0.order < $1.order }
        draft.positions = sorted.enumerated().map { index, position in
            var updated = position
            updated.order = index
            return updated
        }
        draft.updatedAt = Date()
    }

    private func touchAndPersist() {
        draft.updatedAt = Date()
        persistDraft()
    }

    private func persistDraft() {
        if (try? draft.validate()) != nil { model.updateCustomDraft(draft) }
    }

    private func pointIsAvailable(_ point: SpreadPoint, excluding id: UUID) -> Bool {
        draft.positions.filter { $0.id != id }.allSatisfy {
            hypot($0.point.x - point.x, $0.point.y - point.y) >= SpreadDefinition.minimumPointSeparation
        }
    }

    private func nextAvailablePoint(for count: Int) -> SpreadPoint {
        let preferred = SpreadDefinition.arrangedPositions(count: count).map(\.point)
        let candidates = preferred + (1...4).flatMap { columns in
            SpreadDefinition.arrangedPositions(count: 12, columns: columns).map(\.point)
        }
        let scan = (1...11).flatMap { row in
            (1...11).map { column in
                SpreadPoint(x: Double(column) / 12.0, y: Double(row) / 12.0)
            }
        }
        return (candidates + scan).first { candidate in
            draft.positions.allSatisfy {
                hypot($0.point.x - candidate.x, $0.point.y - candidate.y) >= SpreadDefinition.minimumPointSeparation
            }
        } ?? SpreadPoint(x: 0.08, y: 0.12)
    }

    private func moveCanvasPosition(id: UUID, dx: Double, dy: Double) {
        guard let index = draft.positions.firstIndex(where: { $0.id == id }) else { return }
        let current = draft.positions[index].point
        let candidate = SpreadPoint(
            x: min(max(current.x + dx, 0.08), 0.92),
            y: min(max(current.y + dy, 0.12), 0.88)
        )
        guard pointIsAvailable(candidate, excluding: id) else { return }
        pushUndo()
        draft.positions[index].point = candidate
        touchAndPersist()
    }
}

private struct ArrangeSpreadSheet: View {
    let cardCount: Int
    let choose: (Int?) -> Void

    private let options: [(String, Int?)] = [
        ("Automatic", nil), ("One per row", 1), ("Two per row", 2),
        ("Three per row", 3), ("Four per row", 4)
    ]

    var body: some View {
        ZStack {
            CeremonialBackdrop()
            VStack(spacing: 18) {
                Text("Arrange Cards")
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                        Button { choose(option.1) } label: {
                            VStack(spacing: 10) {
                                CustomSpreadMiniMap(
                                    positions: SpreadDefinition.arrangedPositions(
                                        count: cardCount,
                                        columns: option.1
                                    )
                                )
                                .frame(height: 70)
                                Text(AppLocalization.text(option.0))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity, minHeight: 112)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 16).fill(CeremonialObsidianTheme.cardSurface))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
    }
}

private struct CustomSpreadMiniMap: View {
    let positions: [SpreadPosition]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(positions) { position in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(CeremonialObsidianTheme.cardSurface)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(CeremonialObsidianTheme.gold, lineWidth: 0.8))
                        .frame(width: 18, height: 30)
                        .position(
                            x: CGFloat(position.point.x) * proxy.size.width,
                            y: CGFloat(position.point.y) * proxy.size.height
                        )
                }
            }
        }
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

private struct ReadingKindGlyph: View {
    let kindCount: Int
    let cardWidth: CGFloat

    @ViewBuilder
    var body: some View {
        switch kindCount {
        case 0:
            CustomReadingKindGlyph(cardWidth: cardWidth)
        case 6:
            SixCardReadingKindGlyph(cardWidth: cardWidth * 0.52)
        case 1:
            ReadingCountGlyph(count: 1, cardWidth: cardWidth)
        default:
            ReadingCountGlyph(count: 3, cardWidth: cardWidth)
        }
    }
}

private struct SixCardReadingKindGlyph: View {
    let cardWidth: CGFloat

    var body: some View {
        VStack(spacing: cardWidth * 0.18) {
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: cardWidth * 0.20) {
                    ForEach(0..<3, id: \.self) { _ in
                        CeremonialCardBack(spokenLabel: "")
                            .frame(width: cardWidth)
                    }
                }
            }
        }
    }
}

private struct CustomReadingKindGlyph: View {
    let cardWidth: CGFloat

    var body: some View {
        let outlineWidth = cardWidth * 0.72
        let outlineHeight = outlineWidth / CeremonialObsidianTheme.deckAspectRatio

        ZStack {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        CeremonialObsidianTheme.gold.opacity(0.55),
                        style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                    )
                    .frame(width: outlineWidth, height: outlineHeight)
                    .rotationEffect(.degrees(Double(index - 2) * 10))
                    .offset(y: index.isMultiple(of: 2) ? cardWidth * 0.12 : 0)
            }

            RoundedRectangle(cornerRadius: 7)
                .fill(CeremonialObsidianTheme.cardSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(CeremonialObsidianTheme.gold.opacity(0.72), lineWidth: 1)
                }
                .frame(width: outlineWidth * 0.88, height: outlineHeight * 0.72)
                .overlay {
                    Image(systemName: "plus")
                        .font(.system(size: max(cardWidth * 0.42, 10), weight: .light))
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                }
        }
        .frame(width: cardWidth * 2.4, height: outlineHeight * 1.18)
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
    @State private var shuffleGeneration = 0
    @State private var visualBaseline: ReadingVisualState?
    @State private var presentationTask: Task<Void, Never>?
    @State private var presentationToken: UUID?
    @State private var presentationLocked = false
    @State private var placingPosition: Int?
    @State private var placementProgress: CGFloat = 0
    @State private var flippingPosition: Int?
    @State private var flipProgress: CGFloat = 0
    @State private var flipRevealing = true
    @AccessibilityFocusState private var focusedReadingPosition: Int?

    var body: some View {
        GeometryReader { proxy in
            let isPhysicallyLandscape = proxy.size.width > proxy.size.height
            let isLandscape = isPhysicallyLandscape && !dynamicTypeSize.isAccessibilitySize

            ZStack {
                CeremonialBackdrop()

                if isLandscape {
                    landscapeContent(size: proxy.size)
                } else {
                    portraitContent(
                        size: proxy.size,
                        showsOrientationHint: !isPhysicallyLandscape
                    )
                }
            }
            .overlayPreferenceValue(ReadingMotionAnchorPreferenceKey.self) { anchors in
                GeometryReader { coordinateProxy in
                    placementOverlay(anchors: anchors, proxy: coordinateProxy)
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
    private func portraitContent(size: CGSize, showsOrientationHint: Bool) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                portraitLayout(showsOrientationHint: showsOrientationHint)
                    .frame(minHeight: max(size.height, 820))
            }
            .scrollIndicators(.hidden)
        } else {
            portraitLayout(showsOrientationHint: showsOrientationHint)
        }
    }

    private func portraitLayout(showsOrientationHint: Bool) -> some View {
        VStack(spacing: 0) {
            header
                .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 10 : 4)
                .frame(minHeight: 72)

            readingStage(isLandscape: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            portraitActionArea(showsOrientationHint: showsOrientationHint)
                .frame(minHeight: model.activeCardCount > 1 && showsOrientationHint ? 118 : 96)
                .padding(.horizontal, 26)
        }
        .padding(.top, 4)
        .padding(.bottom, 10)
    }

    private func landscapeContent(size: CGSize) -> some View {
        let deckWidth = min(max(size.width * 0.18, 140), 160)
        let deckHeight = deckWidth / CeremonialObsidianTheme.deckAspectRatio
        let deckColumnWidth = deckWidth + 12
        let cueHeight: CGFloat = 34

        return VStack(spacing: 0) {
            landscapeHeader
                .frame(height: 52)

            HStack(spacing: 10) {
                VStack(spacing: 0) {
                    readingStage(isLandscape: true)

                    Group {
                        if shouldShowDeck {
                            Color.clear
                        } else {
                            landscapeCue
                        }
                    }
                    .frame(height: cueHeight)
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

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

                    Spacer(minLength: 0)

                    Group {
                        if shouldShowDeck {
                            landscapeCue
                        } else {
                            Color.clear
                        }
                    }
                    .frame(height: cueHeight)
                }
                .frame(width: deckColumnWidth)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var landscapeHeader: some View {
        ZStack {
            backButton
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Spacer(minLength: 0)
                readingInfoButton
                resetButton
            }

            Text(model.readingTitle)
                .font(.system(.title2, design: .serif, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 112)
                .accessibilityAddTraits(.isHeader)
        }
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
            openReadingTutorial(model.activeTutorialArticleID)
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
        if let definition = model.activeDefinition {
            GeometryReader { proxy in
                let count = definition.cardCount
                let canvasHeight = isLandscape
                    ? proxy.size.height
                    : proxy.size.height * (count <= 3 ? 0.58 : 0.64)
                let canvasSize = CGSize(width: proxy.size.width, height: canvasHeight)
                let orderedPositions = definition.positions.sorted { $0.order < $1.order }
                let metrics = ReadingStageLayoutMetrics.make(
                    points: orderedPositions.map(\.point),
                    canvasSize: canvasSize,
                    maximumCardWidth: maximumCardWidth(count: count, isLandscape: isLandscape),
                    cardAspectRatio: CeremonialObsidianTheme.cardAspectRatio,
                    minimumVisibleGap: 14
                )
                let cardWidth = metrics.cardSize.width
                let cardHeight = metrics.cardSize.height

                ZStack {
                    ForEach(Array(orderedPositions.enumerated()), id: \.element.id) { index, slot in
                        VStack(spacing: 4) {
                            Text(model.activePositionTitle(at: index))
                                .font(.system(count > 6 ? .caption2 : .caption, design: .serif, weight: .semibold))
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                                .lineLimit(2)
                                .minimumScaleFactor(0.62)
                                .multilineTextAlignment(.center)
                                .frame(height: count > 6 ? 24 : 30)
                                .accessibilityHidden(true)

                            ZStack {
                                Color.clear

                                position(at: index, total: count)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                                .frame(width: cardWidth, height: cardHeight)
                                .anchorPreference(
                                    key: ReadingMotionAnchorPreferenceKey.self,
                                    value: .bounds,
                                    transform: { [.slot(index): $0] }
                                )
                        }
                        .frame(width: cardWidth, height: cardHeight + 34)
                        .position(
                            metrics.stackCenters[index]
                        )
                    }
                }
                .frame(width: proxy.size.width, height: canvasHeight, alignment: .topLeading)
                .accessibilityElement(children: .contain)

                if !isLandscape {
                    let availableDeckHeight = max(proxy.size.height - canvasHeight - 8, 1)
                    let deckWidth = min(
                        max(proxy.size.width * (count > 3 ? 0.28 : 0.40), 88),
                        count > 3 ? 128 : 200,
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
                            y: canvasHeight + availableDeckHeight / 2
                        )
                }
            }
        }
    }

    private func maximumCardWidth(count: Int, isLandscape: Bool) -> CGFloat {
        switch count {
        case 1: return isLandscape ? 270 : 238
        case 2...3: return isLandscape ? 190 : 112
        case 4...6: return isLandscape ? 118 : 86
        case 7...9: return isLandscape ? 94 : 70
        default: return isLandscape ? 78 : 58
        }
    }

    private func positionTitle(at index: Int) -> String {
        model.activePositionTitle(at: index)
    }

    @ViewBuilder
    private func position(at index: Int, total: Int) -> some View {
        if let drawnCard = model.placedCard(at: index),
           baselineContainsCard(at: index) {
            let baselineRevealed = baselineSlot(at: index)?.isRevealed ?? drawnCard.isRevealed

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
                positionName: positionTitle(at: index),
                canPlace: model.canPlaceCard(at: index) && !interactionLocked,
                onPlace: { model.placeNextCard(at: index) }
            )
            .transition(.opacity)
            .id("empty-\(index)")
        }
    }

    private var shouldShowDeck: Bool {
        if model.isReadyToShuffle || model.canShuffleDeck || model.hasEmptyPositions { return true }
        return placingPosition != nil
    }

    private var presentedReadingIsCompleteAndRevealed: Bool {
        guard model.layout != nil else { return false }
        let slots = visualBaseline?.slots ?? visualState.slots
        return slots.count == model.activeCardCount
            && slots.allSatisfy { $0?.isRevealed == true }
    }

    private var canUseDeck: Bool {
        model.canShuffleDeck
    }

    @ViewBuilder
    private var deckControl: some View {
        if canUseDeck {
            Button {
                model.shuffleDeck()
            } label: {
                shufflingDeck
                    .contentShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
            }
            .buttonStyle(CeremonialDeckButtonStyle(usesReducedMotion: usesReducedMotion))
            .disabled(interactionLocked)
            .accessibilityHint(
                AppLocalization.text(
                    model.isReadyToShuffle
                        ? "Shuffles all 78 cards"
                        : "Shuffles all 78 cards again"
                )
            )
        } else {
            shufflingDeck
                .accessibilityHidden(true)
        }
    }

    private var shufflingDeck: some View {
            CeremonialShufflingDeck(
                phase: shufflePhase,
                generation: shuffleGeneration,
                reduceMotion: usesReducedMotion,
                spokenLabel: model.isReadyToShuffle
                    ? AppLocalization.text("Unshuffled tarot deck")
                    : AppLocalization.text("Shuffled tarot deck")
            )
    }

    private var usesReducedMotion: Bool {
        reduceMotion || voiceOverEnabled
    }

    private var interactionLocked: Bool {
        model.isBusy || presentationLocked
    }

    private var visualState: ReadingVisualState {
        let slots = (0..<model.activeCardCount).map { index -> ReadingVisualSlot? in
            guard let card = model.placedCard(at: index) else { return nil }
            return ReadingVisualSlot(cardID: card.id.rawValue, isRevealed: card.isRevealed)
        }
        return ReadingVisualState(
            sessionID: model.session?.id,
            slots: slots
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
           baseline.slots.allSatisfy({ $0 == nil }),
           newState.slots.allSatisfy({ $0 == nil }) {
            visualBaseline = newState
            runShuffleChoreography()
            return
        }

        if let placedPosition = newState.slots.indices.first(where: { index in
            let previousSlot = baseline.slots.indices.contains(index) ? baseline.slots[index] : nil
            return previousSlot == nil && newState.slots[index] != nil
        }) {
            runPlacementSequence(at: placedPosition, target: newState)
            return
        }

        for index in newState.slots.indices where baseline.slots.indices.contains(index) {
            guard let oldSlot = baseline.slots[index], let newSlot = newState.slots[index],
                  oldSlot.cardID == newSlot.cardID else { continue }
            if !oldSlot.isRevealed, newSlot.isRevealed {
                runFlip(at: index, revealing: true, target: newState)
                return
            }
            if oldSlot.isRevealed, !newSlot.isRevealed {
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
            shuffleGeneration += 1
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
    private func runPlacementSequence(at position: Int, target: ReadingVisualState) {
        startPresentation { token in
            placingPosition = position
            placementProgress = 0
            await Task.yield()
            guard presentationIsCurrent(token) else { return }

            withAnimation(usesReducedMotion ? CeremonialMotion.reduced : CeremonialMotion.placement) {
                placementProgress = 1
            }
            try? await Task.sleep(
                nanoseconds: usesReducedMotion ? 120_000_000 : 380_000_000
            )
            guard presentationIsCurrent(token) else { return }

            var settleTransaction = Transaction()
            settleTransaction.animation = nil
            withTransaction(settleTransaction) {
                visualBaseline = target
                placingPosition = nil
                placementProgress = 0
            }
            finishPresentation(token)
            CeremonialHaptics.drawn()
            if voiceOverEnabled {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: AppLocalization.format(
                        "%@, card placed face down",
                        positionTitle(at: position)
                    )
                )
            }
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
        placingPosition = nil
        placementProgress = 0
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

    private func portraitActionArea(showsOrientationHint: Bool) -> some View {
        VStack(spacing: 8) {
            actionArea

            if showsOrientationHint, model.activeCardCount > 1 {
                Label(
                    AppLocalization.text("Turn your iPhone sideways to see the cards better."),
                    systemImage: "iphone.landscape"
                )
                .font(.caption)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText.opacity(0.88))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .minimumScaleFactor(0.82)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var landscapeCue: some View {
        Text(landscapeCueText)
            .font(.system(.caption, design: .serif, weight: .medium))
            .foregroundStyle(CeremonialObsidianTheme.secondaryText)
            .lineLimit(2)
            .minimumScaleFactor(0.76)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var landscapeCueText: String {
        if model.isReadyToShuffle {
            return AppLocalization.text("Tap to shuffle")
        }
        guard let session = model.session else { return "" }
        if session.drawnCards.isEmpty || model.hasEmptyPositions {
            return AppLocalization.text("Tap a position")
        }
        if presentedReadingIsCompleteAndRevealed {
            return AppLocalization.text("Tap for meaning")
        }
        return AppLocalization.text("Tap a card")
    }

    private var statusText: String {
        if model.isReadyToShuffle { return AppLocalization.text("Ready to shuffle") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty { return AppLocalization.text("Deck shuffled") }
        if layout == .oneCard {
            let presentedRevealed = visualBaseline.flatMap { $0.slots.first ?? nil }?.isRevealed
                ?? model.placedCard(at: 0)?.isRevealed
                ?? false
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
            model.activeCardCount
        )
    }

    private var instructionText: String {
        if model.isReadyToShuffle { return AppLocalization.text("Tap the deck to shuffle.") }
        guard let session = model.session, let layout = model.layout else { return "" }
        if session.drawnCards.isEmpty {
            return AppLocalization.text("Tap an empty position to place the next card, or tap the deck to shuffle again.")
        }
        if presentedReadingIsCompleteAndRevealed {
            return ""
        }
        if layout == .oneCard, session.drawnCards.count == 1 {
            return AppLocalization.text("Tap the card to reveal it.")
        }
        if model.hasEmptyPositions {
            return AppLocalization.text("Tap any empty position to place the next card.")
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
        baselineSlot(at: index) != nil
    }

    private func baselineSlot(at index: Int) -> ReadingVisualSlot? {
        guard let visualBaseline, visualBaseline.slots.indices.contains(index) else { return nil }
        return visualBaseline.slots[index]
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    @ViewBuilder
    private func placementOverlay(
        anchors: [ReadingMotionAnchor: Anchor<CGRect>],
        proxy: GeometryProxy
    ) -> some View {
        if let position = placingPosition,
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
            .scaleEffect(usesReducedMotion ? 1 : 0.94 + 0.06 * placementProgress)
            .opacity(usesReducedMotion ? placementProgress : 1)
            .position(motionStart)
            .modifier(
                CeremonialPlacementGeometryEffect(
                    progress: placementProgress,
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
    let slots: [ReadingVisualSlot?]
}

private struct ReadingVisualSlot: Equatable {
    let cardID: String
    let isRevealed: Bool
}

/// One deterministic geometry contract for every reading-card presentation state.
/// Empty slots, backs, faces, flips and the placement overlay all consume these exact rects.
private struct ReadingStageLayoutMetrics {
    static let labelAreaHeight: CGFloat = 34
    static let minimumCardWidth: CGFloat = 16

    let cardSize: CGSize
    let stackCenters: [CGPoint]

    static func make(
        points: [SpreadPoint],
        canvasSize: CGSize,
        maximumCardWidth: CGFloat,
        cardAspectRatio: CGFloat,
        minimumVisibleGap: CGFloat
    ) -> Self {
        guard !points.isEmpty, canvasSize.width > 0, canvasSize.height > 0 else {
            return Self(cardSize: .zero, stackCenters: [])
        }

        let widthInsideCanvas = max(canvasSize.width - 8, minimumCardWidth)
        let heightInsideCanvas = max(canvasSize.height - labelAreaHeight - 2, 1)
        var cardWidth = min(
            maximumCardWidth,
            widthInsideCanvas,
            heightInsideCanvas * cardAspectRatio
        )
        cardWidth = max(cardWidth, minimumCardWidth)

        // Point coordinates may be custom and are clamped at the edges. Re-evaluate the actual
        // post-clamp rects instead of assuming evenly spaced rows or columns.
        while true {
            let candidate = layout(
                points: points,
                canvasSize: canvasSize,
                cardWidth: cardWidth,
                cardAspectRatio: cardAspectRatio
            )
            if hasMinimumGap(
                centers: candidate.centers,
                cardSize: candidate.cardSize,
                minimumVisibleGap: minimumVisibleGap
            ) {
                return Self(cardSize: candidate.cardSize, stackCenters: candidate.centers)
            }
            guard cardWidth > minimumCardWidth else { break }
            cardWidth = max(cardWidth - 0.5, minimumCardWidth)
        }

        // Custom points can be valid yet too close for any legible card width. Keep the stored
        // definition untouched and use one deterministic compact presentation grid as a visual
        // fail-safe. Its stack rectangles fit inside the canvas and its card rectangles retain
        // the same minimum gap contract as authored layouts.
        let compact = compactGridLayout(
            count: points.count,
            canvasSize: canvasSize,
            maximumCardWidth: maximumCardWidth,
            cardAspectRatio: cardAspectRatio,
            minimumVisibleGap: minimumVisibleGap
        )
        assert(
            hasMinimumGap(
                centers: compact.centers,
                cardSize: compact.cardSize,
                minimumVisibleGap: minimumVisibleGap
            ),
            "Compact reading geometry must preserve the visible card gap."
        )
        return Self(cardSize: compact.cardSize, stackCenters: compact.centers)
    }

    private static func compactGridLayout(
        count: Int,
        canvasSize: CGSize,
        maximumCardWidth: CGFloat,
        cardAspectRatio: CGFloat,
        minimumVisibleGap: CGFloat
    ) -> (cardSize: CGSize, centers: [CGPoint]) {
        let safeCount = max(count, 1)
        let outerInset: CGFloat = 4
        let resolvedGap = minimumVisibleGap + 0.5
        var bestColumns = 1
        var bestRows = safeCount
        var bestCardWidth: CGFloat = 0

        // Evaluate every stable row-major grid and keep the one with the largest cards.
        // Ascending columns provide a deterministic tie-break without consulting mutable state.
        for columns in 1...safeCount {
            let rows = Int(ceil(Double(safeCount) / Double(columns)))
            let horizontalGaps = CGFloat(max(columns - 1, 0)) * resolvedGap
            let verticalGaps = CGFloat(max(rows - 1, 0)) * resolvedGap
            let horizontalFit = (
                canvasSize.width - outerInset * 2 - horizontalGaps
            ) / CGFloat(columns)
            let verticalCardFit = (
                canvasSize.height
                    - 2
                    - CGFloat(rows) * labelAreaHeight
                    - verticalGaps
            ) / CGFloat(rows)
            let verticalFit = verticalCardFit * cardAspectRatio
            let candidateWidth = min(maximumCardWidth, horizontalFit, verticalFit)

            if candidateWidth > bestCardWidth {
                bestColumns = columns
                bestRows = rows
                bestCardWidth = candidateWidth
            }
        }

        // Valid app canvases always produce positive space. This lower bound keeps the function
        // total for transient zero-adjacent GeometryReader measurements without an infinite loop.
        let cardWidth = max(min(bestCardWidth, maximumCardWidth), 1)
        let cardHeight = cardWidth / cardAspectRatio
        let stackHeight = cardHeight + labelAreaHeight
        let totalHeight = CGFloat(bestRows) * stackHeight
            + CGFloat(max(bestRows - 1, 0)) * resolvedGap
        let firstY = max((canvasSize.height - totalHeight) / 2, 0) + stackHeight / 2
        var centers: [CGPoint] = []
        centers.reserveCapacity(safeCount)

        for row in 0..<bestRows {
            let firstIndex = row * bestColumns
            let itemsInRow = min(bestColumns, safeCount - firstIndex)
            guard itemsInRow > 0 else { continue }
            let rowWidth = CGFloat(itemsInRow) * cardWidth
                + CGFloat(max(itemsInRow - 1, 0)) * resolvedGap
            let firstX = (canvasSize.width - rowWidth) / 2 + cardWidth / 2
            let y = firstY + CGFloat(row) * (stackHeight + resolvedGap)

            for column in 0..<itemsInRow {
                centers.append(
                    CGPoint(
                        x: firstX + CGFloat(column) * (cardWidth + resolvedGap),
                        y: y
                    )
                )
            }
        }

        return (CGSize(width: cardWidth, height: cardHeight), centers)
    }

    private static func layout(
        points: [SpreadPoint],
        canvasSize: CGSize,
        cardWidth: CGFloat,
        cardAspectRatio: CGFloat
    ) -> (cardSize: CGSize, centers: [CGPoint]) {
        let cardHeight = cardWidth / cardAspectRatio
        let horizontalMargin = cardWidth / 2 + 4
        let verticalMargin = cardHeight / 2 + labelAreaHeight / 2 + 1
        let centers = points.map { point in
            CGPoint(
                x: clampedCoordinate(
                    normalized: point.x,
                    extent: canvasSize.width,
                    margin: horizontalMargin
                ),
                y: clampedCoordinate(
                    normalized: point.y,
                    extent: canvasSize.height,
                    margin: verticalMargin
                )
            )
        }
        return (CGSize(width: cardWidth, height: cardHeight), centers)
    }

    private static func hasMinimumGap(
        centers: [CGPoint],
        cardSize: CGSize,
        minimumVisibleGap: CGFloat
    ) -> Bool {
        guard centers.count > 1 else { return true }
        for firstIndex in centers.indices {
            for secondIndex in centers.indices where secondIndex > firstIndex {
                let horizontalGap = abs(centers[firstIndex].x - centers[secondIndex].x) - cardSize.width
                let verticalGap = abs(centers[firstIndex].y - centers[secondIndex].y) - cardSize.height
                if horizontalGap < minimumVisibleGap && verticalGap < minimumVisibleGap {
                    return false
                }
            }
        }
        return true
    }

    private static func clampedCoordinate(
        normalized: Double,
        extent: CGFloat,
        margin: CGFloat
    ) -> CGFloat {
        min(max(CGFloat(normalized) * extent, margin), max(extent - margin, margin))
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
