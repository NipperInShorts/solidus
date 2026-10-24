import XCTest

@MainActor
final class CalculatorFlowTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        // Avoid an unrelated StoreKit sheet interrupting repeated simulator launches.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        app.launchArguments += ["-visitCount", "0", "-lastPromptDate", dateFormatter.string(from: Date())]
        app.launch()
        XCTAssertTrue(app.buttons["input.percent"].waitForExistence(timeout: 10))
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        if let app {
            let capture = XCTAttachment(screenshot: app.screenshot())
            capture.name = name
            capture.lifetime = .keepAlways
            add(capture)
        }
    }

    private func enter(_ value: String) {
        for character in value {
            app.buttons["key.\(character)"].tap()
        }
    }

    private func assertTotal(_ expected: String, file: StaticString = #filePath, line: UInt = #line) {
        let result = app.staticTexts["result.total"]
        let matches = NSPredicate(format: "label == %@", expected)
        let expectation = XCTNSPredicateExpectation(predicate: matches, object: result)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 3), .completed,
                       "Expected total \(expected), displayed \(result.label)", file: file, line: line)
    }

    func testDiscountAndOfModesUseTheEnteredValues() {
        enter("25")
        app.buttons["input.amount"].tap()
        enter("128")
        assertTotal("96.00")
        app.buttons["mode.of"].tap()
        assertTotal("32.00")
        app.buttons["mode.off"].tap()
        assertTotal("96.00")
    }

    func testFractionalEntryAndBackspaceUpdateTheResult() {
        enter("12.5")
        app.buttons["input.amount"].tap()
        enter("19.99")
        assertTotal("17.49")
        app.buttons["key.delete.left.fill"].tap()
        assertTotal("17.41")
    }

    func testClearAllCanStartAnotherCalculation() {
        enter("25")
        app.buttons["input.amount"].tap()
        enter("128")
        app.buttons["clear.all"].tap()
        assertTotal("0.00")
        enter("10")
        app.buttons["input.amount"].tap()
        enter("50")
        assertTotal("45.00")
    }

    func testPercentCapIsAppliedThroughTheUI() {
        enter("999")
        app.buttons["input.amount"].tap()
        enter("128")
        assertTotal("0.00")
        app.buttons["mode.of"].tap()
        assertTotal("128.00")
    }

    func testPrimaryControlsAreVisibleAndTappable() {
        let identifiers = ["input.percent", "input.amount", "mode.off", "mode.of", "clear.all"]
            + ["7", "8", "9", "4", "5", "6", "1", "2", "3", "delete.left.fill", "0", "."].map { "key.\($0)" }
        let window = app.windows.firstMatch.frame
        for identifier in identifiers {
            let control = app.buttons[identifier]
            XCTAssertTrue(control.exists, identifier)
            XCTAssertTrue(control.isHittable, identifier)
            // Accessibility frame conversion can round 44 to 43.999999999999986.
            XCTAssertGreaterThanOrEqual(control.frame.width + 0.001, 44, identifier)
            XCTAssertGreaterThanOrEqual(control.frame.height + 0.001, 44, identifier)
            XCTAssertTrue(window.insetBy(dx: -1, dy: -1).contains(control.frame), "Clipped: \(identifier)")
        }
        let total = app.staticTexts["result.total"]
        XCTAssertTrue(total.exists)
        XCTAssertTrue(window.contains(total.frame), "Total is clipped")
        for (index, identifier) in identifiers.enumerated() {
            let frame = app.buttons[identifier].frame
            XCTAssertFalse(frame.intersects(total.frame), "Total overlaps \(identifier)")
            for other in identifiers.dropFirst(index + 1) {
                XCTAssertFalse(frame.intersects(app.buttons[other].frame),
                               "Overlapping controls: \(identifier), \(other)")
            }
        }
        let capture = XCTAttachment(screenshot: app.screenshot())
        capture.name = "Calculator current layout"
        capture.lifetime = .keepAlways
        add(capture)
    }

    func testRotationPreservesValuesModeAndActiveInput() {
        enter("25")
        app.buttons["input.amount"].tap()
        enter("128")
        app.buttons["mode.of"].tap()
        app.buttons["input.amount"].tap()
        XCUIDevice.shared.orientation = .landscapeLeft
        assertTotal("32.00")
        // Continued typing must still edit the amount after rebuilding the arrangement.
        enter("0")
        assertTotal("320.00")
        for orientation in [UIDeviceOrientation.landscapeRight, .portraitUpsideDown, .portrait] {
            XCUIDevice.shared.orientation = orientation
            assertTotal("320.00")
            XCTAssertTrue(app.windows.firstMatch.frame.contains(app.staticTexts["result.total"].frame))
            XCTAssertTrue(app.buttons["input.amount"].isHittable)
        }
        XCTAssertTrue(app.buttons["mode.of"].isSelected)
    }

    func testLongAmountFitsAndTotalIsRightAligned() {
        enter("12.5")
        app.buttons["input.amount"].tap()
        enter("9999999.99")
        assertTotal("8749999.99")
        let amount = app.buttons["input.amount"].frame
        let total = app.staticTexts["result.total"].frame
        XCTAssertLessThanOrEqual(abs(amount.maxX - total.maxX), 2)
        XCTAssertTrue(app.windows.firstMatch.frame.contains(total))
        XCTAssertTrue(app.buttons["input.amount"].isHittable)
    }

    func testIndividualFieldsCanBeClearedAndReentered() {
        enter("25")
        app.buttons["input.amount"].tap()
        enter("128")
        app.buttons["input.percent.clear"].tap()
        assertTotal("128.00")
        app.buttons["input.percent"].tap()
        enter("50")
        assertTotal("64.00")
        app.buttons["input.amount.clear"].tap()
        assertTotal("0.00")
        app.buttons["input.amount"].tap()
        enter("80")
        assertTotal("40.00")
    }

}
