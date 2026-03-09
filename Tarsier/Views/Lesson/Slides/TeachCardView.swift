import SwiftUI

struct TeachCardView: View {
    let card: SessionCard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Lesson image — render ONLY if file exists in bundle. No placeholder.
            if let uiImage = loadCardImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
                    .accessibilityLabel(card.image?.alt ?? "Lesson image")
            }

            // Body text (with "po" highlighting)
            if let body = card.body {
                Text(highlightPo(in: body, font: TarsierFonts.body(), baseColor: TarsierColors.textPrimary))
                    .lineSpacing(4)
            }

            // Highlight (bold, purple — with "po" highlighting)
            if let highlight = card.highlight {
                Text(highlightPo(in: highlight, font: TarsierFonts.tagalogWord(22), baseColor: TarsierColors.functionalPurple))
            }

            // Example
            if let example = card.example {
                exampleCard(example)
            }
        }
    }

    // MARK: - Image Loading

    /// Returns UIImage only if the file actually exists. Returns nil otherwise — no placeholder.
    private func loadCardImage() -> UIImage? {
        guard let filename = card.image?.filename, !filename.isEmpty else { return nil }
        // Try asset catalog first, then bundle root
        if let img = UIImage(named: filename) { return img }
        // Try without extension in asset catalog (filename may include .jpg)
        let nameWithoutExt = (filename as NSString).deletingPathExtension
        if let img = UIImage(named: nameWithoutExt) { return img }
        return nil
    }

    // MARK: - Example Card

    @ViewBuilder
    private func exampleCard(_ example: CardExample) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Context label (e.g. "Speaking to your lola")
            if let context = example.context {
                Text(context)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            if let casual = example.casual, let withPo = example.withPo {
                // Format 1: casual → with_po transformation
                HStack(spacing: 8) {
                    Text(highlightPo(in: casual, font: TarsierFonts.body(), baseColor: TarsierColors.textSecondary))
                    Image(systemName: "arrow.right")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                    Text(highlightPo(in: withPo, font: TarsierFonts.body().bold(), baseColor: TarsierColors.functionalPurple))
                }
            } else if let sentence = example.sentence {
                // Format 2: sentence + translation
                Text(highlightPo(in: sentence, font: TarsierFonts.tagalogWord(18), baseColor: TarsierColors.textPrimary))

                if let translation = example.translation {
                    Text(highlightPo(in: translation, font: TarsierFonts.body(15), baseColor: TarsierColors.textSecondary))
                }

                if let poPosition = example.poPosition {
                    Text(poPosition)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.functionalPurple)
                        .italic()
                }
            }

            // Note
            if let note = example.note {
                Text(note)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }

            // Taglish variant callout
            if let taglish = example.taglish {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(TarsierColors.functionalPurple)
                        .frame(width: 3)
                    Text(taglish)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                        .padding(.leading, 10)
                        .padding(.vertical, 6)
                }
                .padding(.top, 4)
            }
        }
        .padding(TarsierSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(TarsierColors.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - "Po" Highlighting

/// Highlights standalone "po" (whole-word, case-insensitive) with purple text on light purple background.
func highlightPo(in text: String, font: Font, baseColor: Color) -> AttributedString {
    var result = AttributedString(text)
    result.font = font
    result.foregroundColor = baseColor

    // Match \bpo\b case-insensitive
    guard let regex = try? NSRegularExpression(pattern: "\\bpo\\b", options: .caseInsensitive) else {
        return result
    }

    let nsString = text as NSString
    let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))

    for match in matches {
        guard let range = Range(match.range, in: text),
              let attrRange = Range(range, in: result) else { continue }
        result[attrRange].foregroundColor = UIColor(TarsierColors.functionalPurple)
        result[attrRange].backgroundColor = UIColor(TarsierColors.brandPurple.opacity(0.15))
    }

    return result
}
