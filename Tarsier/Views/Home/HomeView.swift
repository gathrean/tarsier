import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @State private var lessons: [Lesson] = []

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                streakHeader
                lessonList
            }
            .padding()
        }
        .background(TarsierColors.warmWhite)
        .navigationTitle("Tarsier")
        .onAppear {
            lessons = LessonService.shared.loadAllLessons()
            if let profile {
                StreakService.validateStreak(for: profile)
            }
        }
    }

    // MARK: - Streak Header

    private var streakHeader: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(TarsierColors.gold)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("\(profile?.currentStreak ?? 0)")
                    .font(TarsierFonts.heading(22))
                Text("day streak")
                    .font(TarsierFonts.body(15))
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            Spacer()

            Text("Lesson \(profile?.currentLessonIndex ?? 1)")
                .font(TarsierFonts.button())
                .foregroundStyle(TarsierColors.functionalPurple)
        }
        .padding(TarsierSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .fill(TarsierColors.cream)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Lesson List

    private var lessonList: some View {
        VStack(spacing: 12) {
            ForEach(lessons) { lesson in
                let isCompleted = profile?.completedLessonIDs.contains(lesson.id) ?? false
                let isUnlocked = lesson.id <= (profile?.currentLessonIndex ?? 1)

                NavigationLink(value: lesson.id) {
                    LessonCard(
                        lesson: lesson,
                        isCompleted: isCompleted,
                        isUnlocked: isUnlocked
                    )
                }
                .disabled(!isUnlocked)
            }
        }
        .navigationDestination(for: Int.self) { lessonID in
            if let lesson = LessonService.shared.lesson(for: lessonID) {
                LessonView(lesson: lesson)
            }
        }
    }
}

// MARK: - Lesson Card

struct LessonCard: View {
    let lesson: Lesson
    let isCompleted: Bool
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? TarsierColors.functionalPurple : (isUnlocked ? TarsierColors.cream : TarsierColors.cardBorder))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(isUnlocked && !isCompleted ? TarsierColors.functionalPurple : .clear, lineWidth: 2)
                    )

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                } else if isUnlocked {
                    Text("\(lesson.id)")
                        .font(TarsierFonts.button())
                        .foregroundStyle(TarsierColors.functionalPurple)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(TarsierColors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.topic)
                    .font(TarsierFonts.button())
                    .foregroundStyle(isUnlocked ? TarsierColors.textPrimary : TarsierColors.textSecondary)

                Text(lesson.tier.capitalized)
                    .font(TarsierFonts.caption())
                    .foregroundStyle(TarsierColors.textSecondary)
            }

            Spacer()

            if isUnlocked && !isCompleted {
                Image(systemName: "chevron.right")
                    .foregroundStyle(TarsierColors.textSecondary)
            }
        }
        .padding(TarsierSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .fill(TarsierColors.cream)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TarsierSpacing.cardCornerRadius)
                .stroke(TarsierColors.cardBorder, lineWidth: 1)
        )
        .opacity(isUnlocked ? 1 : 0.6)
    }
}
