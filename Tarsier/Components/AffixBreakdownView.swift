import SwiftUI

struct WordPart: Identifiable {
    let id = UUID()
    let text: String
    let type: WordPartType
    let label: String

    enum WordPartType {
        case prefix, infix, suffix, root

        var color: Color {
            switch self {
            case .prefix, .infix, .suffix:
                return TarsierColors.functionalPurple
            case .root:
                return TarsierColors.tarsierDark
            }
        }

        var isAffix: Bool {
            self != .root
        }
    }
}

struct AffixBreakdownView: View {
    let parts: [WordPart]
    let meaning: String

    var body: some View {
        VStack(spacing: TarsierSpacing.itemSpacing) {
            // Word parts with colored underlines
            HStack(spacing: 2) {
                ForEach(parts) { part in
                    VStack(spacing: 4) {
                        Text(part.text)
                            .font(TarsierFonts.tagalogWord())
                            .foregroundStyle(TarsierColors.textPrimary)

                        // Colored underline
                        Rectangle()
                            .fill(part.type.color)
                            .frame(height: 3)

                        // Role label
                        Text(part.label)
                            .font(TarsierFonts.caption(11))
                            .foregroundStyle(part.type.color)
                    }
                }
            }

            // Combined meaning
            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                Text(meaning)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }
        }
        .padding(TarsierSpacing.cardPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .fill(TarsierColors.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }
}
