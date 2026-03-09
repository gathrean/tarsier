import SwiftUI

struct PremiumGateSheet: View {
    let onGetPremium: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundStyle(TarsierColors.gold)

            VStack(spacing: 8) {
                Text("Unlock AI Practice")
                    .font(TarsierFonts.title(24))
                    .foregroundStyle(TarsierColors.textPrimary)

                Text("Practice conversations with Tarsier — your AI Tagalog tutor. Get unlimited sessions with Premium.")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton("Get Premium", icon: "crown.fill") {
                    onGetPremium()
                    dismiss()
                }

                Button {
                    dismiss()
                } label: {
                    Text("Maybe Later")
                        .font(TarsierFonts.body())
                        .foregroundStyle(TarsierColors.textSecondary)
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
