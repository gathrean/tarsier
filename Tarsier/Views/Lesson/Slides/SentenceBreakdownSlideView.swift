import SwiftUI

struct SentenceBreakdownSlideView: View {
    let sentence: SlideSentence
    @State private var selectedWord: SentenceWord?

    var body: some View {
        VStack(spacing: 24) {
            // Full sentence
            VStack(spacing: 8) {
                Text(sentence.tagalog)
                    .font(TarsierFonts.tagalogWord(22))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(sentence.english)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Tappable word chips
            Text("Tap a word to see its role")
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)

            FlowLayout(spacing: 8) {
                ForEach(sentence.words) { word in
                    WordChip(
                        word: word,
                        isSelected: selectedWord?.word == word.word,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedWord = selectedWord?.word == word.word ? nil : word
                            }
                        }
                    )
                }
            }

            // Expanded word detail
            if let word = selectedWord {
                WordDetailCard(word: word)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Taglish variant
            if let taglish = sentence.taglishVariant, !taglish.isEmpty {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(TarsierColors.functionalPurple)
                        .frame(width: 3)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Taglish")
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.functionalPurple)
                        Text(taglish)
                            .font(TarsierFonts.body(15))
                            .foregroundStyle(TarsierColors.textPrimary)
                    }
                    .padding(.leading, 10)
                    .padding(.vertical, 8)

                    Spacer()
                }
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(TarsierColors.cream)
                )
            }
        }
    }
}

// MARK: - Word Chip

private struct WordChip: View {
    let word: SentenceWord
    let isSelected: Bool
    let onTap: () -> Void

    private var hasAffix: Bool { word.hasAffix ?? false }

    var body: some View {
        Button(action: onTap) {
            Text(word.word)
                .font(TarsierFonts.body())
                .foregroundStyle(isSelected ? .white : TarsierColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? TarsierColors.functionalPurple : TarsierColors.cream)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            hasAffix ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                            lineWidth: hasAffix ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Word Detail Card

private struct WordDetailCard: View {
    let word: SentenceWord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Word + role
            HStack {
                Text(word.word)
                    .font(TarsierFonts.tagalogWord(20))
                    .foregroundStyle(TarsierColors.textPrimary)
                Spacer()
                Text(word.role)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.functionalPurple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(TarsierColors.brandPurple.opacity(0.15))
                    )
            }

            // Meaning
            if let meaning = word.meaning {
                Text(meaning)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            // Affix breakdown
            if word.hasAffix ?? false, let affix = word.affix, let root = word.root {
                Divider()

                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text(affix)
                            .font(TarsierFonts.tagalogWord(18))
                            .foregroundStyle(TarsierColors.functionalPurple)
                        Text("affix")
                            .font(TarsierFonts.caption(11))
                            .foregroundStyle(TarsierColors.functionalPurple)
                    }

                    Text("+")
                        .font(TarsierFonts.heading())
                        .foregroundStyle(TarsierColors.textSecondary)

                    VStack(spacing: 2) {
                        Text(root)
                            .font(TarsierFonts.tagalogWord(18))
                            .foregroundStyle(TarsierColors.tarsierDark)
                        Text("root")
                            .font(TarsierFonts.caption(11))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }

                    Text("=")
                        .font(TarsierFonts.heading())
                        .foregroundStyle(TarsierColors.textSecondary)

                    VStack(spacing: 2) {
                        Text(word.word)
                            .font(TarsierFonts.tagalogWord(18))
                            .foregroundStyle(TarsierColors.textPrimary)
                        if let meaning = word.meaning {
                            Text(meaning)
                                .font(TarsierFonts.caption(11))
                                .foregroundStyle(TarsierColors.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(TarsierSpacing.cardPadding)
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

// MARK: - Flow Layout (wrapping word chips)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
