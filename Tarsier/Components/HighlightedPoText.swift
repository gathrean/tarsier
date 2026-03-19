import SwiftUI

/// Renders text with standalone "po" words highlighted in bold purple (inline, no chip).
/// Also supports *italic* markdown for Tagalog words in English text.
struct HighlightedPoText: View {
    let text: String
    let font: Font
    let baseColor: Color

    var body: some View {
        buildAttributedText()
    }

    @ViewBuilder
    private func buildAttributedText() -> some View {
        // Parse markdown italics (*word*) and highlight "po"
        let segments = parseSegments(text)

        // Use Text concatenation for inline styling
        segments.reduce(Text("")) { result, segment in
            switch segment {
            case .plain(let str):
                return result + Text(str).font(font).foregroundColor(baseColor)
            case .po(let str):
                return result + Text(str).font(font).bold().foregroundColor(TarsierColors.functionalPurple)
            case .italic(let str):
                return result + Text(str).font(font).italic().foregroundColor(baseColor)
            }
        }
    }

    private enum TextSegment {
        case plain(String)
        case po(String)
        case italic(String)
    }

    private func parseSegments(_ input: String) -> [TextSegment] {
        var segments: [TextSegment] = []
        var remaining = input[input.startIndex...]

        while !remaining.isEmpty {
            // Look for *italic* markers
            if let starIndex = remaining.firstIndex(of: "*") {
                // Add everything before the star as plain/po text
                let before = remaining[remaining.startIndex..<starIndex]
                if !before.isEmpty {
                    segments.append(contentsOf: parsePoInPlainText(String(before)))
                }

                // Find closing star
                let afterStar = remaining[remaining.index(after: starIndex)...]
                if let closingStar = afterStar.firstIndex(of: "*") {
                    let italicContent = String(afterStar[afterStar.startIndex..<closingStar])
                    segments.append(.italic(italicContent))
                    remaining = remaining[remaining.index(after: closingStar)...]
                } else {
                    // No closing star — treat the * as literal text
                    segments.append(contentsOf: parsePoInPlainText(String(remaining)))
                    remaining = remaining[remaining.endIndex...]
                }
            } else {
                segments.append(contentsOf: parsePoInPlainText(String(remaining)))
                remaining = remaining[remaining.endIndex...]
            }
        }

        return segments
    }

    /// Split plain text into po vs non-po segments (word-level).
    private func parsePoInPlainText(_ text: String) -> [TextSegment] {
        // Use regex to find standalone "po" words (possibly with trailing punctuation)
        var segments: [TextSegment] = []
        let pattern = #"(?<!\w)[Pp]o(?=[.,!?;:…\s]|$)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [.plain(text)]
        }

        let nsText = text as NSString
        var lastEnd = 0

        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
        for match in matches {
            let matchRange = match.range
            if matchRange.location > lastEnd {
                segments.append(.plain(nsText.substring(with: NSRange(location: lastEnd, length: matchRange.location - lastEnd))))
            }
            segments.append(.po(nsText.substring(with: matchRange)))
            lastEnd = matchRange.location + matchRange.length
        }

        if lastEnd < nsText.length {
            segments.append(.plain(nsText.substring(from: lastEnd)))
        }

        return segments
    }
}
