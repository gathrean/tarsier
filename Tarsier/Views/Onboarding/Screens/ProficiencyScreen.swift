import SwiftUI

/// Screens 5–6: Proficiency self-assessment + Bunso response
struct ProficiencyScreen: View {
    let screenIndex: Int // 0 = picker, 1 = response
    @Binding var proficiencyLevel: Int
    let onContinue: () -> Void

    private let levels = [
        "I'm starting from scratch",
        "I recognize common words when I hear them",
        "I understand more than I can say",
        "I can have basic conversations",
        "I'm comfortable in most conversations"
    ]

    var body: some View {
        if screenIndex == 0 {
            pickerView
        } else {
            responseView
        }
    }

    private var pickerView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Bunso mascot + speech bubble (Duolingo style)
            HStack(alignment: .top, spacing: 12) {
                BunsoView(pose: .curious, size: 70)

                Text("How much Tagalog do you know?")
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

            VStack(spacing: 10) {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                    let isSelected = proficiencyLevel >= 0 && proficiencyLevel == index
                    Button {
                        proficiencyLevel = index
                    } label: {
                        HStack(spacing: 14) {
                            SignalBarsView(level: index + 1, filled: isSelected)

                            Text(level)
                                .font(TarsierFonts.body())
                                .foregroundStyle(TarsierColors.textPrimary)
                                .multilineTextAlignment(.leading)
                            Spacer()
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

    private var responseView: some View {
        let (pose, message) = proficiencyResponse

        return VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: pose, size: 120)

            Text(message)
                .font(TarsierFonts.heading(20))
                .foregroundStyle(TarsierColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onContinue() }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onContinue()
            }
        }
    }

    private var proficiencyResponse: (BunsoPose, String) {
        switch proficiencyLevel {
        case 0:
            (.thumbsUp, "No worries, we'll start from the very beginning!")
        case 1, 2:
            (.excited, "Okay, we'll build on what you know!")
        default:
            (.flexing, "Nice! Let's sharpen those skills.")
        }
    }
}

// MARK: - Signal Bars (Duolingo-style proficiency indicator)

private struct SignalBarsView: View {
    let level: Int       // 1–5, how many bars to fill
    let filled: Bool     // only color bars when row is selected

    private let totalBars = 5
    private let barWidth: CGFloat = 4
    private let barSpacing: CGFloat = 2.5

    var body: some View {
        HStack(alignment: .bottom, spacing: barSpacing) {
            ForEach(0..<totalBars, id: \.self) { index in
                let barHeight: CGFloat = 6 + CGFloat(index) * 4 // 6, 10, 14, 18, 22
                let isFilled = index < level

                RoundedRectangle(cornerRadius: 1.5)
                    .fill(isFilled ? TarsierColors.functionalPurple : TarsierColors.cardBorder)
                    .frame(width: barWidth, height: barHeight)
            }
        }
        .frame(width: 32, height: 22, alignment: .bottom)
    }
}
