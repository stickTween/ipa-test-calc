import SwiftUI

enum CalcButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case dot = "."
    case equals = "="
    case plus = "+", minus = "-", multiply = "×", divide = "÷"
    case percent = "%"
    case clear = "AC"
    case negative = "+/-"

    var buttonColor: Color {
        switch self {
        case .divide, .multiply, .minus, .plus, .equals:
            return .orange
        case .clear, .negative, .percent:
            return Color(white: 0.7)
        default:
            return Color(white: 0.2)
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, none
}

struct ContentView: View {
    @State private var display = "0"
    @State private var currentOperation: Operation = .none
    @State private var previousValue: Double = 0
    @State private var shouldResetDisplay = false

    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .dot, .equals]
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Spacer()
                HStack {
                    Spacer()
                    Text(display)
                        .foregroundColor(.white)
                        .font(.system(size: 72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                }
                .padding(.horizontal)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button(action: { tap(button) }) {
                                Text(button.rawValue)
                                    .font(.system(size: 32))
                                    .frame(
                                        width: buttonWidth(button),
                                        height: buttonHeight()
                                    )
                                    .foregroundColor(.white)
                                    .background(button.buttonColor)
                                    .cornerRadius(buttonHeight() / 2)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func buttonWidth(_ button: CalcButton) -> CGFloat {
        let screen = UIScreen.main.bounds.width
        if button == .zero {
            return (screen - 5 * 12) / 4 * 2 + 12
        }
        return (screen - 5 * 12) / 4
    }

    private func buttonHeight() -> CGFloat {
        (UIScreen.main.bounds.width - 5 * 12) / 4
    }

    private func tap(_ button: CalcButton) {
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            let digit = button.rawValue
            if shouldResetDisplay {
                display = digit
                shouldResetDisplay = false
            } else {
                display = display == "0" ? digit : display + digit
            }
        case .dot:
            if shouldResetDisplay {
                display = "0."
                shouldResetDisplay = false
            } else if !display.contains(".") {
                display += "."
            }
        case .clear:
            display = "0"
            currentOperation = .none
            previousValue = 0
        case .negative:
            if let value = Double(display) {
                display = formatted(value * -1)
            }
        case .percent:
            if let value = Double(display) {
                display = formatted(value / 100)
            }
        case .plus, .minus, .multiply, .divide:
            previousValue = Double(display) ?? 0
            currentOperation = operation(for: button)
            shouldResetDisplay = true
        case .equals:
            let current = Double(display) ?? 0
            let result: Double
            switch currentOperation {
            case .add: result = previousValue + current
            case .subtract: result = previousValue - current
            case .multiply: result = previousValue * current
            case .divide: result = current == 0 ? 0 : previousValue / current
            case .none: result = current
            }
            display = formatted(result)
            currentOperation = .none
            shouldResetDisplay = true
        }
    }

    private func operation(for button: CalcButton) -> Operation {
        switch button {
        case .plus: return .add
        case .minus: return .subtract
        case .multiply: return .multiply
        case .divide: return .divide
        default: return .none
        }
    }

    private func formatted(_ value: Double) -> String {
        if value == value.rounded() && abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }
        return String(value)
    }
}

#Preview {
    ContentView()
}