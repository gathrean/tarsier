import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var sessionProgresses: [SessionProgress]
    @State private var chapters: [Chapter] = []
    @State private var lessons: [SlideLesson] = []
    @State private var showPremiumGate = false

    private var profile: UserProfile? { profiles.first }
    private var currentLessonIndex: Int { profile?.currentLessonIndex ?? 1 }
    private var completedIDs: [Int] { profile?.completedLessonIDs ?? [] }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, TarsierSpacing.screenPadding)
                    .padding(.bottom, TarsierSpacing.sectionSpacing)

                roadmap
                    .padding(.horizontal, TarsierSpacing.screenPadding)
            }
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(TarsierColors.warmWhite)
        .navigationTitle("Tarsier")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: LessonNavigation.self) { nav in
            if let lesson = LessonService.shared.lesson(for: nav.lessonId) {
                LessonContainerView(lesson: lesson, sessionNumber: nav.sessionNumber, isReplay: nav.isReplay)
            }
        }
        .navigationDestination(for: String.self) { route in
            if route == "practice" {
                PracticeView()
            }
        }
        .sheet(isPresented: $showPremiumGate) {
            PremiumGateSheet(
                onGetPremium: {
                    // TODO: Superwall paywall trigger
                }
            )
        }
        .onAppear {
            chapters = LessonService.shared.loadChapters()
            lessons = LessonService.shared.loadAllLessons()
            if let profile {
                StreakService.validateStreak(for: profile)
                profile.refillHearts()
            }
        }
    }

    // MARK: - Top Bar (Streak / Hearts / XP)

    private var topBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(TarsierColors.gold)
                Text("\(profile?.currentStreak ?? 0)")
                    .font(TarsierFonts.heading(18))
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(TarsierColors.functionalPurple)
                Text("\(profile?.totalXP ?? 0)")
                    .font(TarsierFonts.heading(18))
                    .foregroundStyle(TarsierColors.functionalPurple)
            }

            Spacer()

            HeartDisplay(
                current: profile?.hearts ?? 5,
                isPremium: profile?.isPremium ?? false
            )
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .padding(.vertical, 12)
        .padding(.horizontal, TarsierSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .fill(TarsierColors.cream)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Roadmap

    private var roadmap: some View {
        VStack(spacing: 0) {
            ForEach(Array(chapters.enumerated()), id: \.element.id) { chapterIndex, chapter in
                chapterSection(chapter, chapterNumber: chapterIndex + 1)
            }
        }
    }

    // MARK: - Chapter Section

    private func chapterSection(_ chapter: Chapter, chapterNumber: Int) -> some View {
        VStack(spacing: 0) {
            // Chapter header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(TarsierColors.functionalPurple)
                        .frame(width: 32, height: 32)
                    Text("\(chapterNumber)")
                        .font(TarsierFonts.caption(14))
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(chapter.title)
                        .font(TarsierFonts.heading(18))
                        .foregroundStyle(TarsierColors.textPrimary)
                    Text(chapter.subtitle)
                        .font(TarsierFonts.caption())
                        .foregroundStyle(TarsierColors.textSecondary)
                }

                Spacer()
            }
            .padding(.top, chapterNumber == 1 ? 0 : TarsierSpacing.sectionSpacing)
            .padding(.bottom, 16)

            // Lesson nodes — 2-column grid
            let columns = [
                GridItem(.flexible(), spacing: 24),
                GridItem(.flexible(), spacing: 24),
            ]
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(chapter.lessonIDs.enumerated()), id: \.element) { index, lessonID in
                    let isCompleted = completedIDs.contains(lessonID)
                    let isCurrent = lessonID == currentLessonIndex
                    let isUnlocked = lessonID <= currentLessonIndex

                    lessonNode(
                        lessonID: lessonID,
                        chapterTitle: chapter.title,
                        indexInChapter: index + 1,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isUnlocked: isUnlocked
                    )
                }
            }

            // AI Practice node after chapter
            aiPracticeNode(chapter: chapter)
        }
    }

    // MARK: - Session Progress Helpers

    private func completedSessionCount(for lessonId: Int) -> Int {
        let lessonIdStr = String(format: "%03d", lessonId)
        return sessionProgresses.filter { $0.lessonId == lessonIdStr && $0.isCompleted }.count
    }

    private func totalSessions(for lessonId: Int) -> Int {
        lessons.first { $0.id == lessonId }?.totalSessions ?? 5
    }

    private func nextSessionNumber(for lessonId: Int) -> Int {
        let lessonIdStr = String(format: "%03d", lessonId)
        let completedNumbers = Set(
            sessionProgresses
                .filter { $0.lessonId == lessonIdStr && $0.isCompleted }
                .map { $0.sessionNumber }
        )
        let total = totalSessions(for: lessonId)
        for i in 1...total {
            if !completedNumbers.contains(i) { return i }
        }
        return 1 // All done, replay from 1
    }

    // MARK: - Lesson Node

    private func lessonNode(lessonID: Int, chapterTitle: String, indexInChapter: Int, isCompleted: Bool, isCurrent: Bool, isUnlocked: Bool) -> some View {
        let completed = completedSessionCount(for: lessonID)
        let total = totalSessions(for: lessonID)
        let isAllSessionsDone = completed >= total
        let isReplay = isAllSessionsDone && isCompleted
        let baseSize: CGFloat = 56 * 1.5 // ~84
        let nodeSize: CGFloat = isCurrent ? baseSize * 1.1 : baseSize
        let label = "\(chapterTitle) \(indexInChapter)"

        return NavigationLink(
            value: LessonNavigation(
                lessonId: lessonID,
                sessionNumber: nextSessionNumber(for: lessonID),
                isReplay: isReplay
            )
        ) {
            VStack(spacing: 6) {
                ZStack {
                    // Progress ring around every unlocked lesson
                    if isUnlocked && !isCompleted {
                        ProgressRingView(
                            completed: completed,
                            total: total,
                            size: nodeSize + 12,
                            lineWidth: 3.5
                        )
                    }

                    Circle()
                        .fill(nodeBackground(isCompleted: isCompleted, isCurrent: isCurrent, isUnlocked: isUnlocked))
                        .frame(width: nodeSize, height: nodeSize)
                        .shadow(
                            color: isCurrent ? TarsierColors.functionalPurple.opacity(0.3) : .clear,
                            radius: isCurrent ? 8 : 0
                        )

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else if isUnlocked {
                        Text("\(indexInChapter)")
                            .font(TarsierFonts.heading(24))
                            .foregroundStyle(TarsierColors.functionalPurple)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }

                Text(label)
                    .font(TarsierFonts.heading(20))
                    .foregroundStyle(isUnlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)
                    .lineLimit(1)
            }
            .opacity(isUnlocked ? 1 : 0.5)
        }
        .disabled(!isUnlocked)
        .padding(.vertical, 8)
    }

    private func nodeBackground(isCompleted: Bool, isCurrent: Bool, isUnlocked: Bool) -> Color {
        if isCompleted { return TarsierColors.functionalPurple }
        if isCurrent || isUnlocked { return TarsierColors.cream }
        return Color(hex: "#EEEAE6")
    }

    // MARK: - AI Practice Node

    private func aiPracticeNode(chapter: Chapter) -> some View {
        let allCompleted = chapter.lessonIDs.allSatisfy { completedIDs.contains($0) }
        let isPremium = profile?.isPremium ?? false

        return Group {
            if allCompleted {
                if isPremium {
                    NavigationLink(value: "practice") {
                        aiPracticeContent(unlocked: true)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        showPremiumGate = true
                    } label: {
                        aiPracticeContent(unlocked: true)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                aiPracticeContent(unlocked: false)
            }
        }
        .padding(.vertical, 4)
    }

    private func aiPracticeContent(unlocked: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(unlocked ? TarsierColors.gold.opacity(0.15) : Color(hex: "#EEEAE6"))
                    .frame(width: 84, height: 84)
                    .overlay(
                        Circle()
                            .stroke(
                                unlocked ? TarsierColors.gold : TarsierColors.cardBorder,
                                style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                            )
                    )

                Image(systemName: "book.fill")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(unlocked ? TarsierColors.gold : TarsierColors.textSecondary)
            }

            Text("Practice")
                .font(TarsierFonts.caption(14))
                .foregroundStyle(unlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .opacity(unlocked ? 1 : 0.5)
    }

}
