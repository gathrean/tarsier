import Foundation
import SwiftData

@Model
final class LessonResult {
    var id: UUID
    var lessonID: Int
    var score: Int
    var totalQuestions: Int
    var completedAt: Date

    init(lessonID: Int, score: Int, totalQuestions: Int) {
        self.id = UUID()
        self.lessonID = lessonID
        self.score = score
        self.totalQuestions = totalQuestions
        self.completedAt = Date()
    }
}
