//
//  ContentView.swift
//  Solidus Mac
//
//  Created by Justin Nipper on 7/14/22.
//

import SwiftUI

struct ContentView: View {
    @State var percent = "0"
    @State var amount = "0"
    @State var total = "0.00"
    @State var percentAction: PercentAction = .off
    @State var activeInput: ActiveInput = .none
    @Namespace var animation
    
    enum ActiveInput {
        case percent
        case amount
        case none
    }
    
    enum PercentAction: String, Equatable, CaseIterable {
        case off = "Off"
        case of = "Of"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Controls()
            Spacer()
            HStack {
                VStack {
                    VStack {
                        Text("Percent")
                        Text("12.5%")
                    }
                    VStack {
                        Text("Amount")
                        Text("12.00")
                    }
                }
            }
            Spacer()
            HStack {
                Text("Total:")
                Text("100.44")
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 200, minHeight: 200, alignment: .leading)
    }
    
    @ViewBuilder
    func Controls() -> some View {
        HStack(spacing: 0) {
            ForEach(PercentAction.allCases, id: \.self) { action in
                Text(action.rawValue)
                    .fontWeight(percentAction == action ? .semibold : .regular)
                    .foregroundColor(percentAction == action
                                     ? Color(
                                        red: 0.1647058824,
                                        green: 0.1921568627,
                                        blue: 0.3176470588)
                                     : .white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background {
                        if percentAction == action {
                            RoundedRectangle(
                                cornerRadius: 8,
                                style: .continuous)
                            .fill(Color(.white))
                            .matchedGeometryEffect(id: "ACTION", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            percentAction = action
                        }
                    }
                
            }
        }
        .padding(2)
        .background {
            Color.black.opacity(0.4)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
