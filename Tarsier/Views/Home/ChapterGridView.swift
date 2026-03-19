import SwiftUI

struct ChapterGridView: View {
    let chapters: [Chapter]
    let completedIDs: [Int]
    let completedSessionCount: (Int) -> Int
    let totalSessions: (Int) -> Int

    var body: some View {
        VStack(spacing: 28) {
            ForEach(Array(gridRows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 24) {
                    if row.count == 1 {
                        Spacer()
                        chapterButton(for: row[0])
                        Spacer()
                    } else {
                        Spacer()
                        chapterButton(for: row[0])
                        Spacer()
                        chapterButton(for: row[1])
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, TarsierSpacing.screenPadding)
    }

    // MARK: - Grid Layout (alternating 1-2-1-2)

    private var gridRows: [[(chapter: Chapter, index: Int)]] {
        var rows: [[(chapter: Chapter, index: Int)]] = []
        var i = 0
        var isSingleRow = true

        while i < chapters.count {
            if isSingleRow {
                rows.append([(chapters[i], i)])
                i += 1
            } else {
                if i + 1 < chapters.count {
                    rows.append([(chapters[i], i), (chapters[i + 1], i + 1)])
                    i += 2
                } else {
                    rows.append([(chapters[i], i)])
                    i += 1
                }
            }
            isSingleRow.toggle()
        }

        return rows
    }

    // MARK: - Chapter Button

    @ViewBuilder
    private func chapterButton(for item: (chapter: Chapter, index: Int)) -> some View {
        let chapter = item.chapter
        let chapterIndex = item.index
        let state = chapterState(for: chapter, at: chapterIndex)
        let completed = completedLessonCount(for: chapter)
        let total = chapter.lessonIDs.count

        // All chapters are tappable — locked ones show a greyed-out detail page
        NavigationLink(value: chapter) {
            ChapterNodeView(
                chapter: chapter,
                chapterIndex: chapterIndex,
                state: state,
                completedLessons: completed,
                totalLessons: total
            )
        }
        .buttonStyle(NodePressStyle())
    }

    // MARK: - State Helpers

    private func chapterState(for chapter: Chapter, at index: Int) -> ChapterNodeState {
        let isUnlocked = index == 0
            || chapters[index - 1].lessonIDs.allSatisfy { completedIDs.contains($0) }

        guard isUnlocked else { return .locked }

        let completed = completedLessonCount(for: chapter)
        let total = chapter.lessonIDs.count

        if completed >= total {
            return .completed
        } else if completed > 0 {
            return .inProgress
        } else {
            // Check if any sessions started
            let hasProgress = chapter.lessonIDs.contains { completedSessionCount($0) > 0 }
            return hasProgress ? .inProgress : .notStarted
        }
    }

    private func completedLessonCount(for chapter: Chapter) -> Int {
        chapter.lessonIDs.filter { completedIDs.contains($0) }.count
    }
}
