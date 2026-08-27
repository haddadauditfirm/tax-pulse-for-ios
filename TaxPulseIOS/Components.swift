import SwiftUI

struct AppCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.slateBorder, lineWidth: 1)
        )
    }
}

struct ResultRow: View {
    var title: String
    var value: String
    var valueColor: Color = .slateTextDark
    var isBold = false
    var titleFontSize: CGFloat = 11

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.app(titleFontSize, weight: .bold))
                .foregroundStyle(Color.slateTextDark)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.app(11.5, weight: isBold ? .bold : .regular))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                // Amounts are a single logical LTR token (sign + digits + currency),
                // so they must not be reordered by the surrounding RTL context.
                .environment(\.layoutDirection, .leftToRight)
        }
        .padding(.vertical, 6)
    }
}

/// Renders "Current Value: <amount> <currency>" so it reads naturally in both
/// directions.
///
/// The label, the grouped number and the currency word are three separate layout
/// nodes inside a direction-aware HStack. That ordering matters: bundling the number
/// and currency into one bidi-isolated string puts the currency at the run's right
/// edge, so an Arabic reader scanning right-to-left hits "ل.ل" *before* the digits.
/// Splitting them lets RTL place the number to the right of the currency, giving the
/// intended reading order "القيمة الحالية: ٢,٦٠٠,٠٠٠,٠٠٠ ل.ل", while LTR still reads
/// "Current Value: 2,600,000,000 LBP". The number keeps its own LTR direction so the
/// digit groups and separators are never reordered.
struct CurrentValueLine: View {
    var label: String
    var amount: Double
    var language: AppLanguage
    var color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
            Text(groupedAmount)
                .environment(\.layoutDirection, .leftToRight)
            Text(currencyWord)
        }
        .environment(\.layoutDirection, language == .arabic ? .rightToLeft : .leftToRight)
        .font(.app(11, weight: .bold))
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: language == .arabic ? .trailing : .leading)
        .accessibilityElement(children: .combine)
    }

    private var groupedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount.rounded())) ?? "0"
    }

    private var currencyWord: String {
        language == .arabic ? "\u{0644}.\u{0644}" : "LBP"
    }
}

struct PillButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.app(13, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blueAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.blueAccent.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.blueAccent)
    }
}

/// Neutral slate info note with a leading info glyph — Android's shared pattern for
/// the annual NSSF ceiling note and the corporate/partnership auditor-report note.
struct InfoNoteBox: View {
    var text: String
    var fontSize: CGFloat = 11
    var background: Color = .slateLight
    var borderColor: Color = .slateBorder
    var textColor: Color = .slateTextDark
    var iconColor: Color = .navyPrimary

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.app(16, weight: .semibold))
                .foregroundStyle(iconColor)
                .padding(.top, 1)
            Text(text)
                .font(.app(fontSize, weight: .medium))
                .foregroundStyle(textColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

/// A small vector calculator glyph — rounded body, a screen bar, and a 3x2 key
/// grid — since "calculator" is not an actual SF Symbol on this SDK and the closest
/// real symbols (math operators) don't read as a calculator the way Android's does.
struct CalculatorIcon: View {
    var color: Color = .white

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let body = RoundedRectangle(cornerRadius: w * 0.2, style: .continuous)
                .path(in: CGRect(x: 0, y: 0, width: w, height: h))
            context.stroke(body, with: .color(color), style: StrokeStyle(lineWidth: w * 0.09, lineCap: .round, lineJoin: .round))

            let screen = RoundedRectangle(cornerRadius: w * 0.05, style: .continuous)
                .path(in: CGRect(x: w * 0.18, y: h * 0.14, width: w * 0.64, height: h * 0.22))
            context.stroke(screen, with: .color(color), style: StrokeStyle(lineWidth: w * 0.07, lineCap: .round, lineJoin: .round))

            let dotSize = w * 0.12
            let columns: [CGFloat] = [w * 0.28, w * 0.5, w * 0.72]
            let rows: [CGFloat] = [h * 0.58, h * 0.79]
            for y in rows {
                for x in columns {
                    let dot = Circle().path(in: CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize))
                    context.fill(dot, with: .color(color))
                }
            }
        }
    }
}

