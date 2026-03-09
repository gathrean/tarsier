import SwiftUI

struct TeachingSlideView: View {
    let slide: LessonSlide

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Image placeholder (some teaching slides have images)
            if slide.image != nil {
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .fill(TarsierColors.cream)
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(TarsierColors.textSecondary.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
            }

            if let title = slide.title {
                Text(title)
                    .font(TarsierFonts.heading())
                    .foregroundStyle(TarsierColors.functionalPurple)
            }

            if let body = slide.body {
                Text(body)
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textPrimary)
                    .lineSpacing(4)
            }

            // Examples
            if let examples = slide.examples {
                VStack(spacing: 12) {
                    ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                        exampleCard(example)
                    }
                }
            }

            // Rules (e.g. po usage rules)
            if let rules = slide.rules {
                VStack(spacing: 8) {
                    ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                        ruleRow(rule)
                    }
                }
            }
        }
    }

    // MARK: - Example Card

    @ViewBuilder
    private func exampleCard(_ example: TeachingExample) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let casual = example.casual, let withPo = example.withPo {
                // Format 1: casual -> with po transformation
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(casual)
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textSecondary)
                        Image(systemName: "arrow.right")
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.textSecondary)
                        Text(withPo)
                            .font(TarsierFonts.body())
                            .bold()
                            .foregroundStyle(TarsierColors.functionalPurple)
                    }
                    if let note = example.note {
                        Text(note)
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.textSecondary)
                            .italic()
                    }
                }
            } else if let tagalog = example.tagalog {
                // Format 2: tagalog sentence with translation
                Text(tagalog)
                    .font(TarsierFonts.tagalogWord(18))
                    .foregroundStyle(TarsierColors.textPrimary)
                if let translation = example.translation {
                    Text(translation)
                        .font(TarsierFonts.body(15))
                        .foregroundStyle(TarsierColors.textSecondary)
                }
                if let poPosition = example.poPosition {
                    Text(poPosition)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.functionalPurple)
                        .italic()
                }
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

    // MARK: - Rule Row

    private func ruleRow(_ rule: TeachingRule) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: rule.usePo ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(rule.usePo ? TarsierColors.correctGreen : TarsierColors.alertRed)
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text(rule.context)
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textPrimary)
                Text(rule.example)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .italic()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(rule.usePo ? TarsierColors.correctGreen.opacity(0.08) : TarsierColors.alertRed.opacity(0.08))
        )
    }
}
