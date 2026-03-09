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
    var completedLessonIDs: [Int]
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var createdAt: Date
    var motivations: [String]

    init(
        skillLevel: SkillLevel = .beginner,
        currentLessonIndex: Int = 1,
        completedLessonIDs: [Int] = [],
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompletedDate: Date? = nil,
        motivations: [String] = []
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
    }
}