/// The calculate CTA shared by the payroll, profit and penalties tabs.
/// Ports Android's `AnimatedCalculateButton`: 54pt tall, 12pt radius, a diagonal
/// NavyPrimary→#2563EB gradient, a 1.5pt white 25% hairline, and a leading
/// calculator glyph 10pt from the label.
struct AnimatedCalculateButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                CalculatorIcon()
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.app(15, weight: .bold))
                    .kerning(0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [Color.navyPrimary, Color(hex: 0x2563EB)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: Color.navyPrimary.opacity(0.28), radius: 4, y: 2)
        }
        // A ButtonStyle reads press state from the system's own tap recognizer
        // instead of adding a competing DragGesture(minimumDistance: 0) — that
        // extra recognizer was claiming touches immediately on touch-down,
        // which could keep the enclosing ScrollView from ever seeing a vertical
        // pan when the swipe started on this button.
        .buttonStyle(CalculateButtonPressStyle())
    }
}

private struct CalculateButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

struct PrimaryActionButton: View {
    var title: String
    var systemImage: String = "arrow.right"
    var color: Color = .blueAccent
    var cornerRadius: CGFloat = 16
    var iconOnLeading = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if iconOnLeading {
                    Image(systemName: systemImage)
                        .font(.app(14, weight: .black))
                    Text(title)
                        .font(.app(15, weight: .black))
                } else {
                    Text(title)
                        .font(.app(15, weight: .black))
                    Image(systemName: systemImage)
                        .font(.app(14, weight: .black))
                }
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: color.opacity(0.22), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct SectionIntro: View {
    var title: String
    var bodyText: String

    var body: some View {
        AppCard {
            Text(title)
                .font(.app(15, weight: .bold))
                .foregroundStyle(Color.navyPrimary)
            Text(bodyText)
                .font(.app(11))
                .foregroundStyle(Color.slateTextLight)
                .lineSpacing(3)
        }
    }
}

struct OptionChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.navyPrimary : Color.slateMuted, lineWidth: 1.5)
                        .frame(width: 19, height: 19)
                    if isSelected {
                        Circle()
                            .fill(Color.navyPrimary)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(title)
                    .font(.app(12, weight: .bold))
                    .foregroundStyle(isSelected ? Color.navyPrimary : Color.slateTextDark)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.app(12, weight: .black))
                        .foregroundStyle(Color.navyPrimary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.navyPrimary.opacity(0.08) : Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.navyPrimary : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct OptionRow: View {
    var options: [(String, String)]
    var selected: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(options, id: \.0) { key, title in
                OptionChip(title: title, isSelected: selected == key) {
                    onSelect(key)
                }
            }
        }
    }
}

struct HorizontalToggleRow: View {
    var options: [(String, String)]
    var selected: String
    var onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.0) { key, title in
                let isSelected = selected == key
                Button {
                    onSelect(key)
                } label: {
                    Text(title)
                        .font(.app(12, weight: .bold))
                        .foregroundStyle(isSelected ? Color.white : Color.slateTextLight)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .padding(.horizontal, 6)
                        .background(isSelected ? Color.navyPrimary : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.slateLight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct LanguageSegmentedControl: View {
    var selected: String
    var onSelect: (String) -> Void

    private let options = [("EN", "ENG"), ("AR", "ARB")]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.0) { key, title in
                let isSelected = selected == key
                Button {
                    onSelect(key)
                } label: {
                    Text(title)
                        .font(.app(14, weight: .black))
                        .foregroundStyle(isSelected ? Color.white : Color.navyPrimary)
                        .frame(width: 70, height: 42)
                        .background(isSelected ? Color.blueAccent : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(key == "EN" ? "English" : "Arabic")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.slateBorder, lineWidth: 1))
        .shadow(color: Color.navyDark.opacity(0.08), radius: 5, y: 2)
        .fixedSize(horizontal: true, vertical: true)
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct CompactOptionButton: View {
    var title: String
    var subtitle: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.app(12, weight: .black))
                if let subtitle {
                    Text(subtitle)
                        .font(.app(8, weight: .bold))
                        .opacity(isSelected ? 0.82 : 0.7)
                }
            }
            .foregroundStyle(isSelected ? Color.white : Color.navyMedium)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.navyPrimary : Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct CompactOptionRow: View {
    var options: [(String, String, String?)]
    var selected: String
    var onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 5) {
            ForEach(options, id: \.0) { key, title, subtitle in
                CompactOptionButton(title: title, subtitle: subtitle, isSelected: selected == key) {
                    onSelect(key)
                }
            }
        }
        .padding(3)
        .background(Color.slateLight)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Color.slateBorder, lineWidth: 1))
    }
}

