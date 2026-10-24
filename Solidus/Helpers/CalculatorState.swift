import Foundation

/// Calculator state shared by the view and the behavior tests.
struct CalculatorState {
    var percent = "0"
    var amount = "0"
    var total = "0.00"
    var percentAction: PercentAction = .off
    var activeInput: ActiveInput = .none

    enum ActiveInput {
        case percent
        case amount
        case none
    }

    enum PercentAction {
        case off
        case of
    }

    enum InputButtons: String {
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case zero = "0"
        case decimal = "."
        case delete = "delete.left.fill"
    }

    mutating func calculateAmounts() {
        let percentNumber = Double(percent) ?? 0
        let amountNumber = Double(amount) ?? 0
        switch percentAction {
        case .off:
            var runningTotal = ((percentNumber / 100) * amountNumber)
            runningTotal = amountNumber - runningTotal
            if (runningTotal <= 0) {
                total = String(format: "%.2f", 0.0)
            } else {
                total = String(format: "%.2f", runningTotal)
            }
        case .of:
            let runningTotal = ((percentNumber / 100) * amountNumber)
            total = String(format: "%.2f", runningTotal)
        }

    }

    mutating func didTap(button: InputButtons) {
        switch activeInput {
        case .amount:
            if (button == .delete) {
                if (amount.count > 0 && amount != "0") {
                    if amount.count == 1 {
                        amount = "0"
                    } else {
                        amount.removeLast()
                    }
                }
                break
            }
            if (amount.count >= 10) {
                break
            }
            if (button == .decimal && amount.contains(".")) {
                break
            }
            let number = button.rawValue
            if (amount == "0" && number == "0") {
                amount = number
            } else if (button != .decimal && button != .delete && button != .zero) {
                if amount == "0" {
                    amount = ""
                }
                amount = "\(amount)\(button.rawValue)"
            } else {
                amount = "\(amount)\(button.rawValue)"
            }
        case .percent:
            if (button == .delete) {
                if (percent.count > 0 && percent != "0") {
                    if (percent.count == 1) {
                        percent = "0"
                    } else {
                        percent.removeLast()
                    }
                }
                self.calculateAmounts()
                break
            }
            if (percent.count >= 11) {
                break
            }
            let percentNumber =  Double("\(percent)\(button.rawValue)") ?? 0
            if (percentNumber >= 100) {
                percent = "100"
                break;
            }
            if (button == .decimal && percent.contains(".")) {
                break
            }
            let number = button.rawValue
            if (percent == "0" && number == "0") {
                percent = number
            } else if (button != .decimal && button != .delete && button != .zero) {
                if percent == "0" {
                    percent = ""
                }
                percent = "\(percent)\(button.rawValue)"
            } else {
                percent = "\(percent)\(button.rawValue)"
            }
        case .none:
            activeInput = .percent
            if (percent != "0") {
                percent = "0"
            }
            didTap(button: button)
        }
        self.calculateAmounts()
    }

    mutating func clearAll() {
        amount = "0"
        percent = "0"
        activeInput = .none
        calculateAmounts()
    }

    mutating func clearPercent() {
        percent = "0"
        calculateAmounts()
    }

    mutating func clearAmount() {
        amount = "0"
        calculateAmounts()
    }

    mutating func selectAction(_ action: PercentAction) {
        percentAction = action
        activeInput = .none
        calculateAmounts()
    }
}
