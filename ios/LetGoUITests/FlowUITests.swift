import XCTest

final class FlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
    }

    func launch(_ language: String) {
        app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(language))", "-AppleLocale", language == "it" ? "it_IT" : "en_US"]
        app.launch()
    }

    var field: XCUIElement { app.descendants(matching: .any).matching(identifier: "thoughtField").firstMatch }
    var releaseButton: XCUIElement { app.buttons["releaseButton"] }
    var againButton: XCUIElement { app.buttons["againButton"] }

    func write(_ text: String) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }

    func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true AND hittable == true")
        return XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: element)], timeout: timeout) == .completed
    }

    func testFullFlowEnglish() {
        launch("en")
        write("one two three")
        XCTAssertTrue(releaseButton.isEnabled)
        releaseButton.tap()
        XCTAssertTrue(againButton.waitForExistence(timeout: 30))
        XCTAssertEqual(againButton.label, "Write another thought")
        againButton.tap()
        XCTAssertTrue(waitUntilHittable(field, timeout: 5))
        XCTAssertFalse(releaseButton.isEnabled)
    }

    func testFullFlowItalian() {
        launch("it")
        XCTAssertTrue(app.staticTexts["Cosa ti pesa, adesso?"].waitForExistence(timeout: 5))
        write("uno due tre")
        XCTAssertEqual(releaseButton.label, "Lascia andare")
        releaseButton.tap()
        XCTAssertTrue(app.staticTexts["Andato."].waitForExistence(timeout: 30))
        XCTAssertTrue(againButton.waitForExistence(timeout: 30))
        XCTAssertEqual(againButton.label, "Scrivi un altro pensiero")
    }

    func testSkipDuringBreath() {
        launch("en")
        write("let it go")
        releaseButton.tap()
        XCTAssertTrue(app.staticTexts["Gone."].waitForExistence(timeout: 30))
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75)).tap()
        XCTAssertTrue(againButton.waitForExistence(timeout: 2))
    }

    func testWhitespaceOnlyKeepsButtonDisabled() {
        launch("en")
        write("   ")
        XCTAssertFalse(releaseButton.isEnabled)
    }

    func testDoubleTapReleasesOnce() {
        launch("en")
        write("twice")
        releaseButton.doubleTap()
        XCTAssertTrue(againButton.waitForExistence(timeout: 30))
        againButton.tap()
        XCTAssertTrue(waitUntilHittable(field, timeout: 5))
        XCTAssertFalse(releaseButton.isEnabled)
    }

    func testLongTextOnSmallPhone() {
        launch("en")
        write(String(repeating: "peso ", count: 120))
        XCTAssertTrue(releaseButton.isHittable)
        releaseButton.tap()
        XCTAssertTrue(againButton.waitForExistence(timeout: 60))
    }

    func testTypingStopsAt600Characters() {
        launch("en")
        write(String(repeating: "x", count: 620))
        XCTAssertEqual((field.value as? String)?.count, 600)
    }
}
