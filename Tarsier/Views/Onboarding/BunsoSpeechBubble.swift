import SwiftUI

/// Reusable Bunso mascot + speech bubble layout (Duolingo-style)
struct BunsoSpeechBubble: View {
    let pose: BunsoPose
    let text: String
    var bunsoSize: CGFloat = 70

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            BunsoView(pose: pose, size: bunsoSize)

            Text(text)
                .font(TarsierFonts.heading(17))
                .foregroundStyle(TarsierColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TarsierColors.cardBorder, lineWidth: 1)
                )
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
    }
}