struct SelectableCardGrid: View {
    var options: [(key: String, title: String, subtitle: String)]
    var selected: String
    var columns: Int = 2
    var selectedFill: Color = .navyPrimary
    var selectedText: Color = .white
    var onSelect: (String) -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
            ForEach(options, id: \.key) { option in
                let isSelected = selected == option.key
                Button {
                    onSelect(option.key)
                } label: {
                    VStack(spacing: 4) {
                        Text(option.title)
                            .font(.app(12, weight: .black))
                            .foregroundStyle(isSelected ? selectedText : Color.navyPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.76)
                        Text(option.subtitle)
                            .font(.app(10, weight: .medium))
                            .foregroundStyle(isSelected ? selectedText.opacity(0.82) : Color.slateTextLight)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, minHeight: 74)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .background(isSelected ? selectedFill : Color.slate50)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? selectedFill : Color.slateBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct NumberCircle: View {
    var number: Int
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.app(13, weight: .black))
                .foregroundStyle(isSelected ? Color.white : Color.slateTextDark)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.navyPrimary : Color.slateLight)
                .clipShape(Circle())
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}

/// Live thousands-separated numeric input.
///
/// Mirrors Android's `ThousandsSeparatorVisualTransformation`: the binding always
/// holds the **raw** unformatted value (digits, plus one optional `.`), while the
/// field *displays* comma-grouped text. Grouping applies only to the integer part,
/// and a trailing `.` is preserved so "1500." reads as "1,500." mid-typing.
///
/// Backed by UITextField rather than SwiftUI's TextField for two reasons the spec
/// calls out: the caret must not jump when commas are inserted (handled by counting
/// significant characters either side of the edit), and numeric keypads need a real
/// Done accessory to dismiss them.
struct NumericTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var decimal: Bool
    var grouping: Bool = true
    var maxDigits: Int? = nil
    var font: UIFont = .systemFont(ofSize: 15 * Typography.scale, weight: .medium)
    var textColor: UIColor = UIColor(Color.slateTextDark)
    /// Visual alignment only — digit order and the parsed/bound value are untouched.
    var textAlignment: NSTextAlignment = .left

    static func sanitize(_ input: String, decimal: Bool) -> String {
        var seenDot = false
        var out = ""
        for ch in input {
            if ch.isNumber {
                out.append(ch)
            } else if decimal, ch == ".", !seenDot {
                out.append(ch)
                seenDot = true
            }
        }
        return out
    }

