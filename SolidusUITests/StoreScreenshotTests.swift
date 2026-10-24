import XCTest

/// Explicitly enabled capture workflow; every image comes from real controls.
@MainActor
final class StoreScreenshotTests: XCTestCase {
    func testCapturePopulatedCalculator() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["SOLIDUS_STORE_SCREENSHOTS"] == "1",
                          "Run only when preparing App Store captures.")
        continueAfterFailure = false
        let app = XCUIApplication()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        app.launchArguments += ["-visitCount", "0", "-lastPromptDate", formatter.string(from: Date())]
        app.launch()
        XCTAssertTrue(app.buttons["input.percent"].waitForExistence(timeout: 10))
        for digit in "25" { app.buttons["key.\(digit)"].tap() }
        app.buttons["input.amount"].tap()
        for digit in "128" { app.buttons["key.\(digit)"].tap() }
        XCTAssertEqual(app.staticTexts["result.total"].label, "96.00")
        capture(app, named: "25-off-128")
        app.buttons["clear.all"].tap()
        for digit in "18" { app.buttons["key.\(digit)"].tap() }
        app.buttons["input.amount"].tap()
        for digit in "86" { app.buttons["key.\(digit)"].tap() }
        app.buttons["mode.of"].tap()
        XCTAssertEqual(app.staticTexts["result.total"].label, "15.48")
        capture(app, named: "18-of-86")
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        // Let the final key release finish before capturing its visual state.
        Thread.sleep(forTimeInterval: 0.5)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
