import SwiftUI

/// Legacy bridge — maps old TarsierTheme references to the new
/// TarsierColors / TarsierFonts system. Existing views continue to compile
/// while we migrate them to use TarsierColors / TarsierFonts directly.
enum TarsierTheme {
    // MARK: - Color Aliases (old → new)
    static let blue = TarsierColors.functionalPurple
    static let yellow = TarsierColors.gold
    static let red = TarsierColors.alertRed
    static let brown = TarsierColors.tarsierDark
    static let cream = TarsierColors.cream

    // MARK: - Typography Aliases (old → new)
    static let largeTitle = TarsierFonts.title(34)
    static let title = TarsierFonts.title()
    static let title2 = TarsierFonts.heading(22)
    static let title3 = TarsierFonts.heading()
    static let headline = TarsierFonts.button()
    static let body = TarsierFonts.body()
    static let callout = TarsierFonts.body(15)
    static let subheadline = TarsierFonts.body(15)
    static let footnote = TarsierFonts.caption(14)
    static let caption = TarsierFonts.caption()
}
