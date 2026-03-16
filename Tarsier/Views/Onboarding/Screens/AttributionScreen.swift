import SwiftUI

/// Screen 4: How did you learn about Tarsier? (multi-select)
struct AttributionScreen: View {
    @Binding var attributionSources: Set<String>
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
            BunsoSpeechBubble(pose: .curious, text: "How did you learn about Tarsier?")

            Text("Pick all that apply")
                .font(TarsierFonts.caption())
                .foregroundStyle(TarsierColors.textSecondary)

            VStack(spacing: 10) {
                ForEach(sources, id: \.self) { source in
                    let isSelected = attributionSources.contains(source)
                    Button {
                        if isSelected {
                            attributionSources.remove(source)
                        } else {
                            attributionSources.insert(source)
                        }
                    } label: {
                        HStack {
                            Text(source)
                                .font(TarsierFonts.body())
                                .foregroundStyle(TarsierColors.textPrimary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isSelected ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isSelected ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                    lineWidth: isSelected ? 2 : 1
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
