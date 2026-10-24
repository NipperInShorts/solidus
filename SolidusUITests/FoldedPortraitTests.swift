import XCTest

/// Run on an inner-display Duo with a horizontal half-fold. This suite deliberately
/// preserves the simulator's configured pose instead of resetting it in setUp.
@MainActor
final class FoldedPortraitTests: XCTestCase {
    func testHalfFoldKeepsEveryKeyVisibleAndWorking() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["SOLIDUS_FOLDED_PORTRAIT_TEST"] == "1",
                          "Requires an explicitly configured Duo portrait half-fold.")
        continueAfterFailure = false
        let app = XCUIApplication()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        app.launchArguments += ["-visitCount", "0", "-lastPromptDate", formatter.string(from: Date())]
        app.launch()
        defer {
            let capture = XCTAttachment(screenshot: app.screenshot())
            capture.name = "Folded portrait calculator"
            capture.lifetime = .keepAlways
            add(capture)
        }
        XCTAssertTrue(app.buttons["input.percent"].waitForExistence(timeout: 10))
        let window = app.windows.firstMatch.frame
        XCTAssertLessThan(window.width, window.height,
                          "Precondition: the inner display must actually be portrait, not just have a hinge angle set.")
        let identifiers = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "delete.left.fill", "0", "."]
        for identifier in identifiers {
            let key = app.buttons["key.\(identifier)"]
            XCTAssertTrue(key.exists, "Missing key: \(identifier)")
            XCTAssertTrue(key.isHittable, "Unreachable key: \(identifier)")
            XCTAssertGreaterThanOrEqual(key.frame.height + 0.001, 44)
            XCTAssertGreaterThanOrEqual(key.frame.width + 0.001, 44)
            XCTAssertTrue(window.contains(key.frame))
            XCTAssertGreaterThan(key.frame.minY, window.midY, "Key crosses into the upper half")
        }
        XCTAssertLessThan(app.staticTexts["result.total"].frame.maxY, window.midY)
        app.buttons["key.2"].tap()
        app.buttons["key.5"].tap()
        app.buttons["input.amount"].tap()
        for key in ["1", "2", "8"] { app.buttons["key.\(key)"].tap() }
        XCTAssertEqual(app.staticTexts["result.total"].label, "96.00")
        app.buttons["clear.all"].tap()
        XCTAssertEqual(app.staticTexts["result.total"].label, "0.00")
    }
}
