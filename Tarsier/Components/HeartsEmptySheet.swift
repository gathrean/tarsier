import SwiftUI

struct HeartsEmptySheet: View {
    let onWatchAd: () -> Void
    let onGetPremium: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Broken heart icon
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundStyle(TarsierColors.heartRed)

            VStack(spacing: 8) {
                Text("No Hearts Left!")
                    .font(TarsierFonts.title(24))
                    .foregroundStyle(TarsierColors.textPrimary)

                Text("Hearts refill over time, or you can get more now.")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            // Refill timer hint
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(TarsierColors.textSecondary)
                Text("1 heart refills every 30 minutes")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            Spacer()

            VStack(spacing: 12) {
                SecondaryButton("Watch Ad for +1 Heart", icon: "play.circle.fill") {
                    onWatchAd()
                    dismiss()
                }

                PrimaryButton("Get Premium", icon: "crown.fill") {
                    onGetPremium()
                    dismiss()
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.bottom, 24)
        }
        .background(TarsierColors.warmWhite.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
