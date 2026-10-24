import StoreKit
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    // One owner across every arrangement, window size, and display transition.
    @State private var calculator = CalculatorState()

    var body: some View {
        CalculatorWorkspace(calculator: $calculator)
        .foregroundStyle(CalculatorPalette.text)
        .background(CalculatorPalette.surface.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .buttonStyle(.plain)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                ReviewRequestManager.shared.incrementVisitCountAndCheckForReview {
                    requestReview()
                }
            }
        }
    }
}

private enum CalculatorPalette {
    static let surface = Color(red: 0.082, green: 0.102, blue: 0.188)
    static let tray = Color(red: 0.031, green: 0.047, blue: 0.110)
    static let text = Color(red: 0.910, green: 0.949, blue: 1)
    static let secondary = Color(red: 0.663, green: 0.702, blue: 0.808)
    static let neutral = Color(red: 0.169, green: 0.200, blue: 0.325)
    static let key = Color(red: 0.925, green: 0.808, blue: 0.965)
    static let ink = Color(red: 0.212, green: 0.165, blue: 0.318)
}

private struct CalculatorWorkspace: View {
    @Binding var calculator: CalculatorState

    var body: some View {
        GeometryReader { geometry in
            let frames = CalculatorWorkspaceFrames(size: geometry.size,
                                                   division: divisionFrame(in: geometry))
            ZStack(alignment: .topLeading) {
                CalculationPanel(calculator: $calculator)
                    .frame(width: frames.calculation.width, height: frames.calculation.height)
                    .position(x: frames.calculation.midX, y: frames.calculation.midY)
                CalculatorKeypad(calculator: $calculator)
                    .frame(width: frames.keypad.width, height: frames.keypad.height)
                    .position(x: frames.keypad.midX, y: frames.keypad.midY)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func divisionFrame(in geometry: GeometryProxy) -> CGRect? {
        if #available(iOS 27.1, *),
           let region = geometry.reservedRegions(kind: .division,
                                                layoutDirectionBehavior: .fixed).first {
            // The frame and its margins are in this GeometryReader's coordinates.
            return CGRect(x: region.frame.minX - region.margins.leading,
                          y: region.frame.minY - region.margins.top,
                          width: region.frame.width + region.margins.leading + region.margins.trailing,
                          height: region.frame.height + region.margins.top + region.margins.bottom)
        }
        return nil
    }
}

private struct CalculationPanel: View {
    @Binding var calculator: CalculatorState

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 430
            ScrollView {
                VStack(spacing: compact ? 8 : 20) {
                    if !compact { Spacer(minLength: 0) }
                    CalculatorInput(title: "Percent", value: calculator.percent, suffix: "%",
                                    selected: calculator.activeInput == .percent,
                                    identifier: "input.percent",
                                    select: { calculator.activeInput = .percent },
                                    clear: { calculator.clearPercent() })
                    HStack(spacing: 8) {
                        modeButton("Off", action: .off)
                        modeButton("Of", action: .of)
                    }
                    CalculatorInput(title: "Amount", value: calculator.amount, suffix: "",
                                    selected: calculator.activeInput == .amount,
                                    identifier: "input.amount",
                                    select: { calculator.activeInput = .amount },
                                    clear: { calculator.clearAmount() })
                    if !compact { Spacer(minLength: 0) }
                    let totalLayout = compact
                        ? AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
                        : AnyLayout(VStackLayout(alignment: .trailing, spacing: 6))
                    totalLayout {
                        Text("Total")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(CalculatorPalette.secondary)
                        if compact { Spacer(minLength: 0) }
                        Text(calculator.total)
                            .font(.system(size: compact ? 36 : 44, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.35)
                            .accessibilityIdentifier("result.total")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, compact ? 4 : 20)
                }
                .padding(compact ? 16 : 24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .accessibilityIdentifier("panel.calculation")
    }

    private func modeButton(_ title: String, action: CalculatorState.PercentAction) -> some View {
        let selected = calculator.percentAction == action
        return Button { calculator.selectAction(action) } label: {
            Text(title)
                .font(.headline)
                .frame(minWidth: 64, minHeight: 44)
                .background(selected ? CalculatorPalette.text : CalculatorPalette.neutral,
                            in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(selected ? CalculatorPalette.ink : CalculatorPalette.text)
        }
        .accessibilityIdentifier("mode.\(title.lowercased())")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct CalculatorInput: View {
    let title: String
    let value: String
    let suffix: String
    let selected: Bool
    let identifier: String
    let select: () -> Void
    let clear: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CalculatorPalette.secondary)
            HStack(spacing: 8) {
                if value != "0" {
                    Button(action: clear) {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                            .frame(width: 44, height: 44)
                    }
                    .foregroundStyle(CalculatorPalette.secondary)
                    .accessibilityLabel("Clear \(title.lowercased())")
                    .accessibilityIdentifier("\(identifier).clear")
                }
                Button(action: select) {
                    Text(value + suffix)
                        .font(.system(size: 34, weight: .regular, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("\(title), \(value)\(suffix)")
                .accessibilityIdentifier(identifier)
            }
            Rectangle()
                .fill(selected ? CalculatorPalette.key : CalculatorPalette.neutral)
                .frame(height: 2)
                .accessibilityHidden(true)
        }
    }
}

private struct CalculatorKeypad: View {
    @Binding var calculator: CalculatorState
    private let rows: [[CalculatorState.InputButtons]] = [
        [.seven, .eight, .nine], [.four, .five, .six],
        [.one, .two, .three], [.delete, .zero, .decimal]
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Button { calculator.clearAll() } label: {
                        Text("Clear all")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .frame(minHeight: 44)
                            .background(CalculatorPalette.neutral, in: RoundedRectangle(cornerRadius: 10))
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityIdentifier("clear.all")

                    VStack(spacing: 12) {
                        ForEach(rows, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(row, id: \.self) { key in
                                    Button { calculator.didTap(button: key) } label: {
                                        Group {
                                            if key == .delete {
                                                Image(systemName: key.rawValue)
                                            } else {
                                                Text(key.rawValue)
                                            }
                                        }
                                        .font(.system(size: 30, weight: .medium, design: .rounded))
                                        .frame(maxWidth: .infinity, minHeight: 48, maxHeight: .infinity)
                                        .background(CalculatorPalette.key, in: RoundedRectangle(cornerRadius: 12))
                                        .foregroundStyle(CalculatorPalette.ink)
                                        .contentShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .accessibilityLabel(key == .delete ? "Delete" : key.rawValue)
                                    .accessibilityIdentifier("key.\(key.rawValue)")
                                }
                            }
                        }
                    }
                    .frame(height: max(228, min(geometry.size.height - 88, 420)))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(CalculatorPalette.tray, in: RoundedRectangle(cornerRadius: 28))
        .accessibilityIdentifier("panel.keypad")
    }
}

#Preview { ContentView() }
