import SwiftUI

enum TarsierColors {
    // MARK: - Brand Purples (two-shade system)
    /// Light/background purple. Icon bg, accents, light fills, marketing.
    static let brandPurple = Color(hex: "#8778C3")
    /// Buttons, nav bars, progress bars. Passes WCAG contrast on white text.
    static let functionalPurple = Color(hex: "#6B5B9A")

    // MARK: - Accent Colours
    /// Rewards, streaks, XP, celebration, tarsier eyes.
    static let gold = Color(hex: "#FCD116")
    /// Corrections, streak freeze warnings, heart loss.
    static let alertRed = Color(hex: "#CE1126")
    /// Correct answer feedback.
    static let correctGreen = Color(hex: "#2ECC71")

    // MARK: - Warm Neutrals
    /// Mascot body, dark text, near-black.
    static let tarsierDark = Color(hex: "#302B27")
    /// Card backgrounds, soft canvas.
    static let cream = Color(hex: "#FFF5E6")
    /// Screen background (NOT pure white).
    static let warmWhite = Color(hex: "#FAFAF7")

    // MARK: - Text
    /// Main body text — near-black, not pure black.
    static let textPrimary = Color(hex: "#1A1A1A")
    /// Secondary labels, hints.
    static let textSecondary = Color(hex: "#6B6B6B")
    /// Text on functionalPurple backgrounds.
    static let textOnPurple = Color.white

    // MARK: - Functional
    /// Heart icon colour.
    static let heartRed = Color(hex: "#E74C3C")
    /// Subtle warm border for cards.
    static let cardBorder = Color(hex: "#E8E4DF")
}
