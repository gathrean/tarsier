import SwiftUI
import SwiftData

/// Plays the first lesson (Po & Opo) after onboarding completes.
/// On session complete, marks onboarding as done → ContentView routes to MainTabView.
struct OnboardingLessonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        if let lesson = LessonService.shared.lesson(for: 1) {
            LessonContainerView(
                lesson: lesson,
                sessionNumber: 1,
                isReplay: false,
                hideCloseButton: true,
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