    static func group(_ raw: String, grouping: Bool) -> String {
        guard grouping else { return raw }
        let parts = raw.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let intPart = String(parts.first ?? "")
        var grouped = ""
        for (offset, ch) in intPart.enumerated() {
            grouped.append(ch)
            let remaining = intPart.count - 1 - offset
            if remaining > 0, remaining % 3 == 0 { grouped.append(",") }
        }
        if parts.count > 1 { return grouped + "." + String(parts[1]) }
        if raw.hasSuffix(".") { return grouped + "." }
        return grouped
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.keyboardType = decimal ? .decimalPad : .numberPad
        field.font = font
        field.textColor = textColor
        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 11
        // Numeric keypads have no return key, so a Done accessory is the only
        // reliable way for the user to dismiss the keyboard.
        field.inputAccessoryView = context.coordinator.makeToolbar()
        field.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        field.semanticContentAttribute = .forceLeftToRight
        field.textAlignment = textAlignment
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        field.placeholder = placeholder
        field.keyboardType = decimal ? .decimalPad : .numberPad
        field.font = font
        field.textColor = textColor
        field.textAlignment = textAlignment
        let desired = Self.group(text, grouping: grouping)
        if field.text != desired, !context.coordinator.isEditingInternally {
            field.text = desired
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NumericTextField
        var isEditingInternally = false

        init(parent: NumericTextField) { self.parent = parent }

        func makeToolbar() -> UIToolbar {
            let bar = UIToolbar()
            bar.sizeToFit()
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
            done.style = .done
            bar.items = [spacer, done]
            return bar
        }

        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        /// Reformats on every keystroke while keeping the caret anchored to the same
        /// number of significant (non-separator) characters.
        @objc func editingChanged(_ field: UITextField) {
            let old = field.text ?? ""
            // How many digits/dots precede the caret right now?
            var significantBeforeCaret = old.count
            if let selected = field.selectedTextRange {
                let caret = field.offset(from: field.beginningOfDocument, to: selected.start)
                significantBeforeCaret = old.prefix(caret).filter { $0.isNumber || $0 == "." }.count
            }

            var raw = NumericTextField.sanitize(old, decimal: parent.decimal)
            if let cap = parent.maxDigits {
                let digitsOnly = raw.filter(\.isNumber)
                if digitsOnly.count > cap {
                    raw = String(raw.prefix(while: { _ in true }).prefix(cap))
                    significantBeforeCaret = min(significantBeforeCaret, cap)
                }
            }
            let formatted = NumericTextField.group(raw, grouping: parent.grouping)

            isEditingInternally = true
            field.text = formatted
            if parent.text != raw { parent.text = raw }

            // The binding may reject or clamp what we just pushed (the 2024 penalty
            // year floor is the live case). Read it back and re-assert the
            // authoritative value here rather than waiting for `updateUIView`:
            // when the clamped result equals the value already in state, SwiftUI
            // sees no change and may never re-render, which would leave the
            // rejected text on screen.
            let authoritative = NumericTextField.group(parent.text, grouping: parent.grouping)
            if authoritative != formatted {
                field.text = authoritative
                if let end = field.position(from: field.beginningOfDocument, offset: authoritative.count) {
                    field.selectedTextRange = field.textRange(from: end, to: end)
                }
                isEditingInternally = false
                return
            }

            // Walk the formatted string until we've passed the same count of
            // significant characters, then place the caret there.
            var seen = 0
            var targetOffset = formatted.count
            for (idx, ch) in formatted.enumerated() {
                if seen >= significantBeforeCaret { targetOffset = idx; break }
                if ch.isNumber || ch == "." { seen += 1 }
            }
            if seen < significantBeforeCaret { targetOffset = formatted.count }
            if let pos = field.position(from: field.beginningOfDocument, offset: targetOffset) {
                field.selectedTextRange = field.textRange(from: pos, to: pos)
            }
            isEditingInternally = false
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isEditingInternally = false
            textField.text = NumericTextField.group(parent.text, grouping: parent.grouping)
        }
    }
}

/// Year selector for Tax Penalties.
///
/// Replaces the free-text year input: the list starts at the legal floor, so a year
/// before it is simply not offerable and the old "you cannot go back before 2024"
/// alert became unreachable. Styled to match `StyledTextField` so the row still
/// lines up with the quarter selector beside it.
struct YearPickerField: View {
    var title: String
    @Binding var year: String
    var years: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.app(11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            Menu {
                ForEach(years, id: \.self) { candidate in
                    Button(candidate) { year = candidate }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(year)
                        .font(.app(15, weight: .bold))
                        .foregroundStyle(Color.navyPrimary)
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.app(12, weight: .bold))
                        .foregroundStyle(Color.navyMedium)
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.slate50)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.slateBorder, lineWidth: 1)
                )
            }
            // Digits read left-to-right even in Arabic.
            .environment(\.layoutDirection, .leftToRight)
        }
    }
}

