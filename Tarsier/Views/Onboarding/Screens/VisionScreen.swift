import SwiftUI

/// Screen 13: Three-month vision — three benefit cards
struct VisionScreen: View {
    let onContinue: () -> Void

    private let benefits: [(icon: String, title: String, subtitle: String)] = [
        ("bubble.left.and.bubble.right.fill", "Converse with confidence", "Stress-free speaking and listening exercises"),
        ("text.book.closed.fill", "Build up your vocabulary", "Common words and practical phrases"),
        ("flame.fill", "Develop a learning habit", "Smart reminders, fun challenges, and more")
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BunsoSpeechBubble(pose: .flexing, text: "Here's what you can achieve in 3 months")

            VStack(spacing: 14) {
                ForEach(benefits, id: \.title) { benefit in
                    HStack(spacing: 14) {
                        Image(systemName: benefit.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(TarsierColors.functionalPurple)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(benefit.title)
                                .font(TarsierFonts.heading(16))
                                .foregroundStyle(TarsierColors.textPrimary)
                            Text(benefit.subtitle)
                                .font(TarsierFonts.caption())
                                .foregroundStyle(TarsierColors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(TarsierSpacing.cardPadding)
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)

            Spacer()
        }
    }
}
