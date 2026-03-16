import SwiftUI

/// Screens 10–12: Daily goal intro, picker, and confirmation
struct DailyGoalScreen: View {
    let screenIndex: Int // 0 = intro, 1 = picker, 2 = confirmation
    @Binding var dailyGoalMinutes: Int
    let onContinue: () -> Void

    private let goals: [(minutes: Int, label: String, icon: String)] = [
        (5, "Casual", "🐢"),
        (10, "Regular", "🚶"),
        (15, "Serious", "🏃"),
        (20, "Intense", "🔥")
    ]

    private let wordEstimates: [Int: Int] = [5: 15, 10: 30, 15: 50, 20: 70]

    var body: some View {
        switch screenIndex {
        case 0: introView
        case 1: pickerView
        default: confirmationView
        }
    }

    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: .tappingWrist, size: 120)

            Text("Let's set up a learning routine!")
                .font(TarsierFonts.title(24))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var pickerView: some View {
        VStack(spacing: 24) {
            Spacer()

            BunsoSpeechBubble(pose: .tappingWrist, text: "What's your daily learning goal?")

            VStack(spacing: 12) {
                ForEach(goals, id: \.minutes) { goal in
                    Button {
                        dailyGoalMinutes = goal.minutes
                    } label: {
                        HStack(spacing: 12) {
                            Text(goal.icon)
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(goal.minutes) min/day")
                                    .font(TarsierFonts.heading(17))
                                    .foregroundStyle(TarsierColors.textPrimary)
                                Text(goal.label)
                                    .font(TarsierFonts.caption())
                                    .foregroundStyle(TarsierColors.textSecondary)
                            }
                            Spacer()
                            if dailyGoalMinutes == goal.minutes {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(TarsierColors.functionalPurple)
                            }
                        }
                        .padding(TarsierSpacing.cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(dailyGoalMinutes == goal.minutes ? TarsierColors.primaryLight : .white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    dailyGoalMinutes == goal.minutes ? TarsierColors.functionalPurple : TarsierColors.cardBorder,
                                    lineWidth: dailyGoalMinutes == goal.minutes ? 2 : 1
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

    private var confirmationView: some View {
        let resolvedGoal = dailyGoalMinutes > 0 ? dailyGoalMinutes : 10
        let words = wordEstimates[resolvedGoal] ?? 30

        return VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: .celebrating, size: 120)

            VStack(spacing: 12) {
                Text("That's about \(words) new words in your first week!")
                    .font(TarsierFonts.heading(20))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("\(resolvedGoal) minutes a day")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}
