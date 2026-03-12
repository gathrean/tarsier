import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var sessionProgresses: [SessionProgress]
    @State private var chapters: [Chapter] = []
    @State private var lessons: [SlideLesson] = []
    @State private var showPremiumGate = false
    @State private var showGreeting = false
    @AppStorage("lastGreetingDate") private var lastGreetingDate: String = ""

    private var profile: UserProfile? { profiles.first }
    private var completedIDs: [Int] { profile?.completedLessonIDs ?? [] }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                topBar
                    .padding(.top, geo.safeAreaInsets.top)

                ScrollView {
                    VStack(spacing: 0) {
                        if showGreeting, let name = profile?.userName {
                            HStack(spacing: 8) {
                                Text("Welcome back, \(name)!")
                                    .font(TarsierFonts.heading(18))
                                    .foregroundStyle(TarsierColors.textPrimary)
                            }
                            .padding(.horizontal, TarsierSpacing.screenPadding)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(TarsierColors.primaryLight)
                            )
                            .padding(.horizontal, TarsierSpacing.screenPadding)
                            .padding(.bottom, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        roadmap
                            .padding(.horizontal, TarsierSpacing.screenPadding)
                    }
                    .padding(.top, TarsierSpacing.sectionSpacing)
                    .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .background(TarsierColors.warmWhite)
        .toolbar(.hidden, for: .navigationBar)
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

            // Show greeting once per day if user has a name
            let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            if profile?.userName != nil && lastGreetingDate != today {
                lastGreetingDate = today
                withAnimation { showGreeting = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation { showGreeting = false }
                }
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
                    .foregroundStyle(TarsierColors.gold)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "hexagon.fill")
                    .foregroundStyle(Color(hex: "#38BDF8"))
                Text("\(profile?.totalXP ?? 0)")
                    .font(TarsierFonts.heading(18))
                    .foregroundStyle(Color(hex: "#38BDF8"))
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(TarsierColors.heartRed)
                Text("\(profile?.hearts ?? 5)")
                    .font(TarsierFonts.heading(18))
                    .foregroundStyle(TarsierColors.heartRed)
            }
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .padding(.vertical, 12)
        .padding(.horizontal, TarsierSpacing.screenPadding)
        .background(TarsierColors.functionalPurple)
    }

    // MARK: - Roadmap

    private var roadmap: some View {
        VStack(spacing: 0) {
            ForEach(Array(chapters.enumerated()), id: \.element.id) { chapterIndex, chapter in
                chapterSection(chapter, chapterNumber: chapterIndex + 1, chapterIndex: chapterIndex)
            }
        }
    }

    // MARK: - Chapter Section

    private func chapterSection(_ chapter: Chapter, chapterNumber: Int, chapterIndex: Int) -> some View {
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

            // Lesson rows from chapters.json
            ForEach(chapter.rows, id: \.row) { row in
                let lessonInts = row.lessons.compactMap { Int($0) }

                HStack(spacing: 24) {
                    if lessonInts.count == 1 {
                        Spacer()
                        lessonNode(lessonID: lessonInts[0], chapter: chapter, chapterIndex: chapterIndex)
                        Spacer()
                    } else {
                        ForEach(lessonInts, id: \.self) { lessonID in
                            lessonNode(lessonID: lessonID, chapter: chapter, chapterIndex: chapterIndex)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Practice node after chapter
            aiPracticeNode(chapter: chapter)
        }
    }

    // MARK: - Unlock Logic

    private func isLessonUnlocked(_ lessonID: Int, chapter: Chapter, chapterIndex: Int) -> Bool {
        // Lesson 1 is always unlocked
        if lessonID == 1 { return true }

        let allIDs = chapter.lessonIDs
        guard let posInChapter = allIDs.firstIndex(of: lessonID) else { return false }

        if posInChapter == 0 {
            // First lesson in chapter — need all lessons in previous chapter completed
            guard chapterIndex > 0 else { return true }
            let prevChapter = chapters[chapterIndex - 1]
            return prevChapter.lessonIDs.allSatisfy { completedIDs.contains($0) }
        } else {
            // Not first — need previous lesson in this chapter completed
            let prevLessonID = allIDs[posInChapter - 1]
            return completedIDs.contains(prevLessonID)
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

    private func lessonTitle(for lessonID: Int) -> String {
        lessons.first { $0.id == lessonID }?.title ?? "Lesson \(lessonID)"
    }

    // MARK: - Lesson Node

    private func lessonNode(lessonID: Int, chapter: Chapter, chapterIndex: Int) -> some View {
        let isCompleted = completedIDs.contains(lessonID)
        let isUnlocked = isLessonUnlocked(lessonID, chapter: chapter, chapterIndex: chapterIndex)
        let completed = completedSessionCount(for: lessonID)
        let total = totalSessions(for: lessonID)
        let isAllSessionsDone = completed >= total
        let isReplay = isAllSessionsDone && isCompleted
        let hasProgress = completed > 0 && !isCompleted
        let indexInChapter = (chapter.lessonIDs.firstIndex(of: lessonID) ?? 0) + 1
        let title = lessonTitle(for: lessonID)
        let nodeSize: CGFloat = 72

        return NavigationLink(
            value: LessonNavigation(
                lessonId: lessonID,
                sessionNumber: nextSessionNumber(for: lessonID),
                isReplay: isReplay
            )
        ) {
            VStack(spacing: 6) {
                ZStack {
                    // Progress ring — only when there's actual progress (1+ sessions done)
                    if hasProgress {
                        ProgressRingView(
                            completed: completed,
                            total: total,
                            size: nodeSize + 12,
                            lineWidth: 3.5
                        )
                    }

                    Circle()
                        .fill(nodeBackground(isCompleted: isCompleted, isUnlocked: isUnlocked))
                        .frame(width: nodeSize, height: nodeSize)
                        .overlay(
                            Circle()
                                .stroke(
                                    isUnlocked && !isCompleted ? TarsierColors.functionalPurple.opacity(0.3) : .clear,
                                    lineWidth: 2
                                )
                        )

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else if isUnlocked {
                        Text("\(indexInChapter)")
                            .font(TarsierFonts.heading(22))
                            .foregroundStyle(TarsierColors.functionalPurple)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }

                Text(title)
                    .font(TarsierFonts.caption(13))
                    .foregroundStyle(isUnlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: nodeSize + 20)
            }
            .opacity(isUnlocked ? 1 : 0.5)
        }
        .disabled(!isUnlocked)
    }

    private func nodeBackground(isCompleted: Bool, isUnlocked: Bool) -> Color {
        if isCompleted { return TarsierColors.functionalPurple }
        if isUnlocked { return TarsierColors.cream }
        return Color(hex: "#F0F0F4")
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
        .padding(.vertical, 8)
    }

    private func aiPracticeContent(unlocked: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(unlocked ? TarsierColors.gold.opacity(0.15) : Color(hex: "#F0F0F4"))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(
                                unlocked ? TarsierColors.gold : TarsierColors.cardBorder,
                                style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                            )
                    )

                Image(systemName: "book.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(unlocked ? TarsierColors.gold : TarsierColors.textSecondary)
            }

            Text("Practice")
                .font(TarsierFonts.caption(12))
                .foregroundStyle(unlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .opacity(unlocked ? 1 : 0.5)
    }
}
