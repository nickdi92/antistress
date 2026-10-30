import XCTest

/// Captures the App Store screenshots. Run with
/// TEST_RUNNER_SCREENSHOT_LANG=en|it TEST_RUNNER_SCREENSHOT_DIR=<folder>
final class StoreScreenshotTests: XCTestCase {
    func testCaptureStoreScreenshots() throws {
        let env = ProcessInfo.processInfo.environment
        guard let dir = env["SCREENSHOT_DIR"] else { throw XCTSkip("SCREENSHOT_DIR not set") }
        let lang = env["SCREENSHOT_LANG"] ?? "en"
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        func save(_ name: String) throws {
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(name).png"))
        }

        let italian = lang == "it"
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(\(lang))", "-AppleLocale", italian ? "it_IT" : "en_US"]
        app.launch()

        let field = app.descendants(matching: .any).matching(identifier: "thoughtField").firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(italian
            ? "La scadenza che continuo a rimandare e la mail a cui non ho ancora risposto."
            : "The deadline I keep pushing back, and the email I still haven't answered.")
        // touching the water closes the keyboard and leaves a ripple
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.14)).tap()
        Thread.sleep(forTimeInterval: 1.2)
        try save("01-write")

        app.buttons["releaseButton"].tap()
        Thread.sleep(forTimeInterval: 3.5)
        try save("02-sinking")

        XCTAssertTrue(app.staticTexts[italian ? "Un respiro lento." : "One slow breath."].waitForExistence(timeout: 40))
        Thread.sleep(forTimeInterval: 2.5)
        try save("03-breath")
    }
}
