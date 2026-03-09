import Foundation

enum TarsierSpacing {
    /// Horizontal padding on all screens
    static let screenPadding: CGFloat = 20
    /// Internal card padding
    static let cardPadding: CGFloat = 16
    /// Rounded cards — NOT 8 or 10, use 16 for warmth
    static let cardCornerRadius: CGFloat = 16
    /// Slightly smaller than cards
    static let buttonCornerRadius: CGFloat = 14
    /// Between list items
    static let itemSpacing: CGFloat = 12
    /// Between sections
    static let sectionSpacing: CGFloat = 24
}
