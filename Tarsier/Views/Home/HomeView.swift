import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
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
        .navigationDestination(for: Int.self) { lessonID in
            if let lesson = LessonService.shared.lesson(for: lessonID) {
                LessonContainerView(lesson: lesson)
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
            // Streak
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(TarsierColors.gold)
                Text("\(profile?.currentStreak ?? 0)")
                    .font(TarsierFonts.heading(18))
            }

            Spacer()

            // XP
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(TarsierColors.functionalPurple)
                Text("\(profile?.totalXP ?? 0)")
                    .font(TarsierFonts.heading(18))
                    .foregroundStyle(TarsierColors.functionalPurple)
            }

            Spacer()

            // Hearts
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

            // Lesson nodes — staggered
            ForEach(Array(chapter.lessonIDs.enumerated()), id: \.element) { nodeIndex, lessonID in
                let isCompleted = completedIDs.contains(lessonID)
                let isCurrent = lessonID == currentLessonIndex
                let isUnlocked = lessonID <= currentLessonIndex

                // Dotted connector (above each node except the first)
                if nodeIndex > 0 {
                    dottedConnector(offset: staggerOffset(for: nodeIndex, previous: nodeIndex - 1))
                }

                // Node
                lessonNode(
                    lessonID: lessonID,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isUnlocked: isUnlocked,
                    nodeIndex: nodeIndex
                )
            }

            // AI Practice node after chapter
            dottedConnector(offset: 0)
            aiPracticeNode(chapter: chapter)
        }
    }

    // MARK: - Stagger

    private func staggerOffset(for index: Int, previous: Int) -> CGFloat {
        let currentX = nodeX(for: index)
        let previousX = nodeX(for: previous)
        return (currentX - previousX) / 2
    }

    private func nodeX(for index: Int) -> CGFloat {
        // Stagger pattern: centre, right, centre, left, centre, right...
        let pattern: [CGFloat] = [0, 50, 0, -50]
        return pattern[index % pattern.count]
    }

    // MARK: - Lesson Node

    private func lessonNode(lessonID: Int, isCompleted: Bool, isCurrent: Bool, isUnlocked: Bool, nodeIndex: Int) -> some View {
        let lesson = lessons.first { $0.id == lessonID }
        let topic = lesson?.topic ?? "Lesson \(lessonID)"
        let offset = nodeX(for: nodeIndex)

        return NavigationLink(value: lessonID) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(nodeBackground(isCompleted: isCompleted, isCurrent: isCurrent, isUnlocked: isUnlocked))
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    isCurrent ? TarsierColors.functionalPurple : .clear,
                                    lineWidth: isCurrent ? 3 : 0
                                )
                        )
                        .shadow(
                            color: isCurrent ? TarsierColors.functionalPurple.opacity(0.3) : .clear,
                            radius: isCurrent ? 8 : 0
                        )

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else if isUnlocked {
                        Text("\(lessonID)")
                            .font(TarsierFonts.heading())
                            .foregroundStyle(TarsierColors.functionalPurple)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(TarsierColors.textSecondary)
                    }
                }

                Text(topic)
                    .font(TarsierFonts.caption(11))
                    .foregroundStyle(isUnlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)
                    .lineLimit(1)
            }
            .opacity(isUnlocked ? 1 : 0.5)
        }
        .disabled(!isUnlocked)
        .offset(x: offset)
        .padding(.vertical, 4)
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
                RoundedRectangle(cornerRadius: 20)
                    .fill(unlocked ? TarsierColors.gold.opacity(0.15) : Color(hex: "#EEEAE6"))
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                unlocked ? TarsierColors.gold : TarsierColors.cardBorder,
                                style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                            )
                    )

                Image(systemName: "eyes")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(unlocked ? TarsierColors.gold : TarsierColors.textSecondary)
            }

            Text("Practice")
                .font(TarsierFonts.caption(11))
                .foregroundStyle(unlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)
        }
        .opacity(unlocked ? 1 : 0.5)
    }

    // MARK: - Dotted Connector

    private func dottedConnector(offset: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 24))
        }
        .stroke(TarsierColors.cardBorder, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
        .frame(width: 2, height: 24)
        .offset(x: offset)
    }
}
