import Foundation
import SwiftData

@Model
final class WordBankEntry {
    var id: UUID
    var word: String
    var root: String
    var meaning: String
    var affix: String?
    var lessonId: Int
    var chapterId: String
    var pronunciationGuide: String?
    var exampleSentence: String?
    var exampleTranslation: String?
    var taglishVariant: String?
    var timesCorrect: Int
    var timesWrong: Int
    var lastPracticed: Date?

    init(
        word: String,
        root: String,
        meaning: String,
        affix: String? = nil,
        lessonId: Int,
        chapterId: String,
        pronunciationGuide: String? = nil,
        exampleSentence: String? = nil,
        exampleTranslation: String? = nil,
        taglishVariant: String? = nil,
        timesCorrect: Int = 0,
        timesWrong: Int = 0
    ) {
        self.id = UUID()
        self.word = word
        self.root = root
        self.meaning = meaning
        self.affix = affix
        self.lessonId = lessonId
        self.chapterId = chapterId
        self.pronunciationGuide = pronunciationGuide
        self.exampleSentence = exampleSentence
        self.exampleTranslation = exampleTranslation
        self.taglishVariant = taglishVariant
        self.timesCorrect = timesCorrect
        self.timesWrong = timesWrong
        self.lastPracticed = nil
    }
}
