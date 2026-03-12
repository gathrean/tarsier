import SwiftUI
import SwiftData

struct OnboardingLessonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        Group {
            if let lesson = LessonService.shared.lesson(for: 1) {
                LessonContainerView(
                    lesson: lesson,
                    sessionNumber: 1,
                    isReplay: false,
                    onSessionComplete: {
                        profile?.hasCompletedOnboarding = true
                        try? modelContext.save()
                    }
                )
            } else {
                // Fallback: if lesson_001.json is missing, skip to home
                Color.clear.onAppear {
                    profile?.hasCompletedOnboarding = true
                    try? modelContext.save()
                }
            }
        }
    }
}
