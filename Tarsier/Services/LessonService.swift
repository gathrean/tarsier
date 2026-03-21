import Foundation

@MainActor
final class LessonService {
    static let shared = LessonService()

    private var cachedLessons: [SlideLesson]?
    private var cachedChapters: [Chapter]?

    private init() {}

    func loadAllLessons() -> [SlideLesson] {
        if let cached = cachedLessons { return cached }

        let decoder = JSONDecoder()
        var lessons: [SlideLesson] = []

        // Load all chapter lesson IDs, then find each file by resource name
        let chapters = loadChapters()

        for chapter in chapters {
            for lessonID in chapter.lessonIDs {
                // Bundle filename: ch01_lesson_001 for lesson ID ch01_001
                let parts = lessonID.split(separator: "_", maxSplits: 1)
                guard parts.count == 2 else { continue }
                let resourceName = "\(parts[0])_lesson_\(parts[1])"

                // Try multiple lookup strategies (subdirectory vs flat bundle)
                let url: URL? =
                    Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: chapter.directory)
                    ?? Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: "Lessons/\(chapter.directory ?? "")")
                    ?? Bundle.main.url(forResource: resourceName, withExtension: "json")

                guard let url else {
                    print("Could not find \(resourceName).json (dir: \(chapter.directory ?? "nil"))")
                    continue
                }
                do {
                    let data = try Data(contentsOf: url)
                    let lesson = try decoder.decode(SlideLesson.self, from: data)
                    lessons.append(lesson)
                } catch {
                    print("Failed to load \(resourceName).json: \(error)")
                }
            }
        }

        lessons.sort {
            if $0.chapterId != $1.chapterId {
                return $0.chapterId < $1.chapterId
            }
            return ($0.positionInChapter ?? 0) < ($1.positionInChapter ?? 0)
        }

        cachedLessons = lessons
        return lessons
    }

    func lesson(for id: String) -> SlideLesson? {
        loadAllLessons().first { $0.id == id }
    }

    func loadChapters() -> [Chapter] {
        if let cached = cachedChapters { return cached }

        let url: URL? =
            Bundle.main.url(forResource: "chapters", withExtension: "json")
            ?? Bundle.main.url(forResource: "chapters", withExtension: "json", subdirectory: "Lessons")

        guard let url else {
            print("Could not find chapters.json in bundle")
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
