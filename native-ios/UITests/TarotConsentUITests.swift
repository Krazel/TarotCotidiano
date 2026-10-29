import XCTest

/// Network-dependent integration tests against the real UMP sample message.
/// Requires a DEBUG app, Google sample ad IDs, an iOS simulator, and the
/// observation/reset contract in docs/technical/consent-ad-preferences-20261027/
/// native-qa-plan.json. No consent fixture is injected or written by these tests.
@MainActor
final class TarotConsentUITests: XCTestCase {
    private var app: XCUIApplication!
    private let networkTimeout: TimeInterval = 90
    private var attMonitor: NSObjectProtocol?
    private var expectedATTAction: String?
    private var performedATTActions: [String] = []
    private var interruptedAppTapCount = 0
    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    private struct Snapshot: Decodable {
        let updateCompleted: Bool
        let busy: Bool
        let canRequestAds: Bool
        let sdkStarted: Bool
        let requestCount: Int
        let formPresentations: Int
        let loadedBannerCount: Int
        let initialTrackingAuthorizationRaw: Int
        let trackingAuthorization: String
        let automaticPresentationAllowed: Bool
        let purposeConsents: String?
        let vendorConsents: String?
        let publisherMessageQA: Bool?
        let requiresPrivacyOptions: Bool?
        let gppPresent: Bool?
        let gppSectionIDs: [Int]?
        let gppObservation: String?
        let gppSaleOptOut: Int?
        let gppSharingOptOut: Int?
        let gppTargetedAdvertisingOptOut: Int?

        // Observation only: not a complete TCF interpretation or a runtime gate.
        func purpose(_ number: Int) -> Bool {
            guard let bits = purposeConsents, number > 0, bits.count >= number else { return false }
            return Array(bits)[number - 1] == "1"
        }
    }

