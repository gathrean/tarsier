import Foundation
import SwiftData

@Model
final class ChapterProgress {
    var id: UUID
    var chapterId: String
    var isUnlocked: Bool
    var aiPracticeCompleted: Bool
    var aiPracticeSessionsUsed: Int

    init(
        chapterId: String,
        isUnlocked: Bool = false,
        aiPracticeCompleted: Bool = false,
        aiPracticeSessionsUsed: Int = 0
    ) {
        self.id = UUID()
        self.chapterId = chapterId
        self.isUnlocked = isUnlocked
        self.aiPracticeCompleted = aiPracticeCompleted
        self.aiPracticeSessionsUsed = aiPracticeSessionsUsed
    }
}
