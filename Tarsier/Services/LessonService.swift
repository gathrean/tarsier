import Foundation

@MainActor
final class LessonService {
    static let shared = LessonService()

    private var cachedLessons: [Lesson]?
    private var cachedChapters: [Chapter]?

    private init() {}

    func loadAllLessons() -> [Lesson] {
        if let cached = cachedLessons { return cached }

        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return []
        }

        let decoder = JSONDecoder()
        var lessons: [Lesson] = []

        for url in urls {
            // Only load lesson files (named like lesson_01.json)
            guard url.lastPathComponent.hasPrefix("lesson_") else { continue }
            do {
                let data = try Data(contentsOf: url)
                let lesson = try decoder.decode(Lesson.self, from: data)
                lessons.append(lesson)
            } catch {
                print("Failed to load lesson from \(url.lastPathComponent): \(error)")
            }
        }

        lessons.sort { $0.id < $1.id }
        cachedLessons = lessons
        return lessons
    }

    func lesson(for id: Int) -> Lesson? {
        loadAllLessons().first { $0.id == id }
    }

    func loadChapters() -> [Chapter] {
        if let cached = cachedChapters { return cached }

        guard let url = Bundle.main.url(forResource: "chapters", withExtension: "json") else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let chapters = try JSONDecoder().decode([Chapter].self, from: data)
            cachedChapters = chapters
            return chapters
        } catch {
            print("Failed to load chapters: \(error)")
            return []
        }
    }
}
