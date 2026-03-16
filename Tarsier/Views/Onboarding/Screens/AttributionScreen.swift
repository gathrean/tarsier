import SwiftUI

/// Screen 4: How did you learn about Tarsier?
struct AttributionScreen: View {
    @Binding var attributionSource: String
    let onContinue: () -> Void

    private let sources = [
        "App Store",
        "TikTok",
        "Instagram",
        "YouTube",
        "Friend or Family",
        "Other"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BunsoView(pose: .curious, size: 80)

            Text("How did you learn about Tarsier?")
                .font(TarsierFonts.title(24))
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                ForEach(sources, id: \.self) { source in
                    Button {
                        attributionSource = source
                    } label: {
                        HStack {
                            Text(source)
                                .font(TarsierFonts.body())
                                .foregroundStyle(TarsierColors.textPrimary)
                            Spacer()
                            if attributionSource == source {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(attributionSource == source ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    attributionSource == source ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                    lineWidth: attributionSource == source ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)

            Spacer()
        }
    }
}
