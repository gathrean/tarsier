import SwiftUI

struct LessonRowView: View {
    let lessonID: String
    let title: String
    let vocabularyPreview: String
    let isCompleted: Bool
    let isLocked: Bool
    let isCurrent: Bool
    let completedSessions: Int
    let totalSessions: Int
    let sessionNumber: Int
    let isReplay: Bool
    let accentColor: Color

    var body: some View {
        if isLocked {
            rowContent
        } else {
            NavigationLink(
                value: LessonNavigation(
                    lessonId: lessonID,
                    sessionNumber: sessionNumber,
                    isReplay: isReplay
                )
            ) {
                rowContent
            }
            .buttonStyle(.plain)
        }
    }

    private var rowContent: some View {
        HStack(spacing: 12) {
            // Left icon circle
            Circle()
                .fill(iconFill)
                .frame(width: 36, height: 36)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(TarsierColors.textSecondary)
                    } else {
                        // Session progress ring
                        Circle()
                            .trim(from: 0, to: sessionProgress)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 32, height: 32)
                    }
                }

            // Centre content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(isLocked ? TarsierColors.textSecondary : TarsierColors.textPrimary)

                if !vocabularyPreview.isEmpty {
                    Text(vocabularyPreview)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(TarsierColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Right indicator
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(accentColor)
            } else if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(TarsierColors.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? accentColor.opacity(0.4) : TarsierColors.cardBorder, lineWidth: isCurrent ? 1.5 : 1)
        )
        .opacity(isLocked ? 0.6 : 1)
    }

    private var iconFill: Color {
        if isCompleted { return accentColor }
        if isLocked { return TarsierColors.lockedFill }
        return accentColor.opacity(0.1)
    }

    private var sessionProgress: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
}
