import XCTest

final class CalculatorStateTests: XCTestCase {
    private typealias Key = CalculatorState.InputButtons

    private func enter(_ text: String, into state: inout CalculatorState) {
        for character in text {
            guard let key = Key(rawValue: String(character)) else {
                XCTFail("Unsupported test input: \(character)")
                return
            }
            state.didTap(button: key)
        }
    }

    private func calculation(percent: String, amount: String,
                             action: CalculatorState.PercentAction = .off) -> CalculatorState {
        var state = CalculatorState()
        enter(percent, into: &state)
        state.activeInput = .amount
        enter(amount, into: &state)
        state.selectAction(action)
        return state
    }

    func testInitialStateIsReadyForANewCalculation() {
        let state = CalculatorState()
        XCTAssertEqual(state.percent, "0")
        XCTAssertEqual(state.amount, "0")
        XCTAssertEqual(state.total, "0.00")
        XCTAssertEqual(state.percentAction, .off)
        XCTAssertEqual(state.activeInput, .none)
    }

    func testDiscountCalculationFromKeypad() {
        XCTAssertEqual(calculation(percent: "25", amount: "128").total, "96.00")
    }

    func testPercentageOfCalculationFromKeypad() {
        XCTAssertEqual(calculation(percent: "25", amount: "128", action: .of).total, "32.00")
    }

    func testZeroPercentDiscountKeepsOriginalAmount() {
        XCTAssertEqual(calculation(percent: "0", amount: "128").total, "128.00")
    }

    func testZeroPercentOfIsZero() {
        XCTAssertEqual(calculation(percent: "0", amount: "128", action: .of).total, "0.00")
    }

    func testFullDiscountIsZero() {
        XCTAssertEqual(calculation(percent: "100", amount: "128").total, "0.00")
    }

    func testFullPercentageOfKeepsOriginalAmount() {
        XCTAssertEqual(calculation(percent: "100", amount: "128", action: .of).total, "128.00")
    }

    func testZeroAmountInBothModes() {
        for action in [CalculatorState.PercentAction.off, .of] {
            XCTAssertEqual(calculation(percent: "25", amount: "0", action: action).total, "0.00")
        }
    }

    func testFractionalPercentAndAmountRoundToTwoPlaces() {
        XCTAssertEqual(calculation(percent: "12.5", amount: "19.99").total, "17.49")
        XCTAssertEqual(calculation(percent: "12.5", amount: "19.99", action: .of).total, "2.50")
    }

    func testSmallFractionRoundsDown() {
        XCTAssertEqual(calculation(percent: "1", amount: "0.01", action: .of).total, "0.00")
    }

    func testLargeSupportedAmount() {
        XCTAssertEqual(calculation(percent: "25", amount: "9999999999").total, "7499999999.25")
    }

    func testFirstKeyAutomaticallyEditsPercent() {
        var state = CalculatorState()
        state.didTap(button: .five)
        XCTAssertEqual(state.percent, "5")
        XCTAssertEqual(state.activeInput, .percent)
        XCTAssertEqual(state.amount, "0")
    }

    func testEditingAmountDoesNotChangePercent() {
        var state = calculation(percent: "25", amount: "128")
        state.activeInput = .amount
        state.didTap(button: .zero)
        XCTAssertEqual(state.percent, "25")
        XCTAssertEqual(state.amount, "1280")
        XCTAssertEqual(state.total, "960.00")
    }

    func testRepeatedLeadingZerosAreSuppressedInBothInputs() {
        for input in [CalculatorState.ActiveInput.percent, .amount] {
            var state = CalculatorState()
            state.activeInput = input
            enter("00005", into: &state)
            XCTAssertEqual(input == .percent ? state.percent : state.amount, "5")
        }
    }

    func testDecimalFirstKeepsLeadingZero() {
        var state = CalculatorState()
        enter(".5", into: &state)
        state.activeInput = .amount
        enter(".8", into: &state)
        XCTAssertEqual(state.percent, "0.5")
        XCTAssertEqual(state.amount, "0.8")
    }

    func testDuplicateDecimalIsIgnoredInBothInputs() {
        var state = CalculatorState()
        enter("1.2.5", into: &state)
        state.activeInput = .amount
        enter("19..99", into: &state)
        XCTAssertEqual(state.percent, "1.25")
        XCTAssertEqual(state.amount, "19.99")
    }

    func testPercentIsCappedAtOneHundred() {
        var state = CalculatorState()
        enter("9999", into: &state)
        XCTAssertEqual(state.percent, "100")
    }

