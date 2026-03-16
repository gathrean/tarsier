import SwiftUI
import UserNotifications

/// Screen 14: Notification permission pitch
struct OnboardingNotificationScreen: View {
    let onContinue: () -> Void

    @State private var hasRequestedPermission = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            BunsoView(pose: .tappingWrist, size: 120)

            VStack(spacing: 12) {
                Text("I'll remind you to practice so it becomes a habit!")
                    .font(TarsierFonts.heading(20))
                    .foregroundStyle(TarsierColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("A quick daily reminder keeps your streak alive")
                    .font(TarsierFonts.body())
                    .foregroundStyle(TarsierColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            // Request notification permission after 3 seconds
            guard !hasRequestedPermission else { return }
            hasRequestedPermission = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
            }
        }
    }
}
