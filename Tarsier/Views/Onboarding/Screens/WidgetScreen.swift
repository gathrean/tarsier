import SwiftUI

// v2: implement actual widget prompt

/// Screen 15: Widget pitch (informational only, no setup)
struct WidgetScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: .celebrating, size: 100)

            Text("I'll cheer you on from your home screen!")
                .font(TarsierFonts.heading(20))
                .foregroundStyle(TarsierColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Mock widget preview
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(TarsierColors.gold)
                    Text("3 day streak!")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(TarsierColors.textPrimary)
                }

                Text("Keep it going!")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
            }
            .padding(20)
            .frame(width: 170, height: 170)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(TarsierColors.cardBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)

            Spacer()
        }
    }
}
