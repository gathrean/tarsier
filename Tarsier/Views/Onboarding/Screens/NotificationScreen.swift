import SwiftUI
import UserNotifications

/// Screen 14: Notification permission pitch
struct OnboardingNotificationScreen: View {
    let onContinue: () -> Void

    @State private var hasRequestedPermission = false

    var body: some View {
        VStack(spacing: 32) {
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
