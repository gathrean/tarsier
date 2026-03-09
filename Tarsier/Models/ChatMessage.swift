import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var content: String
    var isUser: Bool
    var createdAt: Date
    var sessionDate: Date

    init(content: String, isUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.createdAt = Date()
        self.sessionDate = Calendar.current.startOfDay(for: Date())
    }
}
