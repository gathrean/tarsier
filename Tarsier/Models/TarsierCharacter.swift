import SwiftUI

enum TarsierCharacter: String, Codable, CaseIterable {
    case bunso, lola, lolo, ate, kuya
    case nanay, tatay, tita, tito
    case pare, mare, jowa

    var displayName: String {
        switch self {
        case .bunso: "Bunso"
        case .lola: "Lola"
        case .lolo: "Lolo"
        case .ate: "Ate"
        case .kuya: "Kuya"
        case .nanay: "Nanay"
        case .tatay: "Tatay"
        case .tita: "Tita"
        case .tito: "Tito"
        case .pare: "Pare"
        case .mare: "Mare"
        case .jowa: "Jowa"
        }
    }

    var meaning: String {
        switch self {
        case .bunso: "youngest child"
        case .lola: "grandmother"
        case .lolo: "grandfather"
        case .ate: "older sister"
        case .kuya: "older brother"
        case .nanay: "mother"
        case .tatay: "father"
        case .tita: "aunt"
        case .tito: "uncle"
        case .pare: "bro / male friend"
        case .mare: "sis / female friend"
        case .jowa: "boyfriend / girlfriend"
        }
    }

    var emoji: String {
        switch self {
        case .bunso: "🐵"
        case .lola: "👵"
        case .lolo: "👴"
        case .ate: "👩"
        case .kuya: "👦"
        case .nanay: "🤱"
        case .tatay: "👨"
        case .tita: "💁‍♀️"
        case .tito: "🧔"
        case .pare: "🤙"
        case .mare: "💅"
        case .jowa: "😏"
        }
    }

    /// Returns the Image asset name if it exists, nil otherwise.
    /// Falls back to emoji rendering when nil.
    var imageName: String? {
        let name = "character_\(self.rawValue)"
        return UIImage(named: name) != nil ? name : nil
    }

    /// Chapter where this character is first introduced.
    var introductionChapter: Int {
        switch self {
        case .bunso: 0  // onboarding
        case .lola, .lolo, .ate, .kuya: 1
        case .nanay, .tatay: 2
        case .tita, .tito: 3
        case .pare, .mare: 4
        case .jowa: 6
        }
    }
}
