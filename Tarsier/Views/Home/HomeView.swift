import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var sessionProgresses: [SessionProgress]
    @State private var chapters: [Chapter] = []
    @State private var lessons: [SlideLesson] = []
    @State private var showPremiumGate = false
    @State private var showGreetingSheet = false
    @Environment(\.scenePhase) private var scenePhase

    /// In-memory flag: persists for the lifetime of the app process.
    /// Resets only when the app is fully terminated and relaunched.
    nonisolated(unsafe) private static var hasShownGreetingThisLaunch = false

    private var profile: UserProfile? { profiles.first }
    private var completedIDs: [Int] { profile?.completedLessonIDs ?? [] }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    // Spacer to push content below the floating header
                    Color.clear.frame(height: 44)

                    // Chapter grid
                    ChapterGridView(
                        chapters: chapters,
                        completedIDs: completedIDs,
                        completedSessionCount: completedSessionCount(for:),
                        totalSessions: totalSessions(for:)
                    )
                    .padding(.top, 28)
                    .padding(.bottom, 100) // Extra bottom clearance for tab bar
                }
            }

            // Floating gradient header pinned to top
            gradientHeader
                .allowsHitTesting(true)
        }
        .background(TarsierColors.warmWhite)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Chapter.self) { chapter in
            let idx = chapters.firstIndex(where: { $0.id == chapter.id }) ?? 0
            let locked = idx > 0 && !chapters[idx - 1].lessonIDs.allSatisfy({ completedIDs.contains($0) })
            ChapterDetailView(
                chapter: chapter,
                chapterIndex: idx,
                lessons: lessons,
                completedIDs: completedIDs,
                completedSessionCount: completedSessionCount(for:),
                totalSessions: totalSessions(for:),
                nextSessionNumber: nextSessionNumber(for:),
                isPremium: profile?.isPremium ?? false,
                isChapterLocked: locked
            )
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
        .overlay(alignment: .bottom) {
            if showGreetingSheet {
                GreetingSheetView(
                    profile: profile,
                    currentStreak: profile?.currentStreak ?? 0,
                    inProgressLessonTitle: inProgressLessonTitle,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showGreetingSheet = false
                        }
                    }
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 64) // sits above tab bar
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.3), value: showGreetingSheet)
        .onAppear {
            chapters = LessonService.shared.loadChapters()
            lessons = LessonService.shared.loadAllLessons()
            if let profile {
                StreakService.validateStreak(for: profile)
                profile.refillHearts()
            }

            // Show greeting sheet once per app launch (cold start only)
            if !Self.hasShownGreetingThisLaunch {
                Self.hasShownGreetingThisLaunch = true
                showGreetingSheet = true
            }
        }
    }

    // MARK: - Ube Purple Gradient Header

    /// Daily XP goal for the progress bar
    private let dailyXPGoal: Int = 100

    /// XP progress toward next level milestone (totalXP mod dailyGoal)
    private var xpProgress: Int {
        (profile?.totalXP ?? 0) % dailyXPGoal
    }

    private var gradientHeader: some View {
        VStack(spacing: 0) {
            // Stats bar: streak, XP progress bar, hearts
            HStack(spacing: 12) {
                // Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(TarsierColors.gold)
                    Text("\(profile?.currentStreak ?? 0)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(.white)
                }

                // XP progress bar capsule
                HStack(spacing: 6) {
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#38BDF8"))

                    GeometryReader { geo in
                        Capsule()
                            .fill(Color.white.opacity(0.20))
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: max(0, geo.size.width * min(1.0, CGFloat(xpProgress) / CGFloat(dailyXPGoal))))
                            }
                    }
                    .frame(width: 100, height: 8)
                }

                Spacer()

                // Hearts
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(TarsierColors.heartRed)
                    Text("\(profile?.hearts ?? 5)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, TarsierSpacing.screenPadding)
            .padding(.bottom, 12)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "#5B48E0"), Color(hex: "#5B48E0").opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.top, -200)   // extend up behind safe area
            .padding(.bottom, -80) // extend down behind first chapter node
        )
    }

    // MARK: - In-Progress Lesson Title (for greeting sheet)

    private var inProgressLessonTitle: String? {
        for chapter in chapters {
            for lessonID in chapter.lessonIDs {
                if !completedIDs.contains(lessonID) && completedSessionCount(for: lessonID) > 0 {
                    return lessons.first { $0.id == lessonID }?.title
                }
            }
        }
        return nil
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
}
