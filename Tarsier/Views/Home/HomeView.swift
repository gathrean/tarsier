import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var sessionProgresses: [SessionProgress]
    @State private var chapters: [Chapter] = []
    @State private var lessons: [SlideLesson] = []
    @State private var showPremiumGate = false
    @State private var showGreetingSheet = false
    @State private var hasShownGreetingThisSession = false
    @Environment(\.scenePhase) private var scenePhase

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
                    .padding(.bottom, 40)
                }
            }

            // Floating gradient header pinned to top
            gradientHeader
                .allowsHitTesting(true)
        }
        .background(TarsierColors.warmWhite)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: Chapter.self) { chapter in
            ChapterDetailView(
                chapter: chapter,
                chapterIndex: chapters.firstIndex(where: { $0.id == chapter.id }) ?? 0,
                lessons: lessons,
                completedIDs: completedIDs,
                completedSessionCount: completedSessionCount(for:),
                totalSessions: totalSessions(for:),
                nextSessionNumber: nextSessionNumber(for:),
                isPremium: profile?.isPremium ?? false
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
        .sheet(isPresented: $showGreetingSheet) {
            GreetingSheetView(
                profile: profile,
                currentStreak: profile?.currentStreak ?? 0,
                inProgressLessonTitle: inProgressLessonTitle,
                onDismiss: { showGreetingSheet = false }
            )
            .presentationDetents([.height(180)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
        .onAppear {
            chapters = LessonService.shared.loadChapters()
            lessons = LessonService.shared.loadAllLessons()
            if let profile {
                StreakService.validateStreak(for: profile)
                profile.refillHearts()
            }

            // Show greeting sheet once per app session
            if !hasShownGreetingThisSession {
                hasShownGreetingThisSession = true
                showGreetingSheet = true
            }
        }
    }

    // MARK: - Ube Purple Gradient Header

    private var gradientHeader: some View {
        VStack(spacing: 0) {
            // "tarsier" wordmark — tucked behind Dynamic Island
            Text("tarsier")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.top, -28)

            // Stats bar: streak, XP, hearts
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(TarsierColors.gold)
                    Text("\(profile?.currentStreak ?? 0)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 4) {
                    Image(systemName: "hexagon.fill")
                        .foregroundStyle(Color(hex: "#38BDF8"))
                    Text("\(profile?.totalXP ?? 0)")
                        .font(TarsierFonts.heading(16))
                        .foregroundStyle(.white)
                }

                Spacer()

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
