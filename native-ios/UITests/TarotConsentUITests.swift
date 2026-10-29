import XCTest

/// Network-dependent integration tests against the real UMP sample message.
/// Requires a DEBUG app, Google sample ad IDs, an iOS simulator, and the
/// observation/reset contract in docs/technical/consent-ad-preferences-20261027/
/// native-qa-plan.json. No consent fixture is injected or written by these tests.
@MainActor
final class TarotConsentUITests: XCTestCase {
    private var app: XCUIApplication!
    private let networkTimeout: TimeInterval = 90

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
        launch(reset: true, eea: false)
        // The configured Google sample serves a real IDFA explainer here.
        // Advance it, then exercise the real OS choice; never preset ATT/TCC.
        try tapChoice("Continue")
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let action = springboard.alerts.buttons[allow ? "Allow" : "Ask App Not to Track"].firstMatch
        try require(action.waitForExistence(timeout: networkTimeout), "Apple ATT choice did not appear after the real UMP explainer.")
        action.tap()
        let expectedStatus = allow ? "authorized" : "denied"
        let ready = try waitForSnapshot("ATT choice followed by a successfully loaded sample banner") {
            $0.updateCompleted && !$0.busy && $0.canRequestAds && $0.sdkStarted
                && $0.requestCount > 0 && $0.loadedBannerCount > 0
                && $0.trackingAuthorization == expectedStatus
        }
        XCTAssertEqual(ready.trackingAuthorization, expectedStatus)
        recordEvidence(allow ? "actual-att-authorized-banner" : "actual-att-denied-banner")
    }

    func testAcceptAndPersistChoiceAcrossRelaunch() throws {
        try launchFresh()
        try tapConsentAndAwaitTransition()
        try finishOptionalATTWithDenial()
        let accepted = try waitForSnapshot("accepted consent and first test request") {
            $0.updateCompleted && !$0.busy && $0.canRequestAds && $0.sdkStarted && $0.requestCount > 0
        }
        XCTAssertTrue(accepted.purpose(3), "The real sample consent should record purpose 3.")
        XCTAssertTrue(accepted.purpose(4), "The real sample consent should record purpose 4.")
        recordEvidence("accepted")

        // XCUIApplication.launch does NOT uninstall/reset UMP. This second
        // launch deliberately omits the explicit DEBUG reset argument.
        app.terminate()
        launch(reset: false)
        let persisted = try waitForSnapshot("fresh UMP update reuses stored choice") {
            $0.updateCompleted && !$0.busy && $0.canRequestAds && $0.requestCount > 0
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
        try launchFresh()
        try tapConsentAndAwaitTransition()
        try finishOptionalATTWithDenial()
        let accepted = try waitForSnapshot("accepted before withdrawal") {
            $0.updateCompleted && !$0.busy && $0.canRequestAds && $0.requestCount > 0
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
        if reset { app.launchArguments.append("--qa-consent-reset") }
        app.launch()
    }

    /// A cold WebKit form can retain the original GDPR page after XCTest taps.
    /// Retry that same requested choice once only while the exact untouched
    /// form is still visible and requests remain blocked; then require progress.
    private func tapConsentAndAwaitTransition() throws {
        try tapChoice("Consent")
        let moved = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
            return !self.choice("Consent").exists
                || self.choice("Continue").exists
                || XCUIApplication(bundleIdentifier: "com.apple.springboard")
                    .alerts.buttons["Ask App Not to Track"].exists
                || (self.snapshot().map { $0.updateCompleted && !$0.busy } ?? false)
        }
        let initial = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: moved, object: nil)], timeout: 5)
        if initial != .completed {
            guard let state = snapshot() else {
                throw TestFailure.unmetPrecondition("Missing observation before a possible Consent retry")
            }
            let originalForm = ["Consent", "Do not consent", "Manage options"].allSatisfy {
                let element = choice($0)
                return element.exists && element.isHittable
            }
            try require(originalForm && state.busy && !state.canRequestAds
                        && !state.sdkStarted && state.requestCount == 0,
                        "Consent did not transition, but the original blocked GDPR form is not intact; refusing a retry.")
            recordEvidence("original-gdpr-form-before-single-consent-retry")
            try tapChoice("Consent")
            let retried = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: moved, object: nil)],
                                        timeout: networkTimeout)
            try require(retried == .completed,
                        "Original GDPR form did not transition after one documented Consent retry.")
        }
    }

    /// UMP may show its IDFA explainer after GDPR, or proceed straight to ATT.
    /// Continue advances only the explainer; deny the actual Apple prompt.
    /// Completion without that prompt is still not an ATT pass.
    private func finishOptionalATTWithDenial() throws {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let nextStep = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
            return springboard.alerts.buttons["Ask App Not to Track"].exists
                || self.choice("Continue").exists
                || (self.snapshot().map { $0.updateCompleted && !$0.busy } ?? false)
        }
        let next = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: nextStep, object: nil)],
                                 timeout: networkTimeout)
        try require(next == .completed,
                    "Neither the UMP IDFA Continue action, Apple ATT, nor UMP completion appeared. Last state: \(snapshotJSON() ?? "missing")")
        if choice("Continue").exists {
            let before = try waitForSnapshot("real UMP explainer is still in flight") { $0.busy }
            XCTAssertFalse(before.canRequestAds)
            recordEvidence("before-idfa-explainer-continue")
            try tapChoice("Continue")
        }
        let done = NSPredicate { [weak self] _, _ in
            springboard.alerts.buttons["Ask App Not to Track"].exists ||
                (self?.snapshot().map { $0.updateCompleted && !$0.busy } ?? false)
        }
        let result = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: done, object: nil)],
                                   timeout: networkTimeout)
        try require(result == .completed, "Neither UMP completion nor the Apple ATT prompt appeared.")
        let deny = springboard.alerts.buttons["Ask App Not to Track"]
        if deny.exists {
            deny.tap()
            let state = try waitForSnapshot("ATT denial finishes without blocking the app") {
                $0.updateCompleted && !$0.busy
            }
            XCTAssertEqual(state.trackingAuthorization, "denied")
            recordEvidence("actual-att-denied")
        } else {
            let evidence = XCTAttachment(string: "Sample UMP completed without ATT. Real configured Tarot IDFA/ATT QA remains required.")
            evidence.name = "sample-is-not-att-certification"
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
        let element = choice(label)
        try require(element.exists && element.isHittable, "UMP action is not hittable: \(label)")
        element.tap()
    }

    private func waitForChoice(_ label: String) throws {
        // Resolve the element type again on every poll: before the web form
        // loads, neither its button nor its static-text fallback exists.
        let visible = NSPredicate { [weak self] _, _ in
            guard let self else { return false }
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
