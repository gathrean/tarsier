import SwiftUI

struct AlamMoBaView: View {
    let text: String
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: TarsierSpacing.itemSpacing) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(TarsierFonts.heading())
                    .foregroundStyle(TarsierColors.gold)

                TappableTagalogWord(
                    word: "Alam Mo Ba?",
                    translation: "Did you know?",
                    font: TarsierFonts.heading(),
                    color: TarsierColors.textPrimary
                )
            }

            Text(text)
                .font(TarsierFonts.body())
                .foregroundStyle(TarsierColors.textPrimary)

            if let onDismiss {
                PrimaryButton("Got it!", action: onDismiss)
            }
        }
        .padding(TarsierSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .fill(TarsierColors.gold.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .stroke(TarsierColors.gold.opacity(0.3), lineWidth: 1)
        )
    }
}
