import Foundation
import SwiftData

@Model
final class SessionProgress {
    var id: UUID
    var lessonId: String
    var sessionNumber: Int
    var isCompleted: Bool
    var completedAt: Date?
    /// Tracks how many times the user got each card wrong (cardId → count)
    var wrongCounts: [String: Int]

    init(lessonId: String, sessionNumber: Int) {
        self.id = UUID()
        self.lessonId = lessonId
        self.sessionNumber = sessionNumber
        self.isCompleted = false
        self.completedAt = nil
        self.wrongCounts = [:]
    }

    func recordWrongAnswer(cardId: String) {
        wrongCounts[cardId, default: 0] += 1
    }

    func markCompleted() {
        isCompleted = true
        completedAt = Date()
    }
}
