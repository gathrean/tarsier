import SwiftUI

struct ChapterDetailView: View {
    let chapter: Chapter
    let chapterIndex: Int
    let lessons: [SlideLesson]
    let completedIDs: [String]
    let completedSessionCount: (String) -> Int
    let totalSessions: (String) -> Int
    let nextSessionNumber: (String) -> Int
    let isPremium: Bool
    var isChapterLocked: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var showLockedToast = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Themed header banner (desaturated if locked)
                ChapterHeaderView(chapter: chapter, chapterIndex: chapterIndex)
                    .saturation(isChapterLocked ? 0.3 : 1.0)
                    .opacity(isChapterLocked ? 0.7 : 1.0)

                // Chapter description
                if let desc = chapter.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(TarsierColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }

                // Lesson list
                VStack(spacing: 12) {
                    ForEach(chapter.lessonIDs, id: \.self) { lessonID in
                        let lesson = lessons.first { $0.id == lessonID }
                        let isCompleted = isChapterLocked ? false : completedIDs.contains(lessonID)
                        let isLocked = isChapterLocked ? true : !isLessonUnlocked(lessonID)
                        let completed = isChapterLocked ? 0 : completedSessionCount(lessonID)
                        let total = totalSessions(lessonID)
                        let isCurrent = !isCompleted && !isLocked

                        if isChapterLocked {
                            // Locked chapter: tapping a lesson shows a toast
                            Button {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showLockedToast = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation { showLockedToast = false }
                                }
                            } label: {
                                LessonRowView(
                                    lessonID: lessonID,
                                    title: lesson?.title ?? "Lesson \(lessonID)",
                                    vocabularyPreview: vocabularyPreview(for: lesson),
                                    isCompleted: false,
                                    isLocked: true,
                                    isCurrent: false,
                                    completedSessions: 0,
                                    totalSessions: total,
                                    sessionNumber: 1,
                                    isReplay: false,
                                    accentColor: chapter.accentSwiftUIColor
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
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
                    }

                    // AI Practice card (gated behind feature flag + per-chapter flag)
                    if chapter.showsPractice {
                        aiPracticeCard
                    }
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
                LessonContainerView(lesson: lesson, sessionNumber: nav.sessionNumber, isReplay: nav.isReplay, chapterAccentColor: chapter.accentSwiftUIColor)
            }
        }
        .enableSwipeBack()
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
        .overlay(alignment: .bottom) {
            if showLockedToast {
                Text("Complete the previous chapter to unlock")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(TarsierColors.textPrimary.opacity(0.85)))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Unlock Logic

    private func isLessonUnlocked(_ lessonID: String) -> Bool {
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
