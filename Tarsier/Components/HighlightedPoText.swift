import SwiftUI

/// Renders text with standalone "po" words displayed as rounded chips (pill shape with padding).
struct HighlightedPoText: View {
    let text: String
    let font: Font
    let baseColor: Color

    private struct WordSegment: Identifiable {
        let id: Int
        let text: String
        let isPo: Bool
    }

    private var words: [WordSegment] {
        // Split by spaces, preserving empty segments for multiple spaces
        let components = text.components(separatedBy: " ")
        return components.enumerated().map { index, word in
            // Match "po" optionally followed by punctuation (e.g. "po", "po?", "po,", "Po.")
            let isPo = word.range(of: "^[Pp]o[.,!?;:…]*$", options: .regularExpression) != nil
            return WordSegment(id: index, text: word, isPo: isPo)
        }
    }

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(words) { word in
                if word.isPo {
                    poChip(word.text)
                } else {
                    Text(word.text)
                        .font(font)
                        .foregroundStyle(baseColor)
                        .padding(.vertical, 2) // match chip vertical padding for alignment
                }
            }
        }
    }

    @ViewBuilder
    private func poChip(_ raw: String) -> some View {
        // Separate "po"/"Po" from any trailing punctuation
        let poText = String(raw.prefix(2))
        let trailing = String(raw.dropFirst(2))

        HStack(spacing: 0) {
            Text(poText)
                .font(font)
                .foregroundStyle(TarsierColors.functionalPurple)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule().fill(TarsierColors.primaryLight)
                )
            if !trailing.isEmpty {
                Text(trailing)
                    .font(font)
                    .foregroundStyle(baseColor)
            }
        }
    }
}
