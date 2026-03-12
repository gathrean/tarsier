import SwiftUI

struct LessonPopoverCard: View {
    let lessonID: Int
    let title: String
    let chapterNumber: Int
    let unitNumber: Int
    let completedSessions: Int
    let totalSessions: Int
    let isLocked: Bool
    let isReplay: Bool
    let sessionNumber: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(TarsierFonts.heading(16))
                .foregroundStyle(isLocked ? TarsierColors.textSecondary : TarsierColors.textPrimary)

            Text("Chapter \(chapterNumber) Unit \(unitNumber)")
                .font(TarsierFonts.caption(12))
                .foregroundStyle(TarsierColors.textSecondary)

            if !isLocked {
                Text("\(completedSessions)/\(totalSessions) sessions")
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .padding(.top, 2)

                NavigationLink(
                    value: LessonNavigation(
                        lessonId: lessonID,
                        sessionNumber: sessionNumber,
                        isReplay: isReplay
                    )
                ) {
                    Text(isReplay ? "REPLAY" : "START")
                        .font(TarsierFonts.button(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(TarsierColors.functionalPurple)
                        )
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded { onDismiss() })
            } else {
                Label("LOCKED", systemImage: "lock.fill")
                    .font(TarsierFonts.caption(12))
                    .foregroundStyle(TarsierColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(TarsierColors.lockedFill)
                    )
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }
}