struct StyledTextField: View {
    var title: String
    var placeholder: String
    var suffix: String?
    @Binding var text: String
    var decimal = false
    var leadingSystemImage: String?
    var trailingSystemImage: String?
    var trailingColor: Color = .navyPrimary
    /// Off for day/month/year style inputs where grouping would be wrong.
    var grouping = true
    var maxDigits: Int? = nil
    /// Visual alignment only — digit order and the parsed/bound value are untouched.
    var textAlignment: NSTextAlignment = .left

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.app(11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            HStack(spacing: 8) {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                        .font(.app(16, weight: .semibold))
                        .foregroundStyle(Color.navyMedium)
                }
                NumericTextField(
                    text: $text,
                    placeholder: placeholder,
                    decimal: decimal,
                    grouping: grouping,
                    maxDigits: maxDigits,
                    textAlignment: textAlignment
                )
                .frame(height: 24)
                if let trailingSystemImage {
                    Image(systemName: trailingSystemImage)
                        .font(.app(16, weight: .bold))
                        .foregroundStyle(trailingColor)
                }
                if let suffix {
                    Text(suffix)
                        .font(.app(11, weight: .black))
                        .foregroundStyle(Color.navyPrimary)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(Color.slate50)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.slateBorder, lineWidth: 1)
            )
        }
    }
}

struct ToggleLine: View {
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.app(12, weight: .bold))
                .foregroundStyle(Color.slateTextDark)
        }
        .tint(.blueAccent)
    }
}

struct AndroidToggleCard: View {
    var icon: String
    var title: String
    var subtitle: String?
    var subtitleLineLimit: Int? = 2
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.app(18, weight: .bold))
                    .foregroundStyle(isOn ? Color.navyPrimary : Color.slateMuted)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.app(12, weight: .black))
                        .foregroundStyle(Color.slateTextDark)
                    if let subtitle {
                        Text(subtitle)
                            .font(.app(10, weight: .semibold))
                            .foregroundStyle(Color.blueAccent)
                            .lineLimit(subtitleLineLimit)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                // Purely visual: the outer Button already drives `isOn` for the whole
                // row. Leaving this switch tappable too meant a tap landing on it
                // could fire both the switch's own toggle AND the enclosing Button's,
                // toggling `isOn` twice — which reads as "the toggle turned itself
                // back off" right after the user turned it on.
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(.blueAccent)
                    .allowsHitTesting(false)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(isOn ? Color.navyPrimary.opacity(0.05) : Color.slate50)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isOn ? Color.navyPrimary.opacity(0.3) : Color.slateBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct BorderedPillButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.app(11, weight: .black))
                .foregroundStyle(Color.blueAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.slateLight)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.slateBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Android's centered "info" placeholder card — a small filled navy circle with a
/// white "i", then optionally a bold centered heading, then centered body text.
/// Used beneath the Calculate button before a result exists.
struct CenteredInfoCard: View {
    var title: String? = nil
    var text: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.navyPrimary)
                Image(systemName: "info")
                    .font(.app(13, weight: .black))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 28, height: 28)

            if let title {
                Text(title)
                    .font(.app(13, weight: .bold))
                    .foregroundStyle(Color.navyPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(text)
                .font(.app(11, weight: title == nil ? .medium : .regular))
                .foregroundStyle(title == nil ? Color.slateTextDark : Color.slateTextLight)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.slateBorder, lineWidth: 1)
        )
    }
}

/// Canonical Payroll/Profit marital-status ordering, icons, and row style — a single
/// source of truth so the two tabs can never drift apart again. Order matches Android
/// exactly: Single, Spouse doesn't work, Spouse works, Divorced, Widowed.
private let maritalStatusOrder: [(key: String, icon: String)] = [
    ("SINGLE", "person.fill"),
    ("SPOUSE_DEPENDENT", "person.2.fill"),
    ("SPOUSE_WORKS", "briefcase.fill"),
    ("DIVORCED", "person.fill"),
    ("WIDOWED", "person.fill")
]

