import Foundation

struct Lesson: Codable, Identifiable {
    let id: Int
    let tier: String
    let topic: String
    let culturalNote: String
    let etymology: Etymology
    let vocabulary: [VocabularyItem]
    let sentences: [Sentence]
    let quiz: [QuizQuestion]

    enum CodingKeys: String, CodingKey {
        case id, tier, topic, vocabulary, sentences, quiz, etymology
        case culturalNote = "cultural_note"
    }
}

struct Etymology: Codable {
    let focus: String
    let explanation: String
    let pattern: String
    let examples: [EtymologyExample]
}

struct EtymologyExample: Codable, Identifiable {
    let root: String
    let derived: String
    let meaning: String

    var id: String { root }
}

struct VocabularyItem: Codable, Identifiable {
    let tagalog: String
    let english: String
    let pronunciation: String
    let exampleSentence: String
    let exampleTranslation: String

    var id: String { tagalog }

    enum CodingKeys: String, CodingKey {
        case tagalog, english, pronunciation
        case exampleSentence = "example_sentence"
        case exampleTranslation = "example_translation"
    }
}

struct Sentence: Codable, Identifiable {
    let tagalog: String
    let english: String
    let breakdown: String

    var id: String { tagalog }
}

struct QuizQuestion: Codable, Identifiable {
    let type: QuestionType
    let question: String
    let options: [String]?
    let correctIndex: Int?
    let answer: String?
    let acceptAlso: [String]?
    let hint: String?
    let explanation: String?

    var id: String { question }

    enum CodingKeys: String, CodingKey {
        case type, question, options, answer, hint, explanation
        case correctIndex = "correct_index"
        case acceptAlso = "accept_also"
    }
}

enum QuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case fillInBlank = "fill_in_blank"
    case translate
    case rootPattern = "root_pattern"
}
