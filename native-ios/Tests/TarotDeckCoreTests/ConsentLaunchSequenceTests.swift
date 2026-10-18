import XCTest
@testable import TarotDeckCore

final class ConsentLaunchSequenceTests: XCTestCase {
    @MainActor func testFirstLaunchCollectsRequiredChoiceBeforeEnablingAds() async throws {
        var events: [String] = []
        let completed = try await ConsentLaunchSequence.run(
            refresh: { events.append("refresh") }, requiresForm: { true }, mayPresent: { true },
            load: { events.append("load"); return "form" },
            present: { form in XCTAssertEqual(form, "form"); events.append("choice") },
            finish: { events.append("enable") })
        XCTAssertTrue(completed)
        XCTAssertEqual(events, ["refresh", "load", "choice", "enable"])
    }

    @MainActor func testExistingChoiceDoesNotPresentAgain() async throws {
        var events: [String] = []
        let completed = try await ConsentLaunchSequence.run(
            refresh: { events.append("refresh") }, requiresForm: { false }, mayPresent: { true },
            load: { XCTFail("Must not load an unnecessary form"); return 1 },
            present: { _ in XCTFail("Must not prompt again") },
            finish: { events.append("enable") })
        XCTAssertTrue(completed)
        XCTAssertEqual(events, ["refresh", "enable"])
    }

    @MainActor func testReadingStartedDuringRefreshOrLoadDefersPresentation() async throws {
        for switchDuringLoad in [false, true] {
            var safe = true
            let completed = try await ConsentLaunchSequence.run(
                refresh: { if !switchDuringLoad { safe = false } }, requiresForm: { true },
                mayPresent: { safe }, load: { safe = false; return 1 },
                present: { _ in XCTFail("Must not interrupt a reading") },
                finish: { XCTFail("Deferred flow must remain unfinished") })
            XCTAssertFalse(completed)
        }
    }

    @MainActor func testRefreshLoadAndPresentationErrorsNeverEnableAds() async {
        enum Failure: Error { case network }
        for failureAt in 0...2 {
            do {
                _ = try await ConsentLaunchSequence.run(
                    refresh: { if failureAt == 0 { throw Failure.network } },
                    requiresForm: { true }, mayPresent: { true },
                    load: { if failureAt == 1 { throw Failure.network }; return 1 },
                    present: { _ in if failureAt == 2 { throw Failure.network } },
                    finish: { XCTFail("Failed consent must keep ads off") })
                XCTFail("Expected failure")
            } catch { XCTAssertTrue(error is Failure) }
        }
    }
}