struct MaritalStatusSelector: View {
    var language: AppLanguage
    var selected: String
    var onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Copy.t("marital", language))
                .font(.app(11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            VStack(spacing: 8) {
                ForEach(maritalStatusOrder, id: \.key) { item in
                    MaritalStatusRow(
                        title: maritalLabel(for: item.key),
                        icon: item.icon,
                        isSelected: selected == item.key
                    ) {
                        onSelect(item.key)
                    }
                }
            }
        }
    }

    private func maritalLabel(for key: String) -> String {
        switch key {
        case "SINGLE": return Copy.t("single", language)
        case "SPOUSE_DEPENDENT": return Copy.t("spouseDependent", language)
        case "SPOUSE_WORKS": return Copy.t("spouseWorks", language)
        case "DIVORCED": return Copy.t("divorced", language)
        default: return Copy.t("widowed", language)
        }
    }
}

private struct MaritalStatusRow: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            // Icon hugs the leading (start) edge, the radio hugs the trailing (end)
            // edge — matching Android's Row(Arrangement.SpaceBetween). Under RTL this
            // renders the icon on the right and the radio on the left, as in the
            // Android Arabic screenshots.
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.app(16, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.navyPrimary : Color.slateTextLight)
                    .frame(width: 20)
                Text(title)
                    .font(.app(13, weight: .bold))
                    .foregroundStyle(isSelected ? Color.navyPrimary : Color.slateTextDark)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.navyPrimary : Color.slateMuted, lineWidth: 1.8)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.navyPrimary)
                            .frame(width: 11, height: 11)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.navyPrimary.opacity(0.06) : Color.slateLight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.navyPrimary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

/// Branded modal icon styles Android uses across its alert dialogs.
enum ModalIconStyle {
    case triangle(Color)
    case success
}

/// One branded modal design shared by every Tax Pulse alert (year restriction,
/// extension same-date warning, extension saved) so parity can't drift between them.
/// Callers are responsible for presenting this inside a dimmed full-screen overlay.
struct TaxPulseModal: View {
    var icon: ModalIconStyle
    var title: String
    var message: String
    var primaryTitle: String
    var primaryAction: () -> Void
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            iconView
            Text(title)
                .font(.app(17, weight: .black))
                .foregroundStyle(Color.navyPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.app(14, weight: .medium))
                .foregroundStyle(Color.slateTextDark)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 4)
            buttons
        }
        .padding(28)
        .frame(maxWidth: 340)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 30, y: 12)
    }

    @ViewBuilder private var iconView: some View {
        switch icon {
        case .triangle(let color):
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.app(44))
                .foregroundStyle(color)
        case .success:
            ZStack {
                Circle().fill(Color.successGreen)
                Image(systemName: "checkmark")
                    .font(.app(24, weight: .black))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 56, height: 56)
        }
    }

    @ViewBuilder private var buttons: some View {
        if let secondaryTitle, let secondaryAction {
            HStack(spacing: 12) {
                Button(action: secondaryAction) {
                    Text(secondaryTitle)
                        .font(.app(14, weight: .bold))
                        .foregroundStyle(Color.slateTextLight)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
                Button(action: primaryAction) {
                    Text(primaryTitle)
                        .font(.app(14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.navyPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        } else {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.app(15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.navyPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

/// Presents `AppState.activeModal` as a dimmed full-screen overlay. Mounted once at
/// the calculator shell so any tab can trigger a modal via `state.activeModal = ...`.
struct AppModalHost: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Group {
            if let modal = state.activeModal {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                    content(for: modal)
                        .padding(.horizontal, 32)
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: state.activeModal)
    }

    @ViewBuilder
    private func content(for modal: AppModal) -> some View {
        switch modal {
        case .extensionSaved:
            TaxPulseModal(
                icon: .success,
                title: Copy.t("extensionSavedTitle", state.language),
                message: Copy.t("extensionSavedMessage", state.language),
                primaryTitle: Copy.t("ok", state.language),
                primaryAction: { state.activeModal = nil }
            )
        case .extensionSameDate(let dateText):
            TaxPulseModal(
                icon: .triangle(Color.orange800),
                title: Copy.t("extensionSameDateTitle", state.language),
                message: Copy.t("extensionSameDateMessage", state.language)
                    .replacingOccurrences(of: "%@", with: dateText),
                primaryTitle: Copy.t("saveAnyway", state.language),
                primaryAction: { state.performSaveExtension() },
                secondaryTitle: Copy.t("cancel", state.language),
                secondaryAction: { state.activeModal = nil }
            )
        }
    }
}