    private enum TestFailure: Error { case unmetPrecondition(String) }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        expectedATTAction = nil
        performedATTActions = []
        interruptedAppTapCount = 0
        attMonitor = addUIInterruptionMonitor(withDescription: "Explicit Tarot ATT choice") { [weak self] alert in
            guard let self, self.isATTAlert(alert) else { return false }
            self.interruptedAppTapCount += 1
            return self.performATTAction(alert, source: "interruption-monitor")
        }
        // Documented XCTest API resets the real OS permission for this app.
        // UMP.reset alone does not reset ATT. No TCC database writes or fake choice.
        app.resetAuthorizationStatus(for: .userTracking)
    }

    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false, app != nil {
            recordEvidence("failure")
            let description = app.debugDescription
            // CI contains only fresh simulator/sample-ad data. Print this
            // failure-only hierarchy as well as attaching it to the xcresult.
            print("TAROT_QA_FAILURE_HIERARCHY_BEGIN\n\(description)\nTAROT_QA_FAILURE_HIERARCHY_END")
            let hierarchy = XCTAttachment(string: description)
            hierarchy.name = "accessibility-hierarchy"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
        }
        app?.terminate()
        if let attMonitor { removeUIInterruptionMonitor(attMonitor) }
        attMonitor = nil
        app = nil
    }

    func testNoRequestsBeforeFirstConsentChoice() throws {
        try launchFresh()
        recordEvidence("first-required-form")
        let before = try waitForSnapshot("initial consent form without requests") {
            $0.formPresentations >= 1 && $0.busy && !$0.canRequestAds
        }
        XCTAssertFalse(before.sdkStarted)
        XCTAssertEqual(before.requestCount, 0)
        try assertNoRequestIncrease(from: 0, for: 3)
        XCTAssertTrue(choice("Consent").exists, "No selection was made by this test.")
        recordEvidence("no-choice-no-requests")
    }

    func testNonEEAATTDenialAllowsTestBanner() throws {
        try verifyNonEEAATTChoice(allow: false)
    }

    func testNonEEAATTAuthorizationAllowsTestBanner() throws {
        try verifyNonEEAATTChoice(allow: true)
    }

    private func verifyNonEEAATTChoice(allow: Bool) throws {
        let intendedAction = allow ? "Allow" : "Ask App Not to Track"
        expectedATTAction = intendedAction
        launch(reset: true, eea: false)
        // The configured Google sample serves a real IDFA explainer here.
        // Advance it, then exercise the real OS choice; never preset ATT/TCC.
        try tapChoice("Continue")
        let appeared = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
            return !self.performedATTActions.isEmpty || self.isATTAlert(self.springboard.alerts.firstMatch)
        }
        let result = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: appeared, object: nil)], timeout: networkTimeout)
        try require(result == .completed, "Apple ATT choice did not appear after the real UMP explainer.")
        _ = performATTAction(springboard.alerts.firstMatch, source: "explicit-att-case")
        try require(performedATTActions == [intendedAction], "The intended real Apple ATT action was not executed exactly once.")
        let expectedStatus = allow ? "authorized" : "denied"
        let ready = try waitForSnapshot("ATT choice followed by a successfully loaded sample banner") {
            $0.updateCompleted && !$0.busy && $0.automaticPresentationAllowed && $0.canRequestAds && $0.sdkStarted
                && $0.requestCount > 0 && $0.loadedBannerCount > 0
                && $0.trackingAuthorization == expectedStatus
        }
        XCTAssertEqual(ready.trackingAuthorization, expectedStatus)
        recordEvidence(allow ? "actual-att-authorized-banner" : "actual-att-denied-banner")
    }

    func testAcceptAndPersistChoiceAcrossRelaunch() throws {
        expectedATTAction = "Ask App Not to Track"
        try launchFresh()
        try tapConsentAndAwaitTransition()
        try finishOptionalATTWithDenial()
        let accepted = try waitForSnapshot("accepted consent and first test request") {
            $0.updateCompleted && !$0.busy && $0.automaticPresentationAllowed && $0.canRequestAds && $0.sdkStarted && $0.requestCount > 0
        }
        XCTAssertTrue(accepted.purpose(3), "The real sample consent should record purpose 3.")
        XCTAssertTrue(accepted.purpose(4), "The real sample consent should record purpose 4.")
        recordEvidence("accepted")

        // XCUIApplication.launch does NOT uninstall/reset UMP. This second
        // launch deliberately omits the explicit DEBUG reset argument.
        app.terminate()
        launch(reset: false)
        let persisted = try waitForSnapshot("fresh UMP update reuses stored choice") {
            $0.updateCompleted && !$0.busy && $0.automaticPresentationAllowed && $0.canRequestAds && $0.requestCount > 0
        }
        XCTAssertEqual(persisted.formPresentations, 0, "The unchanged sample message should not ask again.")
        XCTAssertTrue(persisted.purpose(3))
        XCTAssertTrue(persisted.purpose(4))
        recordEvidence("accepted-relaunch")
    }

    func testRejectDoesNotBecomePersonalizationConsent() throws {
        try launchFresh()
        try tapChoice("Do not consent")
        let rejected = try waitForSnapshot("completed real rejection") {
            $0.updateCompleted && !$0.busy
        }
        XCTAssertFalse(rejected.purpose(3))
        XCTAssertFalse(rejected.purpose(4))
        XCTAssertEqual(rejected.trackingAuthorization, "notDetermined",
                       "A regulatory rejection must not be followed by ATT in this flow.")
        XCTAssertFalse(XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.firstMatch.exists)
        // Refusal can still permit non-personalized/limited requests. Do not
        // assert canRequestAds == false, and do not infer mode from ad artwork.
        if !rejected.canRequestAds {
            XCTAssertEqual(rejected.requestCount, 0)
            try assertNoRequestIncrease(from: 0, for: 3)
        }
        recordEvidence("rejected")
    }

    func testReopenAdvertisingChoicesAndRevokeAcceptedChoice() throws {
        expectedATTAction = "Ask App Not to Track"
        try launchFresh()
        try tapConsentAndAwaitTransition()
        try finishOptionalATTWithDenial()
        let accepted = try waitForSnapshot("accepted before withdrawal") {
            $0.updateCompleted && !$0.busy && $0.automaticPresentationAllowed && $0.canRequestAds && $0.requestCount > 0
        }
        XCTAssertTrue(accepted.purpose(3))
        XCTAssertTrue(accepted.purpose(4))

        let settings = app.buttons["Settings"].firstMatch
        let settingsExists = settings.waitForExistence(timeout: 15)
        try require(settingsExists && settings.isHittable,
                    "Settings control is not reachable (exists=\(settingsExists), hittable=\(settings.isHittable)).")
        settings.tap()
        let advertising = app.buttons["Advertising choices"].firstMatch
        for _ in 0..<8 {
            if advertising.exists && advertising.isHittable { break }
            app.swipeUp()
        }
        try require(advertising.exists && advertising.isHittable, "Advertising choices is not reachable in Settings.")
        advertising.tap()
        try waitForChoice("Do not consent")
        let editing = try waitForSnapshot("editing privacy choices suspends requests") {
            $0.busy && !$0.canRequestAds && $0.formPresentations > accepted.formPresentations
        }
        try assertNoRequestIncrease(from: editing.requestCount, for: 3)
        recordEvidence("reopened-before-withdrawal")

        try tapChoice("Do not consent")
        let revoked = try waitForSnapshot("withdrawal completed") {
            $0.updateCompleted && !$0.busy
        }
        XCTAssertFalse(revoked.purpose(3))
        XCTAssertFalse(revoked.purpose(4))
        if !revoked.canRequestAds {
            try assertNoRequestIncrease(from: revoked.requestCount, for: 3)
        }
        recordEvidence("withdrawn")
    }

    private func launch(reset: Bool, eea: Bool = true) {
        app.launchArguments = [
            "--qa-english", eea ? "--qa-consent-eea" : "--qa-consent-non-eea", "--qa-consent-observe",
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US"
        ]
        if reset { app.launchArguments += ["--qa-consent-reset", "--qa-consent-fresh-case"] }
        app.launch()
    }

    /// One real tap only. AX can retain an old GDPR subtree after presentation
    /// changes; it is never authority for a second Consent tap.
    private func tapConsentAndAwaitTransition() throws {
        try tapChoice("Consent")
        // The next helper waits on Springboard or the real coordinator first.
        // It may advance IDFA Continue, but never repeats the GDPR choice.
    }

    private func isATTAlert(_ alert: XCUIElement) -> Bool {
        alert.exists && alert.buttons["Ask App Not to Track"].exists && alert.buttons["Allow"].exists
    }

    @discardableResult
    private func performATTAction(_ alert: XCUIElement, source: String) -> Bool {
        guard isATTAlert(alert) else { return false }
        // Unexpected ATT is denied and fails the case; never let XCTest's
        // default interruption handler grant tracking on our behalf.
        let action = expectedATTAction ?? "Ask App Not to Track"
        alert.buttons[action].tap()
        performedATTActions.append(action)
        let evidence = XCTAttachment(string: "Actual Apple ATT action: \(action); source: \(source)")
        evidence.name = "actual-apple-att-action"
        evidence.lifetime = .keepAlways
        add(evidence)
        print("TAROT_QA_ATT_ACTION action=\(action) source=\(source)")
        if expectedATTAction == nil { XCTFail("Unexpected ATT prompt in a case that must not request tracking.") }
        return true
    }

    /// Prefer the real OS alert before any query into the app's AX hierarchy.
    /// Completion without a prompt is not ATT certification.
    private func finishOptionalATTWithDenial() throws {
        try require(expectedATTAction == nil || expectedATTAction == "Ask App Not to Track",
                    "A denial helper cannot override a case configured to allow ATT.")
        expectedATTAction = "Ask App Not to Track"
        let nextStep = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
            if self.isATTAlert(self.springboard.alerts.firstMatch) { return true }
            if self.springboard.alerts.firstMatch.exists { return false }
            guard let state = self.snapshot() else { return false }
            if state.updateCompleted && !state.busy { return true }
            guard state.busy && !state.canRequestAds && state.formPresentations > 0 else { return false }
            let next = self.choice("Continue")
            return next.exists && next.isHittable
        }
        let next = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: nextStep, object: nil)],
                                 timeout: networkTimeout)
        try require(next == .completed, "No real UMP/ATT transition after the single consent action.")
        if !performATTAction(springboard.alerts.firstMatch, source: "optional-att-denial") {
            try require(!springboard.alerts.firstMatch.exists, "Unexpected system alert blocks consent QA.")
            if let state = snapshot(), state.busy && state.formPresentations > 0 {
                try tapChoice("Continue")
            }
        }
        let done = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
            if self.isATTAlert(self.springboard.alerts.firstMatch) { return true }
            if self.springboard.alerts.firstMatch.exists { return false }
            return self.snapshot().map { $0.updateCompleted && !$0.busy } ?? false
        }
        let result = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: done, object: nil)],
                                   timeout: networkTimeout)
        try require(result == .completed, "Neither UMP completion nor the real Apple ATT prompt appeared.")
        _ = performATTAction(springboard.alerts.firstMatch, source: "after-idfa-continue")
        let state = try waitForSnapshot("UMP/ATT flow finishes") { $0.updateCompleted && !$0.busy }
        if !performedATTActions.isEmpty {
            try require(performedATTActions.allSatisfy { $0 == "Ask App Not to Track" }, "Unexpected ATT grant in denial flow.")
            XCTAssertEqual(state.trackingAuthorization, "denied")
            recordEvidence("actual-att-denied")
        } else {
            XCTAssertNotEqual(state.trackingAuthorization, "authorized", "No recorded Apple interaction may be treated as an authorization.")
            let evidence = XCTAttachment(string: "UMP completed without an Apple prompt; this is not an ATT pass.")
            evidence.name = "completion-without-att-certification"
            evidence.lifetime = .keepAlways
            add(evidence)
        }
    }

    private func launchFresh() throws {
        launch(reset: true)
        try waitForChoice("Consent")
        try require(choice("Do not consent").exists, "Sample message has no Do not consent action.")
        try require(choice("Manage options").exists, "Unexpected sample message: Manage options is missing.")
    }

    private func choice(_ label: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label == %@", label)
        let button = app.buttons.matching(predicate).firstMatch
        if button.exists { return button }
        // WKWebView accessibility may expose an HTML action as a text element.
        // Exact labels only; no coordinate taps or broad substring matching.
        return app.staticTexts.matching(predicate).firstMatch
    }

    private func tapChoice(_ label: String) throws {
        try waitForChoice(label)
        // An Apple prompt can replace Continue between polls. Handle that
        // real prompt directly and never resume a stale app tap underneath it.
        if isATTAlert(springboard.alerts.firstMatch) {
            try require(label == "Continue", "Apple ATT replaced an unexpected UMP action; no app tap was issued.")
            _ = performATTAction(springboard.alerts.firstMatch, source: "before-continue-app-tap")
            return
        }
        try requireUMPTapReady()
        let element = choice(label)
        try require(element.exists && element.isHittable, "UMP action is not hittable: \(label)")
        try tapActiveUMPElement(element)
    }

    private func requireUMPTapReady() throws {
        try require(!springboard.alerts.firstMatch.exists, "A system alert blocks the app action; no stale tap is allowed.")
        guard let state = snapshot() else {
            throw TestFailure.unmetPrecondition("Missing real coordinator observation before UMP tap")
        }
        try require(state.busy && !state.canRequestAds && state.formPresentations > 0,
                    "UMP AX is not backed by an active coordinator presentation; refusing the tap.")
    }

    private func tapActiveUMPElement(_ element: XCUIElement) throws {
        try requireUMPTapReady()
        let interruptionsBefore = interruptedAppTapCount
        try require(element.exists && element.isHittable, "Active UMP action is not visible/hittable.")
        try require(!springboard.alerts.firstMatch.exists, "A system alert appeared before the UMP tap; stopping.")
        element.tap()
        // Even a correct explicit monitor choice cannot certify an app tap
        // that XCTest resumes after dismissing the OS alert. Fail that race.
        try require(interruptedAppTapCount == interruptionsBefore,
                    "ATT interrupted and resumed an app tap. The real OS choice was recorded, but this UI path is not a pass.")
    }

    private func waitForChoice(_ label: String) throws {
        // Resolve the element type again on every poll: before the web form
        // loads, neither its button nor its static-text fallback exists.
        let visible = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
            if self.isATTAlert(self.springboard.alerts.firstMatch) { return label == "Continue" }
            if self.springboard.alerts.firstMatch.exists { return false }
            guard let state = self.snapshot(), state.busy, !state.canRequestAds,
                  state.formPresentations > 0 else { return false }
            let element = self.choice(label)
            return element.exists && element.isHittable
        }
        let expectation = XCTNSPredicateExpectation(predicate: visible, object: nil)
        let result = XCTWaiter.wait(for: [expectation], timeout: networkTimeout)
        try require(result == .completed, "Real UMP action did not appear: \(label). Check network/sample IDs; never substitute fake consent.")
    }

    private func snapshotJSON() -> String? {
        let element = app.descendants(matching: .any).matching(identifier: "tarot.qa.consent-state").firstMatch
        guard element.exists else { return nil }
        if let value = element.value as? String, value.hasPrefix("{") { return value }
        return element.label.hasPrefix("{") ? element.label : nil
    }

    private func snapshot() -> Snapshot? {
        guard let text = snapshotJSON(), let bytes = text.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: bytes)
    }

    private func waitForSnapshot(_ description: String, timeout: TimeInterval? = nil,
                                 predicate: @escaping (Snapshot) -> Bool) throws -> Snapshot {
        let condition = NSPredicate { [weak self] _, _ in
            guard let state = self?.snapshot() else { return false }
            return predicate(state)
        }
        let expectation = XCTNSPredicateExpectation(predicate: condition, object: nil)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout ?? networkTimeout)
        try require(result == .completed, "Timed out: \(description). Last state: \(snapshotJSON() ?? "missing DEBUG observation element")")
        guard let state = snapshot() else {
            XCTFail("Missing or malformed DEBUG snapshot after wait: \(description)")
            throw TestFailure.unmetPrecondition(description)
        }
        return state
    }

    private func assertNoRequestIncrease(from count: Int, for duration: TimeInterval) throws {
        let changed = NSPredicate { [weak self] _, _ in
            guard let state = self?.snapshot() else { return true }
            return state.requestCount != count
        }
        let expectation = XCTNSPredicateExpectation(predicate: changed, object: nil)
        expectation.isInverted = true
        let result = XCTWaiter.wait(for: [expectation], timeout: duration)
        try require(result == .completed, "Request count changed, or observation vanished, while requests should be suspended.")
    }

    private func require(_ condition: Bool, _ message: String) throws {
        guard condition else {
            XCTFail(message)
            throw TestFailure.unmetPrecondition(message)
        }
    }

    private func recordEvidence(_ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
        if let json = snapshotJSON() {
            let state = XCTAttachment(string: json)
            state.name = "\(name)-consent-state"
            state.lifetime = .keepAlways
            add(state)
        }
    }
}