    func testAmountLengthLimitAndDeletionAtLimit() {
        var state = CalculatorState()
        state.activeInput = .amount
        enter("12345678901", into: &state)
        XCTAssertEqual(state.amount, "1234567890")
        state.didTap(button: .delete)
        state.didTap(button: .nine)
        XCTAssertEqual(state.amount, "1234567899")
    }

    func testPercentPrecisionLimitAndDeletionAtLimit() {
        var state = CalculatorState()
        enter("0.1234567899", into: &state)
        XCTAssertEqual(state.percent, "0.123456789")
        state.didTap(button: .delete)
        state.didTap(button: .one)
        XCTAssertEqual(state.percent, "0.123456781")
    }

    func testDeletingAmountRecalculatesImmediately() {
        var state = calculation(percent: "25", amount: "128")
        state.activeInput = .amount
        state.didTap(button: .delete)
        XCTAssertEqual(state.amount, "12")
        XCTAssertEqual(state.total, "9.00")
    }

    func testDeletingPercentRecalculatesImmediately() {
        var state = calculation(percent: "25", amount: "128")
        state.activeInput = .percent
        state.didTap(button: .delete)
        XCTAssertEqual(state.percent, "2")
        XCTAssertEqual(state.total, "125.44")
    }

    func testDeletingLastDigitOrZeroLeavesZeroInBothInputs() {
        for input in [CalculatorState.ActiveInput.percent, .amount] {
            var state = CalculatorState()
            state.activeInput = input
            state.didTap(button: .five)
            state.didTap(button: .delete)
            state.didTap(button: .delete)
            XCTAssertEqual(input == .percent ? state.percent : state.amount, "0")
            XCTAssertEqual(state.total, "0.00")
        }
    }

    func testDeletingDecimalAllowsEnteringItAgain() {
        var state = CalculatorState()
        enter("2.", into: &state)
        state.didTap(button: .delete)
        enter(".5", into: &state)
        XCTAssertEqual(state.percent, "2.5")
    }

    func testSwitchingModesRecalculatesAndEndsEditing() {
        var state = calculation(percent: "25", amount: "128")
        state.activeInput = .amount
        state.selectAction(.of)
        XCTAssertEqual(state.total, "32.00")
        XCTAssertEqual(state.activeInput, .none)
        state.selectAction(.off)
        XCTAssertEqual(state.total, "96.00")
        XCTAssertEqual(state.percent, "25")
        XCTAssertEqual(state.amount, "128")
    }

    func testTypingAfterModeSelectionStartsANewPercent() {
        var state = calculation(percent: "25", amount: "128", action: .of)
        state.didTap(button: .five)
        XCTAssertEqual(state.percent, "5")
        XCTAssertEqual(state.amount, "128")
        XCTAssertEqual(state.total, "6.40")
    }

    func testClearPercentPreservesAmountAndEditingTarget() {
        var state = calculation(percent: "25", amount: "128")
        state.activeInput = .percent
        state.clearPercent()
        XCTAssertEqual(state.percent, "0")
        XCTAssertEqual(state.amount, "128")
        XCTAssertEqual(state.total, "128.00")
        XCTAssertEqual(state.activeInput, .percent)
    }

    func testClearAmountPreservesPercent() {
        var state = calculation(percent: "25", amount: "128")
        state.clearAmount()
        XCTAssertEqual(state.percent, "25")
        XCTAssertEqual(state.amount, "0")
        XCTAssertEqual(state.total, "0.00")
    }

    func testClearAllResetsValuesAndPreservesSelectedMode() {
        for action in [CalculatorState.PercentAction.off, .of] {
            var state = calculation(percent: "25", amount: "128", action: action)
            state.clearAll()
            XCTAssertEqual(state.percent, "0")
            XCTAssertEqual(state.amount, "0")
            XCTAssertEqual(state.total, "0.00")
            XCTAssertEqual(state.activeInput, .none)
            XCTAssertEqual(state.percentAction, action)
            state.didTap(button: .seven)
            XCTAssertEqual(state.percent, "7")
        }
    }

    func testSeparateWindowsKeepIndependentCalculations() {
        var first = calculation(percent: "25", amount: "128")
        let second = calculation(percent: "10", amount: "500", action: .of)
        first.clearAll()
        XCTAssertEqual(second.total, "50.00")
        XCTAssertEqual(second.percent, "10")
        XCTAssertEqual(second.amount, "500")
    }
}
