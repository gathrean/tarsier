import Foundation
import SwiftData

enum SkillLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case heritage

    var displayName: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .heritage: "Heritage Speaker"
        }
    }

    var description: String {
        switch self {
        case .beginner: "Never studied Tagalog, starting from zero"
        case .intermediate: "Knows basic phrases, wants to build structure"
        case .heritage: "Understands spoken Tagalog, can't construct sentences or read"
        }
    }
}

@Model
final class UserProfile {
    var id: UUID
    var skillLevel: SkillLevel
    var currentLessonIndex: Int
    var completedLessonIDs: [String]
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var createdAt: Date
    var motivations: [String]
    var totalXP: Int
    var hearts: Int
    var lastHeartRefill: Date?
    var isPremium: Bool
    var hasCompletedOnboarding: Bool = false
    var userName: String?
    var dailyGoalMinutes: Int = 10
    var hasSeenCoachMarks: Bool = false
    var seenUIWords: [String] = []
    var hasPromptedReview: Bool = false
    var notificationTime: Date?

    // v0.3 — Bunso onboarding fields
    var preferredTitle: String? = nil   // "Ate", "Kuya", or nil
    var selectedLanguage: String = "tagalog"
    var attributionSource: String = ""
    var proficiencyLevel: Int = 0       // 0–4

    // v0.4.1 — Character system
    var introducedCharacters: [String] = []           // TarsierCharacter raw values already introduced
    var characterAppearanceCounts: [String: Int] = [:] // Tracks how many times each character has appeared

    init(
        skillLevel: SkillLevel = .beginner,
        currentLessonIndex: Int = 1,
        completedLessonIDs: [String] = [],
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompletedDate: Date? = nil,
        motivations: [String] = [],
        totalXP: Int = 0,
        hearts: Int = 5,
        isPremium: Bool = false,
        hasCompletedOnboarding: Bool = false,
        dailyGoalMinutes: Int = 10
    ) {
        self.id = UUID()
        self.skillLevel = skillLevel
        self.currentLessonIndex = currentLessonIndex
        self.completedLessonIDs = completedLessonIDs
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCompletedDate = lastCompletedDate
        self.createdAt = Date()
        self.motivations = motivations
        self.totalXP = totalXP
        self.hearts = hearts
        self.lastHeartRefill = nil
        self.isPremium = isPremium
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.dailyGoalMinutes = dailyGoalMinutes
    }

    /// Refill hearts based on elapsed time (1 heart per 30 minutes, max 5)
    func refillHearts() {
        guard !isPremium, hearts < 5 else { return }
        let refillInterval: TimeInterval = 30 * 60 // 30 minutes
        let lastRefill = lastHeartRefill ?? createdAt
        let elapsed = Date().timeIntervalSince(lastRefill)
        let heartsToAdd = Int(elapsed / refillInterval)
        if heartsToAdd > 0 {
            hearts = min(5, hearts + heartsToAdd)
            lastHeartRefill = Date()
        }
    }

    /// Lose a heart (returns false if already at 0)
    @discardableResult
    func loseHeart() -> Bool {
        guard !isPremium else { return true }
        guard hearts > 0 else { return false }
        hearts -= 1
        return true
    }

    func addXP(_ amount: Int) {
        totalXP += amount
    }
}
