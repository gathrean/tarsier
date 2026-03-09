import SwiftUI

struct SummarySlideView: View {
    let slide: LessonSlide
    let xpReward: Int
    let quizScore: Int
    let quizTotal: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Celebratory icon
            Image(systemName: quizTotal > 0 && quizScore == quizTotal ? "star.fill" : "checkmark.circle.fill")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundStyle(TarsierColors.gold)

            Text("Lesson Complete!")
                .font(TarsierFonts.title(28))
                .foregroundStyle(TarsierColors.textPrimary)

            // Stats
            HStack(spacing: 20) {
                statBadge(icon: "star.fill", value: "+\(xpReward) XP", color: TarsierColors.functionalPurple)
                if quizTotal > 0 {
                    statBadge(icon: "checkmark.circle.fill", value: "\(quizScore)/\(quizTotal)", color: TarsierColors.correctGreen)
                }
            }

            // Key words learned
            if let words = slide.keyWords, !words.isEmpty {
                VStack(spacing: 10) {
                    Text("Words Learned")
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)

                    // Horizontal scrolling word pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(words, id: \.self) { word in
                                Text(word)
                                    .font(TarsierFonts.caption())
                                    .foregroundStyle(TarsierColors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(TarsierColors.cream)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }

            // Cultural takeaway
            if let takeaway = slide.culturalTakeaway {
                Text(takeaway)
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .italic()
                    .padding(.horizontal)
            }

            Spacer()

            PrimaryButton("Continue") {
                onContinue()
            }
            .padding(.bottom, 16)
        }
    }

    private func statBadge(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(TarsierFonts.heading(18))
                .foregroundStyle(TarsierColors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
