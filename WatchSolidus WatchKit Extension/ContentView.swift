//
//  ContentView.swift
//  WatchSolidus WatchKit Extension
//
//  Created by Justin Nipper on 7/13/22.
//

import SwiftUI

struct ContentView: View {
    @State var percent = "0"
    @State var amount = "0"
    @State var total = "0.00"
    @State var percentAction: PercentAction = .off
    @State var activeInput: ActiveInput = .none
    
    @State var presentSheet: Bool = false
    
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
    
    let buttons: [[InputButtons]] = [
        [.seven, .eight, .nine],
        [.four, .five, .six],
        [.one, .two, .three],
        [.delete, .zero, .decimal],
    ]
    
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Button {
                    activeInput = .percent
                } label: {
                    VStack(alignment: .leading) {
                        Text("Percent")
                            .font(.footnote)
                            .fontWeight(activeInput == .percent ? .bold : .regular)
                        HStack {
                            Text(percent)
                                .font(.headline)
                                .fontWeight(activeInput == .percent ? .bold : .regular)
                            Text("%")
                                .fontWeight(activeInput == .percent ? .bold : .regular)
                        }
                    }
                    .foregroundColor(activeInput == .percent ? Color(red: 0.9254901961, green: 0.8078431373, blue: 0.9647058824) : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                Button {
                    presentSheet = true
                } label: {
                    Text(percentAction == .off ? "Off" : "Of")
                        .font(.system(size: 10, weight: .medium))
                        .padding()
                        .background(Color(red: 0.9098039216, green: 0.9529411765, blue: 1))
                        .foregroundColor(Color(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588))
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)
                Button {
                    activeInput = .amount
                } label: {
                    VStack(alignment: .trailing) {
                        Text("Amount")
                            .font(.footnote)
                            .fontWeight(activeInput == .amount ? .bold : .regular)
                        Text(amount)
                            .fontWeight(activeInput == .amount ? .bold : .regular)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundColor(activeInput == .amount ? Color(red: 0.9254901961, green: 0.8078431373, blue: 0.9647058824) : .white)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .buttonStyle(.plain)
            HStack {
                ActionButton()
                Spacer()
                Text("Total")
                    .font(.footnote)
                Spacer()
                Text(total)
            }
            .background(Color.white.opacity(0.05))
            ForEach(buttons, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { button in
                        Button {
                            didTap(button: button)
                        } label: {
                            if (button == .delete) {
                                Image(systemName: button.rawValue)
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: 20, maxHeight: .infinity)
                                    .background(Color(red: 0.9254901961, green: 0.8078431373, blue: 0.9647058824))
                                    .foregroundColor(Color(red: 0.2117647059, green: 0.1647058824, blue: 0.3176470588))
                            } else {
                                Text(button.rawValue)
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: 20, maxHeight: .infinity)
                                    .background(Color(red: 0.9254901961, green: 0.8078431373, blue: 0.9647058824))
                                    .foregroundColor(Color(red: 0.2117647059, green: 0.1647058824, blue: 0.3176470588))
                            }
                        }
                        .buttonStyle(.plain)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 20, maxHeight: .infinity)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func ActionButton() -> some View {
        if #available(watchOSApplicationExtension 8.0, *) {
            Button {
                presentSheet = true
            } label: {
                Image(systemName: "ellipsis")
            }
            .buttonStyle(.plain)
            .frame(
                minHeight: 20,
                maxHeight: .infinity)
            .confirmationDialog("Choose Action", isPresented: $presentSheet, actions: {
                Button {
                    percentAction = .off
                    activeInput = .none
                    calculateAmounts()
                } label: {
                    Text("Percent Off")
                }
                Button {
                    percentAction = .of
                    activeInput = .none
                    calculateAmounts()
                } label: {
                    Text("Percent Of")
                }
                Button {
                    amount = "0"
                    percent = "0"
                    activeInput = .none
                    calculateAmounts()
                } label: {
                    Text("Clear all")
                }
            })
        } else {
            Button {
                presentSheet = true
            } label: {
                Image(systemName: "ellipsis")
            }
            .buttonStyle(.plain)
            .frame(
                minHeight: 20,
                maxHeight: .infinity)
            .actionSheet(isPresented: $presentSheet) {
                ActionSheet(title: Text("Choose Action"), buttons: [
                    .cancel(),
                    .default(Text("Percent Off"), action: {
                        percentAction = .off
                        activeInput = .none
                        calculateAmounts()
                    }),
                    .default(Text("Percent Of"), action: {
                        percentAction = .of
                        activeInput = .none
                        calculateAmounts()
                    }),
                    .destructive(Text("Clear all"), action: {
                        amount = "0"
                        percent = "0"
                        activeInput = .none
                        calculateAmounts()
                    })
                ])
            }
        }
    }
    
    
    
    func calculateAmounts() {
        let percentNumber = Double(percent) ?? 0
        let amountNumber = Double(amount) ?? 0
        switch percentAction {
        case .off:
            var runningTotal = ((percentNumber / 100) * amountNumber)
            runningTotal = amountNumber - runningTotal
            if (runningTotal <= 0) {
                total = String(format: "%.2f", 0)
            } else {
                total = String(format: "%.2f", runningTotal)
            }
        case .of:
            let runningTotal = ((percentNumber / 100) * amountNumber)
            total = String(format: "%.2f", runningTotal)
        }
        
    }
    
    func didTap(button: InputButtons) {
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
            if (amount.count >= 8) {
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
            if (button != .delete) {
                activeInput = .percent
                if (percent != "0") {
                    percent = "0"
                }
            }
            didTap(button: button)
        }
        self.calculateAmounts()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
