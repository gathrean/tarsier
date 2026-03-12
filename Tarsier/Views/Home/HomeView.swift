import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var sessionProgresses: [SessionProgress]
    @State private var chapters: [Chapter] = []
    @State private var lessons: [SlideLesson] = []
    @State private var showPremiumGate = false
    @State private var showGreeting = false
    @State private var selectedLessonID: Int? = nil
    @AppStorage("lastGreetingDate") private var lastGreetingDate: String = ""

    private var profile: UserProfile? { profiles.first }
    private var completedIDs: [Int] { profile?.completedLessonIDs ?? [] }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                topBar
                    .padding(.top, geo.safeAreaInsets.top)
                    .zIndex(1)

                ZStack(alignment: .top) {
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
                    }
                    .padding(.top, TarsierSpacing.sectionSpacing)
                    .padding(.bottom, 40)
                }

                    // Fade gradient at top of scroll area
                    LinearGradient(
                        colors: [TarsierColors.warmWhite, TarsierColors.warmWhite.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 24)
                    .allowsHitTesting(false)
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

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "hexagon.fill")
                        .foregroundStyle(Color(hex: "#38BDF8"))
                    Text("\(profile?.totalXP ?? 0)")
                        .font(TarsierFonts.heading(18))
                        .foregroundStyle(Color(hex: "#38BDF8"))
                }

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(TarsierColors.heartRed)
                    Text("\(profile?.hearts ?? 5)")
                        .font(TarsierFonts.heading(18))
                        .foregroundStyle(TarsierColors.heartRed)
                }
            }
        }
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .padding(.vertical, 12)
        .padding(.horizontal, TarsierSpacing.screenPadding)
        .background(TarsierColors.functionalPurple)
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
            }
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

}
