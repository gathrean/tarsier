import Foundation

@MainActor
final class LessonService {
    static let shared = LessonService()

    private var cachedLessons: [SlideLesson]?
    private var cachedChapters: [Chapter]?

    private init() {}

    func loadAllLessons() -> [SlideLesson] {
        if let cached = cachedLessons { return cached }

        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return []
        }

        let decoder = JSONDecoder()
        var lessons: [SlideLesson] = []

        for url in urls {
            guard url.lastPathComponent.hasPrefix("lesson_") else { continue }
            do {
                let data = try Data(contentsOf: url)
                let lesson = try decoder.decode(SlideLesson.self, from: data)
                lessons.append(lesson)
            } catch {
                print("Failed to load lesson from \(url.lastPathComponent): \(error)")
            }
        }

        lessons.sort { $0.id < $1.id }
        cachedLessons = lessons
        return lessons
    }

    func lesson(for id: Int) -> SlideLesson? {
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
