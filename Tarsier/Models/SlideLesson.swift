import Foundation

// MARK: - Top-Level Lesson (v0.4 session-based schema)

struct SlideLesson: Codable, Identifiable {
    let lessonId: String
    let title: String
    let subtitle: String?
    let chapterId: String
    let chapterTitle: String
    let totalSessions: Int
    let sessions: [LessonSession]
    let vocabulary: [LessonVocabulary]
    let completionReward: CompletionReward
    let gamification: SessionGamification
    let wrongAnswerTracking: WrongAnswerTracking?
    let aiPractice: AIPracticeConfig?

    var id: Int { Int(lessonId) ?? 0 }
    var topic: String { title }

    enum CodingKeys: String, CodingKey {
        case lessonId = "lesson_id"
        case title, subtitle, sessions, vocabulary, gamification
        case chapterId = "chapter_id"
        case chapterTitle = "chapter_title"
        case totalSessions = "total_sessions"
        case completionReward = "completion_reward"
        case wrongAnswerTracking = "wrong_answer_tracking"
        case aiPractice = "ai_practice"
    }
}

// MARK: - Session

struct LessonSession: Codable, Identifiable {
    let sessionId: String
    let sessionNumber: Int
    let title: String
    let isReview: Bool?
    let cards: [SessionCard]

    var id: String { sessionId }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case sessionNumber = "session_number"
        case title, cards
        case isReview = "is_review"
    }
}

// MARK: - Card

enum CardType: String, Codable {
    case teach
    case quiz
    case characterIntro = "character_intro"
}

struct SessionCard: Codable, Identifiable {
    let cardId: String
    let type: CardType

    // Shared optional fields (v0.5)
    let image: CardImage?
    let alamMoBaInline: AlamMoBaInline?

    // v0.7 — optional pronunciation audio path (relative to bundle)
    let audio: String?

    // v0.4.1 — optional character (used on teach, quiz, and character_intro cards)
    let character: TarsierCharacter?

    // Teach fields
    let body: String?
    let highlight: String?
    let usePo: Bool?
    let example: CardExample?

    // Quiz fields
    let quizType: QuizType?
    let prompt: String?
    let options: [String]?
    let correctAnswer: Int?
    let correctAnswers: [String]?
    let hint: String?
    let explanation: String?
    let shuffleOptions: Bool?

    // Word-order quiz fields
    let givenSentence: String?
    let wordPieces: [String]?
    let correctOrders: [[String]]?
    let bestOrder: [String]?

    // Image-match quiz fields (v0.4)
    let imageMatchOptions: [ImageMatchOption]?

    // Sentence-build quiz fields (v0.4)
    let sourceText: String?
    let correctOrder: [String]?
    let distractors: [String]?

    // Character-intro fields (v0.4.1)
    let text: String?
    let funFact: String?

    var id: String { cardId }

    enum CodingKeys: String, CodingKey {
        case cardId = "card_id"
        case type, body, highlight, image, example, audio, character
        case alamMoBaInline = "alam_mo_ba_inline"
        case usePo = "use_po"
        case quizType = "quiz_type"
        case prompt, options, hint, explanation, text
        case correctAnswer = "correct_answer"
        case correctAnswers = "correct_answers"
        case shuffleOptions = "shuffle_options"
        case givenSentence = "given_sentence"
        case wordPieces = "word_pieces"
        case correctOrders = "correct_orders"
        case bestOrder = "best_order"
        case imageMatchOptions = "image_match_options"
        case sourceText = "source_text"
        case correctOrder = "correct_order"
        case distractors
        case funFact = "fun_fact"
    }
}

// MARK: - Image Match Option

struct ImageMatchOption: Codable, Identifiable {
    let image: String
    let label: String
    let correct: Bool

    var id: String { label }
}

// MARK: - Card Sub-Types

enum QuizType: String, Codable {
    case multipleChoice = "multiple_choice"
    case fillInBlank = "fill_in_blank"
    case wordOrder = "word_order"
    case imageMatch = "image_match"
    case sentenceBuild = "sentence_build"
}

struct CardImage: Codable {
    let filename: String?
    let alt: String?
    let source: String?
    let attribution: String?
}

struct AlamMoBaInline: Codable {
    let term: String
    let fact: String
    let emoji: String?
}

struct CardExample: Codable {
    // Format 1: casual → with_po
    let casual: String?
    let withPo: String?
    let note: String?

    // Format 2: context + sentence
    let context: String?
    let sentence: String?
    let translation: String?
    let taglish: String?
    let poPosition: String?

    enum CodingKeys: String, CodingKey {
        case casual, note, context, sentence, translation, taglish
        case withPo = "with_po"
        case poPosition = "po_position"
    }
}

// MARK: - Vocabulary

struct LessonVocabulary: Codable, Identifiable {
    let word: String
    let meaning: String
    let pronunciation: String
    let type: String

    var id: String { word }
}

// MARK: - Completion Reward

struct CompletionReward: Codable {
    let xp: Int
    let alamMoBa: [String]

    enum CodingKeys: String, CodingKey {
        case xp
        case alamMoBa = "alam_mo_ba"
    }
}

// MARK: - Wrong Answer Tracking

struct WrongAnswerTracking: Codable {
    let behaviour: String?
    let trackWrongCount: Bool?
    let wrongCountUsage: String?

    enum CodingKeys: String, CodingKey {
        case behaviour
        case trackWrongCount = "track_wrong_count"
        case wrongCountUsage = "wrong_count_usage"
    }
}

// MARK: - Gamification

struct SessionGamification: Codable {
    let xpPerLesson: Int
    let heartsPerWrongAnswer: Int
    let streakEligible: Bool
    let progressRing: ProgressRingConfig?
    let replay: ReplayConfig?

    enum CodingKeys: String, CodingKey {
        case xpPerLesson = "xp_per_lesson"
        case heartsPerWrongAnswer = "hearts_per_wrong_answer"
        case streakEligible = "streak_eligible"
        case progressRing = "progress_ring"
        case replay
    }
}

struct ProgressRingConfig: Codable {
    let total: Int
    let display: String?
}

struct ReplayConfig: Codable {
    let allowed: Bool
    let xpOnReplay: Int

    enum CodingKeys: String, CodingKey {
        case allowed
        case xpOnReplay = "xp_on_replay"
    }
}

// MARK: - AI Practice Config

struct AIPracticeConfig: Codable {
    let description: String?
    let systemPromptTemplate: String?
    let maxTurns: Int?
    let wrongAnswerContextExample: String?

    enum CodingKeys: String, CodingKey {
        case description
        case systemPromptTemplate = "system_prompt_template"
        case maxTurns = "max_turns"
        case wrongAnswerContextExample = "wrong_answer_context_example"
    }
}

// MARK: - Navigation

struct LessonNavigation: Hashable {
    let lessonId: Int
    let sessionNumber: Int
    let isReplay: Bool
}
