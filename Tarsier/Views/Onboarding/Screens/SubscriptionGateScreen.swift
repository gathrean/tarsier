import SwiftUI
// import SuperwallKit  // TODO: Re-enable when Superwall is configured

/// Screen 16: Subscription gate — Super Tarsier vs Free
struct SubscriptionGateScreen: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("How do you want to get started?")
                .font(TarsierFonts.title(24))
                .multilineTextAlignment(.center)

            VStack(spacing: 14) {
                // Super Tarsier card
                // TODO: Re-enable Superwall paywall when configured
                Button {
                    onContinue()
                } label: {
                    VStack(spacing: 8) {
                        Text("RECOMMENDED")
                            .font(TarsierFonts.caption(11))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(TarsierColors.functionalPurple))

                        Text("Super Tarsier")
                            .font(TarsierFonts.heading(20))
                            .foregroundStyle(TarsierColors.textPrimary)

                        Text("Faster progress, no ads")
                            .font(TarsierFonts.body())
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(TarsierColors.primaryLight)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(TarsierColors.functionalPurple, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)

                // Free card
                Button {
                    onContinue()
                } label: {
                    VStack(spacing: 4) {
                        Text("Learn for free")
                            .font(TarsierFonts.heading(18))
                            .foregroundStyle(TarsierColors.textPrimary)

                        Text("Core learning features, with ads")
                            .font(TarsierFonts.caption())
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                            .stroke(TarsierColors.cardBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)

            Spacer()
        }
    }
}
