//
//  ContentView.swift
//  Solidus Mac
//
//  Created by Justin Nipper on 7/14/22.
//

import SwiftUI

struct VisualEffectMaterialKey: EnvironmentKey {
    typealias Value = NSVisualEffectView.Material?
    static var defaultValue: Value = nil
}

struct VisualEffectBlendingKey: EnvironmentKey {
    typealias Value = NSVisualEffectView.BlendingMode?
    static var defaultValue: Value = nil
}

struct VisualEffectEmphasizedKey: EnvironmentKey {
    typealias Value = Bool?
    static var defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var visualEffectMaterial: NSVisualEffectView.Material? {
        get { self[VisualEffectMaterialKey.self] }
        set { self[VisualEffectMaterialKey.self] = newValue }
    }
    
    var visualEffectBlending: NSVisualEffectView.BlendingMode? {
        get { self[VisualEffectBlendingKey.self] }
        set { self[VisualEffectBlendingKey.self] = newValue }
    }
    
    var visualEffectEmphasized: Bool? {
        get { self[VisualEffectEmphasizedKey.self] }
        set { self[VisualEffectEmphasizedKey.self] = newValue }
    }
}

struct VisualEffectBackground: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    
    fileprivate init(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode,
        emphasized: Bool) {
            self.material = material
            self.blendingMode = blendingMode
            self.isEmphasized = emphasized
        }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        
        // Not certain how necessary this is
        view.autoresizingMask = [.width, .height]
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = context.environment.visualEffectMaterial ?? material
        nsView.blendingMode = context.environment.visualEffectBlending ?? blendingMode
        nsView.isEmphasized = context.environment.visualEffectEmphasized ?? isEmphasized
    }
}

extension View {
    func visualEffect(
        material: NSVisualEffectView.Material,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        emphasized: Bool = false
    ) -> some View {
        background(
            VisualEffectBackground(
                material: material,
                blendingMode: blendingMode,
                emphasized: emphasized
            )
        )
    }
}

struct CustomTextField: NSViewRepresentable {
    typealias NSViewType = NSTextView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSTextView {
        let view = NSTextView()
        
        view.drawsBackground = false
        view.delegate = context.coordinator
        view.textContainerInset = NSSize(width: 8, height: 8)
        view.alignment = .right
        
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        print(text)
        nsView.string = text
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        let parent: CustomTextField
        
        init (_ textField: CustomTextField) {
            self.parent = textField
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            print("HERE THO")
            if (textView.string.count >= 10 && !textView.string.isEmpty && !(replacementString?.isEmpty ?? false)) {
                return false
            }
            
            let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
            
            // check for valid characters
            if textView.string == "0" && replacementString!.isEmpty {
                return false
            } else if (replacementString?.rangeOfCharacter(from: invalidCharacters) == nil) {
                if (textView.string == "0" && replacementString != "0" && replacementString != ".") {
                    textView.string = replacementString!
                    return false
                }
                // we have valid characters
                // check for presence of decimal and dont allow another
                if textView.string.contains(where: {$0 == "."}) && replacementString == "." {
                    return false
                }
                
                return true
            }
            return false
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
        }
    }
    
}

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
                .padding(.bottom)
            
            VStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Percent")
                        .bold()
                    CustomTextField(text: $percent)
                        .visualEffect(material: .popover, blendingMode: .withinWindow, emphasized: true)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .padding(.horizontal)
                .frame(maxHeight: 50)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Amount")
                        .bold()
                    CustomTextField(text: $amount)
                        .visualEffect(material: .popover, blendingMode: .withinWindow, emphasized: true)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .padding(.horizontal)
                .frame(maxHeight: 50)
            }
            
            Divider()
                .padding(.top)
            HStack {
                Text("Total:")
                    .bold()
                Spacer()
                Text("100.44")
            }
        }
        .padding()
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
