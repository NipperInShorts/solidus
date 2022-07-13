//
//  ContentView.swift
//  Solidus
//
//  Created by Justin Nipper on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var percent = "0"
    @State var amount = "0"
    @State var total = "0.00"
    @State var percentAction: PercentAction = .off
    @State var activeInput: ActiveInput = .none
    
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
        
        VStack{
            Spacer()
            VStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Percent")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .trailing
                        )
                    HStack {
                        if (percent != "0") {
                            Button(action: {
                                percent = "0"
                                self.calculateAmounts()
                            }) {
                                Image(systemName: "clear")
                                    .padding(.all, 5)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(#colorLiteral(red: 0.862745098, green: 0.9176470588, blue: 0.9764705882, alpha: 1)))
                            }
                        }
                        
                        Button(action: {
                            activeInput = .percent
                        }) {
                            HStack(spacing: 0) {
                                
                                Text(percent)
                                    .padding(.trailing, 4)
                                Text("%")
                                    .foregroundColor(Color(red: 0.862745098, green: 0.9176470588, blue: 0.9764705882))
                            }
                            .font(.largeTitle)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                            .padding(.vertical, 4)
                            .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                            .cornerRadius(8)
                        }
                        
                    }
                    Divider()
                        .frame(height: 2)
                        .background(activeInput == .percent ? Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)))
                }
                Spacer()
                HStack(spacing: 5) {
                    Button(action: {
                        percentAction = .off
                        activeInput = .none
                        self.calculateAmounts()
                    }) {
                        Text("Off")
                            .font(.system(size: 18, weight: .medium))
                            .padding(.all, 8)
                            .frame(maxWidth: 60)
                            .background(percentAction == .off ? Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)))
                            .foregroundColor(percentAction == .off ? Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)) : Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                    }
                    .cornerRadius(8)
                    Button(action: {
                        percentAction = .of
                        activeInput = .none
                        self.calculateAmounts()
                    }) {
                        Text("Of")
                            .font(.system(size: 18, weight: .medium))
                            .padding(.all, 8)
                            .frame(maxWidth: 60)
                            .background(percentAction == .of ? Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)))
                            .foregroundColor(percentAction == .of ? Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)) : Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                    }
                    .cornerRadius(8)
                }
                .padding(.vertical, 3)
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("Amount")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .trailing
                        )
                    HStack {
                        if (amount != "0") {
                            Button(action: {
                                amount = "0"
                                self.calculateAmounts()
                            }) {
                                Image(systemName: "clear")
                                    .padding(.all, 5)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(#colorLiteral(red: 0.862745098, green: 0.9176470588, blue: 0.9764705882, alpha: 1)))
                            }
                        }
                        Button(action: {
                            activeInput = .amount
                        }) {
                            Text(amount)
                                .font(.largeTitle)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .trailing
                                )
                                .padding(.vertical, 4)
                                .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                                .cornerRadius(8)
                        }
                    }
                    Divider()
                        .frame(height: 2)
                        .background(activeInput == .amount ? Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)))
                }
            }
            .padding(.leading)
            .padding(.trailing)
            
            HStack {
                Text("Total")
                    .font(.system(size: 20))
                    .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                Text(total)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
            }
            .padding()
            .padding(.bottom, 20)
            .background(Color(#colorLiteral(red: 0.1137254902, green: 0.137254902, blue: 0.2588235294, alpha: 1)))
            .offset(y: 20)
            VStack(alignment: .leading) {
                Button(action: {
                    amount = "0"
                    percent = "0"
                    activeInput = .none
                    self.calculateAmounts()
                }) {
                    Text("Clear all")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .background(Color(#colorLiteral(red: 0.1647058824, green: 0.1921568627, blue: 0.3176470588, alpha: 1)))
                        .foregroundColor(Color(#colorLiteral(red: 0.9098039216, green: 0.9529411765, blue: 1, alpha: 1)))
                        .cornerRadius(8)
                }
                .padding(.bottom, 10)
                Spacer()
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                didTap(button: button)
                            }) {
                                if (button == .delete) { Image(systemName: button.rawValue)
                                    .font(.system(size: 30))
                                    .frame(
                                        minWidth: self.buttonWidth(),
                                        minHeight: self.buttonHeight()
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color(red: 0.9254901961, green: 0.8078431373, blue: 0.9647058824))
                                    .foregroundColor(Color(red: 0.2117647059, green: 0.1647058824, blue: 0.3176470588))
                                    
                                } else {
                                    Text(button.rawValue)
                                        .font(.system(size: 30, weight: .medium))
                                        .frame(
                                            minWidth: self.buttonWidth(),
                                            minHeight: self.buttonHeight()
                                        )
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color(#colorLiteral(red: 0.9254901961, green: 0.8078431373, blue: 0.9647058824, alpha: 1)))
                                        .foregroundColor(Color(#colorLiteral(red: 0.2117647059, green: 0.1647058824, blue: 0.3176470588, alpha: 1)))
                                    
                                }
                            }
                            .cornerRadius(8)
                        }
                        .padding(.bottom, 5)
                    }
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.bottom, 10)
            .background(Color(#colorLiteral(red: 0.01568627451, green: 0.02745098039, blue: 0.0862745098, alpha: 1)))
            .cornerRadius(25)

        }
        .padding(.top, 30)
        .background(Color(#colorLiteral(red: 0.08235294118, green: 0.1019607843, blue: 0.1921568627, alpha: 1)))
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            activeInput = .none
        }
    }
    
    func buttonWidth() -> CGFloat {
        return (UIScreen.main.bounds.width - 10) / 4
    }
    
    func buttonHeight() -> CGFloat {
        return 44
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                .previewDisplayName("iPhone 12 Pro Max")
        }
    }
}
