import Foundation

struct Chapter: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let lessonIDs: [Int]
}
