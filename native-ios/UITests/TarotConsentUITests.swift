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
        let purposeConsents: String?
        let vendorConsents: String?

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
    }

    override func tearDownWithError() throws {
        if testRun?.hasSucceeded == false, app != nil {
            recordEvidence("failure")
            let hierarchy = XCTAttachment(string: app.debugDescription)
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

    func testAcceptAndPersistChoiceAcrossRelaunch() throws {
        try launchFresh()
        try tapChoice("Consent")
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
        try tapChoice("Consent")
        let accepted = try waitForSnapshot("accepted before withdrawal") {
            $0.updateCompleted && !$0.busy && $0.canRequestAds && $0.requestCount > 0
        }
        XCTAssertTrue(accepted.purpose(3))
        XCTAssertTrue(accepted.purpose(4))

        let settings = app.buttons["Settings"].firstMatch
        try require(settings.waitForExistence(timeout: 15) && settings.isHittable, "Settings control is missing.")
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

    private func launch(reset: Bool) {
        app.launchArguments = [
            "--qa-english", "--qa-consent-eea", "--qa-consent-observe",
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US"
        ]
        if reset { app.launchArguments.append("--qa-consent-reset") }
        app.launch()
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
