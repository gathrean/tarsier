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
    let icon: String?
    let accentColor: String?
    let rows: [ChapterRow]

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

    enum CodingKeys: String, CodingKey {
        case chapterId = "chapter_id"
        case title, subtitle, icon, rows
        case accentColor = "accent_color"
    }
}
