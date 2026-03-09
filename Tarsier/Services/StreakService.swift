import Foundation
import SwiftData

struct StreakService {
    static func updateStreak(for profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastCompleted = profile.lastCompletedDate else {
            // First ever lesson completion
            profile.currentStreak = 1
            profile.longestStreak = max(profile.longestStreak, 1)
            profile.lastCompletedDate = today
            return
        }

        let lastDay = calendar.startOfDay(for: lastCompleted)

        if lastDay == today {
            // Already completed a lesson today — no change
            return
        }

        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        if lastDay == calendar.startOfDay(for: yesterday) {
            // Consecutive day — increment streak
            profile.currentStreak += 1
        } else {
            // Missed a day — reset streak
            profile.currentStreak = 1
        }

        profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
        profile.lastCompletedDate = today
    }

    /// Call on app launch to check if streak should be reset (missed yesterday entirely)
    static func validateStreak(for profile: UserProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastCompleted = profile.lastCompletedDate else { return }

        let lastDay = calendar.startOfDay(for: lastCompleted)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if lastDay < calendar.startOfDay(for: yesterday) {
            // More than 1 day ago — streak is broken
            profile.currentStreak = 0
        }
    }
}
