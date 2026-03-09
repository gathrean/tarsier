import SwiftUI

enum TarsierFonts {
    /// Screen titles — 28pt bold rounded
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// Section headers — 20pt semibold rounded
    static func heading(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    /// Body text — 16pt regular rounded
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    /// Tagalog words displayed prominently — 24pt bold rounded
    static func tagalogWord(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// Small labels, hints, captions — 13pt medium rounded
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    /// Button text — 17pt semibold rounded
    static func button(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}
