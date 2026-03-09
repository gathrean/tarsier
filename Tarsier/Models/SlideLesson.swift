import Foundation

// MARK: - Top-Level Lesson (v0.3 slide-based schema)

struct SlideLesson: Codable, Identifiable {
    let lessonId: String
    let title: String
    let chapterId: String
    let chapterTitle: String
    let slides: [LessonSlide]
    let gamification: LessonGamification

    /// Int ID derived from lessonId string (e.g. "001" -> 1)
    var id: Int { Int(lessonId) ?? 0 }
    /// Alias used by HomeView
    var topic: String { title }

    enum CodingKeys: String, CodingKey {
        case lessonId = "lesson_id"
        case title
        case chapterId = "chapter_id"
        case chapterTitle = "chapter_title"
        case slides, gamification
    }
}

// MARK: - Gamification

struct LessonGamification: Codable {
    let xpReward: Int
    let heartsPerWrongAnswer: Int
    let streakEligible: Bool

    enum CodingKeys: String, CodingKey {
        case xpReward = "xp_reward"
        case heartsPerWrongAnswer = "hearts_per_wrong_answer"
        case streakEligible = "streak_eligible"
    }
}

// MARK: - Slide Type

enum SlideType: String, Codable {
    case culturalContext = "cultural_context"
    case teaching
    case vocabulary
    case alamMoBa = "alam_mo_ba"
    case quiz
    case lessonSummary = "lesson_summary"
}

// MARK: - Lesson Slide

struct LessonSlide: Codable, Identifiable {
    let slideId: String
    let type: SlideType

    // Shared
    let title: String?
    let body: String?

    // Cultural context
    let taglishNote: String?
    let image: SlideImage?

    // Teaching
    let examples: [TeachingExample]?
    let rules: [TeachingRule]?

    // Vocabulary
    let words: [SlideVocabWord]?

    // Quiz
    let costsHeart: Bool?
    let questions: [SlideQuestion]?

    // Summary
    let keyWords: [String]?
    let grammarConcept: String?
    let culturalTakeaway: String?
    let rootsLearned: [String]?
    let affixesLearned: [String]?

    // Alam Mo Ba
    let borrowedWord: String?
    let originLanguage: String?

    var id: String { slideId }

    enum CodingKeys: String, CodingKey {
        case slideId = "slide_id"
        case type, title, body
        case taglishNote = "taglish_note"
        case image, examples, rules, words
        case costsHeart = "costs_heart"
        case questions
        case keyWords = "key_words"
        case grammarConcept = "grammar_concept"
        case culturalTakeaway = "cultural_takeaway"
        case rootsLearned = "roots_learned"
        case affixesLearned = "affixes_learned"
        case borrowedWord = "borrowed_word"
        case originLanguage = "origin_language"
    }
}

// MARK: - Slide Sub-Types

struct SlideImage: Codable {
    let source: String?
    let suggestedQuery: String?
    let attribution: String?
    let licence: String?

    enum CodingKeys: String, CodingKey {
        case source
        case suggestedQuery = "suggested_query"
        case attribution, licence
    }
}

struct TeachingExample: Codable {
    // Format 1: casual/with_po/note
    let casual: String?
    let withPo: String?
    let note: String?

    // Format 2: tagalog/translation/po_position
    let tagalog: String?
    let translation: String?
    let poPosition: String?

    enum CodingKeys: String, CodingKey {
        case casual, tagalog, translation, note
        case withPo = "with_po"
        case poPosition = "po_position"
    }
}

struct TeachingRule: Codable {
    let usePo: Bool
    let context: String
    let example: String

    enum CodingKeys: String, CodingKey {
        case usePo = "use_po"
        case context, example
    }
}

struct SlideVocabWord: Codable, Identifiable {
    let word: String
    let type: String
    let meaning: String
    let exampleSentence: String
    let exampleTranslation: String
    let taglishVariant: String?
    let pronunciationGuide: String
    let audioFile: String?

    var id: String { word }

    enum CodingKeys: String, CodingKey {
        case word, type, meaning
        case exampleSentence = "example_sentence"
        case exampleTranslation = "example_translation"
        case taglishVariant = "taglish_variant"
        case pronunciationGuide = "pronunciation_guide"
        case audioFile = "audio_file"
    }
}

struct SlideQuestion: Codable, Identifiable {
    let questionId: String
    let type: SlideQuestionType
    let prompt: String
    let options: [String]?
    let correctAnswer: Int?
    let correctAnswers: [String]?
    let hint: String?
    let explanation: String?

    var id: String { questionId }

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case type, prompt, options, hint, explanation
        case correctAnswer = "correct_answer"
        case correctAnswers = "correct_answers"
    }
}

enum SlideQuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case fillInBlank = "fill_in_blank"
}

// MARK: - Lesson Page (flattened from slides for display)

enum LessonPage: Identifiable {
    case culturalContext(slide: LessonSlide)
    case teaching(slide: LessonSlide)
    case vocabulary(word: SlideVocabWord)
    case alamMoBa(slide: LessonSlide)
    case quiz(question: SlideQuestion, costsHeart: Bool)
    case summary(slide: LessonSlide)

    var id: String {
        switch self {
        case .culturalContext(let slide): "cc_\(slide.slideId)"
        case .teaching(let slide): "teach_\(slide.slideId)"
        case .vocabulary(let word): "vocab_\(word.word)"
        case .alamMoBa(let slide): "amb_\(slide.slideId)"
        case .quiz(let question, _): "quiz_\(question.questionId)"
        case .summary(let slide): "sum_\(slide.slideId)"
        }
    }

    var showsContinueButton: Bool {
        switch self {
        case .quiz, .summary: false
        default: true
        }
    }
}

extension SlideLesson {
    /// Expand slides into individual pages (one word per page, one question per page)
    func expandToPages() -> [LessonPage] {
        var pages: [LessonPage] = []
        for slide in slides {
            switch slide.type {
            case .culturalContext:
                pages.append(.culturalContext(slide: slide))
            case .teaching:
                pages.append(.teaching(slide: slide))
            case .vocabulary:
                for word in slide.words ?? [] {
                    pages.append(.vocabulary(word: word))
                }
            case .alamMoBa:
                pages.append(.alamMoBa(slide: slide))
            case .quiz:
                let costsHeart = slide.costsHeart ?? true
                for question in slide.questions ?? [] {
                    pages.append(.quiz(question: question, costsHeart: costsHeart))
                }
            case .lessonSummary:
                pages.append(.summary(slide: slide))
            }
        }
        return pages
    }
}
