import Foundation
import SwiftData

@Model
final class LessonResult {
    var id: UUID
    var lessonID: String
    var chapterId: String
    var score: Int
    var totalQuestions: Int
    var xpEarned: Int
    var completedAt: Date

    init(lessonID: String, chapterId: String = "", score: Int, totalQuestions: Int, xpEarned: Int = 15) {
        self.id = UUID()
        self.lessonID = lessonID
        self.chapterId = chapterId
        self.score = score
        self.totalQuestions = totalQuestions
        self.xpEarned = xpEarned
        self.completedAt = Date()
    }
}
