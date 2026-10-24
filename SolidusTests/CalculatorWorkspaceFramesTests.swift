import CoreGraphics
import XCTest

final class CalculatorWorkspaceFramesTests: XCTestCase {
    func testPortraitHalfFoldKeepsKeypadBelowTheFold() {
        let size = CGSize(width: 669, height: 951)
        let fold = CGRect(x: 0, y: 460, width: 669, height: 32)
        let frames = CalculatorWorkspaceFrames(size: size, division: fold)
        XCTAssertEqual(frames.calculation, CGRect(x: 0, y: 0, width: 669, height: 460))
        XCTAssertEqual(frames.keypad, CGRect(x: 0, y: 492, width: 669, height: 459))
        XCTAssertGreaterThanOrEqual(frames.keypad.height, 316)
        assertRegionsAreUsable(frames, in: size, avoiding: fold)
    }

    func testFoldDirectionOverridesAWideWindowsPreferredAxis() {
        let size = CGSize(width: 951, height: 669)
        let fold = CGRect(x: 0, y: 319, width: 951, height: 24)
        let frames = CalculatorWorkspaceFrames(size: size, division: fold)
        XCTAssertEqual(frames.calculation.maxY, fold.minY)
        XCTAssertEqual(frames.keypad.minY, fold.maxY)
        XCTAssertEqual(frames.keypad.width, size.width)
        assertRegionsAreUsable(frames, in: size, avoiding: fold)
    }

    func testBookFoldKeepsBothRegionsOnOppositeSides() {
        let size = CGSize(width: 951, height: 669)
        let fold = CGRect(x: 460, y: 0, width: 32, height: 669)
        let frames = CalculatorWorkspaceFrames(size: size, division: fold)
        XCTAssertEqual(frames.calculation.maxX, fold.minX)
        XCTAssertEqual(frames.keypad.minX, fold.maxX)
        assertRegionsAreUsable(frames, in: size, avoiding: fold)
    }

    func testOffCenterFoldUsesTheActualAvailableRegions() {
        let size = CGSize(width: 669, height: 800)
        let fold = CGRect(x: -20, y: 300, width: 730, height: 40)
        let frames = CalculatorWorkspaceFrames(size: size, division: fold)
        XCTAssertEqual(frames.calculation.height, 300)
        XCTAssertEqual(frames.keypad.height, 460)
        assertRegionsAreUsable(frames, in: size, avoiding: fold)
    }

    func testZeroHeightDivisionStillSeparatesTheRegions() {
        let size = CGSize(width: 669, height: 951)
        let frames = CalculatorWorkspaceFrames(size: size,
                                               division: CGRect(x: 0, y: 470, width: 669, height: 0))
        XCTAssertEqual(frames.calculation.maxY, 470)
        XCTAssertEqual(frames.keypad.minY, 470)
        XCTAssertEqual(frames.keypad.height, 481)
    }

    func testFoldOutsideSplitWorkspaceDoesNotHideEitherRegion() {
        let size = CGSize(width: 320, height: 800)
        let frames = CalculatorWorkspaceFrames(size: size,
                                               division: CGRect(x: 450, y: 0, width: 32, height: 800))
        XCTAssertEqual(frames.calculation.height, 400)
        XCTAssertEqual(frames.keypad.minY, 400)
        assertRegionsAreUsable(frames, in: size)
    }

    func testRegularPhoneRemainsStacked() {
        let size = CGSize(width: 393, height: 787)
        let frames = CalculatorWorkspaceFrames(size: size)
        XCTAssertEqual(frames.calculation, CGRect(x: 0, y: 0, width: 393, height: 393.5))
        XCTAssertEqual(frames.keypad, CGRect(x: 0, y: 393.5, width: 393, height: 393.5))
        assertRegionsAreUsable(frames, in: size)
    }

    func testFlatPortraitDuoKeepsBothRegionsStacked() {
        let size = CGSize(width: 669, height: 951)
        let frames = CalculatorWorkspaceFrames(size: size)
        XCTAssertEqual(frames.keypad.minY, size.height / 2)
        assertRegionsAreUsable(frames, in: size)
    }

    func testWideWindowKeepsTheSplitWorkspace() {
        let size = CGSize(width: 951, height: 629)
        let frames = CalculatorWorkspaceFrames(size: size)
        XCTAssertEqual(frames.calculation.width, size.width / 2)
        XCTAssertEqual(frames.keypad.minX, size.width / 2)
        assertRegionsAreUsable(frames, in: size)
    }

    func testResizeAndUnfoldRecalculateBothRegions() {
        let folded = CalculatorWorkspaceFrames(size: CGSize(width: 669, height: 951),
                                               division: CGRect(x: 0, y: 460, width: 669, height: 32))
        let narrow = CalculatorWorkspaceFrames(size: CGSize(width: 320, height: 700))
        let open = CalculatorWorkspaceFrames(size: CGSize(width: 951, height: 629))
        XCTAssertEqual(folded.keypad.minY, 492)
        XCTAssertEqual(narrow.keypad.width, 320)
        XCTAssertEqual(narrow.keypad.minY, 350)
        XCTAssertEqual(open.keypad.minX, 475.5)
    }

    private func assertRegionsAreUsable(_ frames: CalculatorWorkspaceFrames, in size: CGSize,
                                       avoiding fold: CGRect? = nil,
                                       file: StaticString = #filePath, line: UInt = #line) {
        let bounds = CGRect(origin: .zero, size: size)
        for frame in [frames.calculation, frames.keypad] {
            XCTAssertGreaterThan(frame.width, 0, file: file, line: line)
            XCTAssertGreaterThan(frame.height, 0, file: file, line: line)
            XCTAssertTrue(bounds.contains(frame), file: file, line: line)
            if let fold { XCTAssertFalse(frame.intersects(fold), file: file, line: line) }
        }
        XCTAssertFalse(frames.calculation.intersects(frames.keypad), file: file, line: line)
    }
}
