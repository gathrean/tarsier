import Foundation

struct ChapterRow: Codable {
    let row: Int
    let lessons: [String]
}

struct Chapter: Codable, Identifiable {
    let chapterId: String
    let title: String
    let subtitle: String
    let rows: [ChapterRow]

    var id: String { chapterId }

    /// Flat list of all lesson IDs as Ints (backward compat with existing Int-based system)
    var lessonIDs: [Int] {
        rows.flatMap { $0.lessons }.compactMap { Int($0) }
    }

    enum CodingKeys: String, CodingKey {
        case chapterId = "chapter_id"
        case title, subtitle, rows
    }
}
