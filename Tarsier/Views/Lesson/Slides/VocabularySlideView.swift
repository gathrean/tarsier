import SwiftUI

struct VocabularySlideView: View {
    let word: SlideVocabWord

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Tagalog word prominently
            Text(word.word)
                .font(TarsierFonts.tagalogWord(32))
                .foregroundStyle(TarsierColors.textPrimary)

            // Pronunciation
            Text(word.pronunciationGuide)
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)

            // Type badge
            Text(word.type)
                .font(TarsierFonts.caption(11))
                .foregroundStyle(TarsierColors.functionalPurple)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(TarsierColors.brandPurple.opacity(0.15))
                )

            // Meaning
            Text(word.meaning)
                .font(TarsierFonts.body())
                .foregroundStyle(TarsierColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Example sentence card
            VStack(alignment: .leading, spacing: 8) {
                Text(word.exampleSentence)
                    .font(TarsierFonts.body())
                    .bold()
                    .foregroundStyle(TarsierColors.textPrimary)

                Text(word.exampleTranslation)
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textSecondary)
            }
            .padding(TarsierSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .fill(TarsierColors.cream)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )

            // Taglish variant
            if let taglish = word.taglishVariant {
                TaglishCallout(text: taglish)
            }

            // Speaker icon placeholder
            HStack(spacing: 6) {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundStyle(TarsierColors.textSecondary.opacity(0.4))
                Text("Audio coming soon")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary.opacity(0.4))
            }

            Spacer()
        }
    }
}
