import SwiftUI

struct ChapterDetailView: View {
    let chapter: Chapter
    let chapterIndex: Int
    let lessons: [SlideLesson]
    let completedIDs: [Int]
    let completedSessionCount: (Int) -> Int
    let totalSessions: (Int) -> Int
    let nextSessionNumber: (Int) -> Int
    let isPremium: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Themed header banner
                ChapterHeaderView(chapter: chapter, chapterIndex: chapterIndex)

                // Lesson list
                VStack(spacing: 12) {
                    ForEach(chapter.lessonIDs, id: \.self) { lessonID in
                        let lesson = lessons.first { $0.id == lessonID }
                        let isCompleted = completedIDs.contains(lessonID)
                        let isLocked = !isLessonUnlocked(lessonID)
                        let completed = completedSessionCount(lessonID)
                        let total = totalSessions(lessonID)
                        let isCurrent = !isCompleted && !isLocked

                        LessonRowView(
                            lessonID: lessonID,
                            title: lesson?.title ?? "Lesson \(lessonID)",
                            vocabularyPreview: vocabularyPreview(for: lesson),
                            isCompleted: isCompleted,
                            isLocked: isLocked,
                            isCurrent: isCurrent,
                            completedSessions: completed,
                            totalSessions: total,
                            sessionNumber: nextSessionNumber(lessonID),
                            isReplay: isCompleted,
                            accentColor: chapter.accentSwiftUIColor
                        )
                    }

                    // AI Practice card
                    aiPracticeCard
                }
                .padding(.horizontal, TarsierSpacing.screenPadding)
                .padding(.top, 20)
                .padding(.bottom, 40)

                // TODO: v1.0+ "One Step Further" section (Teacher Talk, Speaking practice)
            }
        }
        .background(TarsierColors.warmWhite)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(for: LessonNavigation.self) { nav in
            if let lesson = LessonService.shared.lesson(for: nav.lessonId) {
                LessonContainerView(lesson: lesson, sessionNumber: nav.sessionNumber, isReplay: nav.isReplay)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: 0) }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.black.opacity(0.2)))
            }
            .padding(.leading, 16)
            .padding(.top, 4)
        }
    }

    // MARK: - Unlock Logic

    private func isLessonUnlocked(_ lessonID: Int) -> Bool {
        let allIDs = chapter.lessonIDs
        guard let posInChapter = allIDs.firstIndex(of: lessonID) else { return false }

        if posInChapter == 0 {
            // First lesson in chapter — chapter must be unlocked (handled by parent)
            return true
        } else {
            let prevLessonID = allIDs[posInChapter - 1]
            return completedIDs.contains(prevLessonID)
        }
    }

    // MARK: - Vocabulary Preview

    private func vocabularyPreview(for lesson: SlideLesson?) -> String {
        guard let lesson else { return "" }
        let words = lesson.vocabulary.prefix(4).map { $0.word }
        return words.joined(separator: ", ")
    }

    // MARK: - AI Practice Card

    private var aiPracticeCard: some View {
        let allCompleted = chapter.lessonIDs.allSatisfy { completedIDs.contains($0) }

        return HStack(spacing: 12) {
            Circle()
                .fill(allCompleted ? TarsierColors.gold.opacity(0.15) : TarsierColors.lockedFill)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(allCompleted ? TarsierColors.gold : TarsierColors.textSecondary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Practice")
                    .font(TarsierFonts.heading(17))
                    .foregroundStyle(allCompleted ? TarsierColors.textPrimary : TarsierColors.textSecondary)
                Text(allCompleted ? "Practice with Bunso" : "Complete all lessons to unlock")
                    .font(TarsierFonts.caption(13))
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            Spacer()

            if !allCompleted {
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
                .stroke(
                    allCompleted ? TarsierColors.gold.opacity(0.4) : TarsierColors.cardBorder,
                    style: StrokeStyle(lineWidth: 1.5, dash: allCompleted ? [6, 4] : [])
                )
        )
    }
}
