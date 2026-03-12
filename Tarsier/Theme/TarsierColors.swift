import SwiftUI

enum TarsierColors {
    // MARK: - Brand Primary
    /// Primary — buttons, progress bars, active states. Passes WCAG contrast on white text.
    static let functionalPurple = Color(hex: "#5B48E0")
    /// Light/background purple. Icon bg, accents, light fills, marketing.
    static let brandPurple = Color(hex: "#5B48E0")
    /// Selected-state surface — card fills, chip fills when selected.
    static let primaryLight = Color(hex: "#EEE9FF")

    // MARK: - Accent Colours
    /// Rewards, streaks, XP, celebration.
    static let gold = Color(hex: "#F5A100")
    /// Corrections, streak freeze warnings, heart loss.
    static let alertRed = Color(hex: "#FF4B4B")
    /// Correct answer feedback.
    static let correctGreen = Color(hex: "#58CC02")

    // MARK: - Neutrals
    /// Mascot body, dark text, near-black.
    static let tarsierDark = Color(hex: "#1A1A2E")
    /// Surface — card backgrounds, input fields.
    static let cream = Color(hex: "#F8F8FC")
    /// Screen background — pure white.
    static let warmWhite = Color.white

    // MARK: - Text
    /// Main body text.
    static let textPrimary = Color(hex: "#1A1A2E")
    /// Secondary labels, hints.
    static let textSecondary = Color(hex: "#6B7280")
    /// Text on functionalPurple backgrounds.
    static let textOnPurple = Color.white

    // MARK: - Functional
    /// Heart icon colour.
    static let heartRed = Color(hex: "#FF4B4B")
    /// Default border for cards and inputs.
    static let cardBorder = Color(hex: "#E5E7EB")
}
