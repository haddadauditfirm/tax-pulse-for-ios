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

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 12, weight: isBold ? .bold : .regular))
                .foregroundStyle(Color.slateTextLight)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 12, weight: isBold ? .black : .bold))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct PillButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .bold))
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

struct PrimaryActionButton: View {
    var title: String
    var systemImage: String = "arrow.right"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .black))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(colors: [.navyMedium, .blueAccent], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .blueAccent.opacity(0.22), radius: 12, y: 8)
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
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.navyPrimary)
            Text(bodyText)
                .font(.system(size: 11))
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
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? Color.white : Color.navyMedium)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .padding(.horizontal, 6)
                .background(isSelected ? Color.navyPrimary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct OptionRow: View {
    var options: [(String, String)]
    var selected: String
    var onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.0) { key, title in
                OptionChip(title: title, isSelected: selected == key) {
                    onSelect(key)
                }
            }
        }
        .padding(4)
        .background(Color.slateLight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct NumberCircle: View {
    var number: Int
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isSelected ? Color.white : Color.slateTextDark)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(isSelected ? Color.navyPrimary : Color.slateLight)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct StyledTextField: View {
    var title: String
    var placeholder: String
    var suffix: String?
    @Binding var text: String
    var decimal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.slateTextLight)
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(decimal ? .decimalPad : .numberPad)
                    .textInputAutocapitalization(.never)
                if let suffix {
                    Text(suffix)
                        .font(.system(size: 11, weight: .black))
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
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.slateTextDark)
        }
        .tint(.blueAccent)
    }
}
