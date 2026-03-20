import Foundation
import SwiftUI

struct ChapterRow: Codable, Hashable {
    let row: Int
    let lessons: [String]
}

struct Chapter: Codable, Identifiable, Hashable {
    let chapterId: String
    let title: String
    let subtitle: String
    let directory: String?
    let icon: String?
    let accentColor: String?
    let rows: [ChapterRow]
    let description: String?
    let hasPractice: Bool?
    let totalLessons: Int?
    let totalWords: Int?

    var id: String { chapterId }

    /// Flat list of all lesson IDs as Ints (backward compat with existing Int-based system)
    var lessonIDs: [Int] {
        rows.flatMap { $0.lessons }.compactMap { Int($0) }
    }

    /// Resolved accent colour from hex string, with fallback.
    var accentSwiftUIColor: Color {
        guard let hex = accentColor else { return Color(hex: "#5B48E0") }
        return Color(hex: hex)
    }

    /// Whether this chapter shows an AI Practice node. Defaults to true if not specified,
    /// but also gated behind the global feature flag.
    var showsPractice: Bool {
        (hasPractice ?? true) && FeatureFlags.aiPracticeEnabled
    }

    enum CodingKeys: String, CodingKey {
        case chapterId = "chapter_id"
        case title, subtitle, directory, icon, rows, description
        case accentColor = "accent_color"
        case hasPractice = "has_practice"
        case totalLessons = "total_lessons"
        case totalWords = "total_words"
    }
}
