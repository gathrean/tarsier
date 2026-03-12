import SwiftUI

struct ChapterBannerView: View {
    let chapterNumber: Int
    let title: String
    let subtitle: String
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("CHAPTER \(chapterNumber)")
                .font(TarsierFonts.caption(11))
                .fontWeight(.bold)
                .tracking(1.2)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isUnlocked ? Color.white.opacity(0.2) : TarsierColors.cardBorder)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TarsierFonts.heading(17))
                Text(subtitle)
                    .font(TarsierFonts.caption(13))
                    .opacity(0.8)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .foregroundStyle(isUnlocked ? .white : TarsierColors.textSecondary)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isUnlocked ? TarsierColors.functionalPurple : TarsierColors.lockedFill)
        )
    }
}
