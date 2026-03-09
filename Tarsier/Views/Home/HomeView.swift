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
        .background(Color(.systemGroupedBackground))
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
                    .foregroundStyle(TarsierTheme.yellow)
                    .font(.title2)
                Text("\(profile?.currentStreak ?? 0)")
                    .font(TarsierTheme.title2)
                Text("day streak")
                    .font(TarsierTheme.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("Lesson \(profile?.currentLessonIndex ?? 1)")
                .font(TarsierTheme.headline)
                .foregroundStyle(TarsierTheme.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
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
                    .fill(isUnlocked ? TarsierTheme.blue : Color(.systemGray4))
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(lesson.id)")
                        .font(TarsierTheme.headline)
                        .foregroundStyle(.white)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(lesson.topic)
                    .font(TarsierTheme.headline)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                Text(lesson.tier.capitalized)
                    .font(TarsierTheme.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
        )
        .opacity(isUnlocked ? 1 : 0.6)
    }
}
