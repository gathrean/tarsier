import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var sessionProgresses: [SessionProgress]
    @State private var chapters: [Chapter] = []
    @State private var lessons: [SlideLesson] = []
    @State private var showPremiumGate = false
    @State private var selectedLessonID: Int? = nil
    @State private var showDailyToast = false
    @Environment(\.scenePhase) private var scenePhase

    private var profile: UserProfile? { profiles.first }
    private var completedIDs: [Int] { profile?.completedLessonIDs ?? [] }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                topBar
                    .padding(.top, geo.safeAreaInsets.top)
                    .zIndex(1)

                ZStack(alignment: .top) {
                    ScrollViewReader { scrollProxy in
                    ScrollView {
                    VStack(spacing: 0) {
                        roadmap
                    }
                    .padding(.top, TarsierSpacing.sectionSpacing)
                    .padding(.bottom, 40)
                    }
                    .onAppear {
                        if let chapterId = currentChapterId {
                            scrollProxy.scrollTo("chapter_\(chapterId)", anchor: .center)
                        }
                    }
                }

                    // Fade gradient at top of scroll area
                    LinearGradient(
                        colors: [TarsierColors.warmWhite, TarsierColors.warmWhite.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 24)
                    .allowsHitTesting(false)

                    // Daily toast greeting
                    if showDailyToast, let profile {
                        DailyToastView(
                            greeting: GreetingHelper.greeting(for: profile),
                            onDismiss: { showDailyToast = false }
                        )
                        .show()
                        .padding(.top, 8)
                    }
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

            // Show greeting toast on app open
            showDailyToast = true
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                showDailyToast = true
            }
        }
    }

    // MARK: - Top Bar (Bunso + Name | Streak / Hearts / XP)

    private var topBar: some View {
        HStack(spacing: 0) {
            // Left: Bunso head + user name
            HStack(spacing: 8) {
                bunsoHeaderAvatar
                    .frame(width: 28, height: 28)

                if let profile {
                    Text(displayName(for: profile))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Right: streak, gems, hearts
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(TarsierColors.gold)
                    Text("\(profile?.currentStreak ?? 0)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(TarsierColors.gold)
                }

                HStack(spacing: 4) {
                    Image(systemName: "hexagon.fill")
                        .foregroundStyle(Color(hex: "#38BDF8"))
                    Text("\(profile?.totalXP ?? 0)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(Color(hex: "#38BDF8"))
                }

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(TarsierColors.heartRed)
                    Text("\(profile?.hearts ?? 5)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(TarsierColors.heartRed)
                }
            }
        }
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .padding(.vertical, 12)
        .padding(.horizontal, TarsierSpacing.screenPadding)
        .background(TarsierColors.functionalPurple)
    }

    @ViewBuilder
    private var bunsoHeaderAvatar: some View {
        if let _ = UIImage(named: "character_bunso") {
            Image("character_bunso")
                .resizable()
                .scaledToFit()
        } else if let _ = UIImage(named: "Tarsier-Waving") {
            Image("Tarsier-Waving")
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(Color.white.opacity(0.2))
                .overlay(
                    Text("🐵")
                        .font(.system(size: 16))
                )
        }
    }

    private func displayName(for profile: UserProfile) -> String {
        guard let name = profile.userName, !name.isEmpty else { return "" }
        if let title = profile.preferredTitle, !title.isEmpty {
            return "\(title) \(name)"
        }
        return name
    }

    // MARK: - Roadmap

    private var roadmap: some View {
        VStack(spacing: 8) {
            ForEach(Array(chapters.enumerated()), id: \.element.id) { chapterIndex, chapter in
                let isChapterUnlocked = chapterIndex == 0
                    || chapters[chapterIndex - 1].lessonIDs.allSatisfy { completedIDs.contains($0) }

                ZigzagChapterView(
                    chapter: chapter,
                    chapterNumber: chapterIndex + 1,
                    chapterIndex: chapterIndex,
                    isChapterUnlocked: isChapterUnlocked,
                    isLessonUnlocked: { id in isLessonUnlocked(id, chapter: chapter, chapterIndex: chapterIndex) },
                    completedIDs: completedIDs,
                    completedSessionCount: completedSessionCount(for:),
                    totalSessions: totalSessions(for:),
                    nextSessionNumber: nextSessionNumber(for:),
                    lessonTitle: lessonTitle(for:),
                    isPremium: profile?.isPremium ?? false,
                    selectedLessonID: $selectedLessonID,
                    showPremiumGate: $showPremiumGate
                )
                .id("chapter_\(chapter.chapterId)")
            }
        }
    }

    /// The chapter containing the user's current (next incomplete) lesson.
    private var currentChapterId: String? {
        for chapter in chapters {
            for lessonID in chapter.lessonIDs {
                if !completedIDs.contains(lessonID) {
                    return chapter.chapterId
                }
            }
        }
        return nil
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

}
